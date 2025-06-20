import 'dart:async';
import 'dart:convert';

import 'package:automation/helper/listAnimation.dart' show WidgetANimator;
import 'package:automation/screens/single_plug_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../helper/helper.dart';
import '../helper/prefereces.dart';
import '../helper/urls.dart';
import '../modals/Plug.dart';
import '../modals/SocketValues.dart';
import '../modals/User.dart';

class PlugsScreen extends StatefulWidget {
  const PlugsScreen({super.key});

  @override
  State<PlugsScreen> createState() => _PlugsScreenState();
}

class _PlugsScreenState extends State<PlugsScreen> {
  User? userLoad;
  String userName = "Guest";

  List<Plug> myPlugs = [];
  List<Plug> allPlugs = [];

  bool isLoading = true;


  // 0 - normal
  // 1 - ascending
  // 2 - descending
  int sortVal = 0;

  SimpleFontelicoProgressDialog ?_dialog;
  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key


  // text controllers
  TextEditingController addressController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController _searchQueryController = TextEditingController();


  bool _isSearching = false;
  String searchQuery = "Search query";

  int toggleIndex = 0;

  List<SocketValues> currentValues = [];
  List<SocketValues> allCurrentValues = [];

  WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse(UrlsFile.socketWebUrl),
  );



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
    channel.sink.close();
    super.dispose();
  }


  // send request to web socket
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
    });
  }


  // Search by name
  searchDate(String text){
    setState(() {
      myPlugs.clear();
      // currentValues.clear();

      for(int i = 0; i< allPlugs.length; i++){
        if(allPlugs[i].name!.toLowerCase().contains(text.toLowerCase())){
          // currentValues.add(SocketValues(
          //     source: allCurrentValues[i].source,
          //     current: allCurrentValues[i].current
          // ));
          myPlugs.add(allPlugs[i]);
        }

      }


      List<Plug> dd = [];
      List<SocketValues> dd1 = [];
      for(int i = 0;  i < myPlugs.length; i++){

        // print("Hello12: ${json.encode(myPlugs[i])}");
        // print("Hello34: ${json.encode(currentValues[i])}");


        if(toggleIndex == 1){
          if(currentValues[i].relay! == "ON"){
            // dd1.add(SocketValues(
            //   source: myPlugs[i].zigbeeAddress,
            //   current: currentValues[i].current
            // ));
            dd.add(myPlugs[i]);
          }
        }

        if(toggleIndex == 2){
          if(currentValues[i].relay == "OFF"){
            // dd1.add(SocketValues(
            //     source: myPlugs[i].zigbeeAddress,
            //     current: currentValues[i].current
            // ));
            dd.add(myPlugs[i]);
          }
        }
      }


      if(toggleIndex != 0){
        // currentValues.clear();
        // currentValues.addAll(dd1);
        myPlugs.clear();
        myPlugs.addAll(dd);

      }




      // Sorting Data
      if(sortVal == 1) {
        myPlugs.sort((a, b) => a.name!.compareTo(b.name!));
      } else {
        myPlugs.sort((a, b) => b.name!.compareTo(a.name!));
      }

      // currentValues.clear();
      // for(int i = 0; i < myPlugs.length; i++){
      //   currentValues.add(SocketValues(
      //       source: myPlugs[i].zigbeeAddress,
      //       current: current: currentValues[i].current
      //   ));
      // }



    });
  }

  // // Sorting
  // sorting(int value){
  //   setState(() {
  //
  //
  //   });
  // }

  // Filter by status
  // filterByStatus(){
  //   setState(() {
  //
  //
  //
  //
  //     List<Plug> dd = [];
  //     for(int i = 0;  i < myPlugs.length; i++){
  //
  //       print("Hello: ${myPlugs[i].status}");
  //
  //
  //       if(toggleIndex == 1){
  //         if(myPlugs[i].status == false){
  //           dd.add(myPlugs[i]);
  //         }
  //       }
  //     }
  //
  //
  //     if(toggleIndex != 0){
  //       myPlugs.clear();
  //       myPlugs.addAll(dd);
  //     }
  //
  //
  //
  //   });
  // }


  Widget _buildSearchField() {
    return TextField(
        controller: _searchQueryController,
        autofocus: true,
        textInputAction: TextInputAction.search,
        onSubmitted: (text){

        },
        decoration: const InputDecoration(
          hintText: "Search here...",
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.white70),
        ),
        style: const TextStyle(color: Colors.white, fontSize: 16.0),
        onChanged: (text) {
          if(text.isNotEmpty){
            searchDate(_searchQueryController.text);
            //  myProjects.clear();
          } else if(text.isEmpty){
            getPlugs();
          }
        }

    );
  }





  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQueryController == null ||
                _searchQueryController.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            _clearSearchQuery();
          },
        ),
      ];
    }

    return <Widget>[
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: _startSearch,
      ),
    ];
  }

  void _startSearch() {
    ModalRoute.of(context)!
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));
    setState(() {
      _isSearching = true;
    });
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
    });
  }

  void _stopSearching() {
    _clearSearchQuery();
    setState(() {
      _isSearching = false;
      searchDate(_searchQueryController.text);
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery("");
      searchDate(_searchQueryController.text);
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

        allPlugs.clear();
        allPlugs.addAll(sheet);


        for(int i = 0; i < allPlugs.length; i++){
          currentValues.add(SocketValues(
              current: "0",
              source: allPlugs[i].zigbeeAddress,
            relay: "OFF"
          ));
        }

        allCurrentValues.clear();
        allCurrentValues.addAll(currentValues);


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
        getPlugs();
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
        centerTitle: false,
        automaticallyImplyLeading: false,
        leading: _isSearching ?  const BackButton() :  IconButton(icon:const Icon(Icons.arrow_back, color: Colors.white),onPressed: (){Navigator.pop(context);}),
        title: _isSearching ? _buildSearchField() : const Text("My Plugs", style: TextStyle(fontFamily: ""),),
        // actions: _buildActions(),
      ),
      floatingActionButton: FloatingActionButton(  // show dialog to fill the data
          backgroundColor: Helper.primaryColor,
          child: Icon(Icons.add, color: Colors.white, size: 30),
          onPressed: () async {
            addPlugDialog(context);
          }
      ),// Drawer
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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Filters",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w600
                          ),
                        ),

                        if(toggleIndex != 0 || sortVal != 0)
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              toggleIndex = 0;
                              sortVal = 0;
                              searchDate(_searchQueryController.text);
                            });
                          },
                          child: Image.asset("assets/images/close.png",
                            height: 20,
                          ),
                        )

                      ],
                    ),

                    const SizedBox(height: 20),


                    Row(
                      children: [

                        Expanded(
                          child: ToggleSwitch(
                            initialLabelIndex: toggleIndex,
                            totalSwitches: 3,
                            inactiveBgColor: Colors.grey.shade400,
                            activeBgColor: [
                                if(toggleIndex == 0)
                                  Helper.primaryColor,
                                if(toggleIndex == 1)
                              Colors.green,
                                if(toggleIndex == 2)
                              Colors.red,
                            ],
                            labels: ['ALL','ON', 'OFF'],
                            onToggle: (index) {
                              setState(() {
                                toggleIndex = index!;
                                searchDate(_searchQueryController.text);
                              });
                            },
                          ),
                        ),

                        // Container(
                        //   height: 30,
                        //   width: 1,
                        //   color: Colors.grey.shade400,
                        // ),

                        Expanded(
                            child: GestureDetector(
                              onTap: (){
                                if(sortVal == 0){
                                  sortVal = 1;
                                } else if(sortVal == 1){
                                  sortVal = 2;
                                } else{
                                  sortVal = 1;
                                }
                                searchDate(_searchQueryController.text);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: sortVal != 0 ? Helper.primaryColor : Colors.black)
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 12, right: 12),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset("assets/images/sorting.png", height: 22,
                                            color: sortVal != 0 ? Helper.primaryColor : Colors.black,
                                          ),
                                          const SizedBox(width: 4),
                                          Text("Sort",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: sortVal != 0 ? Helper.primaryColor : Colors.black
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ),

                      ],
                    ),


                    const SizedBox(height: 40),

                    StreamBuilder(
                        stream: channel.stream,
                        builder: (context, snapshot) {
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
                                      // allCurrentValues[index].current = convertedData['data']['current'].toString();
                                      if(convertedData['source'].toString() == myPlugs[index].zigbeeAddress){
                                        if(convertedData['data']['relay'].toString() == "OFF"){
                                          myPlugs[index].status = false;
                                        } else {
                                          myPlugs[index].status = true;
                                        }
                                      }
                                    }

                                  }
                                }
                              }


                              return WidgetANimator(
                                GestureDetector(
                                  onTap: (){
                                    // turn on / off plug
                                    // updateSmartPlugs(myPlugs[index]);

                                    String command = "";

                                    if(currentValues[index].relay == "OFF"){
                                      command = "ON";
                                    } else {
                                      command = "OFF";
                                    }

                                    sendRequest(myPlugs[index], command);

                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Color(0xFFf5f8f9),
                                        border: Border.all(color:  myPlugs[index].status == true ? Colors.green  :
                                        Colors.grey.shade300
                                        ),
                                        boxShadow: [
                                          myPlugs[index].status == true ?
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

                                          Text( "${myPlugs[index].name}",  // myPlugs[index].name!,
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
                                                      fontWeight: FontWeight.w500
                                                  ),
                                                ),

                                                Image.asset("assets/images/stats.png",
                                                  height: 20,
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




