import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flat_segmented_control/flat_segmented_control.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_launch/flutter_launch.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:grocery/Components/drawer.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Pages/Other/timerview.dart';
import 'package:grocery/Pages/locpage/locationpage.dart';
import 'package:grocery/Pages/notificationactvity/notificaitonact.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/appinfo.dart';
import 'package:grocery/beanmodel/appnotice/appnotice.dart';
import 'package:grocery/beanmodel/banner/bannerdeatil.dart';
import 'package:grocery/beanmodel/cart/addtocartbean.dart';
import 'package:grocery/beanmodel/cart/cartitembean.dart';
import 'package:grocery/beanmodel/category/topcategory.dart';
import 'package:grocery/beanmodel/deal/dealproduct.dart';
import 'package:grocery/beanmodel/fourtopcat.dart';
import 'package:grocery/beanmodel/productbean/productwithvarient.dart';
import 'package:grocery/beanmodel/singleapibean.dart';
import 'package:grocery/beanmodel/storefinder/storefinderbean.dart';
import 'package:grocery/beanmodel/tablist.dart';
import 'package:grocery/beanmodel/whatsnew/whatsnew.dart';
import 'package:grocery/beanmodel/wishlist/wishdata.dart';
import 'package:grocery/providergrocery/cartcountprovider.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';


