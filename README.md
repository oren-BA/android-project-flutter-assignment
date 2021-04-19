# dry questions

1) the class of the controller is SnappingSheetController. 
   it allows various features like:
   - extracting information from the sheet such as currentPosition, currentSnappingPosition, currentlySnapping, isAttached. 
   - changing the state of the sheet like snapping it to a position, stopping the current snapping and set the snapping sheet position. 
   - listening to changes of the sheet and acting on it - onSheetMoved (the one i used to blur the background widget), onSnapCompleted, onSnapStart.
    
2) s

3) advantage of InkWell: InkWell provides an "ink splash" animation where the user has tapped, indicating the user that the tap has been registered.
   advantage of GestureDetector: GestureDetector provides a much broader variety of Gestures than InkWell such as "onForcePress" and "onLongPress" which allows        better control on our app
