import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hello_me/Provider/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:hello_me/auxFuncs.dart';

void pushSaved(
    BuildContext context, StreamController controller, Set<WordPair> saved) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Saved Suggestions'),
          ),
          body: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                return StreamBuilder(
                  stream: controller.stream,
                  builder: (context, snapshot) {
                    return ListView.separated(
                      itemCount: saved.length,
                      separatorBuilder: (context, index) => Divider(),
                      itemBuilder: (context, index) {
                        final authRep = AuthRepository.instance();
                        final user = FirebaseAuth.instance.currentUser;
                        return ListTile(
                          title: Text(
                            saved.elementAt(index).asPascalCase,
                            style: TextStyle(fontSize: 18),
                          ),
                          trailing: Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onTap: () {
                            if (authRep.isAuthenticated) {
                              removeItem(saved, saved.elementAt(index));
                            } else {
                              saved.remove(saved.elementAt(index));
                              controller.add("changed");
                            }
                          },
                        );
                      },
                    );
                  },
                );
              }),
        );
      }, // ...to here.
    ),
  );
}
