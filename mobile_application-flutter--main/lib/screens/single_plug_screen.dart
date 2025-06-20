import 'dart:async';
import 'dart:convert';

import 'package:automation/helper/helper.dart' show Helper;
import 'package:automation/helper/listAnimation.dart' show WidgetANimator;
import 'package:automation/modals/EnergyLogs.dart';
import 'package:automation/modals/Plug.dart';
import 'package:automation/screens/schedule_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart' show SimpleFontelicoProgressDialog;
import 'package:web_socket_channel/web_socket_channel.dart' show WebSocketChannel;

import '../helper/urls.dart';

class SinglePlugScreen extends StatefulWidget {
  Plug? plug;
  SinglePlugScreen({super.key, required this.plug});

  @override
  State<SinglePlugScreen> createState() => _SinglePlugScreenState();
}

class _SinglePlugScreenState extends State<SinglePlugScreen> {

  Plug? myPlug;
  EnergyLogs? energyLog;
  bool isLoading = true;

  SimpleFontelicoProgressDialog ?_dialog;

  bool plugStatus = false;

  String power = "0";
  String voltage = "0";
  String current = "0";
  String relay = "0FF";
  String energy = "0";

  WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse(UrlsFile.socketWebUrl),
  );

  void dialog(context) {
    _dialog = SimpleFontelicoProgressDialog(context: context, barrierDimisable:  false);
  }


  void showProgress(){
    setState(() {
      _dialog!.show(message: "Please wait...", indicatorColor: Helper.primaryColor);
    });
  }



  getSmartPlugsById() async {
    Response response;
    try {
      Dio dio =  Dio();
      response = await dio.get("${UrlsFile.smartPlus}/${widget.plug!.id}", options: Options(
          headers: {
            "Authorization" : "Bearer ${Helper.accessToken}"   // token
          }
      ));
      setState(() {
        var rest = response.data;
        myPlug = Plug.fromJson(rest);
        getEnergyLogs();
      });
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {
        print("Bad Response");
        isLoading = false;
      } else if (e.type == DioExceptionType.connectionError) {
        print('No internet connection');
        isLoading = false;
      }
    }
    setState(() {});
  }



  updateSmartPlugs(Plug plug) async {
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

      Dio dio =  Dio();
      response = await dio.patch("${UrlsFile.smartPlus}/${plug.id}", data: userMap4, options: Options(
          headers: {
            "Authorization" : "Bearer ${Helper.accessToken}"   // token
          }
      ));
      setState(() {
        _dialog!.hide();
        getSmartPlugsById();
      });
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {
        _dialog!.hide();
        print("Bad Response");
      } else if (e.type == DioExceptionType.connectionError) {
        _dialog!.hide();
        print('No internet connection');
      }
    }
    setState(() {});
  }


  deleteSmartPlugs(Plug plug) async {
    showProgress();
    Response response;
    try {
      Dio dio =  Dio();
      response = await dio.delete("${UrlsFile.smartPlus}/${plug.id}");
      setState(() {
        _dialog!.hide();
        Navigator.pop(context);
      });
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {
        _dialog!.hide();
        print("Bad Response");
      } else if (e.type == DioExceptionType.connectionError) {
        _dialog!.hide();
        print('No internet connection');
      }
    }
    setState(() {});
  }




  getEnergyLogs() async {

    Response response;
    List<EnergyLogs> sheet = [];

    try {
      Dio dio =  Dio();
      response = await dio.get(UrlsFile.energylogs);

      var creativeData = response.data as List;
      sheet = creativeData
          .map<EnergyLogs>((json) => EnergyLogs.fromJson(json))
          .toList();

      setState(() {
        isLoading = false;

        for(int i = 0; i < sheet.length; i++){
          if(sheet[i].plugID!.id == myPlug!.id){
            energyLog = sheet[i];
          }
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


  @override
  void initState() {
    dialog(context);
    getSmartPlugsById();
    super.initState();
  }


  sendRequest(Plug plug, String command){
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
    channel.sink.add(json.encode(userMap));
    Timer(Duration(seconds: 4), (){
      _dialog!.hide();
      setState(() {});
    });
  }



  @override
  void dispose() {
    // channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        actions: isLoading ? [] : [

          if(myPlug != null)
          GestureDetector(
            onTap: (){
              _deleteAlert(context);
            },
            child: Icon(Icons.delete)
          ),

          const SizedBox(width: 10)

        ],
      ),
      bottomNavigationBar: isLoading ? null : BottomAppBar(
        elevation: 0,
        height: 80,
        color: Color(0xFFDFEBF6),
        padding: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => ScheduleScreen(
                myPlug: myPlug!,
              )));
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Helper.primaryColor,
                borderRadius: BorderRadius.circular(12)
              ),
              child: Text("Schedule",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white
                ),
              ),
            ),
          ),
        ),
      ),
      body:  SingleChildScrollView(
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
          child: isLoading ? Center(child: CircularProgressIndicator()) : Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [





                StreamBuilder(
                  stream: channel.stream,
                  builder: (context, snapshot) {


                    if(snapshot.data != null) {
                      var convertedData = json.decode(snapshot.data);
                      if (convertedData != null) {
                        if (convertedData['data'] != null) {
                          if(convertedData['source'] == widget.plug!.zigbeeAddress) {
                            current =
                                convertedData['data']['current'].toString();
                            power = convertedData['data']['power'].toString();
                            voltage =
                                convertedData['data']['voltage'].toString();
                            energy = convertedData['data']['energy'].toString();
                            relay = convertedData['data']['relay'].toString();

                            if(relay == "OFF"){
                              plugStatus = false;
                            } else {
                              plugStatus = true;
                            }

                            // if(!mounted){
                            //   setState(() {});
                            // }

                          }
                        }
                      }
                    }

                    return  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [


                        GestureDetector(
                          onTap: (){
                            String command = "";
                            if(relay == "ON"){
                              command = "OFF";
                            } else {
                              command = "ON";
                            }
                            sendRequest(widget.plug!, command);
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                color: Color(0xFFf5f8f9),
                                border: Border.all(color: plugStatus ? Colors.green  :
                                Colors.grey.shade300
                                ),
                                boxShadow: [
                                  plugStatus ?
                                  BoxShadow(color: Colors.green, blurRadius: 10)
                                      :   BoxShadow(color: Colors.black12, blurRadius: 5),
                                ],
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Text(myPlug!.name!,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600
                                    ),
                                  ),

                                  SizedBox(height: 5),

                                  Text("Last Active Time: ${DateFormat('dd MMM yyyy hh:mm a').format(DateTime.parse(myPlug!.updatedAt!))}",
                                    style: TextStyle(
                                        fontSize: 13.5,
                                        fontStyle: FontStyle.italic
                                    ),
                                  ),

                                  SizedBox(height: 8),

                                ],
                              ),
                            ),
                          ),
                        ),


                        const SizedBox(height: 40),

                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 0.5,
                          color: Colors.grey.shade400,
                        ),

                        const SizedBox(height: 30),


                        Text("Energy Logs",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600
                          ),
                        ),
                        Container(
                            width: 40,
                            height: 2,
                            color: Colors.grey.shade700
                        ),



                        const SizedBox(height: 30),


                        snapshot.hasData ? Column(
                          children: [

                            Row(
                              children: [
                                Expanded(
                                  child: WidgetANimator(myContainer(Color(0xFF6a89a7),"POWER", power)),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: WidgetANimator(myContainer(Color(0xFF517891), "CURRENT", current)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Expanded(
                                  child: WidgetANimator(myContainer(Color(0xFF7d99aa), "VOLTAGE", voltage)),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: WidgetANimator(myContainer(Color(0xFF93b1b5), "ENERGY CONSUMED", energy)),
                                ),
                              ],
                            ),
                          ],
                        ) : Padding(
                            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 4),
                            child:  Helper.noDataFoundWidget("Energy log not found")
                        ),


                      ],
                    );
                  },
                ),









              ],
            ),
          ),
        ),
      ),
    );
  }

  myContainer(Color color,String title, String value){
    return Container(
      height: 120,
      decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 5),
          ],
          borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          SizedBox(height: 10),

          Expanded(
            child: Container(
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(value,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 40
                    ),
                  ),
                ],
              ),
            ),
          ),


          Text(title,
            style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              fontWeight: FontWeight.w500
            ),
          ),

          SizedBox(height: 10)

        ],
      ),
    );
  }


  Future<void> _deleteAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete", style: TextStyle(fontWeight: FontWeight.w400),),
          content: const Text("Do you want to Delete?"),
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
                deleteSmartPlugs(myPlug!);
              },
            ),
          ],
        );
      },
    );
  }

}
