import 'package:automation/helper/helper.dart';
import 'package:automation/helper/urls.dart' show UrlsFile;
import 'package:automation/modals/User.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import '../helper/prefereces.dart';
import 'dashboard_screen.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {


  User ?userLoad;
  SimpleFontelicoProgressDialog? _dialog;

  bool oldPasswordVisible = true;
  bool newPasswordVisible = true;
  bool conPasswordVisible = true;

  TextEditingController oldPassController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();


  loadSharedPrefs() async {
    try {
      User userDetails = User.fromJson(await Preferences().read("user"));
      setState(() {
        userLoad = userDetails;
      });
    } catch (e) {
      // do something
    }
  }

  @override
  void initState() {
    dialog(context);
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




  changePassword() async {
    showProgress();
    Response response;
    try {
      Map<String, dynamic> userMap4 = {
        "oldPassword": oldPassController.text,
        "newPassword": newPassController.text
      };

      Dio dio =  Dio();
      response = await dio.patch("${UrlsFile.user}/${userLoad!.id}/password", data: userMap4, options: Options(
          headers: {
            "Authorization" : "Bearer ${Helper.accessToken}"   // token
          }
      ));
      setState(() {
        _dialog!.hide();
        Helper.showToast("Password Changed Successfully");


        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => DashboardScreen()),
              (Route<dynamic> route) => false,
        );



      });
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
        title: Text("Change Password"),
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


                headingWidget("Old Password"),
                TextField(
                  controller: oldPassController,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: oldPasswordVisible,
                  decoration: InputDecoration(
                    hintText: "",
                    hintStyle: TextStyle(color: Colors.grey.shade700),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          oldPasswordVisible = !oldPasswordVisible;
                        });
                      },
                      icon: oldPasswordVisible
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

                const SizedBox(height: 15),
                headingWidget("New Password"),
                TextFormField(
                  controller: newPassController,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: newPasswordVisible,
                  decoration: InputDecoration(
                    hintText: "",
                    hintStyle: TextStyle(color: Colors.grey.shade700),

                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          newPasswordVisible = !newPasswordVisible;
                        });
                      },
                      icon: newPasswordVisible
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

                const SizedBox(height: 15),
                headingWidget("Confirm Password"),
                TextFormField(
                  controller: confirmPassController,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: conPasswordVisible,
                  decoration: InputDecoration(
                    hintText: "",
                    hintStyle: TextStyle(color: Colors.grey.shade700),

                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          conPasswordVisible = !conPasswordVisible;
                        });
                      },
                      icon: conPasswordVisible
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
                const SizedBox(height: 50),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: (){
                      if(oldPassController.text.isEmpty && newPassController.text.isEmpty && confirmPassController.text.isEmpty){
                        Helper.showToast("Fill All the Fields");
                      }  else  if(newPassController.text == confirmPassController.text){
                        changePassword();
                      } else{
                        Helper.showToast("Check New Password and Confirm Password");
                      }
                    },
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
