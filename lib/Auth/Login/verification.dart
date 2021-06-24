import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:grocery/Components/custom_button.dart';
import 'package:grocery/Components/entry_field.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/signinmodel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VerificationPage extends StatefulWidget {
  // final VoidCallback onVerificationDone;
  //
  // VerificationPage(this.onVerificationDone);

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final TextEditingController _controller = TextEditingController();
  FirebaseMessaging messaging;
  bool isDialogShowing = false;
  dynamic token = '';
  var showDialogBox = false;
  var verificaitonPin = "";
  String actualCode;
  bool firebaseOtp = false;
  dynamic user_phone;
  String referralcode = '';
  dynamic country_code;
  dynamic activity;

  int firecount = 0;

  @override
  void initState() {
    super.initState();
  }

  void hitAsynInit() async{
    await Firebase.initializeApp();
    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) {
      token = value;
      if (firebaseOtp) {
        initialAuth('+$country_code$user_phone');
      }else{
        setState(() {
          showDialogBox = false;
        });
      }
    }).catchError((e){
      setState(() {
        showDialogBox = false;
      });
      print(e);
    });
  }

  initialAuth(String phoneNumberd) async{
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.verifyPhoneNumber(
      phoneNumber:phoneNumberd,
      verificationCompleted: (PhoneAuthCredential credential) {
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e.message);
        setState(() {
          showDialogBox = false;
        });
      },
      codeSent: (String verificationId, int resendToken) {
        setState(() {
          showDialogBox = false;
          actualCode = verificationId;
        });
        print('code sent');
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  hitSignIn(String smsCode, BuildContext context){
    FirebaseAuth auth = FirebaseAuth.instance;
    PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId:actualCode, smsCode:smsCode);
    auth.signInWithCredential(credential).then((value){
      if(value!=null){
        User userd = value.user;
        if(userd!=null){
          if (activity == 'login') {
            hitFirebaseSuccessLoginStatus('success',context);
          } else {
            hitFirebaseSuccessStatus('success',context);
          }
        }else{
          setState(() {
            showDialogBox = false;
          });
        }
      }else{
        setState(() {
          showDialogBox = false;
        });
      }
    }).catchError((e){
      print('user null + $e');
      setState(() {
        showDialogBox = false;
      });
    });
  }



  @override
  void dispose() {
    // firebaseAuth.signOut();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    if (firecount == 0) {
      final Map<String, Object> dataRecevid =
          ModalRoute.of(context).settings.arguments;
      setState(() {
        firecount = 1;
        showDialogBox = true;
        token = dataRecevid['token'];
        user_phone = dataRecevid['user_phone'];
        firebaseOtp = ('${dataRecevid['firebase']}' == 'on' ||
            '${dataRecevid['firebase']}' == 'ON' ||
            '${dataRecevid['firebase']}' == 'On')
            ? true
            : false;
        referralcode = dataRecevid['referralcode'];
        country_code = dataRecevid['country_code'];
        activity = dataRecevid['activity'];
      });
      hitAsynInit();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          locale.verification,
          style: TextStyle(color: kMainTextColor),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 48),
                  child: Text(
                    locale.pleaseEnterVerificationCodeSentGivenNumber,
                    style: Theme.of(context).textTheme.headline3,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 28.0, left: 18, right: 18, bottom: 4),
                  child: Text(
                    locale.enterVerificationCode,
                    style: Theme.of(context).textTheme.headline3.copyWith(
                        fontSize: 22,
                        color: Theme.of(context).backgroundColor,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                EntryField(
                  controller: _controller,
                  hint: locale.enterVerificationCode,
                  maxLines: 1,
                  maxLength: firebaseOtp ? 6 : 4,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10.0),
                Align(alignment: Alignment.center,child: GestureDetector(
                  onTap: (){
                    if(!showDialogBox){
                      setState(() {
                        showDialogBox = true;
                      });
                      if (firebaseOtp) {
                        initialAuth('+$country_code$user_phone');
                      } else {
                        resendOtpM();
                      }
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Text(locale.resend,style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: kMainColor
                  ),),
                ),),
                SizedBox(height: 10.0),
                Visibility(
                    visible: showDialogBox,
                    child: Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    )),
              ],
            ),
          )),
          CustomButton(
            onTap: () {
              // widget.onVerificationDone();
              if (!showDialogBox) {
                setState(() {
                  showDialogBox = true;
                });
                verificaitonPin = _controller.text;
                if (firebaseOtp) {
                  hitSignIn(verificaitonPin, context);
                } else {
                  if (activity == 'login') {
                    hitLoginService(verificaitonPin, context);
                  } else {
                    hitService(verificaitonPin, context);
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void resendOtpM() async{

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = resendOtpUri;
    await http.post(url, body: {
      'user_phone': '${user_phone}',
    }).then((response) {
      print('Response Body: - ${response.body}');
      if (response.statusCode == 200) {
        setState(() {
          showDialogBox = false;
        });
      } else {
        setState(() {
          showDialogBox = false;
        });
      }
    }).catchError((e) {
      print(e);
      setState(() {
        showDialogBox = false;
      });
    });

  }

  void hitService(String verificaitonPin, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = verifyPhoneRefferalUri;
    await http.post(url, body: {
      'user_phone': '${user_phone}',
      'otp': verificaitonPin,
      'referral_code': (referralcode!=null && referralcode.length>0)?'${referralcode}':''
    }).then((response) {
      print('Response Body: - ${response.body}');
      if (response.statusCode == 200) {
        print('Response Body: - ${response.body}');
        var jsonData = jsonDecode(response.body);
        SignInModel signInData = SignInModel.fromJson(jsonData);
        if(signInData.status == "1" || signInData.status==1){
          var userId = int.parse('${signInData.data.user_id}');
          prefs.setInt("user_id", userId);
          prefs.setString("user_name", '${signInData.data.user_name}');
          prefs.setString("user_email", '${signInData.data.user_email}');
          prefs.setString("user_image", '${signInData.data.user_image}');
          prefs.setString("user_phone", '${signInData.data.user_phone}');
          prefs.setString("user_password", '${signInData.data.user_password}');
          prefs.setString("wallet_credits", '${signInData.data.wallet}');
          prefs.setString("user_city", '${signInData.data.user_city}');
          prefs.setString("user_area", '${signInData.data.user_area}');
          prefs.setString("block", '${signInData.data.block}');
          prefs.setString("app_update", '${signInData.data.app_update}');
          prefs.setString("reg_date", '${signInData.data.reg_date}');
          prefs.setBool("phoneverifed", true);
          prefs.setBool("islogin", true);
          prefs.setString("refferal_code", '${signInData.data.referral_code}');
          prefs.setString("reward", '${signInData.data.rewards}');
          Navigator.of(context).pushNamedAndRemoveUntil(PageRoutes.homePage, (Route<dynamic> route) => false);
        }
        setState(() {
          showDialogBox = false;
        });
      } else {
        setState(() {
          showDialogBox = false;
        });
      }
    }).catchError((e) {
      print(e);
      setState(() {
        showDialogBox = false;
      });
    });
  }

  void hitLoginService(String verificaitonPin, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = loginVerifyPhoneUri;
    await http.post(url, body: {
      'user_phone': '${user_phone}',
      'otp': verificaitonPin,
    }).then((response) {
      print('Response Body: - ${response.body}');
      if (response.statusCode == 200) {
        print('Response Body: - ${response.body}');
        var jsonData = jsonDecode(response.body);
        SignInModel signInData = SignInModel.fromJson(jsonData);
        if(signInData.status == "1" || signInData.status==1){
          var userId = int.parse('${signInData.data.user_id}');
          prefs.setInt("user_id", userId);
          prefs.setString("user_name", '${signInData.data.user_name}');
          prefs.setString("user_email", '${signInData.data.user_email}');
          prefs.setString("user_image", '${signInData.data.user_image}');
          prefs.setString("user_phone", '${signInData.data.user_phone}');
          prefs.setString("user_password", '${signInData.data.user_password}');
          prefs.setString("wallet_credits", '${signInData.data.wallet}');
          prefs.setString("user_city", '${signInData.data.user_city}');
          prefs.setString("user_area", '${signInData.data.user_area}');
          prefs.setString("block", '${signInData.data.block}');
          prefs.setString("app_update", '${signInData.data.app_update}');
          prefs.setString("reg_date", '${signInData.data.reg_date}');
          prefs.setBool("phoneverifed", true);
          prefs.setBool("islogin", true);
          prefs.setString("refferal_code", '${signInData.data.referral_code}');
          prefs.setString("reward", '${signInData.data.rewards}');
          Navigator.of(context).pushNamedAndRemoveUntil(PageRoutes.homePage, (Route<dynamic> route) => false);
        }
        setState(() {
          showDialogBox = false;
        });
      } else {
        setState(() {
          showDialogBox = false;
        });
      }
    }).catchError((e) {
      print(e);
      setState(() {
        showDialogBox = false;
      });
    });
  }

  void hitFirebaseSuccessStatus(String status, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = verifyViaFirebaseUri;
    await http.post(url, body: {
      'user_phone': '${user_phone}',
      'status': status,
      'referral_code': (referralcode!=null && referralcode.length>0)?'${referralcode}':''
    }).then((response) {
      print('Response Body: - ${response.body}');
      if (response.statusCode == 200) {
        print('Response Body: - ${response.body}');
        var jsonData = jsonDecode(response.body);
        SignInModel signInData = SignInModel.fromJson(jsonData);
        if(signInData.status == "1" || signInData.status==1){
          var userId = int.parse('${signInData.data.user_id}');
          prefs.setInt("user_id", userId);
          prefs.setString("user_name", '${signInData.data.user_name}');
          prefs.setString("user_email", '${signInData.data.user_email}');
          prefs.setString("user_image", '${signInData.data.user_image}');
          prefs.setString("user_phone", '${signInData.data.user_phone}');
          prefs.setString("user_password", '${signInData.data.user_password}');
          prefs.setString("wallet_credits", '${signInData.data.wallet}');
          prefs.setString("user_city", '${signInData.data.user_city}');
          prefs.setString("user_area", '${signInData.data.user_area}');
          prefs.setString("block", '${signInData.data.block}');
          prefs.setString("app_update", '${signInData.data.app_update}');
          prefs.setString("reg_date", '${signInData.data.reg_date}');
          prefs.setBool("phoneverifed", true);
          prefs.setBool("islogin", true);
          prefs.setString("refferal_code", '${signInData.data.referral_code}');
          prefs.setString("reward", '${signInData.data.rewards}');
          Navigator.of(context).pushNamedAndRemoveUntil(PageRoutes.homePage, (Route<dynamic> route) => false);
        }
        setState(() {
          showDialogBox = false;
        });
      } else {
        setState(() {
          showDialogBox = false;
        });
      }
    }).catchError((e) {
      print(e);
      setState(() {
        showDialogBox = false;
      });
    });
  }

  void hitFirebaseSuccessLoginStatus(
      String status, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = loginVerifyViaFirebaseUri;
    await http.post(url, body: {
      'user_phone': '${user_phone}',
      'status': status,
    }).then((response) {
      print('Response Body: - ${response.body}');
      if (response.statusCode == 200) {
        print('Response Body: - ${response.body}');
        var jsonData = jsonDecode(response.body);
        SignInModel signInData = SignInModel.fromJson(jsonData);
        if('${signInData.status}' == '1'){
          var userId = int.parse('${signInData.data.user_id}');
          prefs.setInt("user_id", userId);
          prefs.setString("user_name", '${signInData.data.user_name}');
          prefs.setString("user_email", '${signInData.data.user_email}');
          prefs.setString("user_image", '${signInData.data.user_image}');
          prefs.setString("user_phone", '${signInData.data.user_phone}');
          prefs.setString("user_password", '${signInData.data.user_password}');
          prefs.setString("wallet_credits", '${signInData.data.wallet}');
          prefs.setString("user_city", '${signInData.data.user_city}');
          prefs.setString("user_area", '${signInData.data.user_area}');
          prefs.setString("block", '${signInData.data.block}');
          prefs.setString("app_update", '${signInData.data.app_update}');
          prefs.setString("reg_date", '${signInData.data.reg_date}');
          prefs.setBool("phoneverifed", true);
          prefs.setBool("islogin", true);
          prefs.setString("refferal_code", '${signInData.data.referral_code}');
          prefs.setString("reward", '${signInData.data.rewards}');
          Navigator.of(context).pushNamedAndRemoveUntil(PageRoutes.homePage, (Route<dynamic> route) => false);
        }
        setState(() {
          showDialogBox = false;
        });
      } else {
        setState(() {
          showDialogBox = false;
        });
      }
    }).catchError((e) {
      setState(() {
        showDialogBox = false;
      });
    });
  }
}