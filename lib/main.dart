import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hello_me/auth_repository.dart';
import 'package:provider/provider.dart';


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
  final _saved = <WordPair>{};

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // NEW lines from here...
        builder: (BuildContext context) {
          final tiles = _saved.map(
            (WordPair pair) {
              return ListTile(
                title: Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
                trailing: Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                onTap: () {
                  // NEW lines from here...
                  final snackBar = SnackBar(
                    content: Text('Deletion is not implemented yet'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
              );
            },
          );
          final divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();

          return Scaffold(
            appBar: AppBar(
              title: Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        }, // ...to here.
      ),
    );
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
                builder: (context, snapshot){
                  final user = FirebaseAuth.instance.currentUser;
                  final authRep = AuthRepository.instance();
                  if (snapshot.hasData){
                    if(!authRep.isAuthenticated){
                      final snackBar = SnackBar(
                        content: Text('Error with login info'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } else{
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
                            // final snackBar = SnackBar(
                            //   content: Text('Login is not implemented yet'),
                            // );
                            // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            AuthRepository.instance().signIn(emailController.text, passwordController.text);
                          },
                          child: Text('Log in'),
                          style: ButtonStyle(
                              backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.red),
                              minimumSize:
                              MaterialStateProperty.all<Size>(Size(300, 30)),
                              shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40.0),
                                  ))),
                        )
                      ],
                    ),
                  );
                }
              ),
            ),
          );
        }, // ...to here.
      ),
    );
  }

  void attemptLogin(String email, String password){
    AuthRepository.instance().signUp(email, password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Add from here...
      appBar: AppBar(
        title: Text('Startup Name Generator'),
        actions: [
          IconButton(icon: Icon(Icons.favorite), onPressed: _pushSaved),
          IconButton(icon: Icon(Icons.login), onPressed: _pushLogin),
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      // The itemBuilder callback is called once per suggested
      // word pairing, and places each suggestion into a ListTile
      // row. For even rows, the function adds a ListTile row for
      // the word pairing. For odd rows, the function adds a
      // Divider widget to visually separate the entries. Note that
      // the divider may be difficult to see on smaller devices.
      itemBuilder: (BuildContext _context, int i) {
        // Add a one-pixel-high divider widget before each row
        // in the ListView.
        if (i.isOdd) {
          return Divider(
            thickness: 2,
          );
        }

        // The syntax "i ~/ 2" divides i by 2 and returns an
        // integer result.
        // For example: 1, 2, 3, 4, 5 becomes 0, 1, 1, 2, 2.
        // This calculates the actual number of word pairings
        // in the ListView,minus the divider widgets.
        final int index = i ~/ 2;
        // If you've reached the end of the available word
        // pairings...
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);
      },
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
            _saved.remove(pair);
          } else {
            _saved.add(pair);
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
