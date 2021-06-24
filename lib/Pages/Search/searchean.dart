import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:grocery/Components/constantfile.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/appinfo.dart';
import 'package:grocery/beanmodel/cart/addtocartbean.dart';
import 'package:grocery/beanmodel/cart/cartitembean.dart';
import 'package:grocery/beanmodel/productbean/productwithvarient.dart';
import 'package:grocery/beanmodel/storefinder/storefinderbean.dart';
import 'package:grocery/beanmodel/wishlist/wishdata.dart';
import 'package:grocery/providergrocery/cartcountprovider.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:toast/toast.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchEan extends StatefulWidget {
  SearchEan();

  @override
  _SearchEanState createState() => _SearchEanState();
}

class _SearchEanState extends State<SearchEan> {
  List<ProductDataModel> productsd = [];
  dynamic title;
  bool enterFirst = false;
  bool isLoading = false;
  List<WishListDataModel> wishModel = [];
  StoreFinderData storedetails;
  dynamic apCurency;
  List<CartItemData> cartItemd = [];
  int _counter = 0;

  bool progressadd = false;

  CartCountProvider cartCounterProvider;

  @override
  void initState() {
    super.initState();
    cartCounterProvider = BlocProvider.of<CartCountProvider>(context);
    getWislist();
    getCartList();
    // hitAppInfo();
  }

  void getCartList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      apCurency = preferences.getString('app_currency');
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

