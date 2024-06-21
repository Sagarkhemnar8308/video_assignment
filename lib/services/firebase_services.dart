import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_app/model/video_model.dart';

class DataBaseServices {
  final auth = FirebaseAuth.instance;

  Future<String> uploadImageToFirebaseStorageProfile(File imageFile) async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("profileimages/${DateTime.now().microsecondsSinceEpoch}");
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadURL = await taskSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadVideoToFirebase(File videoFile) async {
    String fileName =
        'videos/${DateTime.now().millisecondsSinceEpoch.toString()}.mp4';
    firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.ref().child(fileName);
    firebase_storage.UploadTask task = ref.putFile(videoFile);
    await task;
    String videoUrl = await ref.getDownloadURL();
    return videoUrl;
  }

  Future<void> postVideo(File videoFile, Video videoData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }
    final userId = user.uid;
    final videosCollection = FirebaseFirestore.instance.collection('Videos');
    final usersCollection = FirebaseFirestore.instance.collection('Users');

    try {
      String videoUrl = await uploadVideoToFirebase(videoFile);
      videoData.videoUrl = videoUrl;
      DocumentReference videoRef =
          await videosCollection.add(videoData.toMap());
      Map<String, dynamic> videoDataWithId = videoData.toMap();
      videoDataWithId['id'] = videoRef.id;
      await usersCollection
          .doc(userId)
          .collection('videos')
          .doc(videoRef.id)
          .set(videoData.toMap());

      print("Video posted successfully");
    } catch (e) {
      print("Error posting video: $e");
    }
  }

  Future<void> updateVideoLikesDislikes(
      String docId, String userId, bool like) async {
    final docRef = FirebaseFirestore.instance.collection('Videos').doc(docId);
    final likesRef = docRef.collection('Likes').doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(docRef);
      DocumentSnapshot likesSnapshot = await transaction.get(likesRef);

      if (!snapshot.exists) {
        throw Exception("Video does not exist!");
      }

      int newLikes = snapshot['likes'];
      int newDislikes = snapshot['disLikes'];

      if (likesSnapshot.exists) {
        bool userLike = likesSnapshot['like'];
        if (userLike == like) {
          return; // User has already liked/disliked
        }

        if (like) {
          newLikes += 1;
          newDislikes -= 1;
        } else {
          newLikes -= 1;
          newDislikes += 1;
        }
      } else {
        if (like) {
          newLikes += 1;
        } else {
          newDislikes += 1;
        }
      }

      transaction.update(docRef, {
        'likes': newLikes,
        'disLikes': newDislikes,
      });

      transaction.set(likesRef, {
        'like': like,
      });
    }).catchError((error) {
      print("Failed to update likes/dislikes: $error");
    });
  }

  addComment(String comment, String userId, String documentId) async {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('UserCollection').doc(documentId);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(docRef);
      if (snapshot.exists) {
        List<dynamic> comments = snapshot.get('comments') ?? [];
        comments.add({
          'comment': comment,
          'userId': userId,
        });
        transaction.update(docRef, {'comments': comments});
      }
    });
  }
}
