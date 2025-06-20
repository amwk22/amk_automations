import 'dart:async';
import 'dart:convert';

import 'package:automation/helper/helper.dart' show Helper;
import 'package:automation/helper/urls.dart' show UrlsFile;
import 'package:automation/modals/Schedule.dart';
import 'package:dio/dio.dart' show Dio, DioException, DioExceptionType, Options, Response;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart' show SimpleFontelicoProgressDialog;
import 'package:toggle_switch/toggle_switch.dart';

class CreateScheduleScreen extends StatefulWidget {
  String plugId;
  Schedule? schedule;
  CreateScheduleScreen({super.key, required this.plugId, this.schedule});

  @override
  State<CreateScheduleScreen> createState() => _CreateScheduleScreenState();
}

class _CreateScheduleScreenState extends State<CreateScheduleScreen> {

  final controller = MultiSelectController<String>();
  TextEditingController onTimeController = TextEditingController();
  TextEditingController offTimeController = TextEditingController();

  TimeOfDay selectedTime = TimeOfDay.now();

  String startTime = "";
  String endTime = "";
  List<String> selectedItems = [];


  int isActive = 0;

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


  var items = [
    DropdownItem(label: 'Monday', value: "Monday"),
    DropdownItem(label: 'Tuesday', value: "Tuesday"),
    DropdownItem(label: 'Wednesday', value: "Wednesday"),
    DropdownItem(label: 'Thursday', value: "Thursday"),
    DropdownItem(label: 'Friday', value: "Friday"),
    DropdownItem(label: 'Saturday', value: "Saturday"),
    DropdownItem(label: 'Sunday', value: "Sunday"),
  ];

  List<String> uItems = [];


