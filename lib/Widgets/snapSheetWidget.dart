import 'dart:ui';

import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hello_me/Provider/auth_repository.dart';
import 'package:hello_me/Widgets/SheetBelowContentWidget.dart';
import 'package:hello_me/Widgets/suggestionsListWidget.dart';
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

class SnapSheetWidget extends StatefulWidget {
  List<WordPair> suggestions;
  var saved;
  double xBlurVal = 0;
  double yBlurVal = 0;

  SnapSheetWidget(this.suggestions, this.saved);

  @override
  _SnapSheetWidgetState createState() => _SnapSheetWidgetState();
}

class _SnapSheetWidgetState extends State<SnapSheetWidget> {
  final snappingSheetController = SnappingSheetController();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    String grabText = "Welcome back, ";
    if (user != null) {
      grabText += user.email!;
    }
    return SnappingSheet(
      // lockOverflowDrag: true,
      controller: snappingSheetController,
      child: SuggestionsListWidget(widget.suggestions, widget.saved),
      // child: Text("hello"),
      grabbing: GestureDetector(
        onTap: () {
          if (snappingSheetController.currentPosition == 30) {
            snappingSheetController.snapToPosition(
              SnappingPosition.pixels(positionPixels: 190),
            );
          } else {
            snappingSheetController.snapToPosition(
              SnappingPosition.pixels(positionPixels: 30),
            );
          }
        },
        child: BackdropFilter(
          filter: ImageFilter.blur(
              sigmaX: widget.xBlurVal, sigmaY: widget.yBlurVal),
          child: Container(
              color: Colors.grey[350],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 0, 10),
                    child: Text(grabText, style: TextStyle(fontSize: 17)),
                  ),
                  Icon(Icons.keyboard_arrow_up)
                ],
              )),
        ),
      ),
      initialSnappingPosition: SnappingPosition.pixels(positionPixels: 30),
      snappingPositions: [
        SnappingPosition.pixels(positionPixels: 30),
        SnappingPosition.pixels(positionPixels: 190),
      ],
      grabbingHeight: 65,
      sheetBelow: SnappingSheetContent(
          sizeBehavior: SheetSizeFill(),
          draggable: true,
          child: SheetBelowContentWidget()),
      onSheetMoved: (position) {
        widget.xBlurVal = (position - 30) / 15;
        widget.yBlurVal = (position - 30) / 15;
        setState(() {});
      },
    );
  }
}
