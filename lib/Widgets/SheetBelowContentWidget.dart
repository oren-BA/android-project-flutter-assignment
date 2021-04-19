import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class SheetBelowContentWidget extends StatefulWidget {
  @override
  _SheetBelowContentWidgetState createState() =>
      _SheetBelowContentWidgetState();
}

class _SheetBelowContentWidgetState extends State<SheetBelowContentWidget> {
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
        padding: const EdgeInsets.fromLTRB(15, 15, 10, 10),
        child: Row(
          children: [
            (imageUrl != "")
                ? CircleAvatar(
                    maxRadius: 45,
                    backgroundImage: NetworkImage(imageUrl),
                    backgroundColor: Colors.grey[300],
                  )
                : CircleAvatar(
                    maxRadius: 45,
                    backgroundColor: Colors.grey[300],
                  ),
            SizedBox(
              width: 10,
            ),
            SingleChildScrollView(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(user!.email!, style: TextStyle(fontSize: 22)),
                  SizedBox(height: 7,),
                  ElevatedButton(
                      child: Text("Change Avatar"),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.green[700]!),
                        minimumSize: MaterialStateProperty.all<Size>(Size(140, 27)),
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
    PickedFile? image;
    await Permission.photos.request();
    var permissionStatus = await Permission.photos.status;
    if (permissionStatus.isGranted) {
      image = await _picker.getImage(source: ImageSource.gallery);
      if (image != null) {
        var file = File(image.path);
        TaskSnapshot uploadTask = await _storage
            .ref()
            .child("userAvatars/" + user!.uid)
            .putFile(file); //TODO: change names
        String url = await uploadTask.ref.getDownloadURL();
        //TODO: update url in user doc
        setState(() {
          imageUrl = url;
        });
      } else {
        final snackBar = SnackBar(
          content: Text('No image selected'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
      print("error");
    }
  }

  found(String url) {
    imageUrl = url;
  }

  notFound(error) async {
    final ref = _storage.ref().child("userAvatars/defaultAvatar.jpeg");
    imageUrl = await ref.getDownloadURL();
    setState(() {});
  }
}
