import 'dart:convert';

import 'package:automation/modals/Settings.dart';
import 'package:automation/modals/User.dart';
import 'package:automation/screens/change_password.dart';
import 'package:automation/screens/login_screen.dart';
import 'package:automation/screens/update_profile_screen.dart';
import 'package:dio/dio.dart' show Dio, DioException, DioExceptionType, Options, Response;
import 'package:flutter/material.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import '../helper/helper.dart';
import '../helper/prefereces.dart';
import '../helper/urls.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {


  User? userLoad;
  SimpleFontelicoProgressDialog ?_dialog;

  bool isLoading  = true;

  String current  = "0";

  TextEditingController currentController = TextEditingController();

  void dialog(context) {
    _dialog = SimpleFontelicoProgressDialog(context: context, barrierDimisable:  false);
  }


  void showProgress(){
    setState(() {
      _dialog!.show(message: "Please wait...", indicatorColor: Helper.primaryColor);
    });
  }


  loadSharedPrefs() async {
    try {
      User userDetails = User.fromJson(await Preferences().read("user"));
      setState(() {
        userLoad = userDetails;
      });
    } catch (e) {}
  }


  @override
  void initState() {
    getSettings();
    loadSharedPrefs();
    dialog(context);
    super.initState();
  }


  // Dialog to enter details of plug
  updateCurrentDialog(BuildContext context, String current){
    currentController.text = current;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            insetPadding: const EdgeInsets.all(40),
            shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(20)), //this right here
            child: Wrap( alignment: WrapAlignment.center,
              children: [

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text("Update Current Limit",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black
                        ),
                      ),
                      Container(
                        height: 2,
                        width: 30,
                        color: Colors.black,
                      ),

                      const SizedBox(height: 40),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Enter Current Value", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black)),
                          const SizedBox(height: 4),
                          TextField(
                            style: TextStyle(color: Colors.black),
                            controller: currentController,
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              hintText: "",
                              hintStyle: TextStyle(color: Colors.grey.shade700),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade700)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade700)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade700)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ],
                      ),




                      const SizedBox(height: 40),

                      GestureDetector(
                        onTap: (){
                          if(currentController.text.isNotEmpty){
                            Navigator.pop(context);
                            updateSettings(currentController.text);
                          } else {
                            Helper.showToast("Please Enter Current Limit");
                          }
                        },
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Helper.primaryColor,
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Text("SUBMIT",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                        ),
                      )

                    ],
                  ),
                )

              ],
            ),
          );
        });
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



        isLoading = false;

        var creativeData = response.data as List;
        sheet = creativeData
            .map<Settings>((json) => Settings.fromJson(json))
            .toList();

        for(int i = 0 ; i < sheet.length; i++){
          if(sheet[i].settingKey == "current_limit"){
            current = sheet[i].settingValue!;
            Helper.currentLimit = double.parse(sheet[i].settingValue!);
          }
        }


      });
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {
        _dialog!.hide();
        print("Bad Response: ${e.response}");
      } else if (e.type == DioExceptionType.connectionError) {
        _dialog!.hide();
        print('No internet connection');
      }
    }
    setState(() {});
  }

  updateSettings(String value) async {
    Response response;
    showProgress();
    try {
      Dio dio =  Dio();

      Map<String, dynamic> userMap4 = {
        "userId": userLoad!.id,
        "settingKey": 'current_limit',
        "settingValue": value
      };

      print(json.encode(userMap4));
      response = await dio.patch(UrlsFile.systemSettings+"/22", data: userMap4, options: Options(
          headers: {
            "Authorization" : "Bearer ${Helper.accessToken}"   // token
          }
      ));
      setState(() {
        _dialog!.hide();
        Helper.showToast("Current Limit Updated Successfully");
        getSettings();
      });
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {
        _dialog!.hide();
        print("Bad Response: ${e.response}");
      } else if (e.type == DioExceptionType.connectionError) {
        _dialog!.hide();
        print('No internet connection');
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
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
        child: isLoading ? Center(
          child: CircularProgressIndicator(),
        ) : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [


                GestureDetector(
                  onTap: (){
                    updateCurrentDialog(context, current);
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset("assets/images/flash.png",
                                height: 20,
                              ),
                              const SizedBox(width: 15),
                              Text("Current",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500
                                ),
                              )
                            ],
                          ),
                        ),
                        Text("${current}amp",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500
                          ),
                        )
                      ],
                    ),
                  ),
                ),


                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Container(
                    height: 1.2,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.grey.shade300,
                  ),
                ),


                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateProfileScreen()));
                  },
                  child: myWidget("user", "Update Profile"),
                ),


                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Container(
                    height: 1.2,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.grey.shade300,
                  ),
                ),

                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePassword()));
                  },
                  child: myWidget("padlock", "Change Password"),
                ),


                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Container(
                    height: 1.2,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.grey.shade300,
                  ),
                ),

                GestureDetector(
                  onTap: (){
                    _deleteAlert(context);
                  },
                  child: myWidget("delete", "Delete User"),
                ),



              ],
            ),
          ),
        ),
      ),
    );
  }


  myWidget(String icon, String title){
    return Row(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/images/$icon.png",
                height: 20,
              ),
              const SizedBox(width: 15),
              Text(title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500
                ),
              )
            ],
          ),
        ),
        Icon(Icons.arrow_forward_ios_rounded , size: 18)
      ],
    );
  }



  Future<void> _deleteAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete", style: TextStyle(fontWeight: FontWeight.w400),),
          content: const Text("Do you want to delete account?"),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Cancel".toUpperCase(),
                style: const TextStyle(color: Helper.primaryColor, fontWeight: FontWeight.w400),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                "OK",
                style: TextStyle(color: Helper.primaryColor, fontWeight: FontWeight.w400),
              ),
              onPressed: () {
                Navigator.pop(context);
                showProgress();
                deleteUser();
              },
            ),
          ],
        );
      },
    );
  }





  deleteUser() async {

    Response response;

    try {
      Dio dio =  Dio();
      response = await dio.delete("${UrlsFile.user}/${userLoad!.id}",
          options: Options(
              headers: {
                "Authorization" : "Bearer ${Helper.accessToken}"
              }
          )
      );

      // hide the dialog
      _dialog!.hide();

      print("response Data");
      print(json.encode(response.data));

      Helper.showToast("Account Deleted Successfully");

      removeSharedPrefs();

      // navigate the user to dashboard
      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => LoginScreen()),
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



  // Remove User From Preference
  removeSharedPrefs() async {
    User userLoad;
    try {
      User userDetails = User.fromJson(await Preferences().remove("user"));
      setState(() {
        userLoad = userDetails;
      });
    } catch (e) {}

    try {
      String dd = await Preferences().remove("token");
      setState(() {
      });
    } catch (e) {}

  }




}
