import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hello_me/Provider/auth_repository.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hello_me/auxFuncs.dart';

class LoginWidget extends StatefulWidget {
  Set<WordPair> saved = {};

  LoginWidget(this.saved);

  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final bottomSheetController = TextEditingController();

  final snackBar = SnackBar(
    content: Text('There was an error logging into the app'),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Text('Welcome to Startup Names Generator, please log in below',
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
          Consumer<AuthRepository>(builder: (context, authRep, snapshot) {
            Color color = Colors.red[900]!;
            if (authRep.status == Status.Authenticating) {
              color = Colors.grey;
            }
            return ElevatedButton(
              onPressed: () {
                if (color == Colors.grey) return;
                authRep
                    .signIn(emailController.text, passwordController.text)
                    .then((value) =>
                authRep.isAuthenticated
                    ? authenticated(authRep)
                    : ScaffoldMessenger.of(context).showSnackBar(snackBar));
              },
              child: Text('Log in'),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(color),
                  minimumSize: MaterialStateProperty.all<Size>(Size(350, 35)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.0),
                      ))),
            );
          }),
          Consumer<AuthRepository>(builder: (context, authRep, snapshot) {
            return ElevatedButton(
              onPressed: () {
                showMaterialModalBottomSheet(
                    context: context,
                    // isScrollControlled: true,
                    builder: (context) {
                      return AnimatedPadding(
                        padding: MediaQuery
                            .of(context)
                            .viewInsets,
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.decelerate,
                        child: SingleChildScrollView(
                          child:
                          Column(mainAxisSize: MainAxisSize.min, children: [
                            Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    "Please confirm your password below",
                                    style: TextStyle(fontSize: 15),
                                  ),
                                )),
                            Divider(),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: TextFormField(
                                // autofocus: true,
                                controller: bottomSheetController,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                ),
                                obscureText: true,
                              ),
                            ),
                            Divider(),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (passwordController.text ==
                                      bottomSheetController.text &&
                                      emailController.text != "") {
                                    createUser(authRep, emailController.text,
                                        passwordController.text);
                                  } else {
                                    final snackBar = SnackBar(
                                      content: Text('Passwords must match'),
                                    );
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                  }
                                },
                                child: Text('Confirm'),
                                style: ButtonStyle(
                                  backgroundColor:
                                  MaterialStateProperty.all<Color>(
                                      Colors.green[700]!),
                                  minimumSize: MaterialStateProperty.all<Size>(
                                      Size(90, 35)),
                                ),
                              ),
                            )
                          ]),
                        ),
                      );
                    });
              },
              child: Text('New user? Click to sign up'),
              style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.green[700]!),
                  minimumSize: MaterialStateProperty.all<Size>(Size(350, 35)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.0),
                      ))),
            );
          }),

        ],
      ),
    );
  }

  void authenticated(AuthRepository authRep) {
    if (authRep.isAuthenticated) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var currUser = FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user.email);
        var cloudWordPairs;
        currUser.get().then((snapshot) {
          snapshot.docs.forEach((element) async {
            cloudWordPairs = await element.data()["WordPairs"];
            widget.saved = combineData(widget.saved, cloudWordPairs);
            sendToCloud(widget.saved, element.id);
            print(cloudWordPairs);
          });
        });
      }
    }
    Navigator.of(context).pop();
  }

  void createUser(AuthRepository authRep, String email, String password) async{
      UserCredential newUser = (await authRep.signUp(email, password))!;
      FirebaseFirestore.instance.collection("users").doc(newUser.user!.uid).set({"email": email, "WordPairs": {}});
      authenticated(authRep);
      Navigator.of(context).pop();
  }
}
