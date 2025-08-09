import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CommentList extends StatelessWidget {
  final String postId;
  final Map<String, dynamic> postData;
  final List likes;

  const CommentList({
    required this.postId,
    required this.postData,
    required this.likes,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .snapshots(),
      builder: (context, commentSnapshot) {
        int commentCount = commentSnapshot.data?.docs.length ?? 0;
        return TextButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CommentDetailScreen(
                  postData: postData,
                  postId: postId,
                  likes: likes,
                ),
              ),
            );
          },
          icon: Icon(Icons.comment, color: Colors.teal[800]),
          label: Text(
            'Comments ($commentCount)',
            style: TextStyle(color: Colors.teal[800]),
          ),
        );
      },
    );
  }
}



class CommentDetailScreen extends StatelessWidget {
  final Map<String, dynamic> postData;
  final String postId;
  final List likes;

  CommentDetailScreen({
    required this.postData,
    required this.postId,
    required this.likes,
  });

  final currentUser = FirebaseAuth.instance.currentUser!;
  final TextEditingController commentController = TextEditingController();

  void addComment(String comment) {
    FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add({
      'userId': currentUser.uid,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Post & Comments", style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),),
           elevation: 0,
         leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.teal[800],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Post Content
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    postData['title'] ?? '',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    postData['content'] ?? '',
                    style: TextStyle(fontSize: 16),
                  ),
                  if ((postData['imageUrl'] ?? '').isNotEmpty) ...[
                    SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        postData['imageUrl'],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Comment Input
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.teal[800]),
                    onPressed: () {
                      if (commentController.text.isNotEmpty) {
                        addComment(commentController.text.trim());
                        commentController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // Comments List
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(postId)
                    .collection('comments')
                    .orderBy('createdAt')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final comments = snapshot.data!.docs;

                 return ListView.builder(
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  itemCount: comments.length,
  itemBuilder: (context, index) {
    final commentData = comments[index].data() as Map<String, dynamic>;
    final userId = commentData['userId'] ?? '';

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return SizedBox(); // Prevents loading indicators for each item
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
        final userName = userData['name'] ?? 'Anonymous';
        final userPhoto = userData['photoUrl'] ?? '';

        return Container(
          margin: EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.teal[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.teal[100]!),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: userPhoto.isNotEmpty ? NetworkImage(userPhoto) : null,
                backgroundColor: Colors.teal[800],
                child: userPhoto.isEmpty
                    ? Icon(Icons.person, color: Colors.white, size: 18)
                    : null,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.teal[800],
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      commentData['comment'] ?? '',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  },
);

                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
