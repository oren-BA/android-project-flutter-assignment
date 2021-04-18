import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hello_me/Provider/auth_repository.dart';
import 'package:hello_me/Widgets/suggestionsListWidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
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

class SheetBelowContentWidget extends StatefulWidget {
  @override
  _SheetBelowContentWidgetState createState() =>
      _SheetBelowContentWidgetState();
}

class _SheetBelowContentWidgetState extends State<SheetBelowContentWidget> {
  // String imageUrl = "https://firebasestorage.googleapis.com/v0/b/hellome-2396f.appspot.com/o/userAvatars%2FdefaultAvatar.jpeg?alt=media&token=5d029a03-b38f-4b21-ab79-0b64bf89b5f6";
  String imageUrl = "";
  final user = FirebaseAuth.instance.currentUser;
  final _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
     imageUrl = "";
    _storage
        .ref()
        .child("userAvatars/" + user!.uid)
        .getDownloadURL()
        .then(found, onError: notFound);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 10, 10, 15),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (imageUrl != "")
                ? CircleAvatar(
                    maxRadius: 45,
                    backgroundImage: NetworkImage(imageUrl),
                  )
                : Placeholder(
                    fallbackWidth: 50,
                    fallbackHeight: 50,
                  ),
            SizedBox(
              width: 10,
            ),
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(user!.email!, style: TextStyle(fontSize: 22)),
                  ElevatedButton(
                      child: Text("Change Avatar"),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.green),
                        // minimumSize:
                        //     MaterialStateProperty.all<Size>(Size(120, 25)),
                        // shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        //     RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(40.0),
                        //     ))
                      ),
                      onPressed: () => uploadImage()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  uploadImage() async {
    final _picker = ImagePicker();
    PickedFile image;
    await Permission.photos.request();
    var permissionStatus = await Permission.photos.status;
    if (permissionStatus.isGranted) {
      image = (await _picker.getImage(source: ImageSource.gallery))!;
      var file = File(image.path);

      if (image != null) {
        TaskSnapshot uploadTask = await _storage
            .ref()
            .child("userAvatars/" + user!.uid)
            // .child("defaultAvatar")
            .putFile(file); //TODO: change names
        String url = await uploadTask.ref.getDownloadURL();
        //TODO: update url in user doc
        setState(() {
          imageUrl = url;
        });
      } else {
        print("no path");
      }
    } else {
      print("error");
    }
  }

  found(String url) {
    imageUrl = url;
  }

  notFound(error) async {
    final ref = await _storage.ref().child("userAvatars/defaultAvatar.jpeg");
    imageUrl = await ref.getDownloadURL();
    setState(() {

    });
  }
}

//
// class SheetBelowContentWidget extends StatelessWidget{
//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null){
//       throw Exception();
//     }
//     return Row(
//       children: [
//         CircleAvatar(),
//         Column(
//           children: [
//             Text(user.email!),
//             FloatingActionButton(
//                 child: Text("Change Avatar"),
//                 backgroundColor: Colors.green,
//                 onPressed: () {}),
//           ],
//         )
//       ],
//     );
//   }
//
//   uploadImage() async{
//     final _storage = FirebaseStorage.instance;
//     final _picker = ImagePicker();
//     PickedFile image;
//     await Permission.photos.request();
//     var permissionStatus = await Permission.photos.status;
//     if (permissionStatus.isGranted){
//      image = (await _picker.getImage(source: ImageSource.gallery))!;
//      var file = File(image.path);
//
//      if (image != null){
//        TaskSnapshot uploadTask = await _storage.ref().child("folderName/imageName").putFile(file); //TODO: change names
//        String url = await uploadTask.ref.getDownloadURL();
//        //TODO: update url in user doc
//      } else{
//        print("no path");
//      }
//     }else{
//       print("error");
//     }
//   }
// }