FirebaseMessaging messaging = FirebaseMessaging.instance;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  '1234', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
);
Future<void> myBackgroundMessageHandler(RemoteMessage message) async {
  _showNotification(
      flutterLocalNotificationsPlugin,
      '${message.notification.title}',
      '${message.notification.body}');
}


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var _current = 0;
  bool islogin = false;
  dynamic _scanBarcode;
  String store_id = '';
  String storeName = '';
  String shownMessage = '';
  StoreFinderData storeFinderData;
  List<BannerDataModel> bannerList = [];
  // List<WhatsNewDataModel> whatsNewList = [];
  // List<WhatsNewDataModel> recentSaleList = [];
  // List<WhatsNewDataModel> topSaleList = [];
  // List<DealProductDataModel> dealProductList = [];
  List<TopCategoryDataModel> topCategoryList = [];
  List<WishListDataModel> wishModel = [];
  List<TopCategoryProductData> topcct = [];
  dynamic userName;
  bool singleLoading = true;
  bool singleToLoading = true;
  bool bannerLoading = true;
  bool loci = true;
  bool topCatLoading = true;
  bool topSellingLoading = true;
  bool whatsnewLoading = true;
  bool recentSaleLoading = true;
  bool dealProductLoading = true;

  dynamic lat;
  dynamic lng;
  CameraPosition kGooglePlex = CameraPosition(
    target: LatLng(40.866813, 34.566688),
    zoom: 19.151926,
  );
  String currentAddress = "";
  Completer<GoogleMapController> _controller = Completer();

  String apCurrency;

  String appnoticetext = '';
  bool appnoticeStatus = false;

  int _counter = 0;
  var _NotiCounter = 0;

  AppInfoModel appinfom;

  bool progressadd = false;

  List<CartItemData> cartItemd = [];
  TabController tabController;
  List<Tablist> tabList = [];
  List<TabsD> tabDataList = [];
  int selectTabt = -1;

  TabController _tabC;

  Future<void> _goToTheLake(lat, lng) async {
    // final CameraPosition _kLake = CameraPosition(
    //     bearing: 192.8334901395799,
    //     target: LatLng(lat, lng),
    //     tilt: 59.440717697143555,
    //     zoom: 19.151926040649414);
    setState(() {
      this.lat = lat;
      this.lng = lng;
    });
    kGooglePlex = CameraPosition(
      target: LatLng(lat, lng),
      zoom: 19.151926,
    );
    getStoreId();
    // final GoogleMapController controller = await _controller.future;
    // controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  // GlobalKey<ScaffoldState> scafKey = new GlobalKey<ScaffoldState>();

  void scanProductCode(BuildContext context) async {
    await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", "Cancel", true, ScanMode.DEFAULT)
        .then((value) {
      if(value!=null && value.length>0 && '$value'!='-1'){
        setState(() {
          _scanBarcode = value;
        });
        print('scancode - ${_scanBarcode}');
        Navigator.pushNamed(context, PageRoutes.search, arguments: {
          'ean_code': _scanBarcode,
          'storedetails': storeFinderData,
        }).then((valued) {
          // getCartList();
        });
      }
    }).catchError((e) {});
  }

  void getSharedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      islogin = prefs.getBool('islogin');
      userName = prefs.getString('user_name');
      apCurrency = prefs.getString('app_currency');
    });
  }
  CartCountProvider cartCounterProvider;
  // PageController _pageController;
  Duration pageTurnDuration = Duration(milliseconds: 500);
  Curve pageTurnCurve = Curves.ease;

  @override
  void initState() {
    tabController = new TabController(length: 3, vsync: this);
    _tabC = TabController(length: 5, vsync: this);
    // _pageController = PageController();
    setFirebase();
    super.initState();
    cartCounterProvider = BlocProvider.of<CartCountProvider>(context);
    getSharedValue();
    getCartList();
    hitAppInfo();
    hitAppNotice();
    _getLocation();

    // hitAsyncList();
  }

  void setFirebase() async {
    try{
      await Firebase.initializeApp();
    }catch(e){

    }
    messaging = FirebaseMessaging.instance;
    iosPermission(messaging);
    var initializationSettingsAndroid =
    AndroidInitializationSettings('icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
    messaging.getToken().then((value) {
      debugPrint('token: $value');
    });
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      if (message != null) {
        _showNotification(
            flutterLocalNotificationsPlugin,
            '${message.notification.title}',
            '${message.notification.body}');
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                // TODO add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                icon: 'icon',
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      _showNotification(
          flutterLocalNotificationsPlugin,
          '${message.notification.title}',
          '${message.notification.body}');
    });
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  }


  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // var message = jsonDecode('${payload}');
    _showNotification(flutterLocalNotificationsPlugin, '${title}', '${body}');
  }

  Future selectNotification(String payload) async {}



  void iosPermission(FirebaseMessaging firebaseMessaging) {
    if(Platform.isIOS){
      firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    // firebaseMessaging.requestNotificationPermissions(
    //     IosNotificationSettings(sound: true, badge: true, alert: true));
    // firebaseMessaging.onIosSettingsRegistered.listen((event) {
    //   print('${event.provisional}');
    // });
  }


  void hitAsyncList() async {
    getWislist();
    getSingleAPi();
    getTopCatPAPi();
  }

  void getWislist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic userId = prefs.getInt('user_id');
    var url = showWishlistUri;
    var http = Client();
    http.post(url, body: {
      'user_id': '${userId}',
      'store_id': '${store_id}'
    }).then((value) {
      print('resp - ${value.body}');
      if (value.statusCode == 200) {
        WishListModel data1 = WishListModel.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            wishModel.clear();
            wishModel = List.from(data1.data);
          });
        }
      }
    }).catchError((e) {});
  }

  void getSingleAPi() async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      singleLoading = true;
    });
    var http = Client();
    http.post(oneApiUri, body: {'store_id': '${store_id}'}).then((value) {
      if (value.statusCode == 200) {
        print(value.body);
        SingleApiHomePage data1 =
            SingleApiHomePage.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            bannerList.clear();
            bannerList = List.from(data1.banner);
            topCategoryList.clear();
            topCategoryList = List.from(data1.topCat);
            if (topCategoryList != null && topCategoryList.length > 0) {
              topCategoryList
                  .add(TopCategoryDataModel('', '', 'See all', '', '', '', ''));
            }

            tabList.clear();
            if(data1.tabs!=null && data1.tabs.length>0){
              for(int i=0;i<data1.tabs.length;i++){
                tabList.add(Tablist('${data1.tabs[i].type}', i));
              }
            }
            if(tabList!=null && tabList.length>0){
              selectTabt = tabList[0].identifier;
            }
            tabDataList.clear();
            tabDataList = List.from(data1.tabs);
          });
        }
      }
      setState(() {
        singleLoading = false;
      });
    }).catchError((e) {
      setState(() {
        singleLoading = false;
      });
      print(e);
    });
  }

  void getTopCatPAPi() async {
    setState(() {
      singleToLoading = true;
    });
    var http = Client();
    http.post(topCatPrductUri, body: {'store_id': '${store_id}'}).then((value) {
      if (value.statusCode == 200) {
        TopCategoryProduct data1 =
        TopCategoryProduct.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            topcct.clear();
            topcct = List.from(data1.data);
          });
        }
      }
      setState(() {
        singleToLoading = false;
      });
    }).catchError((e) {
      setState(() {
        singleToLoading = false;
      });
      print(e);
    });
  }

  void hitAppInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var http = Client();
    http.post(appInfoUri, body: {
      'user_id':
          '${(prefs.containsKey('user_id')) ? prefs.getInt('user_id') : ''}'
    }).then((value) {
      print(value.body);
      if (value.statusCode == 200) {
        AppInfoModel data1 = AppInfoModel.fromJson(jsonDecode(value.body));
        print('data - ${data1.toString()}');
        if ('${data1.status}' == '1') {
          setState(() {
            apCurrency = '${data1.currencySign}';
            _counter = int.parse('${data1.totalItems}');
            appinfom = data1;
          });
          prefs.setString('app_currency', '${data1.currencySign}');
          prefs.setString('app_referaltext', '${data1.refertext}');
          prefs.setString('app_name', '${data1.appName}');
          prefs.setString('country_code', '${data1.countryCode}');
          prefs.setString('numberlimit', '${data1.phoneNumberLength}');
          prefs.setInt('last_loc', int.parse('${data1.lastLoc}'));
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  void hitAppNotice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var http = Client();
    http.get(appNoticeUri).then((value) {
      print('wert - ${value.body}');
      if (value.statusCode == 200) {
        AppNotice data1 = AppNotice.fromJson(jsonDecode(value.body));
        print('data - ${data1.toString()}');
        if ('${data1.status}' == '1') {
          setState(() {
            appnoticetext = '${data1.data.notice}';
            appnoticeStatus = ('${data1.data.status}' == '1');
            print('notice text - $appnoticetext');
          });
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  int index = 0;
  int selectedInd = 0;


  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        drawer: buildDrawer(context, userName, islogin, onHit: () {
          SharedPreferences.getInstance().then((pref) {
            pref.clear().then((value) {
              // Navigator.pushAndRemoveUntil(_scaffoldKey.currentContext,
              //     MaterialPageRoute(builder: (context) {return GroceryLogin();}),
              //         (Route<dynamic> route) => false);
              Navigator.of(context).pushNamedAndRemoveUntil(
                  PageRoutes.signInRoot, (Route<dynamic> route) => false);
            });
          });
        }),
        body: IndexedStack(
          index: index,
          children: [
            Column(
              children: [
                Container(
                  height: 70,
                  width: MediaQuery.of(context).size.width,
                  color: kMainTextColor,
                  child: Stack(
                    children: [
                      // Image.asset('assets/header.png',fit: BoxFit.fill,),
                      Container(
                        height: 52,
                        margin: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10),
                        decoration: BoxDecoration(
                          color: kWhiteColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: AppBar(
                          actions: [
                            Visibility(
                              visible: (storeFinderData != null &&
                                  storeFinderData.store_id != null),
                              child: IconButton(
                                icon: ImageIcon(AssetImage(
                                  'assets/scanner_logo.png',
                                )),
                                onPressed: () async {
                                  scanProductCode(context);
                                },
                              ),
                            ),
                            BlocBuilder<CartCountProvider, int>(
                                builder: (context,cartCount){
                                  return Badge(
                                    position: BadgePosition.topEnd(top: 5, end: 5),
                                    padding: EdgeInsets.all(5),
                                    animationDuration: Duration(milliseconds: 300),
                                    animationType: BadgeAnimationType.slide,
                                    badgeContent: Text(
                                      cartCount.toString(),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 10),
                                    ),
                                    child: IconButton(
                                      icon: ImageIcon(AssetImage(
                                        'assets/ic_cart.png',
                                      )),
                                      onPressed: () async {
                                        SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                        if (prefs.containsKey('islogin') &&
                                            prefs.getBool('islogin')) {
                                          Navigator.pushNamed(
                                              context, PageRoutes.cartPage)
                                              .then((valued) {
                                            // getCartList();
                                          });
                                        } else {
                                          Toast.show(locale.loginfirst, context,
                                              gravity: Toast.CENTER,
                                              duration: Toast.LENGTH_SHORT);
                                        }
                                      },
                                    ),
                                  );
                                }),
                            IconButton(
                              icon: Icon(
                                Icons.my_location,
                              ),
                              iconSize: 25,
                              onPressed: () {
                                showAlertDialog(
                                    context, locale, currentAddress);
                                // _getLocation();
                              },
                            )
                          ],
                          title: TextFormField(
                            readOnly: true,
                            onTap: () {
                              if (storeFinderData != null) {
                                int typed;
                                if('${tabDataList[selectTabt].type}'.toUpperCase()=='RECENT SELLING'){
                                  typed = 1;
                                }else if('${tabDataList[selectTabt].type}'.toUpperCase()=='TOP SELLING'){
                                  typed = 0;
                                }else if('${tabDataList[selectTabt].type}'.toUpperCase()=='WHATS NEW'){
                                  typed = 2;
                                }else if('${tabDataList[selectTabt].type}'.toUpperCase()=='DEAL PRODUCTS'){
                                  typed = 3;
                                }
                                Navigator.pushNamed(
                                    context, PageRoutes.searchhistory,
                                    arguments: {
                                      'category': topCategoryList,
                                      'recentsale': tabDataList[selectTabt].data,
                                      'storedetails': storeFinderData,
                                      'wishlist': wishModel,
                                      'type': typed,
                                      'title':'${tabDataList[selectTabt].type}'.toUpperCase()
                                    }).then((value) {
                                  getWislist();
                                  // getCartList();
                                });
                              }
                            },
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                .copyWith(color: Colors.black, fontSize: 18),
                            decoration: InputDecoration(
                                hintText: '${locale.searchOnGoGrocer}$appname',
                                hintStyle:
                                Theme.of(context).textTheme.subtitle2,
                                contentPadding:
                                EdgeInsets.symmetric(vertical: 10),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: (appnoticeStatus &&
                      appnoticetext != null &&
                      appnoticetext.length > 15),
                  child: Container(
                    height: 20,
                    // margin: EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      color: kMainTextColor,
                      // image: DecorationImage(
                      //   image: AssetImage('assets/header.png'),
                      //   fit: BoxFit.fill
                      // )
                    ),
                    alignment: Alignment.center,
                    child: (appnoticeStatus &&
                        appnoticetext != null &&
                        appnoticetext.length > 15)
                        ? Marquee(
                      text: appnoticetext,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kMarqueeColor),
                      scrollAxis: Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      blankSpace: 5.0,
                      velocity: 100.0,
                      pauseAfterRound: Duration(seconds: 1),
                      startPadding: 10.0,
                      accelerationDuration: Duration(seconds: 1),
                      accelerationCurve: Curves.linear,
                      decelerationDuration: Duration(milliseconds: 500),
                      decelerationCurve: Curves.easeOut,
                    )
                        : SizedBox.shrink(),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: (loci && storeFinderData != null || singleLoading)
                        ? SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      primary: true,
                      child: Column(
                        // mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 118,
                            alignment: Alignment.centerLeft,
                            child: ListView.builder(
                                physics: BouncingScrollPhysics(),
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: topCategoryList.length,
                                itemBuilder: (contexts, index) {
                                  return buildCategoryRow(
                                      context,
                                      topCategoryList[index],
                                      storeFinderData);
                                }),
                          ),
                          (bannerList!=null && bannerList.length>0)?Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: 5.0),
                              Stack(
                                children: [
                                  CarouselSlider(
                                    items: bannerList.map((i) {
                                      return Builder(
                                        builder: (BuildContext context) {
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(context,
                                                  PageRoutes.cat_product,
                                                  arguments: {
                                                    'title': i.title,
                                                    'storeid': storeFinderData
                                                        .store_id,
                                                    'cat_id': i.cat_id,
                                                    'storedetail':
                                                    storeFinderData,
                                                  }).then((valuef) {
                                                // getCartList();
                                              });
                                            },
                                            child: Container(
                                                child: CachedNetworkImage(
                                                  imageUrl: '${i.banner_image}',
                                                  placeholder: (context, url) =>
                                                      Align(
                                                        widthFactor: 50,
                                                        heightFactor: 50,
                                                        alignment: Alignment.center,
                                                        child: Container(
                                                          padding:
                                                          const EdgeInsets.all(
                                                              5.0),
                                                          width: 50,
                                                          height: 50,
                                                          child:
                                                          CircularProgressIndicator(),
                                                        ),
                                                      ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                      Image.asset(
                                                          'assets/icon.png'),
                                                )
                                              //     Image(
                                              //   image: NetworkImage(i.banner_image),
                                              // )
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                                    options: CarouselOptions(
                                        autoPlay: true,
                                        viewportFraction: 1.0,
                                        enlargeCenterPage: false,
                                        onPageChanged: (index, reason) {
                                          setState(() {
                                            _current = index;
                                          });
                                        }),
                                  ),
                                  Positioned.directional(
                                    textDirection: Directionality.of(context),
                                    start: 20.0,
                                    bottom: 0.0,
                                    child: Row(
                                      children: bannerList.map((i) {
                                        int index = bannerList.indexOf(i);
                                        return Container(
                                          width: 12.0,
                                          height: 3.0,
                                          margin: EdgeInsets.symmetric(
                                              vertical: 16.0,
                                              horizontal: 4.0),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.rectangle,
                                            color: _current == index
                                                ? Colors
                                                .white /*.withOpacity(0.9)*/
                                                : Colors.white
                                                .withOpacity(0.5),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ):SizedBox.shrink(),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            height: 60,
                            child: ListView.builder(
                                itemCount: tabList.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context,index){
                                  return GestureDetector(
                                    onTap: (){
                                      setState(() {
                                        selectTabt = tabList[index].identifier;
                                      });
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Card(
                                      color: (tabList[index].identifier==selectTabt)?kMainColor:kWhiteColor,
                                      elevation: 0.5,
                                      child: Container(
                                        width: MediaQuery.of(context).size.width*0.42,
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.symmetric(horizontal: 1,vertical: 5),
                                        margin: EdgeInsets.only(),
                                        child: Text(tabList[index].tabString,textAlign: TextAlign.center,style: TextStyle(
                                            fontSize: 16,
                                            color:(tabList[index].identifier==selectTabt)?kWhiteColor:kMainTextColor
                                        ),),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                          (tabDataList!=null && tabDataList.length>0 && selectTabt!=-1)?ListView.builder(
                              itemCount:tabDataList[selectTabt].data.length,
                              shrinkWrap: true,
                              primary: false,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context,index){
                                return GestureDetector(
                                  onTap: (){
                                    if('${tabDataList[selectTabt].data[index].productName}'=='See all'){
                                      int typed;
                                      if('${tabDataList[selectTabt].type}'.toUpperCase()=='RECENT SELLING'){
                                        typed = 1;
                                      }else if('${tabDataList[selectTabt].type}'.toUpperCase()=='TOP SELLING'){
                                        typed = 0;
                                      }else if('${tabDataList[selectTabt].type}'.toUpperCase()=='WHATS NEW'){
                                        typed = 2;
                                      }else if('${tabDataList[selectTabt].type}'.toUpperCase()=='DEAL PRODUCTS'){
                                        typed = 3;
                                      }
                                      Navigator.pushNamed(context, PageRoutes.viewall, arguments: {
                                        'title': tabDataList[selectTabt].type,
                                        'type': typed,
                                        'storedetail': storeFinderData,
                                      });
                                    }else{
                                      int idd = wishModel.indexOf(WishListDataModel('', '',
                                          '${tabDataList[selectTabt].data[index].varientId}', '', '', '', '', '', '', '', '', '', '','',''));
                                      Navigator.pushNamed(context, PageRoutes.product, arguments: {
                                        'pdetails': tabDataList[selectTabt].data[index],
                                        'storedetails': storeFinderData,
                                        'isInWish': (idd >= 0),
                                      });
                                    }

                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 12),
                                    child: ('${tabDataList[selectTabt].data[index].productName}'=='See all')?Material(
                                      elevation: 0.4,
                                      borderRadius: BorderRadius.circular(10),
                                      clipBehavior: Clip.antiAlias,
                                      color: kMainColor,
                                      child: Container(
                                        height: 52,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('${tabDataList[selectTabt].data[index].productName}',style: TextStyle(fontSize: 14,color: kWhiteColor),),
                                            Icon(
                                                Icons.arrow_forward_ios,
                                                size: 15,
                                                color: kWhiteColor
                                            )
                                          ],
                                        ),
                                      ),
                                    ):Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Material(
                                        elevation: 0.4,
                                        borderRadius: BorderRadius.circular(10),
                                        clipBehavior: Clip.antiAlias,
                                        color: kWhiteColor,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Stack(
                                            children: [
                                              Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      children: [
                                                        ClipRRect(
                                                            borderRadius: BorderRadius.circular(10),
                                                            child: Image.network(
                                                              tabDataList[selectTabt].data[index].productImage,
                                                              width: 90,
                                                              height: 95,
                                                            )),
                                                        SizedBox(
                                                          width: 15,
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                tabDataList[selectTabt].data[index].productName,
                                                                style: Theme.of(context).textTheme.subtitle1.copyWith(fontSize: 15),
                                                              ),
                                                              SizedBox(
                                                                height: 8,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    '${tabDataList[selectTabt].data[index].quantity} ${tabDataList[selectTabt].data[index].unit}',
                                                                    style: Theme.of(context).textTheme.subtitle2,
                                                                  ),
                                                                  (tabDataList[selectTabt].data[index].validTo!=null)?TimerView(
                                                                    dateTime: DateTime.parse(DateFormat('yyyy-MM-dd HH:mm:ss')
                                                                        .format(DateTime.parse('${tabDataList[selectTabt].data[index].validTo}'))),
                                                                    // DateTime.now().add(Duration(
                                                                    //     hours: DateTime.parse(DateFormat('yyyy-MM-dd hh:mm:ss')
                                                                    //         .format(DateTime.parse('${tabDataList[selectTabt].data[index].validTo}'))).hour)
                                                                    // ),
                                                                    fontSize: 10,
                                                                  ):SizedBox.shrink(),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 20,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Visibility(
                                                                    visible:(int.parse('${tabDataList[selectTabt].data[index].stock}') > 0),
                                                                    child: Row(
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      children: [
                                                                        buildIconButton(
                                                                            Icons.remove,context,onpressed: (){
                                                                          if (int.parse('${tabDataList[selectTabt].data[index].qty}') > 0 && !progressadd) {
                                                                            // int idd = topcct[listtype].products.indexOf(products);
                                                                            addtocart2('${tabDataList[selectTabt].data[index].storeId}', '${tabDataList[selectTabt].data[index].varientId}', (int.parse('${tabDataList[selectTabt].data[index].qty}') - 1), '0', context, index, selectTabt);
                                                                          }
                                                                        }),
                                                                        SizedBox(
                                                                          width: 15,
                                                                        ),
                                                                        Text('${tabDataList[selectTabt].data[index].qty}', style: Theme.of(context)
                                                                            .textTheme
                                                                            .subtitle1),
                                                                        SizedBox(
                                                                          width: 15,
                                                                        ),
                                                                        buildIconButton(
                                                                            Icons.add,context,type: 1,
                                                                            onpressed: (){

                                                                              if ((int.parse('${tabDataList[selectTabt].data[index].qty}') + 1) <=
                                                                                  int.parse('${tabDataList[selectTabt].data[index].stock}') && !progressadd) {
                                                                                // int idd = topcct[listtype].products.indexOf(products);
                                                                                addtocart2('${tabDataList[0].data[index].storeId}', '${tabDataList[selectTabt].data[index].varientId}', (int.parse('${tabDataList[selectTabt].data[index].qty}') + 1), '0', context, index, selectTabt);
                                                                              } else {
                                                                                if(!progressadd){
                                                                                  Toast.show('no more stock for this product', context,
                                                                                      duration: Toast.LENGTH_SHORT,
                                                                                      gravity: Toast.CENTER);
                                                                                }
                                                                              }
                                                                            }),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  SizedBox(width: 10,),
                                                                  Expanded(
                                                                    child: Row(
                                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                                      children: [
                                                                        Text('$apCurrency ${tabDataList[selectTabt].data[index].price}',
                                                                            textAlign: TextAlign.right,
                                                                            style: Theme.of(context).textTheme.subtitle1.copyWith(
                                                                                fontSize: 12
                                                                            )),
                                                                        Visibility(
                                                                          visible:
                                                                          ('${tabDataList[selectTabt].data[index].price}' == '${tabDataList[selectTabt].data[index].mrp}') ? false : true,
                                                                          child: Padding(
                                                                            padding: const EdgeInsets.only(left: 8.0),
                                                                            child: Text('$apCurrency ${tabDataList[selectTabt].data[index].mrp}',
                                                                                style: TextStyle(
                                                                                    color: Colors.grey[600],
                                                                                    fontWeight: FontWeight.w300,
                                                                                    fontSize: 11,
                                                                                    decoration: TextDecoration.lineThrough)),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 4,
                                                  ),
                                                  Visibility(
                                                    visible:(int.parse('${tabDataList[selectTabt].data[index].stock}') <= 0),
                                                    child: Container(
                                                      height: 15,
                                                      alignment: Alignment.center,
                                                      decoration: BoxDecoration(
                                                        color: kCardBackgroundColor,
                                                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10)),
                                                      ),
                                                      child: Text(
                                                        'Out of stock',
                                                        textAlign: TextAlign.center,
                                                        maxLines: 1,
                                                        style: TextStyle(fontSize: 13,color: kRedColor),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              ((((double.parse('${tabDataList[selectTabt].data[index].mrp}') - double.parse('${tabDataList[selectTabt].data[index].price}'))/double.parse('${tabDataList[selectTabt].data[index].mrp}'))*100)>0)?Align(
                                                alignment: Alignment.topLeft,
                                                child: Container(
                                                    padding: const EdgeInsets.all(3.0),
                                                    margin: const EdgeInsets.only(top: 8),
                                                    decoration: BoxDecoration(
                                                      color: kPercentageBackC,
                                                      borderRadius: BorderRadius.only(topRight: Radius.circular(10),bottomRight: Radius.circular(10)),
                                                    ),
                                                    child: Text('${(((double.parse('${tabDataList[selectTabt].data[index].mrp}') - double.parse('${tabDataList[selectTabt].data[index].price}'))/double.parse('${tabDataList[selectTabt].data[index].mrp}'))*100).toStringAsFixed(2)} %',style: TextStyle(color:kWhiteColor,fontWeight: FontWeight.w500,fontSize: 12),)),
                                              ):SizedBox.shrink(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }):SizedBox.shrink(),
                          (!singleLoading && topcct!=null && topcct.length>0)
                              ? Visibility(
                            visible: (topcct != null &&
                                topcct.length > 0),
                            child: ListView.builder(
                                itemCount: topcct.length,
                                shrinkWrap: true,
                                primary: false,
                                itemBuilder: (context,index){
                                  return buildCompleteVerticalList(
                                      locale,
                                      context,
                                      topcct[index].products,
                                      topcct[index].title,
                                      wishModel, () {
                                    getWislist();
                                  }, storeFinderData,
                                      listtype: index);
                                }),
                          ) : buildCompleteVerticalSHList(context),
                          SizedBox(height: 35.0),
                        ],
                      ),
                    )
                        : Align(
                      alignment: Alignment.center,
                      child: Text(shownMessage),
                    ),
                  ),
                ),
              ],
            ),
            NotificationShow(),
          ],
        ),
        bottomNavigationBar:
        ConvexAppBar(
          items: [
            //
            TabItem(icon: Icons.home, title: 'Home'),
            TabItem(icon: Icon(Icons.category,color: kWhiteColor,), title: 'Categories'),
            TabItem(icon: Icons.search, title: 'Search'),
            TabItem(icon: Badge(
              padding: EdgeInsets.all(5),
              animationDuration: Duration(milliseconds: 300),
              animationType: BadgeAnimationType.slide,
              badgeContent: Text(
                _NotiCounter.toString(),
                style: TextStyle(color: kWhiteColor, fontSize: 10),
              ),
              child: Icon(
                Icons.notifications,
                color: selectedInd==3?kMainColor:kWhiteColor,
              ),
            ), title: 'Notification',),
            TabItem(icon: BlocBuilder<CartCountProvider, int>(
                builder: (context,cartCount){
                  return Badge(
                    padding: EdgeInsets.all(5),
                    animationDuration: Duration(milliseconds: 300),
                    animationType: BadgeAnimationType.slide,
                    badgeContent: Text(
                      cartCount.toString(),
                      style: TextStyle(
                          color: kWhiteColor, fontSize: 10),
                    ),
                    child: ImageIcon(
                      AssetImage(
                        'assets/ic_cart.png',
                      ),
                      size: 20,
                      color: selectedInd == 4 ? kMainColor : kWhiteColor,
                    ),
                  );
                }), title: 'Cart',),
          ],
          color: kCardBackgroundColor,
          // cornerRadius: 15,
          backgroundColor: kMainColor,
          initialActiveIndex: selectedInd,
          disableDefaultTabController: true,
          onTabNotify: (int indi) {
            print(indi);
            if(indi==4){
              hitCart(context,locale);
              return false;
            }else if(indi==1){
              if(loci){
                hitCategroyAllbtn(context);
              }
              return false;
            }else if(indi==2){
              if(loci){
                hitSearchIndex(context);
              }
              return false;
            }else if(indi==3 ){
              return true;
            }else{
              return true;
            }
          },
          controller: _tabC,
          onTap: (int newIndex) {
            print(newIndex);
            if (newIndex == 0) {
              setState(() {
                selectedInd = newIndex;
                index = 0;
              });
            } else if (newIndex == 3) {
              setState(() {
                selectedInd = newIndex;
                index = 1;
              });
            }
          },
        ),
        // BottomNavigationBar(
        //   onTap: (newIndex) {

        //   },
        //   currentIndex: index,
        //   items: [
        //     new BottomNavigationBarItem(
        //       icon: new Icon(
        //         Icons.home,
        //         color: selectedInd == 0 ? kMainColor : kMainTextColor,
        //       ),
        //       title: new Text("Home",
        //           style: TextStyle(
        //             fontSize: 12.0,
        //             color: selectedInd == 0 ? kMainColor : kMainTextColor,
        //           )),
        //     ),
        //     new BottomNavigationBarItem(
        //       icon: new Icon(
        //         Icons.wallet_giftcard,
        //         color: selectedInd == 1 ? kMainColor : kMainTextColor,
        //       ),
        //       title: new Text(
        //         "Categories",
        //         style: TextStyle(
        //           fontSize: 12.0,
        //           color: selectedInd == 1 ? kMainColor : kMainTextColor,
        //         ),
        //       ),
        //     ),
        //     new BottomNavigationBarItem(
        //       icon: new Icon(
        //         Icons.search,
        //         color: selectedInd == 2 ? kMainColor : kMainTextColor,
        //       ),
        //       title: new Text(
        //         "Search",
        //         style: TextStyle(
        //           fontSize: 12.0,
        //           color: selectedInd == 2 ? kMainColor : kMainTextColor,
        //         ),
        //       ),
        //     ),
        //     new BottomNavigationBarItem(
        //       icon: Badge(
        //         position: BadgePosition.topEnd(top: 5, end: 6),
        //         padding: EdgeInsets.all(5),
        //         animationDuration: Duration(milliseconds: 300),
        //         animationType: BadgeAnimationType.slide,
        //         badgeContent: Text(
        //           _NotiCounter.toString(),
        //           style: TextStyle(color: Colors.white, fontSize: 10),
        //         ),
        //         child: IconButton(
        //             icon: Icon(
        //           Icons.notifications,
        //           color: selectedInd == 3 ? kMainColor : kMainTextColor,
        //         )),
        //       ),
        //       title: new Text("Notification",
        //           style: TextStyle(
        //             fontSize: 12.0,
        //             color: selectedInd == 3 ? kMainColor : kMainTextColor,
        //           )),
        //     ),
        //
        //     new BottomNavigationBarItem(
        //       icon: BlocBuilder<CartCountProvider, int>(
        //           builder: (context,cartCount){
        //             return Badge(
        //               position: BadgePosition.topEnd(top: 5, end: 5),
        //               padding: EdgeInsets.all(5),
        //               animationDuration: Duration(milliseconds: 300),
        //               animationType: BadgeAnimationType.slide,
        //               badgeContent: Text(
        //                 cartCount.toString(),
        //                 style: TextStyle(
        //                     color: Colors.white, fontSize: 10),
        //               ),
        //               child: IconButton(
        //                 icon: ImageIcon(
        //                   AssetImage(
        //                     'assets/ic_cart.png',
        //                   ),
        //                   size: 20,
        //                   color: selectedInd == 4 ? kMainColor : kMainTextColor,
        //                 ),
        //                 onPressed: () {
        //                   hitCart(context, locale);
        //                 },
        //               ),
        //             );
        //           }),
        //       // new Icon(Icons.shopping_cart,color: selectedInd==4?kMainColor:kMainTextColor,),
        //       title: new Text("Cart",
        //           style: TextStyle(
        //             fontSize: 12.0,
        //             color: selectedInd == 4 ? kMainColor : kMainTextColor,
        //           )),
        //     ),
        //   ],
        // ),
        floatingActionButton: SpeedDial(
            marginEnd: 10,
            marginBottom: 30,
            animatedIcon: AnimatedIcons.menu_close,
            // animatedIconColor:Colors.white,
            animatedIconTheme: IconThemeData(size: 22.0),
            closeManually: false,
            curve: Curves.bounceIn,
            overlayColor: Colors.white,
            overlayOpacity: 0.5,
            onOpen: () => print('OPENING DIAL'),
            onClose: () => print('DIAL CLOSED'),
            tooltip: 'Speed Dial',
            heroTag: 'speed-dial-hero-tag',
            backgroundColor: kMainColor,
            foregroundColor: Colors.white,
            elevation: 8.0,
            shape: CircleBorder(),
            children: [
              SpeedDialChild(
                  child: Icon(Icons.share, color: Colors.white),
                  backgroundColor: kMainColor,
                  labelStyle: TextStyle(fontSize: 18.0),
                  onTap: () {
                    share(locale.shareheading, locale.sharetext);
                  }),
              SpeedDialChild(
                child: Icon(Icons.rate_review, color: Colors.white),
                backgroundColor: kMainColor,
                onTap: () {
                  launchUrl();
                },
              ),
              SpeedDialChild(
                child: Icon(Icons.call, color: Colors.white),
                backgroundColor: kMainColor,
                onTap: () {
                  callNumberStore(storeFinderData.store_number);
                },
              ),
              SpeedDialChild(
                child: ImageIcon(
                    AssetImage(
                      'assets/whatsapp.png',
                    ),
                    size: 20,
                    color: kWhiteColor),
                backgroundColor: kMainColor,
                onTap: () {
                  openWhatsApp(storeFinderData.store_number,
                      locale.nowhatsappinstalled, context);
                },
              ),
            ]),
      ),
    );
  }

  void addtocart(String storeid, String varientid, dynamic qnty, String special,
      BuildContext context, int index, int listtype) async {
    setState(() {
      progressadd = true;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var http = Client();
    http.post(addToCartUri, body: {
      'user_id': '${preferences.getInt('user_id')}',
      'qty': '${int.parse('$qnty')}',
      'store_id': '${int.parse('$storeid')}',
      'varient_id': '${int.parse('$varientid')}',
      'special': '${special}',
    }).then((value) {
      print('cart add${value.body}');
      if (value.statusCode == 200) {
        AddToCartMainModel data1 =
            AddToCartMainModel.fromJson(jsonDecode(value.body));
        if ('${data1.status}' == '1') {
          int dii = data1.cart_items.indexOf(AddToCartItem(
            '',
            '',
            '',
            '',
            '',
            '$varientid',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
          ));
          print('cart add${dii} \n $storeid \n $varientid');
          setState(() {
            if (dii >= 0) {
              topcct[listtype].products[index].qty = data1.cart_items[dii].qty;
            } else {
              topcct[listtype].products[index].qty = 0;
            }
            _counter = data1.cart_items.length;
            cartCounterProvider.hitCartCounter(_counter);
          });
        } else {
          setState(() {
            topcct[listtype].products[index].qty = 0;
            _counter = 0;
          });
        }
        Toast.show(data1.message, context,
            gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
      }
      setState(() {
        progressadd = false;
      });
    }).catchError((e) {
      setState(() {
        progressadd = false;
      });
      print(e);
    });
  }

  void addtocart2(String storeid, String varientid, dynamic qnty, String special,
      BuildContext context, int index, int listtype) async {
    setState(() {
      progressadd = true;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var http = Client();
    http.post(addToCartUri, body: {
      'user_id': '${preferences.getInt('user_id')}',
      'qty': '${int.parse('$qnty')}',
      'store_id': '${int.parse('$storeid')}',
      'varient_id': '${int.parse('$varientid')}',
      'special': '${special}',
    }).then((value) {
      print('cart add${value.body}');
      if (value.statusCode == 200) {
        AddToCartMainModel data1 =
        AddToCartMainModel.fromJson(jsonDecode(value.body));
        if ('${data1.status}' == '1') {
          int dii = data1.cart_items.indexOf(AddToCartItem(
            '',
            '',
            '',
            '',
            '',
            '$varientid',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
          ));
          print('cart add${dii} \n $storeid \n $varientid');
          setState(() {
            if (dii >= 0) {
              tabDataList[listtype].data[index].qty = data1.cart_items[dii].qty;
            } else {
              tabDataList[listtype].data[index].qty = 0;
            }
            _counter = data1.cart_items.length;
            cartCounterProvider.hitCartCounter(_counter);
          });
        } else {
          setState(() {
            tabDataList[listtype].data[index].qty = 0;
            _counter = 0;
          });
        }
        Toast.show(data1.message, context,
            gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
      }
      setState(() {
        progressadd = false;
      });
    }).catchError((e) {
      setState(() {
        progressadd = false;
      });
      print(e);
    });
  }

  Future<void> share(String share, String sharetext) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var applink =
        Platform.isIOS ? appinfom.iosAppLink : appinfom.androidAppLink;
    await FlutterShare.share(
        title: appname,
        text:
            '${appinfom.refertext}\n$sharetext ${prefs.getString('refferal_code')}.',
        linkUrl: '$applink',
        chooserTitle: '$share ${appname}');
  }

  Future<void> launchUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var applink =
        Platform.isIOS ? appinfom.iosAppLink : appinfom.androidAppLink;
    if (await canLaunch(applink)) {
      await launch(applink);
    } else {
      throw 'Could not launch $applink';
    }
  }

  Column buildCompleteVerticalList(
      AppLocalizations locale,
      BuildContext context,
      List<ProductDataModel> products,
      String heading,
      List<WishListDataModel> wishModel,
      Function callback,
      StoreFinderData storeFinderData,
      {int listtype}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Text(heading,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        buildList(products, wishModel, () {
          callback();
        }, apCurrency, storeFinderData, listype: listtype),
      ],
    );
  }

  void _getLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getInt('last_loc') == 0 ||
        (!prefs.containsKey('lat') && !prefs.containsKey('lng'))) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        bool isLocationServiceEnableds =
            await Geolocator.isLocationServiceEnabled();
        if (isLocationServiceEnableds) {
          Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          if (position != null) {
            Timer(Duration(seconds: 5), () async {
              double lat = position.latitude;
              double lng = position.longitude;
              prefs.setString("lat", lat.toStringAsFixed(8));
              prefs.setString("lng", lng.toStringAsFixed(8));
              final coordinates = new Coordinates(lat, lng);
              await Geocoder.local
                  .findAddressesFromCoordinates(coordinates)
                  .then((value) {
                setState(() {
                  currentAddress = value[0].addressLine;
                });
              });
              _goToTheLake(lat, lng);
            });
          } else {
            _getLocation();
          }
        } else {
          await Geolocator.openLocationSettings().then((value) {
            if (value) {
              _getLocation();
            } else {
              Toast.show('Location permission is required!', context,
                  duration: Toast.LENGTH_SHORT);
            }
          }).catchError((e) {
            Toast.show('Location permission is required!', context,
                duration: Toast.LENGTH_SHORT);
          });
        }
      } else if (permission == LocationPermission.denied) {
        LocationPermission permissiond = await Geolocator.requestPermission();
        if (permissiond == LocationPermission.whileInUse ||
            permissiond == LocationPermission.always) {
          _getLocation();
        } else {
          Toast.show('Location permission is required!', context,
              duration: Toast.LENGTH_SHORT);
        }
      } else if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings().then((value) {
          _getLocation();
        }).catchError((e) {
          Toast.show('Location permission is required!', context,
              duration: Toast.LENGTH_SHORT);
        });
      }
    } else {
      lat = double.parse('${prefs.getString('lat')}');
      lng = double.parse('${prefs.getString('lng')}');
      _goToTheLake(lat, lng);
    }
  }

  showAlertDialog(
      BuildContext context, AppLocalizations locale, String currentAddress) {
    Widget clear = GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        clearAllList();
      },
      child: Material(
        elevation: 2,
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Text(
            locale.saveLoc,
            style: TextStyle(fontSize: 13, color: kWhiteColor),
          ),
        ),
      ),
    );

    Widget no = GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        clipBehavior: Clip.hardEdge,
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Text(
            locale.notext,
            style: TextStyle(fontSize: 13, color: kWhiteColor),
          ),
        ),
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            insetPadding:
                EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            title: Text(locale.locateyourself),
            content: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: kGooglePlex,
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    compassEnabled: false,
                    mapToolbarEnabled: false,
                    buildingsEnabled: false,
                    onMapCreated: (GoogleMapController controller) async {
                      if(!_controller.isCompleted){
                        _controller.complete(controller);
                      }
                    },
                    onCameraIdle: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setString("lat", lat.toString());
                      prefs.setString("lng", lng.toString());
                      final coordinates = new Coordinates(lat, lng);
                      return await Geocoder.local
                          .findAddressesFromCoordinates(coordinates)
                          .then((value) {
                        setState(() {
                          currentAddress = value[0].addressLine;
                        });
                        //
                        print('${currentAddress}');
                      });
                    },
                    onCameraMove: (post) {
                      lat = post.target.latitude;
                      lng = post.target.longitude;
                    },
                  ),
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true)
                            .pop('locpage');
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                            color: kWhiteColor,
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
                        child: Row(
                          children: [
                            Icon(
                              Icons.my_location,
                              size: 25,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                '$currentAddress',
                                maxLines: 2,
                                style: TextStyle(
                                    fontSize: 12, color: kMainTextColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 36.0),
                        child: Image.asset(
                          'assets/map_pin.png',
                          height: 36,
                        ),
                      ))
                ],
              ),
            ),
            actions: [clear, no],
          );
        });
      },
    ).then((value) {
      print('dialog value - ${value}');
      if ('$value' == 'locpage') {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return LocationPage(lat, lng);
        })).then((value) {
          print(value);
          setState(() {
            lat = double.parse('${value[0]}');
            lng = double.parse('${value[1]}');
          });
          clearAllList();
        });
      }
    }).catchError((e) {
      print(e);
    });
  }

  void clearAllList() async {
    setState(() {
      bannerList.clear();
      topCategoryList.clear();
      wishModel.clear();
      bannerLoading = true;
      topCatLoading = true;
      topSellingLoading = true;
      whatsnewLoading = true;
      recentSaleLoading = true;
      dealProductLoading = true;
    });
    getStoreId();
  }

  void getStoreId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bannerLoading = true;
    });
    var http = Client();
    http.post(getNearestStoreUri, body: {
      'lat': '${lat}',
      'lng': '${lng}',
    }).then((value) {
      print('loc - ${value.body}');
      if (value.statusCode == 200) {
        StoreFinderBean data1 =
            StoreFinderBean.fromJson(jsonDecode(value.body));
        setState(() {
          shownMessage = '${data1.message}';
        });
        if ('${data1.status}' == '1') {
          setState(() {
            store_id = '${data1.data.store_id}';
            storeName = '${data1.data.store_name}';
            storeFinderData = data1.data;
            if (prefs.containsKey('storelist') &&
                prefs.getString('storelist').length > 0) {
              var storeListpf =
                  jsonDecode(prefs.getString('storelist')) as List;
              List<StoreFinderData> dataFinderL = [];
              dataFinderL = List.from(
                  storeListpf.map((e) => StoreFinderData.fromJson(e)).toList());
              int idd1 = dataFinderL.indexOf(data1.data);
              if (idd1 < 0) {
                dataFinderL.add(data1.data);
              }
              prefs.setString('storelist', dataFinderL.toString());
            } else {
              List<StoreFinderData> dataFinderLd = [];
              dataFinderLd.add(data1.data);
              prefs.setString('storelist', dataFinderLd.toString());
            }
            prefs.setString('store_id_last', '${storeFinderData.store_id}');
          });
        } else {
          Toast.show(data1.message, context,
              gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
        }
      }
      if (store_id != null && store_id.toString().length > 0) {
        setState(() {
          loci = true;
        });
        hitAsyncList();
      } else {
        setState(() {
          loci = false;
          bannerLoading = false;
          topCatLoading = false;
          singleLoading = false;
        });
      }
    }).catchError((e) {
      print(e);
      if (store_id != null && store_id.toString().length > 0) {
        setState(() {
          loci = true;
        });
        hitAsyncList();
      } else {
        setState(() {
          loci = false;
          bannerLoading = false;
          topCatLoading = false;
          singleLoading = false;
        });
      }
    });
  }

  void hitCart(BuildContext context, AppLocalizations locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('islogin') && prefs.getBool('islogin')) {
      Navigator.pushNamed(context, PageRoutes.cartPage).then((value) {
        setState(() {
          // index = 0;
          // selectedInd = 0;
          // _tabC.index=0;
          // _tabC.index
          // _tabC.animateTo(0);
        });
        // getCartList();
      }).catchError((e) {
        setState(() {
          // index = 0;
          // selectedInd = 0;
          // _tabC.index=selectedInd;
        });
      });
    } else {
      setState(() {
        // selectedInd = 0;
        // _tabC.index=selectedInd;
      });
      Toast.show(locale.loginfirst, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
    }
  }

  void hitCategroyAllbtn(BuildContext context) {
    if (storeFinderData != null) {
      Navigator.pushNamed(context, PageRoutes.all_category, arguments: {
        'store_id': storeFinderData.store_id,
        'storedetail': storeFinderData,
      }).then((value) {
        setState(() {
          index = 0;
          selectedInd = 0;
        });
        // getCartList();
      }).catchError((e) {
        setState(() {
          index = 0;
          selectedInd = 0;
        });
      });
    } else {
      setState(() {
        selectedInd = 0;
      });
    }
  }

  void hitSearchIndex(BuildContext context) {
    if (storeFinderData != null) {
      int typed;
      if('${tabDataList[selectTabt].type}'.toUpperCase()=='RECENT SELLING'){
        typed = 1;
      }else if('${tabDataList[selectTabt].type}'.toUpperCase()=='TOP SELLING'){
        typed = 0;
      }else if('${tabDataList[selectTabt].type}'.toUpperCase()=='WHATS NEW'){
        typed = 2;
      }else if('${tabDataList[selectTabt].type}'.toUpperCase()=='DEAL PRODUCTS'){
        typed = 3;
      }
      Navigator.pushNamed(context, PageRoutes.searchhistory, arguments: {
        'category': topCategoryList,
        'recentsale': tabDataList[selectTabt].data,
        'storedetails': storeFinderData,
        'wishlist': wishModel,
        'type': typed,
        'title':'${tabDataList[selectTabt].type}'.toUpperCase()
      }).then((value) {
        getWislist();
        // getCartList();
        setState(() {
          index = 0;
          selectedInd = 0;
        });
      }).catchError((e) {
        setState(() {
          index = 0;
          selectedInd = 0;
        });
      });
    } else {
      setState(() {
        selectedInd = 0;
      });
    }
  }

  void callNumberStore(store_number) async {
    await launch('tel:$store_number');
  }

  void openWhatsApp(
      store_number, String nowhatsappinstalled, BuildContext context) async {
    bool whatsapp = await FlutterLaunch.hasApp(name: "whatsapp");
    if (whatsapp) {
      await FlutterLaunch.launchWathsApp(phone: "$store_number", message: "");
    } else {
      Toast.show(nowhatsappinstalled, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
    }
  }

  Container buildList(
      List<ProductDataModel> products,
      List<WishListDataModel> wishModel,
      Function callback,
      String apCurrency,
      StoreFinderData storeFinderData,
      {int listype}) {
    return Container(
      height: 210,
      child: ListView.builder(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: products.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(left: 16.0,top: 5,bottom: 5),
              child: Material(
                elevation: 1,
                color: kWhiteColor,
                borderRadius: BorderRadius.circular(10),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  width: MediaQuery.of(context).size.width / 2.5,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child:
                      buildProductCard(context, products[index], wishModel, () {
                    callback();
                  }, apCurrency, storeFinderData, listtype: listype),
                ),
              ),
            );
          }),
    );
  }

  void getCartList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      apCurrency = preferences.getString('app_currency');
    });
    var http = Client();
    http.post(showCartUri,
        body: {'user_id': '${preferences.getInt('user_id')}'}).then((value) {
      print('cart - ${value.body}');
      if (value.statusCode == 200) {
        CartItemMainBean data1 =
            CartItemMainBean.fromJson(jsonDecode(value.body));
        if ('${data1.status}' == '1') {
          cartItemd.clear();
          cartItemd = List.from(data1.data);
          _counter = cartItemd.length;
        } else {
          setState(() {
            cartItemd.clear();
            _counter = 0;
          });
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  // Widget buildProductList(
  //     List<WhatsNewDataModel> products,
  //     List<WishListDataModel> wishModel,
  //     Function callback,
  //     String apCurrency,
  //     StoreFinderData storeFinderData,
  //     String listtype) {
  //   return Container(
  //     height: 200,
  //     child: ListView.builder(
  //         physics: BouncingScrollPhysics(),
  //         scrollDirection: Axis.horizontal,
  //         shrinkWrap: true,
  //         itemCount: products.length,
  //         itemBuilder: (context, index) {
  //           return Padding(
  //             padding: const EdgeInsets.only(left: 16.0),
  //             child: Container(
  //               width: MediaQuery.of(context).size.width / 2.5,
  //               child:
  //                   buildProductCard(context, products[index], wishModel, () {
  //                 callback();
  //               }, apCurrency, storeFinderData, listtype: listtype),
  //             ),
  //           );
  //         }),
  //   );
  // }

  Widget buildProductCard(
      BuildContext context,
      ProductDataModel products,
      List<WishListDataModel> wishModel,
      Function callback,
      String apCurrency,
      StoreFinderData storeFinderData,
      {bool favourites = false,
      int listtype}) {
    if (cartItemd != null && cartItemd.length > 0) {
      int ind1 = cartItemd.indexOf(CartItemData('', '', '', '', '',
          '${products.varientId}', '', '', '', '', '', '', '', ''));
      if (ind1 >= 0) {
        products.qty = cartItemd[ind1].qty;
      }
    }
    // print(products.toString());
    return GestureDetector(
      onTap: () {
        if(('${products.productName}'== 'See all')){
          Navigator.pushNamed(context, PageRoutes.cat_product, arguments: {
            'title': topcct[listtype].title,
            'storeid': storeFinderData.store_id,
            'cat_id': topcct[listtype].catId,
            'storedetail': storeFinderData,
          }).then((value) {
            // getCartList();
          });
        }else{
          int idd = wishModel.indexOf(WishListDataModel(
              '',
              '',
              '${products.varientId}',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              ''));
          print('${idd}');
          Navigator.pushNamed(context, PageRoutes.product, arguments: {
            'pdetails': products,
            'storedetails': storeFinderData,
            'isInWish': (idd >= 0),
          }).then((value) {
            callback();
          });
        }
      },
      behavior: HitTestBehavior.opaque,
      child: ('${products.productName}'== 'See all')?Container(
        height: 180,
        width: MediaQuery.of(context).size.width / 2,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${products.productName}',style: TextStyle(fontSize: 14,color: kMainColor),),
            Icon(
              Icons.arrow_forward_ios,
              size: 15,
              color: kMainColor
            )
          ],
        ),
      ):Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stack(
              //   children: [
              //
              //   ],
              // ),
              Container(
                width: MediaQuery.of(context).size.width/2.5,
                height: 100,
                alignment: Alignment.center,
                child: SizedBox(
                  width: 90,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Card(
                      elevation: 0.5,
                      color: kWhiteColor,
                      clipBehavior: Clip.hardEdge,
                      child: CachedNetworkImage(
                        width: 80,
                        imageUrl: '${products.productImage}',
                        placeholder: (context, url) => Align(
                          widthFactor: 50,
                          heightFactor: 50,
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.all(5.0),
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            Image.asset('assets/icon.png'),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: Column(
                    children: [
                      Align(alignment: Alignment.centerLeft,
                        child: Text(products.productName,
                            maxLines: 1, style: TextStyle(fontWeight: FontWeight.w500)),),
                      SizedBox(height: 4),
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('$apCurrency ${products.price}',
                                style:
                                TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            Visibility(
                              visible:
                              ('${products.price}' == '${products.mrp}') ? false : true,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text('$apCurrency ${products.mrp}',
                                    style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w300,
                                        fontSize: 13,
                                        decoration: TextDecoration.lineThrough)),
                              ),
                            ),
                            // buildRating(context),
                          ],
                        ),
                      ),
                    ],
                  )),
              Align(
                alignment: Alignment.centerRight,
                child: Text('${products.quantity} ${products.unit}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ),
              SizedBox(height: 5),
              (int.parse('${products.stock}') > 0)
                  ? Container(
                width: MediaQuery.of(context).size.width / 2,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildIconButton(Icons.remove, context,
                        onpressed: () {
                          if (int.parse('${products.qty}') > 0) {
                            int idd = topcct[listtype].products.indexOf(products);
                            addtocart(
                                '${products.storeId}',
                                '${products.varientId}',
                                (int.parse('${products.qty}') - 1),
                                '0',
                                context,
                                idd,
                                listtype);
                          }
                        }),
                    SizedBox(
                      width: 8,
                    ),
                    Text('${products.qty}',
                        style: Theme.of(context).textTheme.subtitle1),
                    SizedBox(
                      width: 8,
                    ),
                    buildIconButton(Icons.add, context,
                        type: 1,
                        onpressed: () {
                          if ((int.parse('${products.qty}') + 1) <=
                              int.parse('${products.stock}')) {
                            int idd = topcct[listtype].products.indexOf(products);
                            addtocart(
                                '${products.storeId}',
                                '${products.varientId}',
                                (int.parse('${products.qty}') + 1),
                                '0',
                                context,
                                idd,
                                listtype);
                          } else {
                            Toast.show('no more stock for this product', context,
                                duration: Toast.LENGTH_SHORT,
                                gravity: Toast.CENTER);
                          }
                        }),
                  ],
                ),
              )
                  :
              Container(
                height: 15,
                width: MediaQuery.of(context).size.width / 2,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kCardBackgroundColor,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10)),
                ),
                child: Text(
                  'Out of stock',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(fontSize: 13,color: kRedColor),
                ),
              ),
              SizedBox(height: 5),
            ],
          ),
          ((((double.parse('${products.mrp}') - double.parse('${products.price}'))/double.parse('${products.mrp}'))*100)>0)?Align(
            alignment: Alignment.topLeft,
            child: Container(
                padding: const EdgeInsets.all(3.0),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: kPercentageBackC,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(10),bottomRight: Radius.circular(10)),
                ),
                child: Text('${(((double.parse('${products.mrp}') - double.parse('${products.price}'))/double.parse('${products.mrp}'))*100).toStringAsFixed(2)} %',style: TextStyle(color:kWhiteColor,fontWeight: FontWeight.w500,fontSize: 12),),),
          ):SizedBox.shrink(),
        ],
      ),
    );
  }



  Widget buildIconButton(
      IconData icon, BuildContext context,
      {Function onpressed, int type}) {
    return GestureDetector(
      onTap: () {
        onpressed();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 25,
        height: 25,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: type==1?kMainColor:kRedColor, width: 0)),
        child: Icon(
          icon,
          color: type==1?kMainColor:kRedColor,
          size: 16,
        ),
      ),
    );
  }

  Container buildRating(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 1.5, bottom: 1.5, left: 4, right: 3),
      //width: 30,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            "4.2",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.button.copyWith(fontSize: 10),
          ),
          SizedBox(
            width: 1,
          ),
          Icon(
            Icons.star,
            size: 10,
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
        ],
      ),
    );
  }

  GestureDetector buildCategoryRow(BuildContext context,
      TopCategoryDataModel categories, StoreFinderData storeFinderData) {
    return GestureDetector(
      onTap: () {
        if ('${categories.title}' == 'See all') {
          Navigator.pushNamed(context, PageRoutes.all_category, arguments: {
            'store_id': storeFinderData.store_id,
            'storedetail': storeFinderData,
          }).then((value) {
            // getCartList();
          });
        } else {
          Navigator.pushNamed(context, PageRoutes.cat_product, arguments: {
            'title': categories.title,
            'storeid': categories.store_id,
            'cat_id': categories.cat_id,
            'storedetail': storeFinderData,
          }).then((value) {
            // getCartList();
          });
        }
      },
      behavior: HitTestBehavior.opaque,
      child: ('${categories.title}' == 'See all')
          ? Container(
              margin: EdgeInsets.only(left: 16),
              width: 96,
              height: 117,
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(12),
              //   border: Border.all(color: kMainColor,width: 1),
              //   color: kWhiteColor,
              // ),
              alignment: Alignment.center,
              child: Column(
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kMainColor, width: 1),
                          color: kWhiteColor,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${categories.title}'),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 15,
                            )
                          ],
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    // child: Text(
                    //   categories.title,
                    //   maxLines: 1,
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(
                    //       color: kMainTextColor, fontWeight: FontWeight.w600),
                    // ),
                  ),
                ],
              ),
            )
          : Container(
              margin: EdgeInsets.only(left: 16),
              // padding: EdgeInsets.all(10),
              width: 96,
              height: 117,
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(12),
              //   color: kWhiteColor,
              //   // image: DecorationImage(
              //   //     image: NetworkImage(categories.image), fit: BoxFit.fill)
              // ),
              child: Column(
                children: [
                  Material(
                    elevation: 0.5,
                    color: kWhiteColor,
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 96,
                      height: 96,
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kWhiteColor, width: 1),
                        color: kWhiteColor,
                      ),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            categories.image,
                            fit: BoxFit.cover,
                            height: 96,
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      categories.title,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: kMainTextColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              // child: Stack(
              //   fit: StackFit.expand,
              //   children: [
              //     ClipRRect(
              //         borderRadius: BorderRadius.circular(12),
              //         child:
              //             Image.network(categories.image, fit: BoxFit.cover)),
              //     ClipRRect(
              //       borderRadius: BorderRadius.circular(12), // Clip it cleanly.
              //       child: BackdropFilter(
              //         filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
              //         child: Container(
              //           padding: EdgeInsets.only(top: 5, left: 5, right: 5),
              //           color: Colors.grey.withOpacity(0.3),
              //           alignment: Alignment.topLeft,
              //           child:

              //         ),
              //       ),
              //     ),
              //   ],
              // ),
            ),
    );
  }

  Column buildCompleteVerticalSHList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Shimmer(
            duration: Duration(seconds: 3),
            color: Colors.white,
            enabled: true,
            direction: ShimmerDirection.fromLTRB(),
            child: Container(
              height: 15,
              width: 150,
              color: Colors.grey[300],
            ),
          ),
        ),
        buildShList(context),
      ],
    );
  }

  Container buildShList(context) {
    return Container(
      height: 240,
      child: ListView.builder(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: 10,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Container(
                width: MediaQuery.of(context).size.width / 2.5,
                child: buildProductShHCard(context),
              ),
            );
          }),
    );
  }

  Widget buildProductShHCard(BuildContext context) {
    return Shimmer(
      duration: Duration(seconds: 3),
      color: Colors.white,
      enabled: true,
      direction: ShimmerDirection.fromLTRB(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                alignment: Alignment.center,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 2.5,
                  height: MediaQuery.of(context).size.width / 2.5,
                  child: Container(
                    color: Colors.grey[300],
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 4),
          Container(
            height: 10,
            color: Colors.grey[300],
          ),
          // Text(type, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
          SizedBox(height: 4),
          Container(
            width: MediaQuery.of(context).size.width / 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 10,
                  width: 30,
                  color: Colors.grey[300],
                ),
                Container(
                  height: 10,
                  width: 30,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
Future<void> _showNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    dynamic title,
    dynamic body) async {
  final Int64List vibrationPattern = Int64List(4);
  vibrationPattern[0] = 0;
  vibrationPattern[1] = 1000;
  vibrationPattern[2] = 5000;
  vibrationPattern[3] = 2000;
  final AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails('1234', 'Notify', 'Notify On Shopping',
      vibrationPattern: vibrationPattern,
      importance: Importance.max,
      priority: Priority.high,
      enableLights: true,
      enableVibration: true,
      playSound: true,
      ticker: 'ticker');
  final IOSNotificationDetails iOSPlatformChannelSpecifics =
  IOSNotificationDetails(presentSound: true);
  final NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );
  await flutterLocalNotificationsPlugin.show(
      0, '${title}', '${body}', platformChannelSpecifics,
      payload: 'item x');
}
