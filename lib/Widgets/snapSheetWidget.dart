import 'dart:ui';

import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hello_me/Provider/auth_repository.dart';
import 'package:hello_me/Widgets/GrabbingWidget.dart';
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
      grabbing: GrabbingWidget(
          snappingSheetController, widget.xBlurVal, widget.yBlurVal, grabText),
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
        widget.xBlurVal = (position - 30) / 25;
        widget.yBlurVal = (position - 30) / 25;
        setState(() {});
      },
    );
  }
}
