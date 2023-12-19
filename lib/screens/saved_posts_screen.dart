import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_flutter/utils/colors.dart';
import 'package:instagram_clone_flutter/utils/global_variables.dart';
import 'package:instagram_clone_flutter/widgets/post_card.dart';

class SavedPostsScreen extends StatefulWidget {
  const SavedPostsScreen({Key? key}) : super(key: key);

  @override
  State<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: width > webScreenSize
          ? null
          : AppBar(
              title: const Text('Saved posts'),
              backgroundColor: mobileBackgroundColor,
            ),
      body: FutureBuilder(
        future: _getUserSavedPosts(),
        builder: (context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No saved posts.'),
            );
          }

          return StreamBuilder(
            stream: FirebaseFirestore.instance.collection('posts').snapshots(),
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                    postSnapshot) {
              if (postSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final savedPostIds = snapshot.data!;

              // Filter posts based on savedPostIds
              final savedPosts = postSnapshot.data!.docs.where(
                  (post) => savedPostIds.contains(post.data()!['postId']));

              return ListView.builder(
                itemCount: savedPosts.length,
                itemBuilder: (context, index) => Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: width > webScreenSize ? width * 0.2 : 0,
                    vertical: width > webScreenSize ? 15 : 0,
                  ),
                  child: PostCard(
                    snap: savedPosts.elementAt(index).data(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<String>> _getUserSavedPosts() async {
    final user = _auth.currentUser;
    final uid = user!.uid;

    // Replace 'users' with the correct collection name if it's different
    final userSavedPostsDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('savedPosts')
        .get();

    final savedPostIds = userSavedPostsDoc.docs
        .map((doc) => doc.data()!['postId'].toString())
        .toList();

    return savedPostIds;
  }
}
