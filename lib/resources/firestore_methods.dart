import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone_flutter/models/post.dart';
import 'package:instagram_clone_flutter/resources/storage_methods.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String username,
    String profImage,
  ) async {
    String res = 'Some error occured';
    try {
      String imgUrl =
          await StorageMethods().uploadImageToStoarge('posts', file, true);
      String postId = Uuid().v1();
      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        postId: postId,
        datePublished: Timestamp.now(),
        postUrl: imgUrl,
        profImage: profImage,
        likes: [],
      );
      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String> postComment(
    String postId,
    String text,
    String uid,
    String name,
    String profilePic,
  ) async {
    String res = 'Something went wrong';
    try {
      if (text.isNotEmpty) {
        String commentId = Uuid().v1();
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set(
          {
            'profilePic': profilePic,
            'name': name,
            'text': text,
            'uid': uid,
            'commentId': commentId,
            'datePublished': DateTime.now(),
          },
        );
        res = 'success';
      } else {
        res = 'comment cannot be empty';
      }
    } catch (e) {
      res = e.toString();
      print(e.toString());
    }
    return res;
  }

  //Deleting the post
  Future<String> deletePost(String postId) async {
    String res = 'Something went wrong';
    try {
      await _firestore.collection('posts').doc(postId).delete();
      res = 'success';
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> followUser(String uid, String followUId) async {
    String res = 'Something went wrong';
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List following = snap['following'];

      if (following.contains(followUId)) {
        await _firestore.collection('users').doc(followUId).update({
          'followers': FieldValue.arrayRemove(
            [uid],
          ),
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove(
            [followUId],
          ),
        });
      } else {
        await _firestore.collection('users').doc(followUId).update({
          'followers': FieldValue.arrayUnion(
            [uid],
          ),
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion(
            [followUId],
          ),
        });
      }

      res = 'success';
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> toggleSavedPost(String postId) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String res = 'Something went wrong';
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List savedposts = snap['savedposts'];

      if (savedposts.contains(postId)) {
        await _firestore.collection('users').doc(uid).update({
          'savedposts': FieldValue.arrayRemove([postId]),
        });
        res = 'Post removed from saved.';
      } else {
        await _firestore.collection('users').doc(uid).update({
          'savedposts': FieldValue.arrayUnion([postId]),
        });
        res = 'Post saved successfully.';
      }
    } catch (e) {
      res = 'Something went wrong: $e';
    }
    return res;
  }
}
