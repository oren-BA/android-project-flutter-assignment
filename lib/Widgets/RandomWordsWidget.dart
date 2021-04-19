import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/Provider/auth_repository.dart';
import 'package:hello_me/Widgets/suggestionsListWidget.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:hello_me/Pages/savedPage.dart';
import 'package:hello_me/Pages/loginPage.dart';
import 'package:hello_me/Widgets/snapSheetWidget.dart';
import '../Provider/auth_repository.dart';

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  var _saved = <WordPair>{};
  StreamController<String> controller = StreamController.broadcast();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthRepository>(
      builder: (context, authRep, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Startup Name Generator'),
            actions: (authRep.isAuthenticated)
                ? [
                    IconButton(
                        icon: Icon(Icons.favorite),
                        onPressed: () =>
                            pushSaved(context, controller, _saved)),
                    IconButton(
                        icon: Icon(Icons.exit_to_app),
                        onPressed: () => signOut(authRep)),
                  ]
                : [
                    IconButton(
                        icon: Icon(Icons.favorite),
                        onPressed: () =>
                            pushSaved(context, controller, _saved)),
                    IconButton(
                        icon: Icon(Icons.login),
                        onPressed: () => pushLogin(context, _saved, this)),
                  ],
          ),
          body: _buildSuggestions(),
        );
      },
    );
  }

  void setStateWidget(){
    setState(() {

    });
  }

  void signOut(AuthRepository authRep) {
    authRep.signOut();
    setState(() {});
  }

  Widget _buildSuggestions() {
    return Consumer<AuthRepository>(builder: (context, authRep, snapshot) {
      return StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            return StreamBuilder(
                stream: controller.stream,
                builder: (context, snapshot) {
                  if (authRep.isAuthenticated) {
                    return Scaffold(
                      body: SnapSheetWidget(_suggestions, _saved),
                    );
                  }
                  return SuggestionsListWidget(_suggestions, _saved, null);
                });
          });
    });
  }
}
