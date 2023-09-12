import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ifood/widgets/error_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;

import '../widgets/custom_text_field.dart';
import '../widgets/loading_dialog.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController? nameController = TextEditingController();
  TextEditingController? emailController = TextEditingController();
  TextEditingController? passwordController = TextEditingController();
  TextEditingController? confirmPasswordController = TextEditingController();
  TextEditingController? phoneController = TextEditingController();
  TextEditingController? locationController = TextEditingController();

  File? imageFile;
  final ImagePicker _picker = ImagePicker();
  String? sellerImageUrl;

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
    setState(() {
      isLoading = true;
    });
    // Check if the app has permission to access location
    LocationPermission permission;
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (kDebugMode) {
        print('Location permission denied by user');
      }
    } else if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      if (kDebugMode) {
        print(
            "the app has been granted permission to access the device's location at any time.");
      }
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
      if (kDebugMode) {
        print('Error getting current location: $e');
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (imageFile == null) {
      return showDialog(
        context: context,
        builder: (_) => const ErrorDialog(
          message: 'Please select an image.',
        ),
      );
    }

    _formKey.currentState!.save();
    try {
      showDialog(
        context: context,
        builder: (_) => const LoadingDialog(
          message: 'Registering Account',
        ),
      );

      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      final fStorage.Reference reference = fStorage.FirebaseStorage.instance
          .ref()
          .child('sellers')
          .child(fileName);
      final fStorage.UploadTask uploadTask = reference.putFile(imageFile!);
      final fStorage.TaskSnapshot storageTaskSnapshot =
          await uploadTask.whenComplete(() => null);
      final String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
      sellerImageUrl = downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
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
                      labelText: "Name",
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter your name";
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      controller: emailController,
                      icon: Icons.email,
                      labelText: "Email",
                      validator: (value) {
                        if (value!.isEmpty || !value.contains('@')) {
                          return 'Please enter a valid email address.';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      controller: passwordController,
                      icon: Icons.lock,
                      labelText: "Password",
                      isObscure: true,
                      validator: (value) {
                        if (value!.isEmpty || value.length < 6) {
                          return 'Password must be at least 6 characters long.';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      controller: confirmPasswordController,
                      icon: Icons.lock,
                      labelText: "Confirm Password",
                      isObscure: true,
                      validator: (value) {
                        if (value != passwordController!.text) {
                          return 'Passwords do not match!';
                        }
                        return null;
                      },
                    ),
                    CustomTextField(
                      controller: phoneController,
                      icon: Icons.phone,
                      labelText: "Phone",
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter your phone number.";
                        }
                        if (double.tryParse(value) == null ||
                            double.parse(value) <= 10) {
                          return "Please enter a valid phone number.";
                        }

                        return null;
                      },
                    ),
                    CustomTextField(
                      controller: locationController,
                      icon: Icons.location_on,
                      labelText: "Cafe/Restaurant Location",
                      enabled: false,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter your location.";
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      width: 250,
                      height: 40,
                      child: Stack(children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            _getCurrentLocation();
                          },
                          icon: const Icon(Icons.add_location),
                          label: const Text("Get My Current Location"),
                        ),
                        if (isLoading)
                          const Positioned.fill(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      ]),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submit,
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
