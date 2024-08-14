import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sellers_app/global/global_instance.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStore;
import 'package:sellers_app/global/global_var.dart';
import 'package:sellers_app/view/authScreens/auth_screen.dart';
import 'package:sellers_app/view/authScreens/userhome.dart';
import 'package:sellers_app/view/mainScreens/adminhome2.dart';
import 'package:sellers_app/view/mainScreens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class AuthViewModel {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> _pickImage() async {
    return await _picker.pickImage(source: ImageSource.gallery);
  }

  validateSignUpForm(
      XFile imageXFile,
      String password,
      String confirmPassword,
      String name,
      String email,
      String phone,
      String locationAddress,
      BuildContext context,
      {XFile? adminImageXFile}) async {
    if (imageXFile == null) {
      _showImagePickerDialog(context);
      return;
    } else {
      if (password == confirmPassword) {
        if (_isValidEmail(email, context) &&
            _isValidPhoneNumber(phone, context) &&
            name.isNotEmpty &&
            password.isNotEmpty &&
            confirmPassword.isNotEmpty &&
            locationAddress.isNotEmpty) {
          User? currentFirebaseUser =
              await createUserInFirebaseAuth(email, password, context);
          commonViewModel.ShowSnackBar("Registering credentials...", context);
          String downloadUrl = await uploadImageToStorage(imageXFile);

          String? adminDownloadUrl;
          if (adminImageXFile != null) {
            adminDownloadUrl = await uploadImageToStorage(adminImageXFile);
          }

          await saveUserDataToFireStore(
              currentFirebaseUser!,
              downloadUrl,
              name,
              email,
              password,
              locationAddress,
              phone,
              confirmPassword,
              adminDownloadUrl);

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (c) => HomeScreen2()));
        } else {
          commonViewModel.ShowSnackBar(
              "Please fill all fields correctly", context);
          return;
        }
      } else {
        commonViewModel.ShowSnackBar("Passwords don't match", context);
        return;
      }
    }
  }

  bool _isValidEmail(String email, BuildContext context) {
    // Custom email validation for allowed domains
    if (email.isEmpty) {
      commonViewModel.ShowSnackBar("Email is required", context);
      return false;
    } else if (!email.trim().endsWith('@gmail.com') &&
        !email.trim().endsWith('@sves.org.in')) {
      commonViewModel.ShowSnackBar(
          "Only @gmail.com and @sves.org.in domains are allowed", context);
      return false;
    }
    return true;
  }

  bool _isValidPhoneNumber(String phone, BuildContext context) {
    // Custom phone number validation
    if (phone.isEmpty) {
      commonViewModel.ShowSnackBar("Phone number is required", context);
      return false;
    } else if (phone.length != 10 ||
        !phone.trim().startsWith(RegExp(r'[0-9]'))) {
      commonViewModel.ShowSnackBar(
          "Phone number must be 10 digits and numeric", context);
      return false;
    }
    return true;
  }

  void _showImagePickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select an image'),
          content: const Text('Please select an image to continue.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  createUserInFirebaseAuth(
      String email, String password, BuildContext context) async {
    User? currentFirebaseUser;
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((valueAuth) {
      currentFirebaseUser = valueAuth.user;
    }).catchError((errorMsg) {
      commonViewModel.ShowSnackBar(errorMsg.toString(), context);
    });
    if (currentFirebaseUser == null) {
      FirebaseAuth.instance.signOut();
      return;
    }
    return currentFirebaseUser;
  }

  uploadImageToStorage(XFile? imageXFile) async {
    String downloadUrl = "";
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    fStore.Reference storageRef = fStore.FirebaseStorage.instance
        .ref()
        .child("sellerImages")
        .child(fileName);
    fStore.UploadTask uploadTask = storageRef.putFile(File(imageXFile!.path));
    fStore.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
    await taskSnapshot.ref.getDownloadURL().then((urlImage) {
      downloadUrl = urlImage;
    });
    return downloadUrl;
  }

  saveUserDataToFireStore(
      currentFirebaseUser,
      downloadUrl,
      name,
      email,
      password,
      locationAddress,
      phone,
      confirmpassword,
      String? adminImageUrl) async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    FirebaseFirestore.instance
        .collection("sellers")
        .doc(currentFirebaseUser.uid)
        .set({
      "uid": currentFirebaseUser.uid,
      "email": email,
      "name": name,
      "image": downloadUrl,
      "phone": phone,
      "password": password,
      "confirm": confirmpassword,
      "address": locationAddress,
      "status": "approved",
      "earnings": 0.0,
      "latitude": position!.latitude,
      "longitude": position!.longitude,
      "fcmToken": fcmToken,
      "adminImage": adminImageUrl,
    });

    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!.setString("uid", currentFirebaseUser.uid);
    await sharedPreferences!.setString("email", email);
    await sharedPreferences!.setString("name", name);
    await sharedPreferences!.setString("password", password);
    await sharedPreferences!.setString("confirm", confirmpassword);
    await sharedPreferences!.setString("imageUrl", downloadUrl);
  }

  validateSignInForm(
      String email, String password, BuildContext context) async {
    // if (email == 'admin' && password == 'password') {
    //   XFile? adminImageXFile = await _pickImage();
    //   if (adminImageXFile != null) {
    //     String adminImageUrl = await uploadImageToStorage(adminImageXFile);
    //     await saveAdminImage(adminImageUrl, context);
    //   }

    //   var a;
    //   sharedPreferences = await SharedPreferences.getInstance();
    //   a = await sharedPreferences!.setBool("isAdminLoggedIn", true);
    //   print(a);
    //   Navigator.pushReplacement(
    //       context, MaterialPageRoute(builder: (c) => const HomeScreen1()));
    // }
    if (email.isNotEmpty && password.isNotEmpty) {
      commonViewModel.ShowSnackBar("Checking credentials...", context);
      User? currentFirebaseUser = await loginUser(email, password, context);
      await readDataFromFirestoreAndSetDataLocally(
          currentFirebaseUser, context);

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (c) => HomeScreen2()));
    } else {
      commonViewModel.ShowSnackBar("Password or email is incorrect", context);
      throw Exception("Password or email is incorrect");
    }
  }

  Future<void> saveAdminImage(
      String adminImageUrl, BuildContext context) async {
    await FirebaseFirestore.instance
        .collection("admin")
        .doc("adminProfile")
        .set({
      "image": adminImageUrl,
    });

    await sharedPreferences!.setString("adminImageUrl", adminImageUrl);
  }

  Future<User?> loginUser(
      String email, String password, BuildContext context) async {
    User? currentFirebaseUser;
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      currentFirebaseUser = userCredential.user;
      if (currentFirebaseUser == null) {
        // Handle null user case if necessary
        throw FirebaseAuthException(
            code: "user-not-found", message: "User not found");
      } else {
        // Successfully logged in
        await readDataFromFirestoreAndSetDataLocally(
            currentFirebaseUser, context);
        if (email == 'jayashankar1407@gmail.com' &&
            password == 'jayashankar@12') {
          XFile? adminImageXFile = await _pickImage();
          if (adminImageXFile != null) {
            String adminImageUrl = await uploadImageToStorage(adminImageXFile);
            await saveAdminImage(adminImageUrl, context);
          }
          var a;
          sharedPreferences = await SharedPreferences.getInstance();
          a = await sharedPreferences!.setBool("isAdminLoggedIn", true);
          print(a);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (c) => HomeScreen1()));
        } else {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (c) => HomeScreen2()));
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw FirebaseAuthException(
            code: e.code, message: "Password or email is incorrect");
      } else {
        throw FirebaseAuthException(
            code: "unknown-error", message: "Password or email is incorrect.");
      }
    } catch (e) {
      throw Exception("Login failed. Please try again later.");
    }
    return currentFirebaseUser;
  }

  readDataFromFirestoreAndSetDataLocally(
      currentFirebaseUser, BuildContext context) async {
    await FirebaseFirestore.instance
        .collection("sellers")
        .doc(currentFirebaseUser.uid)
        .get()
        .then((dataSnapshot) async {
      if (dataSnapshot.exists) {
        if (dataSnapshot.data()!["status"] == "approved") {
          String? fcmToken = await FirebaseMessaging.instance.getToken();

          await FirebaseFirestore.instance
              .collection("sellers")
              .doc(currentFirebaseUser.uid)
              .update({"fcmToken": fcmToken});

          await sharedPreferences!.setString("uid", currentFirebaseUser.uid);
          await sharedPreferences!
              .setString("email", dataSnapshot.data()!["email"]);
          await sharedPreferences!
              .setString("name", dataSnapshot.data()!["name"]);
          await sharedPreferences!
              .setString("imageUrl", dataSnapshot.data()!["image"]);
        } else {
          commonViewModel.ShowSnackBar(
              "You do not have access to this account.", context);
          FirebaseAuth.instance.signOut();
          throw Exception("You do not have access to this account.");
        }
      } else {
        commonViewModel.ShowSnackBar(
            "This account details do not exist.", context);
        FirebaseAuth.instance.signOut();
        throw Exception("This account details do not exist.");
      }
    });
  }

  Future<void> signOut(BuildContext context) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (c) => const AuthScreen()));
  }

  void showSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
