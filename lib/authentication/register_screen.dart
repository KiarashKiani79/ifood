import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController? nameController = TextEditingController();
  TextEditingController? emailController = TextEditingController();
  TextEditingController? passwordController = TextEditingController();
  TextEditingController? confirmPasswordController = TextEditingController();
  TextEditingController? phoneController = TextEditingController();
  TextEditingController? locationController = TextEditingController();

  File? imageFile;
  final ImagePicker _picker = ImagePicker();

  Position? _currentPosition;
  List<Placemark>? _placemarks;

  Future<void> _getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _getAddressFromLatLng() async {
    try {
      final placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude, _currentPosition!.longitude);
      setState(() {
        _placemarks = placemarks;
        locationController!.text =
            '${_placemarks![0].subThoroughfare} ${_placemarks![0].thoroughfare}, ${_placemarks![0].subLocality} ${_placemarks![0].locality}, ${_placemarks![0].subAdministrativeArea}, ${_placemarks![0].administrativeArea} ${_placemarks![0].postalCode}, ${_placemarks![0].country}';
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _getCurrentLocation() async {
    // Check if the app has permission to access location
    LocationPermission permission;
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      print('Location permission denied by user');
    } else if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      print('log');
    }

    try {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
      _getAddressFromLatLng();
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            InkWell(
              onTap: _getImage,
              child: CircleAvatar(
                radius: MediaQuery.of(context).size.width * 0.2,
                backgroundColor: Colors.white,
                backgroundImage:
                    imageFile == null ? null : FileImage(imageFile!),
                child: imageFile == null
                    ? Icon(
                        Icons.add_photo_alternate,
                        size: MediaQuery.of(context).size.width * 0.2,
                        color: Colors.grey,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Card(
                elevation: 20,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: nameController,
                      icon: Icons.person,
                      lableText: "Name",
                    ),
                    CustomTextField(
                      controller: emailController,
                      icon: Icons.email,
                      lableText: "Email",
                    ),
                    CustomTextField(
                      controller: passwordController,
                      icon: Icons.lock,
                      lableText: "Password",
                      isObscure: true,
                    ),
                    CustomTextField(
                      controller: confirmPasswordController,
                      icon: Icons.lock,
                      lableText: "Confirm Password",
                      isObscure: true,
                    ),
                    CustomTextField(
                      controller: phoneController,
                      icon: Icons.phone,
                      lableText: "Phone",
                      keyboardType: TextInputType.phone,
                    ),
                    CustomTextField(
                      controller: locationController,
                      icon: Icons.location_on,
                      lableText: "Cafe/Restaurant Location",
                      enabled: false,
                    ),
                    SizedBox(
                      width: 250,
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _getCurrentLocation();
                        },
                        icon: const Icon(Icons.add_location),
                        label: const Text("Get My Current Location"),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.purple),
              ),
              child: const Text(
                "Register",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
