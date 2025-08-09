import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:namaz_timing/view/Auth/loginScreen.dart';

class ProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Observable variables
  var isLoading = false.obs;
  var userPosts = <DocumentSnapshot>[].obs;
  var userPostsCount = 0.obs;
  var totalLikes = 0.obs;
  var totalComments = 0.obs;
  var userName = ''.obs;
  var userPhotoUrl = ''.obs;
  var userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadUserPosts();
  }

  // Load current user's basic data
  Future<void> loadUserData() async {
    try {
      isLoading(true);
      User? currentUser = _auth.currentUser;
      
      if (currentUser != null) {
        // Get user data from Firestore users collection if it exists
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();
            
        if (userDoc.exists) {
          var userData = userDoc.data() as Map<String, dynamic>;
          userName.value = userData['name'] ?? currentUser.displayName ?? 'Anonymous';
          userPhotoUrl.value = userData['photoUrl'] ?? currentUser.photoURL ?? '';
        } else {
          // Fallback to Firebase Auth data
          userName.value = currentUser.displayName ?? 'Anonymous';
          userPhotoUrl.value = currentUser.photoURL ?? '';
        }
        
        userEmail.value = currentUser.email ?? '';
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      isLoading(false);
    }
  }

  // Load user's posts and calculate stats
  Future<void> loadUserPosts() async {
    try {
      isLoading(true);
      User? currentUser = _auth.currentUser;
      
      if (currentUser != null) {
        print('Loading posts for user: ${currentUser.uid}'); // Debug print
        
        // Get user's posts - try without orderBy first if timestamp field doesn't exist
        QuerySnapshot postsSnapshot;
        try {
          postsSnapshot = await _firestore
              .collection('posts')
              .where('userId', isEqualTo: currentUser.uid)
              .orderBy('createdAt', descending: true)
              .get();
        } catch (e) {
          // If orderBy fails, try without it
          print('OrderBy failed, trying without orderBy: $e');
          postsSnapshot = await _firestore
              .collection('posts')
              .where('userId', isEqualTo: currentUser.uid)
              .get();
        }
            
        print('Found ${postsSnapshot.docs.length} posts'); // Debug print
            
        userPosts.value = postsSnapshot.docs;
        userPostsCount.value = postsSnapshot.docs.length;
        
        // Calculate total likes and comments
        int likes = 0;
        int comments = 0;
        
        for (var post in postsSnapshot.docs) {
          var postData = post.data() as Map<String, dynamic>;
          print('Post data: $postData'); // Debug print
          
          // Count likes
          List<dynamic> postLikes = postData['likes'] ?? [];
          likes += postLikes.length;
          
          // Count comments for this post
          QuerySnapshot commentsSnapshot = await _firestore
              .collection('posts')
              .doc(post.id)
              .collection('comments')
              .get();
          comments += commentsSnapshot.docs.length;
        }
        
        totalLikes.value = likes;
        totalComments.value = comments;
        
        print('Total likes: $likes, Total comments: $comments'); // Debug print
      }
    } catch (e) {
      print('Error loading user posts: $e');
    } finally {
      isLoading(false);
    }
  }

  // Delete a specific post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
      
      // Remove from local list
      userPosts.removeWhere((post) => post.id == postId);
      userPostsCount.value = userPosts.length;
      
      // Recalculate stats
      await loadUserPosts();
      
      Get.snackbar(
        "Deleted",
        "Post has been deleted successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
        colorText: Get.theme.primaryColor,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to delete post",
        snackPosition: SnackPosition.BOTTOM,
        // backgroundColor: Get.theme.errorColor.withOpacity(0.1),
        // colorText: Get.theme.errorColor,
      );
    }
  }

  // Refresh all data
  Future<void> refreshData() async {
    await loadUserData();
    await loadUserPosts();
  }

  // Toggle like on a post (for profile view)
  void toggleLike(String postId, List likes) {
    final postRef = _firestore.collection('posts').doc(postId);
    if (likes.contains(_auth.currentUser!.uid)) {
      postRef.update({'likes': FieldValue.arrayRemove([_auth.currentUser!.uid])});
    } else {
      postRef.update({'likes': FieldValue.arrayUnion([_auth.currentUser!.uid])});
    }
    // Refresh data to update counts
    Future.delayed(Duration(milliseconds: 500), () => loadUserPosts());
  }

  // Update user profile
  Future<void> updateUserProfile(String newName) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Update in Firestore users collection
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .set({
          'name': newName,
          'email': currentUser.email,
          'photoUrl': userPhotoUrl.value,
        }, SetOptions(merge: true));

        // Update in Firebase Auth
        await currentUser.updateDisplayName(newName);
        
        // Update local state
        userName.value = newName;
        
        Get.snackbar(
          "Success",
          "Profile updated successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.teal[100],
          colorText: Colors.teal[800],
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update profile: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  // Logout user
  Future<void> logoutUser() async {
    try {
      await _auth.signOut();
      Get.to(LoginScreen()); // Replace with your login route
      Get.snackbar(
        "Logged Out",
        "You have been logged out successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.teal[100],
        colorText: Colors.teal[800],
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to logout: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }
}