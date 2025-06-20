import 'package:automation/helper/helper.dart';
import 'package:automation/modals/Plug.dart';
import 'package:automation/modals/Schedule.dart';
import 'package:automation/screens/create_schedule_screen.dart' show CreateScheduleScreen;
import 'package:dio/dio.dart' show Dio, DioException, DioExceptionType, Options, Response;
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import '../helper/urls.dart';

class ScheduleScreen extends StatefulWidget {
  Plug? myPlug;
  ScheduleScreen({super.key, required this.myPlug});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {


  List<Schedule> mySchedule = [];
  bool isLoading = true;


  // Loader helps to show loading dialog when API hit
  SimpleFontelicoProgressDialog ?_dialog;


  void dialog(context) {
    _dialog = SimpleFontelicoProgressDialog(context: context, barrierDimisable:  false);
  }


  void showProgress(){
    setState(() {
      _dialog!.show(message: "Please wait...", indicatorColor: Helper.primaryColor);
    });
  }


  Future<void> _deleteAlert(BuildContext context, String id) {
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
                deleteSchedule(id);
              },
            ),
          ],
        );
      },
    );
  }



  getSchedule() async {

    Response response;
    List<Schedule> sheet = [];

    try {
      Dio dio =  Dio();
      response = await dio.get("${UrlsFile.schedule}/${widget.myPlug!.id}", options: Options(
          headers: {
            "Authorization" : "Bearer ${Helper.accessToken}"   // token
          }
      ));

      var creativeData = response.data as List;
      sheet = creativeData
          .map<Schedule>((json) => Schedule.fromJson(json))
          .toList();

      setState(() {
        isLoading = false;
        mySchedule.clear();
        mySchedule.addAll(sheet);
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



  deleteSchedule(String id) async {
    showProgress();
    Response response;
    try {

      Dio dio =  Dio();
      response = await dio.delete("${UrlsFile.schedule}/$id", options: Options(
          headers: {
            "Authorization" : "Bearer ${Helper.accessToken}"   // token
          }
      ));
      setState(() {
        _dialog!.hide();
        Helper.showToast("Deleted Successfully");
        getSchedule();
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


  @override
  void initState() {
    dialog(context);
    getSchedule();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.myPlug!.name!} Schedule"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
         await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateScheduleScreen(
           plugId: widget.myPlug!.id.toString(),
         )));
         setState(() {
           getSchedule();
         });
        },
        backgroundColor: Helper.primaryColor,
        child: Icon(Icons.add, size: 30, color: Colors.white),
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
        ) : mySchedule.isEmpty ?

            Center(
              child: Text("No Schedule Yet!"),
            )

            : ListView.builder(
          padding: EdgeInsets.all(12),
          itemCount: mySchedule.length,
          itemBuilder: (BuildContext context, int position){
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          if(mySchedule[position].isActive!)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Container(
                                height: 14,
                                width: 14,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green
                                ),
                              ),
                            ),


                          Expanded(
                            child: Column(
                              children: [
                                Text("On Time",
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: Colors.grey.shade700
                                  ),
                                ),
                                Text(DateFormat('hh:mm a').format(DateTime.parse("${DateFormat('yyyy-MM-dd').format(DateTime.now())} ${mySchedule[position].onTime!}")),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black
                                  ),
                                )
                              ],
                            ),
                          ),


                          Expanded(
                            child: Column(
                              children: [
                                Text("Off Time",
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: Colors.grey.shade700
                                  ),
                                ),
                                Text(DateFormat('hh:mm a').format(DateTime.parse("${DateFormat('yyyy-MM-dd').format(DateTime.now())} ${mySchedule[position].offTime!}")),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black
                                  ),
                                )
                              ],
                            ),
                          ),




                          // GestureDetector(
                          //   onTap: (){
                          //     _deleteAlert(context, mySchedule[position].id.toString());
                          //   },
                          //   child: Padding(
                          //     padding: const EdgeInsets.only(top: 2),
                          //     child: Image.asset("assets/images/delete.png",
                          //       height: 15,
                          //     ),
                          //   ),
                          // )
                        ],
                      ),


                      Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 5),
                        child: DottedLine(
                          direction: Axis.horizontal,
                          alignment: WrapAlignment.center,
                          lineLength: double.infinity,
                          lineThickness: 1.0,
                          dashLength: 4.0,
                          dashColor: Colors.grey.shade400,
                          dashRadius: 0.0,
                          dashGapLength: 4.0,
                          dashGapColor: Colors.transparent,
                          dashGapRadius: 0.0,
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(mySchedule[position].days!.toString().replaceAll("[", "").replaceAll("]", ""),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                          ),

                          const SizedBox(width: 20),

                          PopupMenuButton<String>(
                            onSelected: (val) async {
                              if(val == "Edit"){
                                await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateScheduleScreen(plugId: widget.myPlug!.id.toString(),schedule: mySchedule[position])));
                                setState(() {
                                  getSchedule();
                                });
                              } else {
                                _deleteAlert(context, mySchedule[position].id.toString());
                              }
                            },
                            itemBuilder: (BuildContext context) {
                              return {'Edit', 'Delete'}.map((String choice) {
                                return PopupMenuItem<String>(
                                  value: choice,
                                  child: Text(choice),
                                );
                              }).toList();
                            },
                          ),

                        ],
                      )


                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }




}
