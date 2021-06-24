import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/appinfo.dart';
import 'package:grocery/beanmodel/category/categorymodel.dart';
import 'package:grocery/beanmodel/storefinder/storefinderbean.dart';
import 'package:grocery/providergrocery/cartcountprovider.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:toast/toast.dart';

class AllCategory extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AllCategoryState();
  }
}

class AllCategoryState extends State<AllCategory> {
  bool enterFirst = false;
  bool isLoading = false;
  dynamic storeid;
  StoreFinderData storedetail;
  List<CategoryDataModel> categories = [];

  int _counter = 0;
  CartCountProvider cartCounterProvider;

  @override
  void initState() {
    super.initState();
    cartCounterProvider = BlocProvider.of<CartCountProvider>(context);
    // hitAppInfo();
  }

  // void hitAppInfo() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var http = Client();
  //   http.post(appInfoUri, body: {
  //     'user_id':
  //         '${(prefs.containsKey('user_id')) ? prefs.getInt('user_id') : ''}'
  //   }).then((value) {
  //     print(value.body);
  //     if (value.statusCode == 200) {
  //       AppInfoModel data1 = AppInfoModel.fromJson(jsonDecode(value.body));
  //       print('data - ${data1.toString()}');
  //       if (data1.status == "1" || data1.status == 1) {
  //         setState(() {
  //           _counter = int.parse('${data1.totalItems}');
  //         });
  //         prefs.setString('app_currency', '${data1.currencySign}');
  //         prefs.setString('app_referaltext', '${data1.refertext}');
  //         prefs.setString('app_name', '${data1.appName}');
  //         prefs.setString('country_code', '${data1.countryCode}');
  //         prefs.setString('numberlimit', '${data1.phoneNumberLength}');
  //         prefs.setInt('last_loc', int.parse('${data1.lastLoc}'));
  //       }
  //     }
  //   }).catchError((e) {
  //     print(e);
  //   });
  // }

  void getCategory(dynamic store_id) async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    var http = Client();
    http.post(categoryUri, body: {'store_id': '${store_id}'}).then((value) {
      if (value.statusCode == 200) {
        CategoryModel data1 = CategoryModel.fromJson(jsonDecode(value.body));
        if (data1.status == "1" || data1.status == 1) {
          setState(() {
            categories.clear();
            categories = List.from(data1.data);
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
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    Map<String, dynamic> receivedData =
        ModalRoute.of(context).settings.arguments;
    setState(() {
      if (!enterFirst) {
        // title = receivedData['title'];
        enterFirst = true;
        isLoading = true;
        storeid = receivedData['store_id'];
        storedetail = receivedData['storedetail'];
        getCategory(storeid);
      }
    });

    return Scaffold(
      backgroundColor: kCardBackgroundColor,
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        title: Text(locale.shopbycategory),
        actions: [
          BlocBuilder<CartCountProvider, int>(builder: (context, cartCount) {
            return Badge(
              position: BadgePosition.topEnd(top: 5, end: 5),
              padding: EdgeInsets.all(5),
              animationDuration: Duration(milliseconds: 300),
              animationType: BadgeAnimationType.slide,
              badgeContent: Text(
                cartCount.toString(),
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
              child: IconButton(
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    if (prefs.containsKey('islogin') &&
                        prefs.getBool('islogin')) {
                      Navigator.pushNamed(context, PageRoutes.cartPage);
                      // Navigator.pushNamed(context, PageRoutes.cart)

                    } else {
                      Toast.show(locale.loginfirst, context,
                          gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                    }
                  },
                  icon: ImageIcon(AssetImage('assets/ic_cart.png'))),
            );
          }),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: (!isLoading && (categories != null && categories.length > 0))
            ? GridView.builder(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                physics: ScrollPhysics(),
                shrinkWrap: true,
                primary: true,
                itemCount: categories.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  return buildCategoryRow(
                      context, categories[index], storeid, storedetail);
                })
            : (isLoading)
                ? GridView.builder(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    primary: true,
                    itemCount: 10,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      return buildCategorySHRow(context);
                    })
                : Align(
                    alignment: Alignment.center,
                    child: Text(locale.nomorcategory),
                  ),
      ),
    );
  }
}

GestureDetector buildCategoryRow(
    BuildContext context,
    CategoryDataModel categories,
    dynamic storeid,
    StoreFinderData storedetail) {
  bool hasSubCategory = false;

  if (categories.subcategory.length > 0) {
    hasSubCategory = true;
  }

  return GestureDetector(
    onTap: () {
      print(hasSubCategory);
      if (hasSubCategory) {
        Navigator.pushNamed(context, PageRoutes.cat_sub_p, arguments: {
          'title': categories.title,
          'categories': categories,
          'storedetail': storedetail,
        });
      } else {
        Navigator.pushNamed(context, PageRoutes.cat_product, arguments: {
          'title': categories.title,
          'storeid': storedetail.store_id,
          'cat_id': categories.cat_id,
          'storedetail': storedetail,
        });
      }
    },
    child: Column(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: kWhiteColor,
              // image: DecorationImage(
              //     image: NetworkImage(categories.image), fit: BoxFit.fill)
            ),
            child: CachedNetworkImage(
              imageUrl: '${categories.image}',
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
        SizedBox(height: 4),
        Text(
          categories.title,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(color: kMainTextColor, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 4),
      ],
    ),
  );
}

GestureDetector buildCategorySHRow(BuildContext context) {
  return GestureDetector(
    onTap: () {},
    child: Shimmer(
      duration: Duration(seconds: 3),
      color: Colors.white,
      enabled: true,
      direction: ShimmerDirection.fromLTRB(),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: kWhiteColor,
        ),
        child: Container(
          height: 10,
          width: 100,
          color: Colors.grey[300],
        ),
      ),
    ),
  );
}
