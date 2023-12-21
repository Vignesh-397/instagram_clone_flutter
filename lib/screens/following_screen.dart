import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_flutter/utils/colors.dart';
import 'package:instagram_clone_flutter/widgets/user_prof_details.dart';

class FollowingScreen extends StatefulWidget {
  final String uid;
  const FollowingScreen({super.key, required this.uid});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          title: const Text('Following'),
          centerTitle: false,
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                child: Text('Not following anyone.'),
              );
            }
            if (snapshot.data!.data()?['following'].length < 1) {
              return const Center(
                child: Text('Not following anyone.'),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.data()?['following'].length,
              itemBuilder: (context, index) => UserProfDetails(
                snap: snapshot.data!.data()?['following'][index],
              ),
            );
          },
        ));
  }
}
