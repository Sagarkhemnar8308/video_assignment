import 'package:cloud_firestore/cloud_firestore.dart';

class Video {
  String title;
  String description;
  String location;
  String videoUrl;
  int likes;
  int disLikes;
  DateTime timestamp;
  List<String> comments;
  String username;
  String profileurl;

  Video({
    required this.title,
    required this.description,
    required this.location,
    required this.videoUrl,
    this.likes = 0,
    required this.timestamp,
    this.comments = const [],
    required this.username,
    required this.profileurl,
    required this.disLikes,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'videoUrl': videoUrl,
      'likes': likes,
      'timestamp': timestamp,
      'comments': comments,
      'username':username,
      'profileurl':profileurl,
      "dislikes":disLikes,
    };
  }

  factory Video.fromMap(Map<String, dynamic> map) {
    return Video(
      title: map['title'],
      description: map['description'],
      location: map['location'],
      videoUrl: map['videoUrl'],
      likes: map['likes'] ?? 0,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      comments: List<String>.from(map['comments'] ?? []),
      username: map['username'],
      profileurl: map['profileurl'],
      disLikes: map['disLikes']
    );
  }
}
