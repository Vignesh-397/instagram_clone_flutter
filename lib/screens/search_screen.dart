import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone_flutter/screens/profile_screen.dart';
import 'package:instagram_clone_flutter/utils/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;
  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextFormField(
          controller: searchController,
          decoration: const InputDecoration(
            labelText: 'Search for a user',
          ),
          onFieldSubmitted: (String _) {
            setState(() {
              isShowUsers = true;
            });
          },
        ),
      ),
      body: isShowUsers
          ? FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .where('username',
                      isGreaterThanOrEqualTo: searchController.text)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || (snapshot.data?.docs ?? []).isEmpty) {
                  return const Center(
                    child: Text('No users found.'),
                  );
                }

                return ListView.builder(
                  itemCount: (snapshot.data?.docs ?? []).length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                            uid: snapshot.data!.docs[index]['uid'],
                          ),
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            snapshot.data!.docs[index]['imgUrl'].toString(),
                          ),
                        ),
                        title: Text(snapshot.data!.docs[index]['username']),
                      ),
                    );
                  },
                );
              },
            )
          : FutureBuilder(
              future: FirebaseFirestore.instance.collection('posts').get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || (snapshot.data?.docs ?? []).isEmpty) {
                  return const Center(
                    child: Text('No posts found.'),
                  );
                }

                return MasonryGridView.count(
                  crossAxisCount: 3,
                  itemCount: (snapshot.data?.docs ?? []).length,
                  itemBuilder: (context, index) => Image.network(
                    snapshot.data!.docs[index]['postUrl'],
                    fit: BoxFit.cover,
                  ),
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                );
              },
            ),
      // isShowUsers
      //     ? FutureBuilder(
      //         future: FirebaseFirestore.instance
      //             .collection('users')
      //             .where('username',
      //                 isGreaterThanOrEqualTo: searchController.text)
      //             .get(),
      //         builder: (context, snapshot) {
      //           if (snapshot.connectionState == ConnectionState.waiting) {
      //             return const Center(
      //               child: CircularProgressIndicator(),
      //             );
      //           }

      //           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      //             return const Center(
      //               child: Text('No data available.'),
      //             );
      //           }
      //           return ListView.builder(
      //               itemCount: snapshot.data!.docs.length,
      //               itemBuilder: (context, index) {
      //                 return ListTile(
      //                   leading: CircleAvatar(
      //                     backgroundImage: NetworkImage(
      //                       snapshot.data!.docs[index]['imgUrl'].toString(),
      //                     ),
      //                   ),
      //                   title: Text(snapshot.data!.docs[index]['username']),
      //                 );
      //               });
      //         })
      //     : FutureBuilder(
      //         future: FirebaseFirestore.instance.collection('posts').get(),
      //         builder: (context, snapshot) {
      //           if (!snapshot.hasData) {
      //             const Center(
      //               child: CircularProgressIndicator(),
      //             );
      //           }
      //           return MasonryGridView.count(
      //             crossAxisCount: 3,
      //             itemCount: (snapshot.data?.docs ?? []).length,
      //             itemBuilder: (context, index) => Image.network(
      //               snapshot.data!.docs[index]['postUrl'],
      //               fit: BoxFit.cover,
      //             ),
      //             mainAxisSpacing: 8.0,
      //             crossAxisSpacing: 8.0,
      //           );
      //         },
      //       ),
    );
  }
}
