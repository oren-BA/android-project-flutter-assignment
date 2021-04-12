import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hello_me/auth_repository.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';
import 'dart:async';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        // Add the 3 lines from here...
        primaryColor: Colors.red,
      ),
      home: RandomWords(),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _biggerFont = const TextStyle(fontSize: 18);
  var _saved = <WordPair>{};
  StreamController<String> controller = StreamController.broadcast();

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // NEW lines from here...
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Saved Suggestions'),
            ),
            body: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .snapshots(),
                builder: (context, snapshot) {
                  log(_saved.toString());
                  return StreamBuilder(
                    stream: controller.stream,
                    builder: (context, snapshot){
                      return ListView.separated(
                        itemCount: _saved.length,
                        separatorBuilder: (context, index) => Divider(),
                        itemBuilder: (context, index) {
                          final authRep = AuthRepository.instance();
                          final user = FirebaseAuth.instance.currentUser;
                          return ListTile(
                            title: Text(
                              _saved.elementAt(index).asPascalCase,
                              style: _biggerFont,
                            ),
                            trailing: Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onTap: () {
                              if (authRep.isAuthenticated){
                                removeItem(_saved.elementAt(index));
                              } else {
                                _saved.remove(_saved.elementAt(index));
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

  void removeItem(WordPair pair) {
    final authRep = AuthRepository.instance();
    final user = FirebaseAuth.instance.currentUser;
    _saved.remove(pair);
    if (authRep.isAuthenticated && user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get()
          .then((snapshot) {
        snapshot.docs.forEach((element) async {
          sendToCloud(_saved, element.id);
        });
      });
    }
    setState(() {
    });
  }

  void addItem(WordPair pair) {
    final authRep = AuthRepository.instance();
    final user = FirebaseAuth.instance.currentUser;
    _saved.add(pair);
    if (authRep.isAuthenticated && user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get()
          .then((snapshot) {
        snapshot.docs.forEach((element) async {
          sendToCloud(_saved, element.id);
        });
      });
    }
  }

  void _pushLogin() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // NEW lines from here...
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
                            _saved = combineData(_saved, cloudWordPairs);
                            sendToCloud(_saved, element.id);
                            print(cloudWordPairs);
                          });
                        });
                        // Navigator.of(context).pop();
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
        }, // ...to here.
      ),
    );
  }

  Set<WordPair> combineData(Set<WordPair> saved, List data) {
    for (int i = 0; i < data.length; i++) {
      saved.add(WordPair(data[i]['first'], data[i]['second']));
    }
    return saved;
  }

  void sendToCloud(Set<WordPair> saved, String docId) {
    List wordPairs = [];
    saved.forEach((element) {
      wordPairs.add({'first': element.first, 'second': element.second});
    });
    FirebaseFirestore.instance
        .collection('users')
        .doc(docId)
        .update({'WordPairs': wordPairs});
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthRepository.instance(),
      child: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          return Scaffold(
            // Add from here...
            appBar: AppBar(
              title: Text('Startup Name Generator'),
              actions: (AuthRepository.instance().isAuthenticated)
                  ? [
                      IconButton(
                          icon: Icon(Icons.favorite), onPressed: _pushSaved),
                      IconButton(
                          icon: Icon(Icons.exit_to_app), onPressed: signOut),
                    ]
                  : [
                      IconButton(
                          icon: Icon(Icons.favorite), onPressed: _pushSaved),
                      IconButton(
                          icon: Icon(Icons.login), onPressed: _pushLogin),
                    ],
            ),
            body: _buildSuggestions(),
          );
        },
      ),
    );
  }

  void signOut() {
    AuthRepository.instance().signOut();
    setState(() {});
  }

  Widget _buildSuggestions() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .snapshots(),
        builder: (context, snapshot){
          return StreamBuilder(
              stream: controller.stream,
              builder: (context, snapshot){
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
              }
          );
        }
    );
  }

  Widget _buildRow(WordPair pair) {
    final alreadySaved = _saved.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        // NEW from here...
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        // NEW lines from here...
        setState(() {
          if (alreadySaved) {
            // _saved.remove(pair);
            removeItem(pair);
          } else {
            // _saved.add(pair);
            addItem(pair);
          }
        });
      },
    );
  }
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
