import 'dart:convert';

import 'package:automation/modals/User.dart';
import 'package:automation/screens/dashboard_screen.dart';
import 'package:automation/screens/login_screen.dart';
import 'package:automation/screens/pending_requests_screen.dart';
import 'package:automation/screens/plugs_screen.dart';
import 'package:automation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import '../helper/helper.dart';
import '../helper/prefereces.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({Key? key}) : super(key: key);

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {

  User? userLoad;
  SimpleFontelicoProgressDialog ?_dialog;


  loadSharedPrefs() async {
    try {
      User userDetails = User.fromJson(await Preferences().read("user"));
      setState(() {
        userLoad = userDetails;
      });
    } catch (e) {}
  }

  void showProgress() {
    _dialog!.show(message: "Please wait...", indicatorColor: Helper.primaryColor);
  }

  void dialog(context) {
    _dialog = SimpleFontelicoProgressDialog(context: context, barrierDimisable:  false);
  }


  @override
  void initState() {
    dialog(context);
    loadSharedPrefs();
    super.initState();
  }


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


  Future<void> _logoutAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.w400),),
          content: const Text("Do you want to Logout?"),
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
                removeSharedPrefs();

                // ignore: use_build_context_synchronously
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                      (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(
                height: MediaQuery.of(context).size.height / 3.7,
                width: MediaQuery.of(context).size.width,
                child: DrawerHeader(
                  padding: EdgeInsets.zero,
                  decoration: const BoxDecoration(
                    color: Helper.primaryColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Container(
                          height: 150,
                          alignment: Alignment.center,
                          child: Image.asset("assets/images/logo.png"),
                        ),

                      ],
                    ),
                  ),
                ),
              ),

              Column(
                children: [

                  ListTile(
                    leading: Image.asset("assets/images/home.png",
                      height: 21,
                      width: 21,
                    ),
                    title: Transform.translate(
                      offset: const Offset(-1, 0),
                      child: const Text(
                        'Home',
                        style: TextStyle(fontSize: 14.0, color: Colors.black, fontWeight: FontWeight.w400),
                      ),
                    ),
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const DashboardScreen()),
                            (Route<dynamic> route) => false,
                      );
                    },
                  ),

                  ListTile(
                    leading: Image.asset("assets/images/plug.png",
                      height: 21,
                      width: 21,
                    ),
                    title: Transform.translate(
                      offset: const Offset(-1, 0),
                      child: const Text(
                        'My Plugs',
                        style: TextStyle(fontSize: 14.0, color: Colors.black, fontWeight: FontWeight.w400),
                      ),
                    ),
                    onTap: () {
                      // Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PlugsScreen()));
                    },
                  ),

                  ListTile(
                    leading: Image.asset("assets/images/docs.png",
                      height: 21,
                      width: 21,
                    ),
                    title: Transform.translate(
                      offset: const Offset(-1, 0),
                      child: const Text(
                        'Pending Requests',
                        style: TextStyle(fontSize: 14.0, color: Colors.black, fontWeight: FontWeight.w400),
                      ),
                    ),
                    onTap: () {
                      // Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PendingRequestsScreen()));
                    },
                  ),
                  ListTile(
                    leading: Image.asset("assets/images/settings.png",
                      height: 21,
                      width: 21,
                    ),
                    title: Transform.translate(
                      offset: const Offset(-1, 0),
                      child: const Text(
                        'Settings',
                        style: TextStyle(fontSize: 14.0, color: Colors.black, fontWeight: FontWeight.w400),
                      ),
                    ),
                    onTap: () {
                      // Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
                    },
                  ),

                  ListTile(
                    leading: Image.asset("assets/images/exit.png",
                      height: 22,
                      width: 22,
                    ),
                    title: Transform.translate(
                      offset: const Offset(-1, 0),
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(fontSize: 14.0, color: Colors.black),
                      ),
                    ),
                    onTap: () {
                      _logoutAlert(context);
                    },
                  ),

                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
