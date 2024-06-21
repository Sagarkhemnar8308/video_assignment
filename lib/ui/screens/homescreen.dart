import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pod_player/pod_player.dart';
import 'package:video_app/services/firebase_services.dart';
import 'package:video_app/ui/auth/signup.dart';
import 'package:video_app/ui/screens/commentscreen.dart';
import 'package:video_app/ui/screens/uploadvideo.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PodPlayerController controller;

  // String videolink = '';
  // int currentPlayingIndex = 0;

  User? user = FirebaseAuth.instance.currentUser;
  double? latitude;
  double? longitude;
  final auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  getvideoFile(ImageSource sourceimg, double lat, double long,
      String profileUrl, String username) async {
    final videofile = await ImagePicker().pickVideo(source: sourceimg);

    if (videofile != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UploadVideo(
              profileurl: profileUrl,
              username: username,
              latitude: lat,
              longitude: long,
              videoFile: File(videofile.path),
              videoPath: videofile.path,
            ),
          ));
    }
  }

  Future<Position> _getcurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error(
        "Location Services are disabled",
      );
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error(
          "Location Services are disabled",
        );
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        "Location Permission are permanetly denied , we cannot request ",
      );
    }
    return await Geolocator.getCurrentPosition();
  }

  _liveLocation() {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((event) {
      latitude = event.latitude;
      longitude = event.longitude;
    });
  }

  @override
  void initState() {
    _getcurrentLocation().then((value) => {
          latitude = value.latitude,
          longitude = value.longitude,
        });
    super.initState();
  }

  // void initializeController() {
  //   PlayVideoFrom videoSource;
  //   videoSource = PlayVideoFrom.network(
  //     videolink,
  //     videoPlayerOptions: VideoPlayerOptions(),
  //   );
  //   controller = PodPlayerController(playVideoFrom: videoSource)..initialise();
  // }

  void _handleLike(String docId) async {
    await DataBaseServices().updateVideoLikesDislikes(
        docId, DataBaseServices().auth.currentUser?.uid ?? "", true);
  }

  void _handleDislike(String docId) async {
    await DataBaseServices().updateVideoLikesDislikes(
        docId, DataBaseServices().auth.currentUser?.uid ?? "", false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 15, 14, 51),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot?>(
            stream: FirebaseFirestore.instance.collection('Users').snapshots(),
            builder: (context, snapshot) {
              final currentUserData = snapshot.data?.docs.firstWhere(
                (doc) => doc.id == user?.uid,
              );
              return FloatingActionButton(
                onPressed: () {
                  _liveLocation();
                  getvideoFile(
                    ImageSource.camera,
                    latitude!,
                    longitude!,
                    currentUserData?['imageUrl'],
                    currentUserData?['username'],
                  );
                },
                child: const Icon(
                  Icons.add,
                  size: 20,
                  color: Colors.black,
                ),
              );
            }),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Video App',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(
          255,
          15,
          14,
          51,
        ),
        actions: [
          IconButton(
            onPressed: () {
              auth.signOut().then((value) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignUpScreen(),
                  ),
                  (route) => false,
                );
                Fluttertoast.showToast(msg: 'Sign out SuccessFully');
              }).onError((error, stackTrace) {
                Fluttertoast.showToast(msg: 'Error to logout');
              });
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextFormField(
              style: const TextStyle(
                color: Colors.white,
              ),
              cursorColor: Colors.white,
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search new Videos...........",
                hintStyle: const TextStyle(
                  color: Colors.white,
                ),
                suffixIcon: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                ),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Videos')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Error to get data',
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No videos found',
                        ),
                      );
                    }
                    var videos = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: videos.length,
                      itemBuilder: (context, index) {
                        var video =
                            videos[index].data() as Map<String, dynamic>;
                        var videoUrl = video['videoUrl'];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                color: Colors.white,
                              )),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundImage:
                                            NetworkImage(video['profileurl']),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            video['username'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            "${video['location']}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  PodVideoPlayer(
                                    podPlayerLabels: const PodPlayerLabels(
                                      error: "",
                                      fullscreen: "Full screen",
                                    ),
                                    videoAspectRatio: 16 / 9,
                                    videoTitle: Text(
                                      video['title'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    controller: PodPlayerController(
                                      podPlayerConfig: const PodPlayerConfig(
                                        autoPlay: false,
                                        forcedVideoFocus: true,
                                      ),
                                      playVideoFrom: PlayVideoFrom.network(
                                        videoUrl,
                                      ),
                                    )..initialise(),
                                    frameAspectRatio: 16 / 9,
                                    // videoThumbnail: const DecorationImage(
                                    //   image: AssetImage(
                                    //     "asset/images/app-logo.png",
                                    //   ),
                                    // ),
                                  ),
                                  // Column(
                                  //   crossAxisAlignment:
                                  //       CrossAxisAlignment.start,
                                  //   children: [
                                  //     Text(
                                  //       video['title'],
                                  //       style: const TextStyle(
                                  //         color: Colors.white,
                                  //       ),
                                  //     ),
                                  //     Text(
                                  //       video['description'],
                                  //       style: const TextStyle(
                                  //         color: Colors.white,
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              _handleLike(videos[index].id);
                                            },
                                            icon: const Icon(
                                              Icons.thumb_up_alt_outlined,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            "${video['likes']} Likes",
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Column(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              _handleDislike(videos[index].id);
                                            },
                                            icon: const Icon(
                                              Icons.thumb_down_alt_outlined,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            "${video['disLikes']} Dislikes",
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Column(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      CommentScreen(
                                                    documentId:
                                                        videos[index].id,
                                                    userid:
                                                        auth.currentUser?.uid ??
                                                            '',
                                                  ),
                                                ),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.comment,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const Text(
                                            "Comments",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Column(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              Share.share(
                                                "Not uploaded on Play Store ",
                                                subject:
                                                    'Check out this amazing video application!',
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.share,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const Text(
                                            "Share",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

// ListTile(
//                           title: Text(
//                             video['title'] ?? 'No Title',
//                             style: TextStyle(
//                               color: Colors.white,
//                             ),
//                           ),
//                           subtitle: Text(
//                             video['description'] ?? 'No Description',
//                             style: TextStyle(
//                               color: Colors.white,
//                             ),
//                           ),
//                         );
