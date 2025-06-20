import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class Helper {

    /// Colors
    static const Color primaryColor = Color(0xff6A89a7);
    static const Color scaffoldColor = Colors.white;


    static const Color yellowLightColor = Color(0xFFFDF5E6);
    static const Color redDarkColor = Color(0xFF2B0100);
    static const Color redColor = Color(0xFFD90404);
    static const Color greyColor = Color(0xFF707070);
    static const Color greenColor = Color(0xFF03A60F);
    static const Color greenLightColor = Color(0xFFE5F6E7);
    static const Color blueColor = Color(0xFF307AFF);


    static String accessToken = "";
    static double currentLimit = 0.0;
    static double currentConsumed = 0.0;


    /// Toast
    static showToast(String text){
      return Fluttertoast.showToast(
          msg: text,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey[400],
          textColor: Colors.black,
          fontSize: 14.0);
    }


    // show internet error dialog
    static showInternetError(context){
      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: const Text("Error"),
        content: const Text("Something went wrong."),
        actions: [
          TextButton(
            child: Text("ok".toUpperCase(),
                style: const TextStyle(
                    color: Helper.primaryColor, fontWeight: FontWeight.w500)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );
      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }


    /// Gradient Bar
    static gradientBar(){
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [
                Helper.primaryColor,
                Helper.primaryColor,
              ],
              begin:  FractionalOffset(0.0, 0.0),
              end:  FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
        ),
      );
    }


    /// Others
    static noDataFoundWidget(String text){
      return Center(
        child: Text(text,
          style: TextStyle(
              fontSize: 13.5,
              color: Colors.grey[600]
          ),
        ),
      );
    }

}