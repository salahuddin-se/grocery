import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grocery/Components/drawer.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/notificationbean/notificationlistdata.dart';
import 'package:grocery/main.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationShow extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NotificationShowState();
  }
}

class NotificationShowState extends State<NotificationShow> {
  var http = Client();
  List<NotificationListData> listdata = [];
  bool isLoading = false;
  String userName;
  bool islogin = false;

  @override
  void initState() {
    super.initState();
    getProfileValue();
  }

  void getProfileValue() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    dynamic userId = preferences.getInt('user_id');
    setState(() {
      islogin = preferences.getBool('islogin');
      userName = preferences.getString('user_name');
    });
    getNotificaitonList(userId);
  }

  void getNotificaitonList(dynamic userid) async {
    setState(() {
      isLoading = true;
    });
    http.post(notificationListUri, body: {'user_id': '$userid'}).then((value) {
      if (value.statusCode == 200) {
        NotificationList data1 =
            NotificationList.fromJson(jsonDecode(value.body));
        if ('${data1.status}' == '1') {
          setState(() {
            listdata.clear();
            listdata = List.from(data1.data);
          });
        }
      }
      setState(() {
        isLoading = false;
      });
    }).catchError((e) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Scaffold(
      drawer: buildDrawer(context, userName, islogin, onHit: () {
        SharedPreferences.getInstance().then((pref) {
          pref.clear().then((value) {
            // Navigator.pushAndRemoveUntil(context,
            //     MaterialPageRoute(builder: (context) {
            //   return GroceryLogin();
            // }), (Route<dynamic> route) => false);
            Navigator.of(context).pushNamedAndRemoveUntil(PageRoutes.signInRoot, (Route<dynamic> route) => false);
          });
        });
      }),
      appBar: AppBar(
        title: Text(
          locale.notificaitonh,
          style: TextStyle(color: kMainTextColor),
        ),
        centerTitle: true,
      ),
      body: (!isLoading && listdata!=null && listdata.length>0)
          ?ListView.builder(
        itemCount: listdata.length,
          shrinkWrap: true,
          itemBuilder: (context,index){
        return Card(
          elevation: 3,
          margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
          clipBehavior: Clip.hardEdge,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${listdata[index].notiTitle}',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: kWhiteColor),),
                SizedBox(height: 5,),
                Text('${listdata[index].notiMessage}',style: TextStyle(fontSize: 13,color: kWhiteColor),),
              ],
            ),
          ),
        );
      }):Align(
        child: isLoading?SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(),
        ):Text(locale.nonotificaiton),
      ),
    );
  }
}
