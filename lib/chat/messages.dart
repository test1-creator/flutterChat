import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashchat/chat/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Messages extends StatelessWidget {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.value(user),
      builder: (ctx, futureSnapshot) {
        if (futureSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chat')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder:
                (BuildContext ctx, AsyncSnapshot<QuerySnapshot> chatSnapShot) {
              if (chatSnapShot.hasError) {
                return Text('Something went wrong');
              }
              if (chatSnapShot.connectionState == ConnectionState.waiting) {
                return Text("Loading");
              }
              return ListView(
                reverse: true,
                children: chatSnapShot.data!.docs.map((DocumentSnapshot document) {
                  return MessageBubble(
                      (document.data() as Map)['text'],
                      (document.data() as Map)['username'],
                      (document.data() as Map)['userImage'],
                      (document.data() as Map)['userId'] == user!.uid);
                }).toList(),
              );
            });
      },
    );
  }
}
