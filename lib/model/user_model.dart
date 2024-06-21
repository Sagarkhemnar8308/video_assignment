import 'package:video_app/model/video_model.dart';

class UserModel {
  String id;
  String imageUrl;
  String name;
  String username;
  List<Video> videos;

  UserModel({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.username,
    required this.videos,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      imageUrl: map['imageUrl'] ?? '',
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      videos: List<Video>.from(
        (map['videos'] ?? []).map((videoMap) => Video.fromMap(videoMap)),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'name': name,
      'username': username,
      'videos': videos.map((video) => video.toMap()).toList(),
    };
  }
}