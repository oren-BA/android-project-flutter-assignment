import 'dart:developer';

import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hello_me/Provider/auth_repository.dart';
import 'package:hello_me/Widgets/loginWidget.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hello_me/auxFuncs.dart';

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
