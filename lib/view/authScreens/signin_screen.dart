import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:sellers_app/global/global_instance.dart';
import 'package:sellers_app/viewmodel/auth_view.dart';
import '../../view/widgets/custom_text_field.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  bool isLoading = false;

  void _toggleLoading([bool? value]) {
    setState(() {
      isLoading = value ?? !isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "images/b.jpg"), // Replace with your background image asset
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Transparent overlay
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          // Center content with flip card
          Center(
            child: FlipCard(
              key: cardKey,
              flipOnTouch: true,
              front: _buildFrontCard(),
              back: _buildBackCard(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrontCard() {
    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        image: DecorationImage(
          image:
              AssetImage("images/welcome.png"), // Replace with your image asset
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBackCard(BuildContext context) {
    return Container(
      width: 300,
      height: 400,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.43), // Transparent white box
        borderRadius: BorderRadius.circular(15),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "images/logo.png", // Replace with your logo asset
              height: 120,
            ),
            const SizedBox(height: 5),
            Form(
              key: formKey,
              child: Column(
                children: [
                  CustomTextField(
                    textEditingController: emailTextEditingController,
                    iconData: Icons.email,
                    hintString: "Email",
                    isObscure: false,
                    enabled: true,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    textEditingController: passwordTextEditingController,
                    iconData: Icons.lock,
                    hintString: "Password",
                    isObscure: true,
                    enabled: true,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  const SizedBox(height: 20),
                  isLoading
                      ? CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : ElevatedButton(
                          onPressed: () async {
                            _toggleLoading(true);
                            try {
                              await authViewModel.validateSignInForm(
                                emailTextEditingController.text.trim(),
                                passwordTextEditingController.text.trim(),
                                context,
                              );
                            } catch (e) {
                              // Handle errors here, e.g., show a snackbar
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Login failed"),
                                ),
                              );
                            } finally {
                              _toggleLoading(false);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final TextEditingController? textEditingController;
  final IconData? iconData;
  final String? hintString;
  final bool isObscure;
  final bool enabled;
  final BorderRadius? borderRadius;

  const CustomTextField({
    Key? key,
    this.textEditingController,
    this.iconData,
    this.hintString,
    this.isObscure = false,
    this.enabled = true,
    this.borderRadius,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
      ),
      child: TextField(
        controller: widget.textEditingController,
        obscureText: widget.isObscure && !_isPasswordVisible,
        enabled: widget.enabled,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: widget.hintString,
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: widget.iconData != null
              ? Icon(widget.iconData, color: Colors.black)
              : null,
          suffixIcon: widget.isObscure
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.black,
                    size: 23, 
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}
