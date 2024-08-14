// ignore_for_file: non_constant_identifier_names, avoid_web_libraries_in_flutter, unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sellers_app/global/global_var.dart';

class CommonViewModel {
  getCurrentLocation() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    position = cPosition;

    placeMark =
        await placemarkFromCoordinates(cPosition.latitude, cPosition.longitude);

    Placemark placeMarkVar = placeMark![0];

    fullAddress =
        "${placeMarkVar.subThoroughfare} ${placeMarkVar.thoroughfare}, ${placeMarkVar.subLocality} ${placeMarkVar.locality}, ${placeMarkVar.subAdministrativeArea}, ${placeMarkVar.administrativeArea} ${placeMarkVar.postalCode}, ${placeMarkVar.country}";

    return fullAddress;
  }

  updateLocationInDatabase() async {
    String address = await getCurrentLocation();
    await FirebaseFirestore.instance
        .collection("sellers")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      "address": address,
      "latitude": position!.latitude,
      "longitude": position!.longitude,
    });
  }

  ShowSnackBar(String message, BuildContext context) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
