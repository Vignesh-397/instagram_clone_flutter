import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String imgUrl;
  final String username;
  final String bio;
  final List followers;
  final List following;
  final List savedposts;

  User({
    required this.email,
    required this.uid,
    required this.imgUrl,
    required this.username,
    required this.bio,
    required this.followers,
    required this.following,
    required this.savedposts,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'uid': uid,
        'email': email,
        'bio': bio,
        'followers': [],
        'following': [],
        'imgUrl': imgUrl,
        'savedposts': [],
      };

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      email: snapshot['email'],
      uid: snapshot['uid'],
      imgUrl: snapshot['imgUrl'],
      username: snapshot['username'],
      bio: snapshot['bio'],
      followers: snapshot['followers'],
      following: snapshot['following'],
      savedposts: snapshot['savedposts'],
    );
  }
}
