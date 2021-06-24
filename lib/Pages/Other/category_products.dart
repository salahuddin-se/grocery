import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
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

// class Product {
//   Product(this.image, this.productName, this.productType, this.price);
//   String image;
//   String productName;
//   String productType;
//   String price;
// }

class CategoryProduct extends StatefulWidget {
  CategoryProduct();

  @override
  _CategoryProductState createState() => _CategoryProductState();
}

class _CategoryProductState extends State<CategoryProduct> {
  List<ProductDataModel> products = [];
  dynamic title;
  dynamic store_id;
  bool enterFirst = false;
  bool isLoading = false;
  StoreFinderData storedetail;
  List<WishListDataModel> wishModel = [];
  dynamic apCurrency;
  List<CartItemData> cartItemd = [];
  int _counter = 0;

  bool progressadd = false;

  CartCountProvider cartCounterProvider;
  @override
  void initState() {
    super.initState();
    cartCounterProvider = BlocProvider.of<CartCountProvider>(context);
    getSharedValue();
    getCartList();
    // hitAppInfo();
  }

  void getSharedValue() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      apCurrency = pref.getString('app_currency');
    });
  }

  // void hitAppInfo() async{
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var http = Client();
  //   http.post(appInfoUri,body: {
  //     'user_id':'${(prefs.containsKey('user_id'))?prefs.getInt('user_id'):''}'
  //   }).then((value) {
  //     print(value.body);
  //     if (value.statusCode == 200) {
  //       AppInfoModel data1 = AppInfoModel.fromJson(jsonDecode(value.body));
  //       print('data - ${data1.toString()}');
  //       if (data1.status == "1" || data1.status == 1) {
  //         setState(() {
  //           apCurrency = '${data1.currencySign}';
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

  void getWislist(dynamic storeid) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic userId = prefs.getInt('user_id');
    var url = showWishlistUri;
    var http = Client();
    http.post(url, body: {
      'user_id': '${userId}',
      'store_id':'${storeid}'
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

  void getCategory(dynamic catid, dynamic storeid) async{
    var http = Client();
    http.post(catProductUri,body: {
      'cat_id':'${catid}',
      'store_id':'${storeid}'
    }).then((value){
      print('${value.body}');
      if(value.statusCode == 200){
        ProductModel data1 = ProductModel.fromJson(jsonDecode(value.body));
        if(data1.status=="1" || data1.status==1){
          setState(() {
            products.clear();
            products = List.from(data1.data);
          });
        }
      }
      setState(() {
        isLoading = false;
      });
    }).catchError((e){
      print(e);
      setState(() {
        isLoading = false;
      });
    });
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

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    Map<String,dynamic> receivedData = ModalRoute.of(context).settings.arguments;
    setState(() {
      title = receivedData['title'];
      if(!enterFirst){
        enterFirst = true;
        isLoading = true;
        store_id = receivedData['storeid'];
        storedetail = receivedData['storedetail'];
        getWislist(store_id);
        getCategory(receivedData['cat_id'], receivedData['storeid']);
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(color: kMainTextColor),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<CartCountProvider, int>(
              builder: (context,cartCount){
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
                      onPressed: () async {
                        SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                        if (prefs.containsKey('islogin') &&
                            prefs.getBool('islogin')) {

                          Navigator.pushNamed(context, PageRoutes.cartPage).then((value) {
                            print('value d');
                            getCartList();
                          }).catchError((e) {
                            print('dd');
                            getCartList();
                          });
                          // Navigator.pushNamed(context, PageRoutes.cart)

                        } else {
                          Toast.show(locale.loginfirst, context,
                              gravity: Toast.CENTER,
                              duration: Toast.LENGTH_SHORT);
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
        padding: const EdgeInsets.all(5.0),
        child: SingleChildScrollView(
          primary: true,
          child: (isLoading)?buildGridShView():buildGridView(products,wishModel,'$apCurrency',storedetail),
        ),
      ),
    );
  }

  GridView buildGridView(List<ProductDataModel> listName, List<WishListDataModel> wishModel,String apCurrency,StoreFinderData storedetail,{bool favourites = false}) {
    return GridView.builder(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        primary: false,
        itemCount: listName.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 10,
            mainAxisSpacing: 5
        ),
        itemBuilder: (context, index) {
          return buildProductCard(
              context,
              listName[index],
              wishModel,
              '$apCurrency',
              storedetail);
        });
  }


  Widget buildProductCard(
      BuildContext context,ProductDataModel product,
      List<WishListDataModel> wishModel,String apCurrency,StoreFinderData storedetail) {
    // if (cartItemd != null && cartItemd.length > 0) {
    //   int ind1 = cartItemd.indexOf(CartItemData('', '', '', '', '',
    //       '${product.varients[0].varientId}', '', '', '', '', '', '', '', ''));
    //   if (ind1 >= 0) {
    //     product.qty = cartItemd[ind1].qty;
    //   }
    // }
    // return GestureDetector(
    //   onTap: () {
    //     int idd = wishModel.indexOf(WishListDataModel('', '', '${product.varientId}', '', '', '', '', '', '', '', '', '', '','',''));
    //     Navigator.pushNamed(context, PageRoutes.product,arguments: {
    //       'pdetails':product,
    //       'storedetails':storedetail,
    //       'isInWish': (idd>=0),
    //     });
    //   },
    //   child: Padding(
    //     padding: const EdgeInsets.all(8.0),
    //     child: Material(
    //       elevation: 1,
    //       color: kWhiteColor,
    //       borderRadius: BorderRadius.circular(10),
    //       clipBehavior: Clip.antiAlias,
    //       child: Container(
    //         // height: 200,
    //         // padding: EdgeInsets.all(5),
    //         width: MediaQuery.of(context).size.width / 2.5,
    //         padding: const EdgeInsets.symmetric(horizontal: 5),
    //         alignment: Alignment.center,
    //         decoration: BoxDecoration(
    //             borderRadius: BorderRadius.circular(10)
    //         ),
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             // Stack(
    //             //   children: [
    //             //     Container(
    //             //       alignment: Alignment.center,
    //             //       width: MediaQuery.of(context).size.width / 2.5,
    //             //       height: MediaQuery.of(context).size.width / 2.8,
    //             //       child: Image.network(
    //             //         '${product.productImage}',
    //             //         width: MediaQuery.of(context).size.width / 2.5-20,
    //             //         height: 90,
    //             //         fit: BoxFit.fill,
    //             //       ),
    //             //     ),
    //             //     favourites
    //             //         ? Align(
    //             //       alignment: Alignment.topRight,
    //             //       child: IconButton(
    //             //         onPressed: () {},
    //             //         icon: Icon(
    //             //           Icons.favorite,
    //             //           color: Theme.of(context).primaryColor,
    //             //         ),
    //             //       ),
    //             //     )
    //             //         : SizedBox.shrink(),
    //             //   ],
    //             // ),
    //             Container(
    //               width: MediaQuery.of(context).size.width/2.5,
    //               height: 100,
    //               alignment: Alignment.center,
    //               child: SizedBox(
    //                 width: 90,
    //                 child: ClipRRect(
    //                   borderRadius: BorderRadius.circular(8),
    //                   child: Card(
    //                     elevation: 0.5,
    //                     color: kWhiteColor,
    //                     clipBehavior: Clip.hardEdge,
    //                     child: CachedNetworkImage(
    //                       width: 80,
    //                       imageUrl: '${product.productImage}',
    //                       placeholder: (context, url) => Align(
    //                         widthFactor: 50,
    //                         heightFactor: 50,
    //                         alignment: Alignment.center,
    //                         child: Container(
    //                           padding: const EdgeInsets.all(5.0),
    //                           width: 50,
    //                           height: 50,
    //                           child: CircularProgressIndicator(),
    //                         ),
    //                       ),
    //                       errorWidget: (context, url, error) =>
    //                           Image.asset('assets/icon.png'),
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             ),
    //             Expanded(
    //               child: Column(
    //                 children: [
    //                   Align(alignment: Alignment.centerLeft,
    //                     child: Text(product.productName,
    //                         maxLines: 1, style: TextStyle(fontWeight: FontWeight.w500)),),
    //                   SizedBox(height: 4),
    //                   Container(
    //                     width: MediaQuery.of(context).size.width / 2,
    //                     child: Row(
    //                       mainAxisAlignment: MainAxisAlignment.start,
    //                       children: [
    //                         Text('$apCurrency ${product.varients[0].price}',
    //                             style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
    //                         Visibility(
    //                           visible: ('${product.varients[0].price}'=='${product.varients[0].mrp}')?false:true,
    //                           child: Padding(
    //                             padding: const EdgeInsets.only(left:8.0),
    //                             child: Text('$apCurrency ${product.varients[0].mrp}',
    //                                 style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w300, fontSize: 13,decoration: TextDecoration.lineThrough)),
    //                           ),
    //                         ),
    //                         // buildRating(context),
    //                       ],
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //             Align(
    //               alignment: Alignment.centerRight,
    //               child: Text('${product.quantity} ${product.unit}',
    //                   style: TextStyle(color: Colors.grey[600], fontSize: 13)),
    //             ),
    //             SizedBox(height: 4),
    //             (int.parse('${product.varients[0].stock}') > 0)
    //                 ? Container(
    //               width: MediaQuery.of(context).size.width / 2,
    //               alignment: Alignment.center,
    //               child: Row(
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 children: [
    //                   buildIconButton(Icons.remove, context,
    //                       onpressed: () {
    //                         if (int.parse('${product.qty}') > 0 && !progressadd) {
    //                           int idd = products.indexOf(product);
    //                           addtocart(
    //                               '${product.storeId}',
    //                               '${product.varientId}',
    //                               (int.parse('${product.qty}')-1),
    //                               '0',
    //                               context,
    //                               idd);
    //                         }
    //                       },type: 0),
    //                   SizedBox(
    //                     width: 8,
    //                   ),
    //                   Text('${product.qty}',
    //                       style: Theme.of(context).textTheme.subtitle1),
    //                   SizedBox(
    //                     width: 8,
    //                   ),
    //                   buildIconButton(Icons.add, context,
    //                       onpressed: () {
    //                         if(!progressadd && (int.parse('${product.qty}')+1)<=int.parse('${product.varients[0].stock}')){
    //                           int idd = products.indexOf(product);
    //                           addtocart(
    //                               '${product.storeId}',
    //                               '${product.varients[0].varientId}',
    //                               (int.parse('${product.qty}')+1),
    //                               '0',
    //                               context,
    //                               idd);
    //                         }else{
    //                           if(!progressadd){
    //                             Toast.show('no more stock for this product', context,duration: Toast.LENGTH_SHORT,gravity: Toast.CENTER);
    //                           }
    //                         }
    //                       },type: 1),
    //                 ],
    //               ),
    //             ):Container(
    //               height: 15,
    //               width: MediaQuery.of(context).size.width / 2,
    //               decoration: BoxDecoration(
    //                 color: kCardBackgroundColor,
    //                 borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10)),
    //               ),
    //               alignment: Alignment.center,
    //               child: Text(
    //                 'Out of stock',
    //                 textAlign: TextAlign.center,
    //                 maxLines: 1,
    //                 style: TextStyle(fontSize: 13,color: kRedColor),
    //               ),
    //             ),
    //             SizedBox(height: 4),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
    if (cartItemd != null && cartItemd.length > 0) {
      int ind1 = cartItemd.indexOf(CartItemData('', '', '', '', '',
          '${product.varientId}', '', '', '', '', '', '', '', ''));
      if (ind1 >= 0) {
        product.qty = cartItemd[ind1].qty;
      }
    }
    return GestureDetector(
      onTap: () {
        // ProductDataModel modelP = ProductDataModel(
        //     pId: products.productId,
        //     productImage: products.productImage,
        //     productName: products.productName,
        //     tags: products.tags,
        //     varients: <ProductVarient>[
        //       ProductVarient(
        //           varientId: products.varientId,
        //           description: products.description,
        //           price: products.price,
        //           mrp: products.mrp,
        //           varientImage: products.varientImage,
        //           unit: products.unit,
        //           quantity: products.quantity,
        //           stock: products.stock,
        //           storeId: products.storeId)
        //     ]);
        int idd = wishModel.indexOf(WishListDataModel('', '',
            '${product.varientId}', '', '', '', '', '', '', '', '', '', '','',''));
        Navigator.pushNamed(context, PageRoutes.product, arguments: {
          'pdetails': product,
          'storedetails': storedetail,
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
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10)
            ),
            child: Stack(
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
                              imageUrl: '${product.productImage}',
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
                              child: Text(product.productName,
                                  maxLines: 1, style: TextStyle(fontWeight: FontWeight.w500)),),
                            SizedBox(height: 4),
                            Container(
                              width: MediaQuery.of(context).size.width / 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('$apCurrency ${product.price}',
                                      style:
                                      TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                  Visibility(
                                    visible:
                                    ('${product.price}' == '${product.mrp}') ? false : true,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text('$apCurrency ${product.mrp}',
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
                      child: Text('${product.quantity} ${product.unit}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ),
                    SizedBox(height: 5),
                    (int.parse('${product.stock}') > 0)
                        ? Container(
                      width: MediaQuery.of(context).size.width / 2,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildIconButton(Icons.remove, context,
                              onpressed: () {
                                if (int.parse('${product.qty}') > 0 && !progressadd) {
                                  int idd = products.indexOf(product);
                                  addtocart2(
                                      '${product.storeId}',
                                      '${product.varientId}',
                                      (int.parse('${product.qty}') - 1),
                                      '0',
                                      context,
                                      idd);
                                }
                              }),
                          SizedBox(
                            width: 8,
                          ),
                          Text('${product.qty}',
                              style: Theme.of(context).textTheme.subtitle1),
                          SizedBox(
                            width: 8,
                          ),
                          buildIconButton(Icons.add, context,
                              type: 1,
                              onpressed: () {
                                if ((int.parse('${product.qty}') + 1) <=
                                    int.parse('${product.stock}') && !progressadd) {
                                  int idd = products.indexOf(product);
                                  addtocart2(
                                      '${product.storeId}',
                                      '${product.varientId}',
                                      (int.parse('${product.qty}') + 1),
                                      '0',
                                      context,
                                      idd);
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
                ((((double.parse('${product.mrp}') - double.parse('${product.price}'))/double.parse('${product.mrp}'))*100)>0)?Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    padding: const EdgeInsets.all(3.0),
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: kPercentageBackC,
                      borderRadius: BorderRadius.only(topRight: Radius.circular(10),bottomRight: Radius.circular(10)),
                    ),
                    child: Text('${(((double.parse('${product.mrp}') - double.parse('${product.price}'))/double.parse('${product.mrp}'))*100).toStringAsFixed(2)} %',style: TextStyle(color:kWhiteColor,fontWeight: FontWeight.w500,fontSize: 12),),),
                ):SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
      // Column(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      //     Container(
      //       width: MediaQuery.of(context).size.width / 2.5,
      //       height: MediaQuery.of(context).size.width / 2.5,
      //       child: CachedNetworkImage(
      //         imageUrl: '${products.productImage}',
      //         placeholder: (context, url) => Align(
      //           widthFactor: 50,
      //           heightFactor: 50,
      //           alignment: Alignment.center,
      //           child: Container(
      //             padding: const EdgeInsets.all(5.0),
      //             width: 50,
      //             height: 50,
      //             child: CircularProgressIndicator(),
      //           ),
      //         ),
      //         errorWidget: (context, url, error) =>
      //             Image.asset('assets/icon.png'),
      //       ),
      //     ),
      //     Text(products.productName,maxLines: 1,
      //         style: TextStyle(fontWeight: FontWeight.w500)),
      //     Text('${products.quantity} ${products.unit}',
      //         style: TextStyle(color: Colors.grey[600], fontSize: 13)),
      //     SizedBox(height: 4),
      //     Container(
      //       width: MediaQuery.of(context).size.width / 2,
      //       child: Row(
      //         mainAxisAlignment: MainAxisAlignment.start,
      //         children: [
      //           Text('$apCurrency ${products.price}',
      //               style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      //           Visibility(
      //             visible:
      //             ('${products.price}' == '${products.mrp}') ? false : true,
      //             child: Padding(
      //               padding: const EdgeInsets.only(left: 8.0),
      //               child: Text('$apCurrency ${products.mrp}',
      //                   style: TextStyle(
      //                       color: Colors.grey[600],
      //                       fontWeight: FontWeight.w300,
      //                       fontSize: 13,
      //                       decoration: TextDecoration.lineThrough)),
      //             ),
      //           ),
      //           // buildRating(context),
      //         ],
      //       ),
      //     ),
      //     SizedBox(height: 4),
      //     (int.parse('${products.stock}') > 0)
      //         ? Container(
      //       width: MediaQuery.of(context).size.width / 2,
      //       alignment: Alignment.center,
      //       child: Row(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: [
      //           buildIconButton(Icons.remove, context,
      //               onpressed: () {
      //                 if (int.parse('${products.qty}') > 0) {
      //                   int idd = sellerProducts.indexOf(products);
      //                   addtocarts(
      //                       '${products.storeId}',
      //                       '${products.varientId}',
      //                       (int.parse('${products.qty}')-1),
      //                       '0',
      //                       context,
      //                       idd);
      //                 }
      //               }),
      //           SizedBox(
      //             width: 8,
      //           ),
      //           Text('${products.qty}',
      //               style: Theme.of(context).textTheme.subtitle1),
      //           SizedBox(
      //             width: 8,
      //           ),
      //           buildIconButton(Icons.add, context,
      //               onpressed: () {
      //                 if((int.parse('${products.qty}')+1)<=int.parse('${products.stock}')){
      //                   int idd = sellerProducts.indexOf(products);
      //                   addtocarts(
      //                       '${products.storeId}',
      //                       '${products.varientId}',
      //                       (int.parse('${products.qty}')+1),
      //                       '0',
      //                       context,
      //                       idd);
      //                 }else{
      //                   Toast.show('no more stock for this product', context,duration: Toast.LENGTH_SHORT,gravity: Toast.CENTER);
      //                 }
      //               }),
      //         ],
      //       ),
      //     )
      //         : Center(
      //       child: Text(
      //         'Out off stock',
      //         textAlign: TextAlign.center,
      //         maxLines: 1,
      //         style: TextStyle(fontSize: 10),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  GridView buildGridShView() {
    return GridView.builder(
        padding: EdgeInsets.symmetric(vertical: 10),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        primary: false,
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

  void addtocart2(String storeid, String varientid, dynamic qnty, String special,
      BuildContext context, int index) async {
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
              products[index].qty = data1.cart_items[dii].qty;
            } else {
              products[index].qty = 0;
            }
            _counter = data1.cart_items.length;
            cartCounterProvider.hitCartCounter(_counter);
          });
        } else {
          setState(() {
            products[index].qty = 0;
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



