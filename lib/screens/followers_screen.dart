import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_flutter/utils/colors.dart';
import 'package:instagram_clone_flutter/widgets/user_prof_details.dart';

class FollowersScreen extends StatefulWidget {
  final String uid;
  const FollowersScreen({super.key, required this.uid});

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          title: const Text('Followers'),
          centerTitle: false,
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .snapshots(),
          builder: (context, snapshot) {
            // print(snapshot.data!.data()?['followers']);
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                child: Text('No followers found.'),
              );
            }
            if (snapshot.data!.data()?['followers'].length < 1) {
              return const Center(
                child: Text('No followers found.'),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.data()?['followers'].length,
              itemBuilder: (context, index) => UserProfDetails(
                snap: snapshot.data!.data()?['followers'][index],
              ),
            );
          },
        ));
  }
}
