import 'dart:convert';

import 'package:automation/helper/helper.dart';
import 'package:automation/modals/User.dart';
import 'package:automation/screens/dashboard_screen.dart';
import 'package:automation/screens/login_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import '../helper/MyBehavior.dart';
import '../helper/my_widgets.dart';
import '../helper/prefereces.dart';
import '../helper/urls.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {


  // for loader
  SimpleFontelicoProgressDialog ?_dialog;

  // hide and show password
  bool toggleVisibility = true;


  // text controllers
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  // key to open drawer
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  var selectUserType;

  List<String> userTypes = [
    'Admin',
    'User'
  ];


  void dialog(context) {
    _dialog = SimpleFontelicoProgressDialog(context: context, barrierDimisable:  false);
  }


  void showProgress(){
    setState(() {
      _dialog!.show(message: "Please wait...", indicatorColor: Helper.primaryColor);
    });
  }

  @override
  void initState() {
    dialog(context);
    super.initState();
  }


  // To Create new User
  registerUser() async {

    User? myUser;
    Response response;

    try {
      Map<String, dynamic> userMap4 = {
        "username": userNameController.text,
        "email": emailController.text,
        "password": passController.text,
        "role": selectUserType.toString().toLowerCase()
      };
      print(json.encode(userMap4));
      print(UrlsFile.user);
      Dio dio =  Dio();
      response = await dio.post(UrlsFile.user,
        data: userMap4,
      );
      Helper.showToast("User Added Successfully");

      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false,
      );

    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {

        _dialog!.hide();

        print("Hell!");
        print(e.response!.data);

        var message;
        message = e.response!.data['message'];

        // set up the AlertDialog
        AlertDialog alert = AlertDialog(
          title: const Text("Error"),
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
        print('No internet connection');
      }
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Helper.scaffoldColor,
      appBar: AppBar(

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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ScrollConfiguration(
            behavior: MyBehavior(),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 40),


                    MyWidgets.text("Get Started Now", 24, Colors.black, FontWeight.w500),


                    const SizedBox(height: 8),

                    MyWidgets.text("Create an account or log in to explore\nabout our app", 13, Colors.grey.shade700, FontWeight.w400),


                    SizedBox(height: MediaQuery.of(context).size.height / 10),


                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Username", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black)),
                        const SizedBox(height: 8),
                        TextField(
                          style: TextStyle(color: Colors.black),
                          controller: userNameController,
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            hintText: "Username",
                            hintStyle: TextStyle(color: Colors.grey.shade700),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ),

                    // MyWidgets.buildTextField(label: "Username", hintText: "Username"),

                    const SizedBox(height: 30),



                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Email", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black)),
                        const SizedBox(height: 8),
                        TextField(
                          style: TextStyle(color: Colors.black),
                          controller: emailController,
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            hintText: "Email Address",
                            hintStyle: TextStyle(color: Colors.grey.shade700),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ),

                    // MyWidgets.buildTextField(label: "Email", hintText: "Email Address"),


                    const SizedBox(height: 30),


                    const Text(
                      "Select Role",
                      style: TextStyle(
                          color: Colors.black
                      ),
                    ),
                    const SizedBox(height: 12 * 0.3),


                    SizedBox(
                      height: 50,
                      child: FormField<String>(builder: (FormFieldState<String>state) {
                        return InputDecorator(
                            decoration: InputDecoration(
                              // filled: true,
                              // hintStyle: TextStyle(color: Color(0xFFC0C0C0)),
                              contentPadding: const EdgeInsets.only(left: 5),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(Radius.circular(12)),
                                borderSide: BorderSide(color: Colors.grey.shade700),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(Radius.circular(12)),
                                borderSide: BorderSide(color: Colors.grey.shade700),
                              ),
                            ),
                            isEmpty: selectUserType == '',
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                items: userTypes.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value!,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  );
                                }).toList(),
                                value: selectUserType,
                                onChanged: (newValue) {
                                  setState(() {
                                    selectUserType =
                                    newValue!;state.didChange(newValue);
                                  });
                                },
                              ),
                            ));
                      }),
                    ),


                    const SizedBox(height: 30),


                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Password", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: passController,
                          obscureText: toggleVisibility,
                          style: TextStyle(color: Colors.black),
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            hintText: "••••••••",
                            hintStyle: TextStyle(color: Colors.grey.shade700),

                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  toggleVisibility = !toggleVisibility;
                                });
                              },
                              icon: toggleVisibility
                                  ? Icon(
                                Icons.visibility_off,
                                color: Colors.grey.shade700,
                              )
                                  : Icon(
                                Icons.visibility,
                                color: Colors.grey.shade700,
                              ),
                            ),

                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color:  Colors.grey.shade700)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),


                    GestureDetector(
                      onTap: (){

                        if(userNameController.text.isNotEmpty || emailController.text.isNotEmpty || selectUserType != null || passController.text.isNotEmpty){

                          if(emailController.text.contains("@") == true) {
                            showProgress();
                            registerUser();
                          } else {
                            Helper.showToast("Enter valid email");
                          }

                        } else {

                          Helper.showToast("Fill all the fields");

                        }
                      },
                      child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Helper.primaryColor,
                              borderRadius: BorderRadius.circular(30)
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(top: 12, bottom: 12),
                            child: MyWidgets.text("Sign Up", 16, Colors.white, FontWeight.w600),
                          )
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
