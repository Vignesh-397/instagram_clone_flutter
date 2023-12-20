import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone_flutter/screens/chat_screen.dart';
import 'package:instagram_clone_flutter/utils/colors.dart';
import 'package:instagram_clone_flutter/utils/global_variables.dart';
import 'package:instagram_clone_flutter/widgets/post_card.dart';

class SavedPostsScreen extends StatefulWidget {
  const SavedPostsScreen({super.key});

  @override
  State<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> {
  String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: width > webScreenSize
          ? null
          : AppBar(
              backgroundColor: mobileBackgroundColor,
              centerTitle: false,
              title: const Text('Saved posts'),
            ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserUid)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('No saved posts found.'),
            );
          }

          // Extract the list of saved post IDs from the user document
          List<String> savedPostIds =
              List<String>.from(snapshot.data!.data()?['savedposts'] ?? []);

          if (savedPostIds.isEmpty) {
            return const Center(
              child: Text('No saved posts found.'),
            );
          }

          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .where('postId', whereIn: savedPostIds)
                .snapshots(),
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                    postSnapshot) {
              if (postSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (!postSnapshot.hasData ||
                  (postSnapshot.data?.docs ?? []).isEmpty) {
                return const Center(
                  child: Text('No saved posts found.'),
                );
              }
              return ListView.builder(
                itemCount: postSnapshot.data!.docs.length,
                itemBuilder: (context, index) => Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: width > webScreenSize ? width * 0.2 : 0,
                    vertical: width > webScreenSize ? 15 : 0,
                  ),
                  child: PostCard(
                    snap: postSnapshot.data!.docs[index].data(),
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