  void getWislist() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apCurency = prefs.getString('app_currency');
    });
    dynamic userId = prefs.getInt('user_id');
    dynamic storeId = prefs.getInt('store_id');
    var url = showWishlistUri;
    var http = Client();
    http.post(url, body: {
      'user_id': '${userId}',
      'store_id':'37'
    }).then((value){
      print('resp - ${value.body}');
      if(value.statusCode == 200){
        WishListModel data1 = WishListModel.fromJson(jsonDecode(value.body));
        if(data1.status=="1" || data1.status==1){
          setState(() {
            wishModel.clear();
            wishModel = List.from(data1.data);
          });
        }
      }
    }).catchError((e){
    });
  }

  void getCategory(dynamic ean_code, dynamic storeid, BuildContext context) async{
    var http = Client();
    http.post(searchUri,body: {
      'ean_code':'${ean_code}',
      // 'ean_code':'HXBCX',
      'store_id':'${storeid}'
    }).then((value){
      print('${value.body}');
      if(value.statusCode == 200){
        ProductModel data1 = ProductModel.fromJson(jsonDecode(value.body));
        if('${data1.status}'=='1'){
          setState(() {
            productsd.clear();
            productsd = List.from(data1.data);
          });
        }
        Toast.show(data1.message, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
      }
      setState(() {
        isLoading = false;
      });
    }).catchError((e){
      Toast.show('Something went wrong\nPlease check your internet connection.', context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
      print(e);
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    Map<String,dynamic> receivedData = ModalRoute.of(context).settings.arguments;
    setState(() {
      // title = receivedData['title'];
      if(!enterFirst){
        enterFirst = true;
        isLoading = true;
        storedetails = receivedData['storedetails'];
        getCategory(receivedData['ean_code'], storedetails.store_id, context);
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scan Product',
          style: TextStyle(color: kMainTextColor),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<CartCountProvider,int>(builder: (context,cartCount){
            return Badge(
              position: BadgePosition.topEnd(top: 5, end: 5),
              padding: EdgeInsets.all(5),
              animationDuration: Duration(milliseconds: 300),
              animationType: BadgeAnimationType.slide,
              badgeContent: Text(
                cartCount.toString(),
                style: TextStyle(color: Colors.white,fontSize: 10),
              ),
              child: IconButton(
                icon: ImageIcon(AssetImage(
                  'assets/ic_cart.png',
                )),
                onPressed: () async{
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  if(prefs.containsKey('islogin') && prefs.getBool('islogin')){
                    Navigator.pushNamed(context,PageRoutes.cartPage);
                  }else{
                    Toast.show(locale.loginfirst, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                  }
                },
              ),
            );
          }),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(5.0),
        child: (isLoading)?buildGridShView()
              :(productsd!=null && productsd.length>0)?buildGridView(productsd,wishModel,storedetails,apCurency)
          :Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(locale.productnotfound,textAlign: TextAlign.center,style: TextStyle(
              fontSize: 18,
            ),),
          )
        ],
      ),
      ),
    );
  }


  GridView buildGridView(List<ProductDataModel> listName, List<WishListDataModel> wishModel,StoreFinderData storedetails,dynamic apCurency,{bool favourites = false}) {
    return GridView.builder(
        padding: EdgeInsets.symmetric(vertical: 10),
        // physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        primary: true,
        itemCount: listName.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.80,
          crossAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          return buildProductCard(
              context,listName[index],
              wishModel,
              storedetails,
              apCurency,
              favourites: favourites);
        });
  }

  // Widget buildProductCard(
  //     BuildContext context,ProductDataModel products,List<WishListDataModel> wishModel,StoreFinderData finderDetails,dynamic apCurency,
  //     {bool favourites = false}) {
  //   return GestureDetector(
  //     onTap: () {
  //       int idd = -1;
  //       if(wishModel!=null && wishModel.length>0){
  //         idd = wishModel.indexOf(WishListDataModel('', '', '${products.varients[0].varientId}', '', '', '', '', '', '', '', '', '', '','',''));
  //       }
  //       Navigator.pushNamed(context, PageRoutes.product,arguments: {
  //         'pdetails':products,
  //         'storedetails':finderDetails,
  //         'isInWish': (idd>=0),
  //       });
  //     },
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Stack(
  //           children: [
  //             Container(
  //               alignment: Alignment.center,
  //               child: Image.network(
  //                 '${products.productImage}',
  //                 width: MediaQuery.of(context).size.width / 2.5,
  //                 height: MediaQuery.of(context).size.width / 2.8,
  //                 fit: BoxFit.fill,
  //               ),
  //             ),
  //             favourites
  //                 ? Align(
  //               alignment: Alignment.topRight,
  //               child: IconButton(
  //                 onPressed: () {},
  //                 icon: Icon(
  //                   Icons.favorite,
  //                   color: Theme.of(context).primaryColor,
  //                 ),
  //               ),
  //             )
  //                 : SizedBox.shrink(),
  //           ],
  //         ),
  //         Text('${products.productName}', maxLines:1,style: TextStyle(fontWeight: FontWeight.w500)),
  //         Text('${products.varients[0].quantity} ${products.varients[0].unit}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
  //         SizedBox(height: 4),
  //         Container(
  //           width: MediaQuery.of(context).size.width / 2,
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.start,
  //             children: [
  //               Text('$apCurency ${products.varients[0].price}',
  //                   style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
  //               Visibility(
  //                 visible: ('${products.varients[0].price}'=='${products.varients[0].mrp}')?false:true,
  //                 child: Padding(
  //                   padding: const EdgeInsets.only(left:8.0),
  //                   child: Text('$apCurency ${products.varients[0].mrp}',
  //                       style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w300, fontSize: 13,decoration: TextDecoration.lineThrough)),
  //                 ),
  //               ),
  //               // buildRating(context),
  //             ],
  //           ),
  //         ),
  //         SizedBox(height: 4),
  //         (int.parse('${products.varients[0].stock}') > 0)
  //             ? Container(
  //           width: MediaQuery.of(context).size.width / 2,
  //           alignment: Alignment.center,
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               buildIconButton(Icons.remove, context,
  //                   onpressed: () {
  //                     if (int.parse('${products.qty}') > 0 && !progressadd) {
  //                       int idd = productsd.indexOf(products);
  //                       addtocart(
  //                           '${products.varients[0].storeId}',
  //                           '${products.varients[0].varientId}',
  //                           (int.parse('${products.qty}')-1),
  //                           '0',
  //                           context,
  //                           idd);
  //                     }
  //                   }),
  //               SizedBox(
  //                 width: 8,
  //               ),
  //               Text('${products.qty}',
  //                   style: Theme.of(context).textTheme.subtitle1),
  //               SizedBox(
  //                 width: 8,
  //               ),
  //               buildIconButton(Icons.add, context,
  //                   onpressed: () {
  //                     if(!progressadd && (int.parse('${products.qty}')+1)<=int.parse('${products.varients[0].stock}')){
  //                       int idd = productsd.indexOf(products);
  //                       addtocart(
  //                           '${products.varients[0].storeId}',
  //                           '${products.varients[0].varientId}',
  //                           (int.parse('${products.qty}')+1),
  //                           '0',
  //                           context,
  //                           idd);
  //                     }else{
  //                       if(!progressadd){
  //                         Toast.show('no more stock for this product', context,duration: Toast.LENGTH_SHORT,gravity: Toast.CENTER);
  //                       }
  //                     }
  //                   }),
  //             ],
  //           ),
  //         )
  //             : Center(
  //           child: Text(
  //             'Out off stock',
  //             textAlign: TextAlign.center,
  //             maxLines: 1,
  //             style: TextStyle(fontSize: 10),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  GridView buildGridShView() {
    return GridView.builder(
        padding: EdgeInsets.symmetric(vertical: 10),
        // physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        primary: true,
        itemCount: 10,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.80,
          crossAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          return buildProductShCard(
              context);
        });
  }

  Widget buildProductShCard(BuildContext context) {
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
          Container(height: 10,color: Colors.grey[300],),
          // Text(type, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
          SizedBox(height: 4),
          Container(
            width: MediaQuery.of(context).size.width / 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(height: 10,width: 30,color: Colors.grey[300],),
                Container(height: 10,width: 30,color: Colors.grey[300],),
              ],
            ),
          ),
        ],
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

  Widget buildProductCard(
      BuildContext context,ProductDataModel products,List<WishListDataModel> wishModel,StoreFinderData finderDetails,dynamic apCurency,
      {bool favourites = false}) {
    if (cartItemd != null && cartItemd.length > 0) {
      int ind1 = cartItemd.indexOf(CartItemData('', '', '', '', '',
          '${products.varientId}', '', '', '', '', '', '', '', ''));
      if (ind1 >= 0) {
        products.qty = cartItemd[ind1].qty;
      }
    }
    return GestureDetector(
      onTap: () {
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
        Navigator.pushNamed(context, PageRoutes.product, arguments: {
          'pdetails': products,
          'storedetails': storedetails,
          'isInWish': (idd >= 0),
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Material(
          elevation: 1,
          color: kWhiteColor,
          borderRadius: BorderRadius.circular(10),
          clipBehavior: Clip.antiAlias,
          child: Container(
            width: MediaQuery.of(context).size.width / 2.5,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 2.5,
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
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(products.productName,
                                  maxLines: 1,
                                  style: TextStyle(fontWeight: FontWeight.w500)),
                            ),
                            SizedBox(height: 4),
                            Container(
                              width: MediaQuery.of(context).size.width / 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('$apCurency ${products.price}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16)),
                                  Visibility(
                                    visible:
                                    ('${products.price}' == '${products.mrp}')
                                        ? false
                                        : true,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text('$apCurency ${products.mrp}',
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w300,
                                              fontSize: 13,
                                              decoration:
                                              TextDecoration.lineThrough)),
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
                          style:
                          TextStyle(color: Colors.grey[600], fontSize: 13)),
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
                                if (int.parse('${products.qty}') > 0 &&
                                    !progressadd) {
                                  int idd = productsd.indexOf(products);
                                  addtocart2(
                                      '${products.storeId}',
                                      '${products.varientId}',
                                      (int.parse('${products.qty}') - 1),
                                      '0',
                                      context,
                                      idd);
                                }
                              }),
                          SizedBox(
                            width: 8,
                          ),
                          Text('${products.qty}',
                              style:
                              Theme.of(context).textTheme.subtitle1),
                          SizedBox(
                            width: 8,
                          ),
                          buildIconButton(Icons.add, context, type: 1,
                              onpressed: () {
                                if ((int.parse('${products.qty}') + 1) <=
                                    int.parse('${products.stock}') &&
                                    !progressadd) {
                                  int idd = productsd.indexOf(products);
                                  addtocart2(
                                      '${products.storeId}',
                                      '${products.varientId}',
                                      (int.parse('${products.qty}') + 1),
                                      '0',
                                      context,
                                      idd);
                                } else {
                                  Toast.show('no more stock for this product',
                                      context,
                                      duration: Toast.LENGTH_SHORT,
                                      gravity: Toast.CENTER);
                                }
                              }),
                        ],
                      ),
                    )
                        : Container(
                      height: 15,
                      width: MediaQuery.of(context).size.width / 2,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: kCardBackgroundColor,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                      ),
                      child: Text(
                        'Out of stock',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: TextStyle(fontSize: 13, color: kRedColor),
                      ),
                    ),
                    SizedBox(height: 5),
                  ],
                ),
                ((((double.parse('${products.mrp}') -
                    double.parse('${products.price}')) /
                    double.parse('${products.mrp}')) *
                    100) >
                    0)
                    ? Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    padding: const EdgeInsets.all(3.0),
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: kPercentageBackC,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10)),
                    ),
                    child: Text(
                      '${(((double.parse('${products.mrp}') - double.parse('${products.price}')) / double.parse('${products.mrp}')) * 100).toStringAsFixed(2)} %',
                      style: TextStyle(
                          color: kWhiteColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 12),
                    ),
                  ),
                )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void addtocart2(String storeid, String varientid, dynamic qnty,
      String special, BuildContext context, int index) async {
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
              productsd[index].qty = data1.cart_items[dii].qty;
            } else {
              productsd[index].qty = 0;
            }
            _counter = data1.cart_items.length;
            cartCounterProvider.hitCartCounter(_counter);
          });
        } else {
          setState(() {
            productsd[index].qty = 0;
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
}