  Future<TimeOfDay?> getTime({
    required BuildContext context,
    String? title,
    TimeOfDay? initialTime,
    String? cancelText,
    String? confirmText,
  }) async {
    TimeOfDay? time = await showTimePicker(
      initialEntryMode: TimePickerEntryMode.dial,
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      cancelText: cancelText ?? "Cancel",
      confirmText: confirmText ?? "Save",
      helpText: title ?? "Select time",
      builder: (context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    return time;
  }


  String convertTo12HourFormat(String time24) {
    final dateTime = DateFormat("HH:mm").parse(time24);
    final time12 = DateFormat("hh:mm a").format(dateTime); // 'a' for AM/PM
    return time12;
  }


  createSchedule() async {
    showProgress();
    Response response;
    try {
      Map<String, dynamic> userMap4 = {
        "onTime": startTime,
        "offTime": endTime,
        "days": selectedItems,
        "isActive": isActive == 0 ? true : false,
        "plugId": widget.plugId,

      };
      print(json.encode(userMap4));
      Dio dio =  Dio();
      response = await dio.post(UrlsFile.schedule, data: userMap4, options: Options(
          headers: {
            "Authorization" : "Bearer ${Helper.accessToken}"   // token
          }
      ));
      setState(() {
        _dialog!.hide();
        Helper.showToast("Schedule Added Successfully");
        Navigator.pop(context);
      });
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {
        _dialog!.hide();
        print("Bad Response ${e.response}");
      } else if (e.type == DioExceptionType.connectionError) {
        _dialog!.hide();
        print('No internet connection');
      }
    }
    setState(() {});
  }


  updateSchedule() async {
    showProgress();
    Response response;
    try {
      Map<String, dynamic> userMap4 = {
        "onTime": startTime,
        "offTime": endTime,
        "days": selectedItems,
        "isActive": isActive == 0 ? true : false
      };
      print(json.encode(userMap4));
      Dio dio =  Dio();
      response = await dio.put("${UrlsFile.schedule}/${widget.schedule!.id!}", data: userMap4, options: Options(
          headers: {
            "Authorization" : "Bearer ${Helper.accessToken}"   // token
          }
      ));
      setState(() {
        _dialog!.hide();
        Helper.showToast("Schedule Updated Successfully");
        Navigator.pop(context);
      });
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {
        _dialog!.hide();
        print("Bad Response ${e.response}");
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
    setData();
    super.initState();
  }


  setData(){

    Timer(Duration(milliseconds: 500), (){
      setState(() {

        if(widget.schedule!.isActive == true){
          isActive = 0;
        } else {
          isActive = 1;
        }

        // On Time
        startTime = widget.schedule!.onTime!;
        String ss = convertTo12HourFormat(startTime);
        onTimeController.text = ss;


        // Off Time
        endTime = widget.schedule!.offTime!;
        String ss1 = convertTo12HourFormat(endTime);
        offTimeController.text = ss1;



        if(widget.schedule != null){
          uItems = widget.schedule!.days!;
          for(int q = 0; q < items.length; q++){
            for(int i = 0; i < uItems.length; i++){
              if(uItems[i] == items[q].value) {
                controller.selectAtIndex(q);
              }
            }
          }



        }
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( widget.schedule == null ? "Create Schedule" : "Update Schedule"),
        // actions: [
        //   IconButton(onPressed: (){setData();}, icon: Icon(Icons.print))
        // ],
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [


                const SizedBox(height: 30),

                Row(
                  children: [
                    Expanded(child: Text("isActive", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black))),

                    ToggleSwitch(
                      minWidth: 80.0,
                      minHeight: 35,
                      initialLabelIndex: isActive,
                      cornerRadius: 20.0,
                      activeFgColor: Colors.white,
                      inactiveBgColor: Colors.grey,
                      inactiveFgColor: Colors.white,
                      totalSwitches: 2,
                      labels: ['TRUE', 'FALSE'],
                      activeBgColors: [[Colors.green],[Colors.red]],
                      onToggle: (index) {
                       setState(() {
                         isActive = index!;
                       });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                Row(
                  children: [



                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("On Time", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: onTimeController,
                            style: TextStyle(color: Colors.black),
                            cursorColor: Colors.black,
                            readOnly: true,
                            onTap: () async {


                              TimeOfDay? dd = await getTime(context: context);
                              startTime =
                              "${dd!.hour.toString().padLeft(2, "0")}:${dd
                                  .minute.toString().padLeft(2, "0")}";

                              String ss = convertTo12HourFormat(startTime);
                              onTimeController.text = ss;

                              // if(endTime == "") {
                              //
                              // } else {
                              //   String cd = DateFormat('yyyy-MM-dd').format(DateTime.now());
                              //
                              //   if(DateTime.parse(
                              //       "$cd $startTime:00").isAfter(DateTime.parse( cd+" "+endTime+":00"))){
                              //
                              //     onTimeController.text = "";
                              //     startTime = "";
                              //     Helper.showToast("Off time must be after On time.");
                              //
                              //   } else {
                              //     String ss = convertTo12HourFormat(startTime);
                              //     onTimeController.text = ss;
                              //   }
                              //
                              //
                              // }

                            },
                            decoration: InputDecoration(
                              hintText: "",
                              hintStyle: TextStyle(color: Colors.grey.shade700),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    Padding(
                      padding: EdgeInsets.only(top: 25),
                      child: Text("To",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Off Time", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: offTimeController,
                            style: TextStyle(color: Colors.black),
                            cursorColor: Colors.black,
                            readOnly: true,
                            onTap: () async {

                              TimeOfDay? dd = await getTime(context: context);
                              endTime =
                              "${dd!.hour.toString().padLeft(2, "0")}:${dd
                                  .minute.toString().padLeft(2, "0")}";

                              if(startTime == "") {
                                String ss = convertTo12HourFormat(endTime);
                                offTimeController.text = ss;
                              } else {
                                String cd = DateFormat('yyyy-MM-dd').format(DateTime.now());

                                if(DateTime.parse(
                                    "$cd $endTime:00").isBefore(DateTime.parse( cd+" "+startTime+":00"))){

                                  offTimeController.text = "";
                                  endTime = "";
                                  Helper.showToast("Off time must be after On time.");

                                } else {
                                  String ss = convertTo12HourFormat(endTime);
                                  offTimeController.text = ss;
                                }


                              }

                            },
                            decoration: InputDecoration(
                              hintText: "",
                              hintStyle: TextStyle(color: Colors.grey.shade700),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),



                  ],
                ),

                const SizedBox(height: 20),


                Text("Select Days", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black)),
                const SizedBox(height: 6),
                MultiDropdown<String>(
                  items: items,
                  controller: controller,
                  enabled: true,
                  searchEnabled: true,
                  chipDecoration: const ChipDecoration(
                    backgroundColor: Colors.yellow,
                    wrap: true,
                    runSpacing: 2,
                    spacing: 10,
                  ),
                  fieldDecoration: FieldDecoration(
                    hintText: '',
                    hintStyle: const TextStyle(color: Colors.black87),
                    showClearIcon: false,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade700)),
                  ),
                  dropdownDecoration: const DropdownDecoration(
                    marginTop: 2,
                    maxHeight: 500,
                    header: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Select Days',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  dropdownItemDecoration: DropdownItemDecoration(
                    selectedIcon:
                    const Icon(Icons.check_box, color: Colors.green),
                    disabledIcon:
                    Icon(Icons.lock, color: Colors.grey.shade300),
                  ),
                  onSelectionChange: (sItems) {
                    setState(() {
                      selectedItems.clear();
                      selectedItems.addAll(sItems);
                    });
                  },
                ),


                const SizedBox(height: 50),

                GestureDetector(
                  onTap: (){
                    if(onTimeController.text.isNotEmpty) {
                      if(offTimeController.text.isNotEmpty) {
                        if(selectedItems.isNotEmpty) {
                            String cd = DateFormat('yyyy-MM-dd').format(DateTime.now());
                            if(DateTime.parse(
                                "$cd $startTime:00").isAfter(DateTime.parse( cd+" "+endTime+":00"))){
                              onTimeController.text = "";
                              startTime = "";
                              endTime = "";
                              offTimeController.text = "";
                              Helper.showToast("Off time must be after On time.");

                            } else {
                              if(widget.schedule == null) {
                                createSchedule();
                              } else {
                                updateSchedule();
                              }
                            }


                        } else {
                          Helper.showToast("Select Days");
                        }
                      } else {
                        Helper.showToast("Please Select Off Time");
                      }
                    } else {
                      Helper.showToast("Please Select On Time");
                    }
                  },
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Helper.primaryColor,
                        borderRadius: BorderRadius.circular(12)
                    ),
                    child: Text("SAVE",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white
                      ),
                    ),
                  ),
                ),




              ],
            ),
          ),
        ),
      ),
    );
  }
}
