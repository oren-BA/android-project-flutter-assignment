import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hello_me/Provider/auth_repository.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:hello_me/Pages/savedPage.dart';
import 'package:hello_me/Pages/loginPage.dart';
import 'package:hello_me/auxFuncs.dart';

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _biggerFont = const TextStyle(fontSize: 18);
  var _saved = <WordPair>{};
  StreamController<String> controller = StreamController.broadcast();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthRepository>(
      builder: (context, authRep, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Startup Name Generator'),
            actions: (AuthRepository.instance().isAuthenticated)
                ? [
              IconButton(
                  icon: Icon(Icons.favorite),
                  onPressed: () =>
                      pushSaved(context, controller, _saved)),
              IconButton(
                  icon: Icon(Icons.exit_to_app), onPressed: signOut),
            ]
                : [
              IconButton(
                  icon: Icon(Icons.favorite),
                  onPressed: () =>
                      pushSaved(context, controller, _saved)),
              IconButton(
                  icon: Icon(Icons.login), onPressed:() => pushLogin(context, _saved)),
            ],
          ),
          body: _buildSuggestions(),
        );
      },
    );
  }

  void signOut() {
    AuthRepository.instance().signOut();
    setState(() {});
  }

  Widget _buildSuggestions() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          return StreamBuilder(
              stream: controller.stream,
              builder: (context, snapshot) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (BuildContext _context, int i) {
                    if (i.isOdd) {
                      return Divider(
                        thickness: 2,
                      );
                    }
                    final int index = i ~/ 2;
                    if (index >= _suggestions.length) {
                      _suggestions.addAll(generateWordPairs().take(10));
                    }
                    return _buildRow(_suggestions[index]);
                  },
                );
              });
        });
  }

  Widget _buildRow(WordPair pair) {
    final alreadySaved = _saved.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            removeItem(_saved, pair);
          } else {
            addItem(_saved, pair);
          }
        });
      },
    );
  }
}