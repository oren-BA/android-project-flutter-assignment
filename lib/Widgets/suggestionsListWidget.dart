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
import 'package:snapping_sheet/snapping_sheet.dart';
import '../Provider/auth_repository.dart';
import '../Provider/auth_repository.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:hello_me/Widgets/RandomWordsWidget.dart';

import 'RandomWordsWidget.dart';

class SuggestionsListWidget extends StatefulWidget{
  List<WordPair> suggestions;
  var saved;

  SuggestionsListWidget(this.suggestions, this.saved);

  @override
  _SuggestionsListState createState() => _SuggestionsListState();

}

class _SuggestionsListState extends State<SuggestionsListWidget>{

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemBuilder: (BuildContext _context, int i) {
        if (i.isOdd) {
          return Divider(
            thickness: 2,
          );
        }
        final int index = i ~/ 2;
        if (index >= widget.suggestions.length) {
          widget.suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(widget.suggestions[index]);
      },
    );
  }

  Widget _buildRow(WordPair pair) {
    final alreadySaved = widget.saved.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: TextStyle(fontSize: 18),
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red[900] : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            removeItem(widget.saved, pair);
          } else {
            addItem(widget.saved, pair);
          }
        });
      },
    );
  }
}