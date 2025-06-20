import 'dart:async';
import 'dart:convert';

import 'package:automation/helper/helper.dart';
import 'package:automation/helper/listAnimation.dart' show WidgetANimator;
import 'package:automation/helper/prefereces.dart';
import 'package:automation/helper/urls.dart';
import 'package:automation/modals/Plug.dart';
import 'package:automation/modals/SocketValues.dart' show SocketValues;
import 'package:automation/modals/User.dart';
import 'package:automation/screens/drawer_screen.dart';
import 'package:automation/screens/pending_requests_screen.dart';
import 'package:automation/screens/single_plug_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart' show SimpleFontelicoProgressDialog;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;



class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  User? userLoad;
  String userName = "Guest";
  List<Plug> myPlugs = [];
  bool isLoading = true;

  List<SocketValues> currentValues = [];

  SimpleFontelicoProgressDialog ?_dialog;
  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key

  WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse(UrlsFile.socketWebUrl),
  );

  // text controllers
  TextEditingController addressController = TextEditingController();
  TextEditingController nameController = TextEditingController();


  // load user data
  loadSharedPrefs() async {
    try {
      User userDetails = User.fromJson(await Preferences().read("user"));
      setState(() {
        userLoad = userDetails;
        userName = userLoad!.username!;
      });
    } catch (e) {
      // do something
    }
  }

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
    loadSharedPrefs();
    getPlugs();
    super.initState();
  }



  @override
  void dispose() {
    super.dispose();
  }

  // send request to web socket
  sendRequest(Plug plug, String command, double current, int index) async {
    showProgress();
    channel = WebSocketChannel.connect(
      Uri.parse(UrlsFile.socketWebUrl),
    );
    Map<String, dynamic> userMap = {
      "event": "toggle-relay",
      "data": {
        "command": command,
        "address64": plug.zigbeeAddress
      }
    };
    await channel.ready;

    channel.sink.add(json.encode(userMap));

      Timer(Duration(seconds: 4), (){
        _dialog!.hide();

      });
      setState(() {

      });

  }


  // get all the plugs
  getPlugs() async {

    Response response;
    List<Plug> sheet = [];

    try {
      Dio dio =  Dio();
      response = await dio.get(UrlsFile.smartPlus, options: Options(
          headers: {
            "Authorization" : "Bearer ${Helper.accessToken}"   // token
          }
      ));

      var creativeData = response.data as List;
      sheet = creativeData
          .map<Plug>((json) => Plug.fromJson(json))
          .toList();

      setState(() {
        isLoading = false;
        myPlugs.clear();
        myPlugs.addAll(sheet);

        for(int i = 0; i < myPlugs.length; i++){
          currentValues.add(SocketValues(
            current: "0",
            source: myPlugs[i].zigbeeAddress,
            relay: "OFF",
            currentConsumed: 0.0
          ));
        }

      });

    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {
        isLoading = false;
        print("Bad Response");
      } else if (e.type == DioExceptionType.connectionError) {
        isLoading = false;
        print('No internet connection');
      }
    }
    setState(() {});
  }



  // turn on / off plug
  updateSmartPlugs(Plug plug) async {

    print("Address: ");
    print(plug.zigbeeAddress);

    showProgress();
    Response response;
    try {
        Map<String, dynamic> userMap4 = {
          "zigbeeAddress": plug.zigbeeAddress,
          "name": plug.name,
          "status": plug.status.toString() == "true" ? false : true,
          "estimatedAmps":plug.estimatedAmps,
          "userID": plug.users!.id
        };

        print(json.encode(plug.id));
        Dio dio =  Dio();
        response = await dio.patch("${UrlsFile.smartPlus}/${plug.id}", data: userMap4, options: Options(
            headers: {
              "Authorization" : "Bearer ${Helper.accessToken}"   // token
            }
        ));


      setState(() {
        Map<String, dynamic> userMap = {
          "event": "toggle-relay",
          "data": {
            "command":  plug.status.toString() == "true" ? "ON" : "OFF",
            "address64": plug.zigbeeAddress
          }
        };
        channel.sink.add(json.encode(userMap));

        _dialog!.hide();


        getPlugs();

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


  // create new plug
  createSmartPlugs() async {
    showProgress();
    Response response;
    try {

      Map<String, dynamic> userMap4 = {
        "zigbeeAddress": addressController.text,
        "name": nameController.text,
        "status": false,
        "estimatedAmps":1,
        "userID": userLoad!.id
      };
      print(json.encode(userMap4));
      Dio dio =  Dio();
      response = await dio.post(UrlsFile.smartPlus, data: userMap4, options: Options(
          headers: {
            "Authorization" : "Bearer ${Helper.accessToken}"   // token
          }
      ));
      setState(() {
        _dialog!.hide();
        Helper.showToast("Plug Added Successfully");
        getPlugs();
      });
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {

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
        _dialog!.hide();
        print('No internet connection');
      }
    }
    setState(() {});
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      backgroundColor: Helper.scaffoldColor,
      appBar: AppBar(
        title: Text("AMK Automations"),
        leading: Padding(
          padding: const EdgeInsets.all(16),
          child: GestureDetector(
            onTap: (){
              _key.currentState!.openDrawer();
            },
            child: Image.asset("assets/images/drawer.png",
              color: Colors.white,
            ),
          ),
        ),
        actions: [


        ],
      ),
      floatingActionButton: FloatingActionButton(  // show dialog to fill the data
        backgroundColor: Helper.primaryColor,
          child: Icon(Icons.add, color: Colors.white, size: 30),
          onPressed: () async {
            addPlugDialog(context);
          }
      ),
      drawer: DrawerScreen(), // Drawer
      onDrawerChanged: (v){
        setState(() {
          getPlugs(); // hit api for update the ui
        });
      },
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              isLoading ? SizedBox(
                  height: MediaQuery.of(context).size.height / 1.2,
                  child: Center(child: CircularProgressIndicator())) : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text("Hi $userName",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 24,
                            color: Colors.black,
                            fontWeight: FontWeight.w600
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text("Welcome to your smart home",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14.5,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w400
                        ),
                      ),

                      const SizedBox(height: 40),

                      StreamBuilder(
                          stream: channel.stream,
                          builder: (context, snapshot)  {
                            if(snapshot.data != null)  {
                              var convertedData1 = json.decode(snapshot.data);
                              if (convertedData1['data'] != null) {
                                if (convertedData1['data']['s'] == "Q") {

                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    _dialog!.hide();
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) =>
                                            PendingRequestsScreen()));
                                  });

                                }
                              }
                            }
                          return GridView.builder(
                            itemCount: myPlugs.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                              childAspectRatio: 1,
                            ),
                            itemBuilder: (context, index) {


                              if(snapshot.data != null) {
                                var convertedData = json.decode(snapshot.data);
                                if (convertedData != null) {
                                  if (convertedData['data'] != null) {




                                    if(currentValues[index].source == convertedData['source']){
                                      currentValues[index].relay = convertedData['data']['relay'].toString();
                                      currentValues[index].current = convertedData['data']['current'].toString();
                                      // if(currentValues[index].relay == "ON"){
                                      //   currentValues[index].currentConsumed = double.parse(convertedData['data']['current'].toString());
                                      //   // Helper.currentConsumed = Helper.currentConsumed + double.parse(convertedData['data']['current'].toString());
                                      // }
                                    }

                                  }
                                }
                              }


                              return WidgetANimator(
                                GestureDetector(
                                  onTap: (){
                                    // turn on / off plug
                                    // updateSmartPlugs(myPlugs[index]);



                                    // if(currentValues[index].relay == "ON"){
                                    //
                                    //   sendRequest(
                                    //       myPlugs[index],
                                    //       "OFF",
                                    //       double.parse(currentValues[index].current!),
                                    //       index
                                    //   );
                                    //
                                    // } else {
                                    //
                                    //   double consumed  = 0;
                                    //
                                    //   for(int i = 0; i < currentValues.length; i++){
                                    //     consumed = consumed + currentValues[i].currentConsumed!;
                                    //   }
                                    //
                                    //   double cLeft = Helper.currentLimit - consumed;
                                    //
                                    //   Helper.showToast(cLeft.toString());
                                    //
                                    //
                                    //   if(double.parse(currentValues[index].current!) < cLeft){
                                    //     sendRequest(myPlugs[index], "ON",
                                    //         double.parse(
                                    //             currentValues[index].current!), index);
                                    //   } else {
                                    //     Helper.showToast("Hit Api For Pending Request");
                                    //   }
                                    // }


                                    // double currentLeft = Helper.currentLimit - Helper.currentConsumed;
                                    //
                                    //
                                    // print("current: "+Helper.currentLimit.toString());
                                    // print("current: "+Helper.currentConsumed.toString());
                                    // print("current: "+currentLeft.toString());
                                    //
                                    // if(currentLeft > Helper.currentConsumed) {

                                      String command = "";

                                      if (currentValues[index].relay == "ON") {
                                        command = "OFF";
                                      } else {
                                        command = "ON";
                                      }

                                      sendRequest(myPlugs[index], command,
                                          double.parse(
                                              currentValues[index].current!), index);


                                    // } else {
                                    //   Helper.showToast("No Limit Left");
                                    // }


                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Color(0xFFf5f8f9),
                                        border: Border.all(
                                            color:  currentValues[index].relay == "ON" ? Colors.green  :
                                        Colors.grey.shade300
                                        ),
                                        boxShadow: [
                                          currentValues[index].relay == "ON" ?
                                          BoxShadow(color: Colors.green, blurRadius: 10)
                                              :   BoxShadow(color: Colors.black12, blurRadius: 5),
                                        ],
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [

                                          Text( myPlugs[index].name!,
                                            style: TextStyle(
                                                fontSize: 25,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600
                                            ),
                                          ),

                                          GestureDetector(
                                            onTap: () async {
                                              await Navigator.push(context, MaterialPageRoute(builder: (context) => SinglePlugScreen(plug: myPlugs[index])));
                                              setState(() {
                                                getPlugs();
                                              });
                                            },
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [

                                                Text("Energy",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                    fontSize: 15
                                                  ),
                                                ),

                                                Image.asset("assets/images/stats.png",
                                                  height: 30,
                                                )
                                              ],
                                            ),
                                          )

                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      )

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // Dialog to enter details of plug
  addPlugDialog(BuildContext context){
    nameController.text = "";
    addressController.text = "";
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

                      Text("ADD PLUG",
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
                          Text("Zigbee Address", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black)),
                          const SizedBox(height: 4),
                          TextField(
                            style: TextStyle(color: Colors.black),
                            controller: addressController,
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


                      const SizedBox(height: 20),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Name", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black)),
                          const SizedBox(height: 4),
                          TextField(
                            style: TextStyle(color: Colors.black),
                            controller: nameController,
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
                          if(addressController.text.isNotEmpty && nameController.text.isNotEmpty){
                            createSmartPlugs();
                            Navigator.pop(context);
                          } else {
                            Helper.showToast("Please Enter all the Fields");
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
}






