import 'dart:io';

import 'package:chat_app/components/app_progress_indicator.dart';
import 'package:chat_app/components/circular_image.dart';
import 'package:chat_app/components/login_text_field.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/utils/image_utils.dart';
import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final AuthService _authService = AuthService();
  final ImageUtils _imageUtils = ImageUtils();
  String? _imagePath;
  bool loading = false;
  File? uploadedImage;

  Future<void> uploadProfilePhoto(BuildContext context) async {
    try {
      uploadedImage = await _imageUtils.getImage();
      if (uploadedImage != null) {
        if (context.mounted) {
          showAdaptiveDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog.adaptive(
                content: Column(children: [
                  AppProgressIndicator(),
                  Text("Uploading photo, please wait...")
                ]),
              );
            },
          );
        }
        _imagePath = await _imageUtils.uploadProfilePhoto(uploadedImage);
        //TODO Delete the previous image, if uploading a new one
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (context.mounted && uploadedImage != null) { // Don't pop if the user didn't selected image.
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppUser? user =
        ModalRoute.of(context)?.settings.arguments as AppUser?;

    final TextEditingController firstNameTextEditingController =
        TextEditingController.fromValue(
            TextEditingValue(text: user?.firstName ?? ""));

    final TextEditingController lastNameTextEditingController =
        TextEditingController.fromValue(
            TextEditingValue(text: user?.lastName ?? ""));

    final TextEditingController bioTextEditingController =
        TextEditingController.fromValue(
            TextEditingValue(text: user?.bio ?? ""));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit profile"),
        actions: [
          IconButton.filledTonal(
              onPressed: () {
                if (firstNameTextEditingController.text.isNotEmpty &&
                    lastNameTextEditingController.text.isNotEmpty) {
                  _authService.editUser(
                      firstNameTextEditingController.text,
                      lastNameTextEditingController.text,
                      bioTextEditingController.text,
                      _imagePath);
                  Navigator.pop(context);
                }
              },
              icon: Icon(Icons.check))
        ],
      ),
      body: user != null
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Stack(alignment: Alignment.bottomRight, children: [
                    CircularImage(
                      url: _imagePath ?? user.profilePhotoUrl,
                    ),
                    Positioned(
                        bottom: 0,
                        child: IconButton.filled(
                            onPressed: () {
                              uploadProfilePhoto(context);
                              _authService.editUser(
                                  firstNameTextEditingController.text,
                                  lastNameTextEditingController.text,
                                  bioTextEditingController.text,
                                  _imagePath);
                            },
                            icon: Icon(Icons.edit)))
                  ]),
                ),
                SizedBox(
                  height: 40,
                ),
                Row(
                  spacing: 20,
                  children: [
                    Expanded(
                      child: LoginTextField(
                          labelText: "First name",
                          obscureText: false,
                          controller: firstNameTextEditingController),
                    ),
                    Expanded(
                      child: LoginTextField(
                          labelText: "Last name",
                          obscureText: false,
                          controller: lastNameTextEditingController),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                LoginTextField(
                    labelText: "Bio",
                    obscureText: false,
                    isBio: true,
                    controller: bioTextEditingController),
              ],
            )
          : const Center(
              child: Text("Invalid User"),
            ),
    );
  }
}
