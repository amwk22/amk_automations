
import 'dart:async';
import 'dart:convert';

import 'package:automation/helper/MyBehavior.dart';
import 'package:automation/helper/helper.dart';
import 'package:automation/helper/my_widgets.dart';
import 'package:automation/helper/prefereces.dart';
import 'package:automation/modals/AllUsers.dart';
import 'package:automation/modals/User.dart';
import 'package:automation/screens/register_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import '../helper/urls.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {


  // Loader helps to show loading dialog when API hit
  SimpleFontelicoProgressDialog ?_dialog;


  // text controllers to get text from text fields
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // hide and show password
  bool toggleVisibility = true;

  double animatedSize = 80;

  AnimationController? animation;
  Animation<double>? _fadeInFadeOut;

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

    animatedSize = 250.0;

    super.initState();

    data();
    animation = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
    _fadeInFadeOut = Tween<double>(begin: 0.0, end: 1).animate(animation!);
    animation!.addStatusListener((status){
      if(status == AnimationStatus.completed){
        // animation!.reverse();
      }
      else if(status == AnimationStatus.dismissed){
        // animation!.forward();
      }
    });
    animation!.forward();


  }

  data(){
    setState(() {

      Timer.periodic(const Duration(milliseconds: 50), (timer) {
        setState(() {
          if(animatedSize < 280) {
            animatedSize = animatedSize + 1;
          }
        });
      });

    });
  }

  userLogin() async {

    showProgress();
    Response response;

    // Request
    try {
      Map<String, dynamic> userMap4 = {
        "email": emailController.text,
        "password": passwordController.text
      };
      print(json.encode(userMap4));
      print(UrlsFile.user);
      Dio dio =  Dio();
      response = await dio.post(UrlsFile.authLogin,
        data: userMap4,
      );

      // save access token
      String token = response.data['access_token'].toString();
      Helper.accessToken = token;
      Preferences().save("token", Helper.accessToken);

      print("token: "+Helper.accessToken);

      // to get users for login
      getUsers(emailController.text, token);

    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {

        // hide the dialog
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
        // internet error dialog when internet not connected
        Helper.showInternetError(context);
      }
    }

  }


  getUsers(String email, String token) async {

    List<AllUsers> allUsers = [];

    Response response;
    try {
      Dio dio =  Dio();
      response = await dio.get(UrlsFile.user,
        options: Options(
          headers: {
            "Authorization" : "Bearer $token"   // token
          }
        )
      );

      // save data into local list
      var creativeData = response.data as List;
      allUsers = creativeData
          .map<AllUsers>((json) => AllUsers.fromJson(json))
          .toList();

      // check the which user login
      for(int i = 0; i < allUsers.length; i++){
        if(allUsers[i].email == email){
          getUserById(token, allUsers[i].id.toString());
          break;
        }
      }

    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {

        _dialog!.hide();

        print("Hell!");
        print(e.response!.data);
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


  getUserById(String token, String id) async {

    User? myUser;
    Response response;

    try {
      Dio dio =  Dio();
      response = await dio.get("${UrlsFile.user}/$id",
          options: Options(
              headers: {
                "Authorization" : "Bearer $token"
              }
          )
      );

      // hide the dialog
      _dialog!.hide();

      // save data to preference
      var rest = response.data;
      myUser = User.fromJson(rest);
      Preferences().save('user', myUser);


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
      extendBody: true,
      backgroundColor: Helper.scaffoldColor,
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        height: 50,
        color: Colors.transparent,
        child: GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
          },
          child: Center(
            child: Text.rich(
              TextSpan(
                text: "Don't have an account? ",
                style: TextStyle(color: Colors.grey.shade700),
                children: [
                  TextSpan(
                    text: "Sign up",
                    style:  TextStyle(color: Helper.primaryColor, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 50),




                  SizedBox(
                    height: 300,
                    child: FadeTransition(
                      opacity: _fadeInFadeOut!,
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                           width: animatedSize,
                          // color: Colors.grey.shade400,
                          alignment: Alignment.center,
                          child: Image.asset("assets/images/logo.png"),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),


                  MyWidgets.text("Welcome Back!", 24, Colors.black, FontWeight.w500),


                  const SizedBox(height: 8),

                  MyWidgets.text("We happy to see you here again. enter your email address and password", 13, Colors.grey.shade700, FontWeight.w400),


                  const SizedBox(height: 50),


                  // Email Controller
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Email", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailController,
                        style: TextStyle(color: Colors.black),
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

                  const SizedBox(height: 30),

                  // Password Controller
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Password", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black)),
                      const SizedBox(height: 8),
                      TextField(
                        obscureText: toggleVisibility,
                        controller: passwordController,
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
                                ? const Icon(
                              Icons.visibility_off,
                              color: Colors.black,
                            )
                                : const Icon(
                              Icons.visibility,
                              color: Colors.black,
                            ),
                          ),

                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 50),

                  // Login Button to hit API
                  GestureDetector(
                    onTap: (){
                      if(emailController.text.isNotEmpty && passwordController.text.isNotEmpty){
                        if(emailController.text.contains("@")){
                          userLogin();
                        } else{
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
                          child: MyWidgets.text("Log In", 16, Colors.white, FontWeight.w600),
                        )
                    ),
                  ),

                  const SizedBox(height: 30),


                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
