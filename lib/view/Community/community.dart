import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:get/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:namaz_timing/controller/UserController.dart';
import 'dart:convert';

import 'package:namaz_timing/view/Community/createPostScreen.dart';
import 'package:namaz_timing/view/Community/showall_comments.dart';
class PostFeedScreen extends StatelessWidget {
  final currentUser = FirebaseAuth.instance.currentUser!;
final UserController userController = Get.put(UserController());
  void toggleLike(String postId, List likes) {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    if (likes.contains(currentUser.uid)) {
      postRef.update({'likes': FieldValue.arrayRemove([currentUser.uid])});
    } else {
      postRef.update({'likes': FieldValue.arrayUnion([currentUser.uid])});
    }
  }

  void addComment(String postId, String comment) {
    final user = FirebaseAuth.instance.currentUser!;
    FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add({
      'userId': user.uid,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
void deletePost(String postId) async {
  try {
    await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
    Get.snackbar(
      "Deleted",
      "Post has been deleted",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[900],
    );
  } catch (e) {
    Get.snackbar(
      "Error",
      "Failed to delete post",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[900],
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Islamic Community",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal[800],
        elevation: 0,
         leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal[600],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.add, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreatePostScreen()),
              ),
            ),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal[800]!),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final postId = doc.id;
              final likes = List<String>.from(data['likes'] ?? []);
              final commentController = TextEditingController();

              return Container(
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post Header
                   // Post Header
 Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: (data['userPhotoUrl'] != null &&
                                    data['userPhotoUrl'].toString().isNotEmpty)
                                ? NetworkImage(data['userPhotoUrl'])
                                : null,
                            backgroundColor: Colors.teal[100],
                            child: (data['userPhotoUrl'] == null ||
                                    data['userPhotoUrl'].toString().isEmpty)
                                ? Icon(Icons.person, color: Colors.teal[800], size: 30)
                                : null,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['userName'] ?? 'Anonymous',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.teal[800],
                                  ),
                                ),
                               Text(
  data['createdAt'] != null
      ? DateFormat('dd MMM yyyy, hh:mm a').format(
          data['createdAt'] is Timestamp 
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
        )
      : 'No date',
  // ... rest of style
),

                              ],
                            ),
                          ),
                        ],
                      ),

                      
                      SizedBox(height: 12),
                      
                      // Post Content
                      Text(
                        data['content'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.4,
                          color: Colors.grey[800],
                        ),
                      ),
                      
                      if ((data['imageUrl'] ?? '').isNotEmpty) ...[
                        SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            data['imageUrl'],
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey[600],
                                  size: 48,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      
                      SizedBox(height: 16),
                      
                      // Like Button
                     
                      SizedBox(height: 16),
                      
                      // Comment Input
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: commentController,
                                decoration: InputDecoration(
                                  hintText: 'Add a comment...',
                                  hintStyle: TextStyle(color: Colors.grey[500]),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: Colors.teal[800],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.send, color: Colors.white, size: 20),
                                onPressed: () {
                                  if (commentController.text.isNotEmpty) {
                                    addComment(postId, commentController.text);
                                    commentController.clear();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 8),
                     
                       Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           CommentList(postId: postId, postData: data, likes: likes),
                          GestureDetector(
                            onTap: () => toggleLike(postId, likes),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: likes.contains(currentUser.uid)
                                    ? Colors.red[50]
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: likes.contains(currentUser.uid)
                                      ? Colors.red
                                      : Colors.grey[300]!,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    likes.contains(currentUser.uid)
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: likes.contains(currentUser.uid)
                                        ? Colors.red
                                        : Colors.grey[600],
                                    size: 20,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '${likes.length}',
                                    style: TextStyle(
                                      color: likes.contains(currentUser.uid)
                                          ? Colors.red
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                          ),
                            if (data['userId'] == currentUser.uid)
      IconButton(
        icon: Icon(Icons.delete, color: Colors.red),
        onPressed: () {
          Get.defaultDialog(
            title: "Delete Post?",
            middleText: "Are you sure you want to delete this post?",
            textCancel: "Cancel",
            textConfirm: "Delete",
            confirmTextColor: Colors.white,
            onConfirm: () {
              deletePost(postId);
              Get.back();
            },
          );
        },
      ),
                        ],
                      ),
                     
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

