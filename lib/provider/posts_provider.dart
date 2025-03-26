import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/post.dart';
import '../models/user.dart';
import '../services/post_service.dart';

class PostsProvider extends ChangeNotifier {
  List<Post> posts = [];
  List<Post> userPosts = [];
  String? error;
  bool loading = true;

  Future<void> getUserPosts(AppUser user, PostService postService) async {
    error = null;
    userPosts = [];
    loading = true;
    notifyListeners();
    try {
      userPosts = await postService.getUserPosts(user.id);
    } on FirebaseException catch (e) {
      error = e.message;
    } finally {
      loading = false;
    }
    notifyListeners();
  }

    Future<void> getPosts(PostService postService) async {
    try {
      posts = await postService.getPostsFromFollowing();
    } on FirebaseException catch (e) {
      error = e.message;
    } finally {
      loading = false;
    }
    notifyListeners();
  }

  void deletePost(String postId) {
    posts.removeWhere((e) => e.id == postId);
    userPosts.removeWhere((e) => e.id == postId);
    notifyListeners();
  }
}
