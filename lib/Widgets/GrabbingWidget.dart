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

class GrabbingWidget extends StatelessWidget {
  var snappingSheetController;
  double xBlurVal;
  double yBlurVal;
  String grabText;

  GrabbingWidget(this.snappingSheetController, this.xBlurVal, this.yBlurVal, this.grabText);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
            sigmaX: xBlurVal, sigmaY: yBlurVal),
        child: Container(
            color: Colors.grey[350],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 5, 0, 10),
                  child: Text(grabText, style: TextStyle(fontSize: 17)),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Icon(Icons.keyboard_arrow_up),
                )
              ],
            )),
      ),
    );
  }
}
