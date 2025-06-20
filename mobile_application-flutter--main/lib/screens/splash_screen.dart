import 'dart:async';

import 'package:automation/helper/helper.dart';
import 'package:automation/helper/prefereces.dart' show Preferences;
import 'package:automation/modals/User.dart';
import 'package:automation/screens/dashboard_screen.dart';
import 'package:automation/screens/login_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../helper/urls.dart';
import '../modals/Settings.dart' show Settings;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  User? userLoad;



  loadSharedPrefs() async {
    // to get user data from preferences
    try {
      User userDetails = User.fromJson(await Preferences().read("user"));
      setState(() {
        userLoad = userDetails;
        loadTokenSharedPrefs();
      });
    } catch (e) {
      // do something
    }
  }



  loadTokenSharedPrefs() async {
    try {
      String token = await Preferences().read("token");
      setState(() {
        Helper.accessToken = token;
      });
    } catch (e) {
      // do something
    }
  }

  getSettings() async {
    Response response;
    List<Settings> sheet = [];
    try {
      Dio dio =  Dio();
      response = await dio.get(UrlsFile.systemSettings, options: Options(
          headers: {
            "Authorization" : "Bearer ${Helper.accessToken}"   // token
          }
      ));
      setState(() {
        var creativeData = response.data as List;
        sheet = creativeData
            .map<Settings>((json) => Settings.fromJson(json))
            .toList();

        for(int i = 0 ; i < sheet.length; i++){
          if(sheet[i].settingKey == "current_limit"){
            Helper.currentLimit = double.parse(sheet[i].settingValue!);
          }
        }
      });
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {
        print("Bad Response: ${e.response}");
      } else if (e.type == DioExceptionType.connectionError) {
        print('No internet connection');
      }
    }
    setState(() {});
  }


  @override
  void initState() {
    getSettings();

    loadSharedPrefs();

    // check if user is already login or not and redirect to particular screen
    Timer(
        const Duration(seconds: 3),
            () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => userLoad == null ? LoginScreen() : DashboardScreen()
          ));
        });

    super.initState();




  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Helper.scaffoldColor,
      body: Column(
        children: [

          Container(
            clipBehavior: Clip.antiAlias,
            height: MediaQuery.of(context).size.height / 1.6,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30)
              )
            ),
            child: Image.asset("assets/images/splash.jpg",
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 20),

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const SizedBox(height: 20),

              Text("Control Your Home\nEasily",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.black,
                  fontWeight: FontWeight.w600
                ),
              ),

              const SizedBox(height: 20),

              Text("Manage your home from anytime\nanywhere",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w400
                ),
              ),


              const SizedBox(height: 60),

              SizedBox(
                  width: 100,
                  child: LinearProgressIndicator(
                    borderRadius: BorderRadius.circular(10),
                  ))

            ],
          )
        ],
      ),
    );
  }
}
