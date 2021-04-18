import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hello_me/Provider/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


void removeItem(Set<WordPair> saved, WordPair pair) {
  final authRep = AuthRepository.instance();
  final user = FirebaseAuth.instance.currentUser;
  saved.remove(pair);
  if (authRep.isAuthenticated && user != null) {
    FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((element) async {
        sendToCloud(saved, element.id);
      });
    });
  }
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

Set<WordPair> combineData(Set<WordPair> saved, List data) {
  for (int i = 0; i < data.length; i++) {
    saved.add(WordPair(data[i]['first'], data[i]['second']));
  }
  return saved;
}


void addItem(Set<WordPair> saved, WordPair pair) {
  final authRep = AuthRepository.instance();
  final user = FirebaseAuth.instance.currentUser;
  saved.add(pair);
  if (authRep.isAuthenticated && user != null) {
    FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((element) async {
        sendToCloud(saved, element.id);
      });
    });
  }
}

