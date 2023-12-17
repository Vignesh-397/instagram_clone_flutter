import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clone_flutter/models/user.dart' as model;
import 'package:instagram_clone_flutter/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(snap);
  }

  // signup the user
  Future<String> signupUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    String res = 'Some error occured';
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          username.isNotEmpty &&
          bio.isNotEmpty &&
          file != null) {
        //Register user
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        String imgUrl = await StorageMethods()
            .uploadImageToStoarge('profilePics', file, false);

        //Add user to database

        model.User user = model.User(
          email: email,
          uid: cred.user!.uid,
          username: username,
          imgUrl: imgUrl,
          bio: bio,
          followers: [],
          following: [],
        );
        await _firestore.collection('users').doc(cred.user!.uid).set(
              user.toJson(),
            );
        res = 'success';
      } else {
        res = "Please enter all the fields";
      }
    } on FirebaseAuthException catch (err) {
      res = err.code;
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = 'Some error occured';

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = 'Success';
      } else {
        res = "Please enter all the fields";
      }
    } on FirebaseAuthException catch (err) {
      res = err.code;
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Future<String> uploadPost({
  //   required Uint8List file,
  // }) async {
  //   String res = 'post upload failed';
  //   try {
  //     String postUrl =
  //         await StorageMethods().uploadImageToStoarge('posts', file, true);
  //     await _firestore.collection('posts').doc(_auth.currentUser!.uid).set({
  //       'postUrl': postUrl,
  //     });
  //     res = 'post-success';
  //   } catch (err) {
  //     res = err.toString();
  //   }
  //   return res;
  // }
}
