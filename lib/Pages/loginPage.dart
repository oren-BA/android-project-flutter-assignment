import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/Widgets/loginWidget.dart';

void pushLogin(BuildContext context, Set<WordPair> saved) {

  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Login'),
            centerTitle: true,
          ),
          body: LoginWidget(saved),
        );
      },
    ),
  );
}
