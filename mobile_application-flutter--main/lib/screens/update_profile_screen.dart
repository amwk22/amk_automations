import 'dart:convert';

import 'package:dio/dio.dart' show Dio, DioException, DioExceptionType, Options, Response;
import 'package:flutter/material.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import '../helper/helper.dart';
import '../helper/prefereces.dart';
import '../helper/urls.dart';
import '../modals/User.dart' show User;
import 'dashboard_screen.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {



  User ?userLoad;
  String token = "";
  SimpleFontelicoProgressDialog? _dialog;

  bool oldPasswordVisible = true;
  bool newPasswordVisible = true;
  bool conPasswordVisible = true;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();


  loadSharedPrefs() async {
    try {
      User userDetails = User.fromJson(await Preferences().read("user"));
      setState(() {
        userLoad = userDetails;
        nameController.text = userLoad!.username!;
        emailController.text = userLoad!.email!;
      });
    } catch (e) {
      // do something
    }
  }

  loadTokenPrefs() async {
    try {
      String tt = await Preferences().read("token");
      setState(() {
        token = tt;
      });
    } catch (e) {
      // do something
    }
  }

  @override
  void initState() {
    dialog(context);
    loadTokenPrefs();
    loadSharedPrefs();
    super.initState();
  }



  void dialog(context) {
    _dialog = SimpleFontelicoProgressDialog(context: context, barrierDimisable:  false);
  }

  void showProgress(){
    setState(() {
      _dialog!.show(message: "Please wait...", indicatorColor: Helper.primaryColor);
    });
  }

  headingWidget(String text){
    return Container(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(text,
        style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600]
        ),
      ),
    );
  }



  updateUser() async {

    User? myUser;
    Response response;

    Map<String, dynamic> userMap4 = {
      "username": nameController.text,
      "email": emailController.text,
      "password": userLoad!.passwordHash,
      "role": userLoad!.role
    };

    try {
      Dio dio =  Dio();
      response = await dio.patch("${UrlsFile.user}/${userLoad!.id}", data: userMap4,
          options: Options(
              headers: {
                "Authorization" : "Bearer $token"
              }
          )
      );

      // hide the dialog
      _dialog!.hide();

      print("response Data");
      print(json.encode(response.data));

      // save data to preference
      var rest = response.data;
      myUser = User.fromJson(rest);
      Preferences().save('user', myUser);


      Helper.showToast("Profile Updated Successfully");

      // navigate the user to dashboard
      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => DashboardScreen()),
            (Route<dynamic> route) => false,
      );


    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {

        // hide dialog
        _dialog!.hide();

        var message;
        message = e.response!.data['message'];

        // set up the AlertDialog
        AlertDialog alert = AlertDialog(
          title: Text("Error"),
          content: Text(message.toString().replaceAll("[", "").replaceAll("]", "")),
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
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          },
        );

      } else if (e.type == DioExceptionType.connectionError) {
        Helper.showInternetError(context);
      }
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Profile"),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF7FAFC),
              Color(0xFFE3EDF7),
              Color(0xFFDFEBF6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [


                headingWidget("Username"),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "",
                    hintStyle: TextStyle(color: Colors.grey.shade700),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),

                const SizedBox(height: 15),
                headingWidget("Email"),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "",
                    hintStyle: TextStyle(color: Colors.grey.shade700),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),

                const SizedBox(height: 50),
                GestureDetector(
                  onTap: (){
                    updateUser();
                  },
                  child: SizedBox(
                    width: double.infinity,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          color: Helper.primaryColor,
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          "SAVE",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),



              ],
            ),
          ),
        ),
      ),
    );
  }
}
