import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sellers_app/global/global_instance.dart';
import 'package:sellers_app/viewmodel/auth_view.dart'; // Import your AuthViewModel here
import '../../view/widgets/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  XFile? imageFile;
  ImagePicker pickerImage = ImagePicker();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController confirmPasswordTextEditingController =
      TextEditingController();
  TextEditingController phonenumberTextEditingController = TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();
  AuthViewModel authViewModel = AuthViewModel();
  bool isLoading = false;

  void _toggleLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  pickImageFromGallery() async {
    imageFile = await pickerImage.pickImage(source: ImageSource.gallery);

    setState(() {
      imageFile;
    });
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    } else if (value != passwordTextEditingController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with two colors
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "images/b.jpg"), // Replace with your background image asset
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Transparent Box
          Center(
            child: Container(
              margin: EdgeInsets.all(24.0),
              padding: EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 11),
                    InkWell(
                      onTap: () {
                        pickImageFromGallery();
                      },
                      child: CircleAvatar(
                        radius: MediaQuery.of(context).size.width * 0.20,
                        backgroundColor: Colors.white,
                        backgroundImage: imageFile == null
                            ? null
                            : FileImage(File(imageFile!.path)),
                        child: imageFile == null
                            ? Icon(
                                Icons.add_photo_alternate,
                                size: MediaQuery.of(context).size.width * 0.20,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 11),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            textEditingController: nameTextEditingController,
                            iconData: Icons.person,
                            hintText: "Name",
                            isObscure: false,
                            enabled: true,
                          ),
                          CustomTextField(
                            textEditingController: emailTextEditingController,
                            iconData: Icons.email,
                            hintText: "Email",
                            isObscure: false,
                            enabled: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              } else if (!value.contains('@gmail.com')) {
                                return 'Email must end with @gmail.com';
                              }
                              return null;
                            },
                          ),
                          CustomTextField(
                            textEditingController: phonenumberTextEditingController,
                            iconData: Icons.phone,
                            hintText: "Phone Number",
                            isObscure: false,
                            enabled: true,
                            keyboardType: TextInputType.phone,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              } else if (value.length != 10) {
                                return 'Please enter a 10-digit phone number';
                              }
                              return null;
                            },
                          ),
                          CustomTextField(
                            textEditingController: passwordTextEditingController,
                            iconData: Icons.lock,
                            hintText: "Password",
                            isObscure: true,
                            enabled: true,
                            validator: validatePassword,
                          ),
                          CustomTextField(
                            textEditingController: confirmPasswordTextEditingController,
                            iconData: Icons.lock,
                            hintText: "Confirm Password",
                            isObscure: true,
                            enabled: true,
                            validator: validateConfirmPassword,
                          ),
                          CustomTextField(
                            textEditingController: locationTextEditingController,
                            iconData: Icons.my_location,
                            hintText: "Address",
                            isObscure: false,
                            enabled: true,
                          ),
                          Container(
                            width: 398,
                            height: 39,
                            alignment: Alignment.center,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                // Implement your location logic here
                                locationTextEditingController.text =
                                    await commonViewModel.getCurrentLocation();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                              ),
                              label: const Text(
                                "Get my Current Location",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              icon: const Icon(
                                Icons.location_on,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                if (imageFile == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Please select an image"),
                                    ),
                                  );
                                  return;
                                }

                                _toggleLoading();

                                await authViewModel.validateSignUpForm(
                                  imageFile!,
                                  passwordTextEditingController.text.trim(),
                                  confirmPasswordTextEditingController.text.trim(),
                                  nameTextEditingController.text.trim(),
                                  emailTextEditingController.text.trim(),
                                  phonenumberTextEditingController.text.trim(),
                                  locationTextEditingController.text.trim(),
                                  context,
                                );

                                _toggleLoading();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 10),
                            ),
                            child: isLoading
                                ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final TextEditingController? textEditingController;
  final IconData? iconData;
  final String? hintText;
  final bool? isObscure;
  final bool? enabled;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;

  const CustomTextField({
    Key? key,
    this.textEditingController,
    this.iconData,
    this.hintText,
    this.isObscure = false,
    this.enabled = true,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: widget.textEditingController,
        obscureText: widget.isObscure! && !_isPasswordVisible,
        enabled: widget.enabled!,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          prefixIcon: Icon(widget.iconData, color: Colors.black),
          hintText: widget.hintText,
          labelText: widget.hintText,
          labelStyle: TextStyle(color: Colors.black),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          suffixIcon: widget.isObscure!
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.black,
                    size: 20, // Smaller icon size
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
        ),
        validator: widget.validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter ${widget.hintText}';
              }
              return null;
            },
      ),
    );
  }
}
