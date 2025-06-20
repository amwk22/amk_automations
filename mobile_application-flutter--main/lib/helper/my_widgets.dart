import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyWidgets {


  static text(String t, double size, Color color, FontWeight? fWeight){
    return Text(t,
      style: TextStyle(
          fontWeight: fWeight,
          fontSize: size,
          color: color
      ),
    );
  }


  static pTitleText(String t, double size, Color color, FontWeight? fWeight){
    return Text(t,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          fontWeight: fWeight,
          fontSize: size,
          color: color
      ),
    );
  }


  static Widget buildTextField({required String label, required String hintText, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black)),
        const SizedBox(height: 8),
        TextField(
          obscureText: isPassword,
          style: TextStyle(color: Colors.black),
          cursorColor: Colors.black,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade700),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  static cachedNetworkImage(String image, double height, double width){
    return CachedNetworkImage(
      imageUrl: image,
      imageBuilder: (context, imageProvider) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
              image: imageProvider, fit: BoxFit.fill),
        ),
      ),
      placeholder: (context, url) => SizedBox(
          width: width,
          height: height,
          child: Center(child: CircularProgressIndicator())),
      errorWidget: (context, url, error) => SizedBox(
          width: width,
          height: height,
          child: Center(child: const Icon(Icons.error))),
    );
  }


  static cachedNetworkAvatarImage(String image, double height, double width){
    return CachedNetworkImage(
      imageUrl: image,
      imageBuilder: (context, imageProvider) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
              image: imageProvider, fit: BoxFit.cover),
        ),
      ),
      placeholder: (context, url) => SizedBox(
          width: width,
          height: height,
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          )),
      errorWidget: (context, url, error) => SizedBox(
          width: width,
          height: height,
          child: const Icon(Icons.error)),
    );
  }

  static networkImageWithLoader(String image, double? height, double? weight, BoxFit? boxFit){
    return Image.network(image,
      height: height,
      width: weight,
      fit: boxFit,
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
    );
  }

  static myDivider(BuildContext context){
    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 25),
      child: Container(
        height: 0.8,
        width: MediaQuery.of(context).size.width,
        color: Colors.grey.shade300,
      ),
    );
  }

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

  static showValidationToast(BuildContext context){
    return Fluttertoast.showToast(
        msg: "Fill all the fields",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 14.0);
  }

}