import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:video_app/services/firebase_services.dart';

class CommentScreen extends StatefulWidget {
  const CommentScreen({
    super.key,
    required this.documentId,
    required this.userid,
  });
  final String userid;
  final String documentId;

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final commentController = TextEditingController();
  bool _isloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        15,
        14,
        51,
      ),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Comments',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
        backgroundColor: const Color.fromARGB(
          255,
          15,
          14,
          51,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('Users').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                List<DocumentSnapshot> docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data =
                        docs[index].data() as Map<String, dynamic>;
                    String documentId = docs[index].id;
                    List<dynamic> comments = data['comments'] ?? [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Document ID: $documentId'),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          itemBuilder: (context, commentIndex) {
                            Map<String, dynamic> commentData =
                                comments[commentIndex];
                            return ListTile(
                              title: Text(commentData['comment']),
                              subtitle:
                                  Text('User ID: ${commentData['userId']}'),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(
              8.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.9),
                      spreadRadius: 3,
                      blurRadius: 3,
                      offset: const Offset(
                        0,
                        1,
                      ),
                    )
                  ]),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: const InputDecoration(
                            hintText: "Search text here",
                            contentPadding: EdgeInsets.all(12),
                            border: InputBorder.none),
                      ),
                    ),

                  const SizedBox(
                    width: 10,
                  ),
                  _isloading
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : IconButton(
                          onPressed: () {
                            DataBaseServices().addComment(
                              commentController.text,
                              widget.userid,
                              widget.documentId,
                            );
                          },
                          icon: const Icon(
                            Icons.send_rounded,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
