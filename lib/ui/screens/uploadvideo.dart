import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:pod_player/pod_player.dart';
import 'package:video_app/model/video_model.dart';
import 'package:video_app/services/firebase_services.dart';
import 'package:video_app/ui/screens/homescreen.dart';

class UploadVideo extends StatefulWidget {
  const UploadVideo({
    super.key,
    required this.videoFile,
    required this.videoPath,
    required this.latitude,
    required this.longitude,
    required this.profileurl,
    required this.username,
  });
  final File videoFile;
  final String videoPath;
  final double latitude;
  final double longitude;
  final String username;
  final String profileurl;
  @override
  State<UploadVideo> createState() => _UploadVideoState();
}

class _UploadVideoState extends State<UploadVideo> {
  bool isLoading = false;
  late final PodPlayerController _controller;
  final locationController = TextEditingController();
  final titleController = TextEditingController();
  final discController = TextEditingController();
  List<Placemark>? placemarks;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      placemarks = await placemarkFromCoordinates(
        widget.latitude,
        widget.longitude,
      );
      locationController.text =
          "${placemarks!.first.locality},${placemarks!.first.administrativeArea},${placemarks!.first.country}";
    });
    _controller = PodPlayerController(
      playVideoFrom: PlayVideoFrom.file(widget.videoFile),
      podPlayerConfig: const PodPlayerConfig(
        autoPlay: true,
      ),
    )..initialise();
  }

  @override
  Widget build(BuildContext context) {
    print(
        "object  me ${widget.videoFile} ${widget.videoPath}  ${widget.profileurl} ${widget.username} ");
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 15, 14, 51),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: const Color.fromARGB(255, 15, 14, 51),
        title: const Text(
          'Upload video',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              PodVideoPlayer(
                controller: _controller,
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                style: const TextStyle(
                  color: Colors.white,
                ),
                cursorColor: Colors.white,
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: "Title",
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
                controller: discController,
                decoration: const InputDecoration(
                  hintText: "description",
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
              IgnorePointer(
                child: TextFormField(
                  readOnly: true,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  cursorColor: Colors.white,
                  controller: locationController,
                  decoration: const InputDecoration(
                    hintText: "",
                    hintStyle: TextStyle(
                      color: Colors.white,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    suffixIcon: Icon(
                      Icons.location_on_outlined,
                      color: Colors.white,
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
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    Video videoData = Video(
                      title: titleController.text,
                      description: discController.text,
                      location: locationController.text,
                      videoUrl: '',
                      timestamp: DateTime.now(),
                      comments: [],
                      likes: 0,
                      profileurl: widget.profileurl,
                      username: widget.username,
                      disLikes: 0,
                    );

                    try {
                      await DataBaseServices()
                          .postVideo(
                        widget.videoFile,
                        videoData,
                      )
                          .then((value) {
                        setState(() {
                          isLoading = false;
                        });
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                          (route) => false,
                        );

                        Fluttertoast.showToast(
                            msg: 'Video posted successfully');
                      });
                      print("Video posted successfully");
                    } catch (e, stk) {
                      print("Error posting video: $e $stk");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          height: 50,
                          width: 50,
                          child: LottieBuilder.asset(
                            "asset/lottie/loader.json",
                          ),
                        )
                      : const Text(
                          'Post Video',
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
    );
  }
}
