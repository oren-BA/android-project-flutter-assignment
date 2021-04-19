import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

class GrabbingWidget extends StatelessWidget {
  var snappingSheetController;
  double xBlurVal;
  double yBlurVal;
  String grabText;

  GrabbingWidget(this.snappingSheetController, this.xBlurVal, this.yBlurVal,
      this.grabText);

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
        filter: ImageFilter.blur(sigmaX: xBlurVal, sigmaY: yBlurVal),
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
