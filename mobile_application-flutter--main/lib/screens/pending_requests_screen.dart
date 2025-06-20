import 'package:automation/helper/urls.dart';
import 'package:automation/modals/PendingRequests.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PendingRequestsScreen extends StatefulWidget {
  const PendingRequestsScreen({super.key});

  @override
  State<PendingRequestsScreen> createState() => _PendingRequestsScreenState();
}

class _PendingRequestsScreenState extends State<PendingRequestsScreen> {


  List<PendingRequests> myRequests = [];
  bool  isLoading = true;




  getRequestQueue() async {

    Response response;
    List<PendingRequests> sheet = [];

    try {
      Dio dio =  Dio();
      response = await dio.get(UrlsFile.getPendingRequests);

      var creativeData = response.data as List;
      sheet = creativeData
          .map<PendingRequests>((json) => PendingRequests.fromJson(json))
          .toList();

      setState(() {
        isLoading = false;
        myRequests.clear();
        myRequests.addAll(sheet);
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
    getRequestQueue();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pending Requests"),
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
        child: isLoading ? Center(child: CircularProgressIndicator()) :
            myRequests.isEmpty ? Center(
              child: Text("No Pending Request Yet!"),
            ) :
        ListView.builder(
          padding: EdgeInsets.all(12),
          shrinkWrap: true,
          itemCount: myRequests.length,
          itemBuilder: (BuildContext context, int position){
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                    color: Color(0xFFf5f8f9),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 5),
                    ],
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        children: [
                          Expanded(
                            child: Text("#${myRequests[position].id}",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black
                              ),
                            ),
                          ),

                          Container(
                            decoration: BoxDecoration(
                              color: myRequests[position].status == "pending" ? Colors.grey.shade500 : Colors.green,
                              borderRadius: BorderRadius.circular(4)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2),
                              child: Text("PENDING",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )

                        ],
                      ),

                      const SizedBox(height: 10),


                      Text("Action : ${myRequests[position].action!.toUpperCase()}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500
                        ),
                      ),

                      const SizedBox(height: 10),


                      Text("Plug : ${myRequests[position].plug!.name}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500
                        ),
                      ),

                      const SizedBox(height: 10),


                      Text("Time Queued : ${DateFormat('dd MMM yyyy hh:mm a ').format(DateTime.parse(myRequests[position].createdAt!))}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500
                        ),
                      ),


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
