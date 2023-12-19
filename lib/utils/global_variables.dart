import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_flutter/screens/add_post_screen.dart';
import 'package:instagram_clone_flutter/screens/feed_screen.dart';
import 'package:instagram_clone_flutter/screens/profile_screen.dart';
import 'package:instagram_clone_flutter/screens/search_screen.dart';

const webScreenSize = 600;

List<Widget> homScreenItems = [
  const FeedScreen(),
  const SearchScreen(),
  const AddPostScreen(),
  const Center(child: Text('This feature is not impleted yet.')),
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];
