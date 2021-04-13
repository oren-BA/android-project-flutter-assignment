import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hello_me/Provider/auth_repository.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hello_me/auxFuncs.dart';


void pushLogin(BuildContext context, Set<WordPair> saved) {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Login'),
            centerTitle: true,
          ),
          body: ChangeNotifierProvider(
            create: (context) => AuthRepository.instance(),
            child: StreamBuilder(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  final authRep = AuthRepository.instance();
                  if (snapshot.hasData) {
                    if (!authRep.isAuthenticated) {
                      final snackBar = SnackBar(
                        content: Text('Error with login info'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } else {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        return Center();
                      } //boilerplate...
                      var currUser = FirebaseFirestore.instance
                          .collection('users')
                          .where('email', isEqualTo: user.email);
                      var updatedWordPairs;
                      var cloudWordPairs;
                      currUser.get().then((snapshot) {
                        snapshot.docs.forEach((element) async {
                          cloudWordPairs = await element.data()["WordPairs"];
                          saved = combineData(saved, cloudWordPairs);
                          sendToCloud(saved, element.id);
                          print(cloudWordPairs);
                        });
                      });
                    }
                  }
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                            'Welcome to Startup Names Generator, please log in below',
                            style: TextStyle(fontSize: 15)),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                          ),
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                          obscureText: true,
                        ),
                        SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            AuthRepository.instance()
                                .signIn(emailController.text,
                                passwordController.text)
                                .then((value) => Navigator.of(context).pop());
                          },
                          child: Text('Log in'),
                          style: ButtonStyle(
                              backgroundColor:
                              MaterialStateProperty.all<Color>(
                                  Colors.red),
                              minimumSize: MaterialStateProperty.all<Size>(
                                  Size(300, 30)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40.0),
                                  ))),
                        ),
                      ],
                    ),
                  );
                }),
          ),
        );
      },
    ),
  );
}