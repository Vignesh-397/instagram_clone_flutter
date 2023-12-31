import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_flutter/models/user.dart' as model;
import 'package:instagram_clone_flutter/providers/user_provider.dart';
import 'package:instagram_clone_flutter/resources/firestore_methods.dart';
import 'package:instagram_clone_flutter/screens/comments_screen.dart';
import 'package:instagram_clone_flutter/screens/profile_screen.dart';
import 'package:instagram_clone_flutter/utils/colors.dart';
import 'package:instagram_clone_flutter/utils/utils.dart';
import 'package:instagram_clone_flutter/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({
    super.key,
    required this.snap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  String currentUid = FirebaseAuth.instance.currentUser!.uid;
  bool isLikeAnimating = false;
  int commentLength = 0;
  List savedposts = [];
  bool isPostSaved = false;

  @override
  void initState() {
    super.initState();
    getComments();
    getuser();
  }

  void getuser() async {
    try {
      DocumentSnapshot userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUid)
          .get();
      setState(() {
        savedposts =
            (userSnap.data() as Map<String, dynamic>?)?['savedposts'] ?? [];
        isPostSaved = savedposts.contains(widget.snap['postId']);
      });
    } catch (e) {
      showSnackbar(e.toString(), context);
    }
  }

  void getComments() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      setState(() {
        commentLength = snap.docs.length;
      });
    } catch (e) {
      showSnackbar(e.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<UserProvider>(context).getUser;
    final width = MediaQuery.of(context).size.width;
    return Container(
      color: mobileBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          // Username Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16)
                .copyWith(
              right: 0,
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        uid: widget.snap['uid'],
                      ),
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(
                      widget.snap['profImage'].toString(),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                uid: widget.snap['uid'],
                              ),
                            ),
                          ),
                          child: Text(
                            widget.snap['username'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shrinkWrap: true,
                          children: [
                            'Report',
                          ]
                              .map(
                                (e) => InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    showSnackbar(
                                        'Reported successfully.', context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                    child: Text(e),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ),
          // Image Section
          GestureDetector(
            onDoubleTap: () async {
              await FireStoreMethods().likePost(
                widget.snap['postId'],
                user.uid,
                widget.snap['likes'],
              );
              setState(() {
                isLikeAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: widget.snap['postUrl'].toString(),
                    fit: BoxFit.cover,
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLikeAnimating ? 1 : 0,
                  child: LikeAnimation(
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 100,
                    ),
                    isAnimating: isLikeAnimating,
                    duration: const Duration(milliseconds: 400),
                    onEnd: () {
                      setState(() {
                        isLikeAnimating = false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          //Likes and comment section
          Row(
            children: [
              LikeAnimation(
                isAnimating: widget.snap['likes'].contains(user.uid),
                smallLike: true,
                child: IconButton(
                  onPressed: () async {
                    await FireStoreMethods().likePost(
                      widget.snap['postId'].toString(),
                      user.uid,
                      widget.snap['likes'],
                    );
                  },
                  icon: widget.snap['likes'].contains(user.uid)
                      ? const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        )
                      : const Icon(
                          Icons.favorite_outline,
                        ),
                ),
              ),
              IconButton(
                onPressed: () => showModalBottomSheet(
                  useSafeArea: true,
                  isScrollControlled: true,
                  context: context,
                  builder: (ctx) {
                    return CommentScreen(
                      snap: widget.snap,
                    );
                  },
                ),
                icon: const Icon(
                  Icons.comment_outlined,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.send,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    onPressed: () async {
                      String res = await FireStoreMethods()
                          .toggleSavedPost(widget.snap['postId']);
                      setState(() {
                        isPostSaved = !isPostSaved;
                      });
                      showSnackbar(res, context);
                    },
                    icon: isPostSaved
                        ? const Icon(Icons.bookmark)
                        : const Icon(Icons.bookmark_border),
                  ),
                ),
              ),
            ],
          ),

          //Description and number of likes

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (widget.snap['likes']?.length ?? 0).toString() + ' likes',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 8,
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: primaryColor,
                      ),
                      children: [
                        TextSpan(
                            text: widget.snap['username'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                        TextSpan(
                          text: ' ${widget.snap['description']}',
                        )
                      ],
                    ),
                  ),
                ),
                InkWell(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: commentLength > 0
                        ? InkWell(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CommentScreen(
                                  snap: widget.snap,
                                ),
                              ),
                            ),
                            child: Text(
                              'View all ${commentLength} comments',
                              style: TextStyle(
                                  fontSize: 16, color: secondaryColor),
                            ),
                          )
                        : null,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    DateFormat.yMMMd().format(
                      widget.snap['datePublished'].toDate(),
                    ),
                    style: const TextStyle(fontSize: 16, color: secondaryColor),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
