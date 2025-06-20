
import 'package:flutter/material.dart';

import 'dimensions.dart';
import 'helper.dart';


class CustomStyle {
  static var textStyle = TextStyle(
      color: Helper.greyColor,
      fontSize: Dimensions.defaultTextSize
  );


  static var textInspectionStyle = TextStyle(
      color: Colors.black,
      fontSize: Dimensions.defaultTextSize
  );

  static var hintTextStyle = TextStyle(
      color: Colors.grey.withOpacity(0.5),
      fontSize: Dimensions.defaultTextSize
  );

  static var listStyle = TextStyle(
      color: Helper.redDarkColor,
      fontSize: Dimensions.defaultTextSize
  );

  static var defaultStyle = TextStyle(
      color: Colors.black,
      fontSize: Dimensions.largeTextSize
  );

  static var focusBorder = OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
    borderSide: BorderSide(color: Colors.black.withOpacity(0.2), width: 1.5),
  );

  static var focusErrorBorder = OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
    borderSide: BorderSide(color: Colors.black.withOpacity(0.2), width: 1.5),
  );

  static var searchBox = OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
    borderSide: BorderSide(color: Colors.black.withOpacity(0.2), width: 1.5),
  );
}