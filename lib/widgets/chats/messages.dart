import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './message_bubble.dart';

class Messages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAuth.instance.currentUser(),
      builder: (context, futureSnapShot) {
        if (futureSnapShot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        return StreamBuilder(
          stream: Firestore.instance
              .collection('chat')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, chatSnapshot) {
            if (chatSnapshot.connectionState == ConnectionState.waiting) {
              return Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            final chatDocs = chatSnapshot.data.documents;
            return Expanded(
              child: ListView.builder(
                reverse: true, //Scrow from bottom to top
                itemBuilder: (context, index) => MessageBubble(
                  chatDocs[index]['text'],
                  chatDocs[index]['username'],
                  chatDocs[index]['userImage'],
                  chatDocs[index]['userId'] == futureSnapShot.data.uid,
                  key: ValueKey(
                    chatDocs[index].documentID,
                  ),
                ),
                itemCount: chatDocs.length,
              ),
            );
          },
        );
      },
    );
  }
}
