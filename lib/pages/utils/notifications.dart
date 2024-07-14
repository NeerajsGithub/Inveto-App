import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:practice/global_func.dart';
import 'package:practice/provider/homeProvider.dart';
import 'package:provider/provider.dart'; // Import Provider package

class NotificationsPage extends StatefulWidget {
  NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {

  void initState() {
    super.initState();
    final provider = Provider.of<HomeProvider>(context, listen: false);
    provider.fetchRequests();
  }

  
  Future<void> _refresh() async {
  final provider = Provider.of<HomeProvider>(context, listen: false);
  await provider.fetchRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        backgroundColor: Colors.white,
          color: Color.fromRGBO(6, 148, 132, 1),
          onRefresh: _refresh ,
        child:
         Provider.of<HomeProvider>(context, listen: false).requests.isNotEmpty ?
         Padding(
          padding: const EdgeInsets.all(20.0),
          child: Consumer<HomeProvider>(
            builder: (context, requestsProvider, _) {
              return ListView.builder(
                itemCount: requestsProvider.requests.length,
                itemBuilder: (context, index) {
                  final email = requestsProvider.requests.elementAt(index);
                  return buildNotificationCard(email , context);
                },
              );
            },
          ),
        )
        :
        Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              imageLoader(
                'https://cdn0.iconfinder.com/data/icons/flatt3d-icon-pack/512/Flatt3d-Box-1024.png',
                MediaQuery.of(context).size.width * 0.20,
              ),
              Text(
                'No requests yet',
                style: TextStyle(color: const Color.fromARGB(255, 65, 65, 65), fontSize: 20),
              ),
              Text(
                'Share profile code to procees',
                style: TextStyle(color: const Color.fromARGB(255, 65, 65, 65)),
              ),
              SizedBox(height: 70,)
            ],
          ),
      ),
      ),
    );
  }

  Widget buildNotificationCard(String email, context  ) {
    
    return Container(
      padding: EdgeInsets.symmetric( horizontal: 10 , vertical: 13  ),
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Color.fromARGB(137, 234, 234, 234),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: <Widget>[
          ClipOval(
            child: Icon(
                        Icons.account_circle,
                        color: Color.fromARGB(255, 61, 61, 61),
                        size: 70,
                      ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Text(
                      email, // Display email or name
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                           Provider.of<HomeProvider>(context, listen: false).addMember(email, context);
                        },
                        child: Text(
                          'Accept',
                          style: TextStyle(
                            color: Color.fromRGBO(6, 148, 132, 1),
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            Color.fromRGBO(6, 148, 132, 1).withOpacity(0.1),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          Provider.of<HomeProvider>(context, listen: false).deleteRequest(email, context);
                        },
                        child: Text(
                          'Reject',
                          style: TextStyle(
                            color: Color.fromRGBO(192, 20, 20, 1),
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            Color.fromRGBO(192, 20, 20, 1).withOpacity(0.1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
