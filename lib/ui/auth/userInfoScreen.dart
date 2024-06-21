import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_app/services/firebase_services.dart';
import 'package:video_app/ui/screens/homescreen.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

final firestore = FirebaseFirestore.instance.collection('Users');

class _UserInfoScreenState extends State<UserInfoScreen> {
  
  Uint8List? _image;
  File? selectedIamge;
  final nameController = TextEditingController();
  final usernameController = TextEditingController();

  Future pickImageFromGallery() async {
    final returnimage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnimage == null) return;
    setState(() {
      selectedIamge = File(returnimage.path);
      print("is a n a select image $selectedIamge");
      _image = File(returnimage.path).readAsBytesSync();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color.fromARGB(255, 15, 14, 51),
        body: Padding(
          padding: const EdgeInsets.all(
            10.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 100,
                ),
                _image != null
                    ? InkWell(
                        onTap: () {
                          pickImageFromGallery();
                        },
                      child: CircleAvatar(
                          radius: 60,
                          backgroundImage: MemoryImage(_image!),
                        ),
                    )
                    : InkWell(
                        onTap: () {
                          pickImageFromGallery();
                        },
                        child: Stack(
                          children: [
                            const CircleAvatar(
                              radius: 60,
                              backgroundImage: NetworkImage(
                                  "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Default_pfp.svg/510px-Default_pfp.svg.png"),
                            ),
                            Positioned(
                              top: 50,
                              left: 45,
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                  Radius.circular(
                                    20,
                                  ),
                                )),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  cursorColor: Colors.white,
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: "Enter Your Name",
                    hintStyle: TextStyle(
                      color: Colors.white,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  cursorColor: Colors.white,
                  controller: usernameController,
                  decoration: const InputDecoration(
                    hintText: "Enter Your username",
                    hintStyle: TextStyle(
                      color: Colors.white,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      String imgurl =
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Default_pfp.svg/510px-Default_pfp.svg.png';

                      if (_image != null) {
                        try {
                          imgurl = await DataBaseServices()
                              .uploadImageToFirebaseStorageProfile(
                                  selectedIamge!);
                        } catch (e) {
                          print("Failed to upload image: $e");
                        }
                      }
                      String userId =
                          FirebaseAuth.instance.currentUser?.uid ?? "0";
                      await firestore.doc(userId).set({
                        "id": userId,
                        "videos": [

                        ],
                        "name": nameController.text,
                        "username": usernameController.text,
                        "imageUrl": imgurl,
                      }).then((value) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Get Started ',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
