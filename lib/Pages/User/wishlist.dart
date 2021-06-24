import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery/Components/constantfile.dart';
import 'package:grocery/Components/custom_button.dart';
import 'package:grocery/Components/drawer.dart';
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
import 'package:grocery/main.dart';
import 'package:grocery/providergrocery/cartcountprovider.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:toast/toast.dart';

class MyWishList extends StatefulWidget {
  @override
  _MyWishListState createState() => _MyWishListState();
}

class _MyWishListState extends State<MyWishList> {
  var userName;
  bool islogin = false;
  List<WishListDataModel> wishModel = [];
  StoreFinderData _storeFinderData;
  bool isLoading = false;
  dynamic apCurrency;
  var http = Client();
  bool progressadd = false;
  List<CartItemData> cartItemd = [];
  int _counter = 0;
  CartCountProvider cartCounterProvider;

  @override
  void initState() {
    super.initState();
    cartCounterProvider = BlocProvider.of<CartCountProvider>(context);
    getSharedValue();
    getCartList();
    // hitAppInfo();
  }

  getSharedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
      islogin = prefs.getBool('islogin');
      userName = prefs.getString('user_name');
      apCurrency = prefs.getString('app_currency');
    });
    int st = -1;
    if (prefs.containsKey('store_id_last')) {
      st = int.parse('${prefs.getString('store_id_last')}');
      if (prefs.containsKey('storelist')) {
        var storeListpf = jsonDecode(prefs.getString('storelist')) as List;
        List<StoreFinderData> dataFinderL = [];
        dataFinderL = List.from(
            storeListpf.map((e) => StoreFinderData.fromJson(e)).toList());
        int idd1 = dataFinderL.indexOf(StoreFinderData('', st, '', '', '', '',''));
        if (idd1 >= 0) {
          _storeFinderData = dataFinderL[idd1];
        }
      }
      getWislist(st);
    } else {
      getWislist('');
    }
  }

  void getWislist(dynamic storeId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic userId = prefs.getInt('user_id');
    var url = showWishlistUri;
    await http.post(url,
        body: {'user_id': '${userId}', 'store_id': '$storeId'}).then((value) {
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
      setState(() {
        isLoading = false;
      });
    }).catchError((e) {
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
  void dispose() {
    http.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          locale.myWishList.toUpperCase(),
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
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
              child: IconButton(
                icon: ImageIcon(AssetImage(
                  'assets/ic_cart.png',
                )),
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  if (prefs.containsKey('islogin') && prefs.getBool('islogin')) {
                    Navigator.pushNamed(context, PageRoutes.cartPage);
                  } else {
                    Toast.show(locale.loginfirst, context,
                        gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
                  }
                },
              ),
            );
          })
        ],
      ),
      drawer: buildDrawer(context, '$userName', islogin, onHit: () {
        SharedPreferences.getInstance().then((pref) {
          pref.clear().then((value) {
            Navigator.of(context).pushNamedAndRemoveUntil(PageRoutes.signInRoot, (Route<dynamic> route) => false);
          });
        });
      }),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: (isLoading)
                  ? buildGridShView()
                  : (wishModel != null && wishModel.length > 0)
                      ? buildGridView(wishModel, apCurrency, _storeFinderData)
                      : Container(
                          alignment: Alignment.center,
                          child: Text(locale.noprodwishlist),
                        ),
            ),
          ),
          Visibility(
            visible: ((_storeFinderData != null &&
                    _storeFinderData.store_id != null) &&
                (wishModel != null && wishModel.length > 0)),
            child: CustomButton(
              onTap: () {
                if (!isLoading) {
                  setState(() {
                    isLoading = true;
                  });
                  hitWishToCart();
                }
              },
              label: locale.clickToAddCart,
            ),
          )
        ],
      ),
    );
  }

  void hitWishToCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    http.post(wishlistToCartUri, body: {
      'user_id': '${prefs.getInt('user_id')}',
      'store_id': '${_storeFinderData.store_id}',
    }).then((value) {
      print('waddct -  ${value.body}');
      if (value.statusCode == 200) {
        AddToCartMainModel data1 =
            AddToCartMainModel.fromJson(jsonDecode(value.body));
        Toast.show(data1.message, context,
            gravity: Toast.CENTER, duration: Toast.LENGTH_SHORT);
      }
      getWislist(_storeFinderData.store_id);
// setState(() {
//   isLoading = false;
// });
    }).catchError((e) {
      setState(() {
        isLoading = false;
      });
    });
  }

  GridView buildGridView(List<WishListDataModel> wishModel, String apCurrency,
      StoreFinderData finderData) {
    return GridView.builder(
        padding: EdgeInsets.symmetric(vertical: 20),
        // physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: wishModel.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          return buildProductCard(
              context, wishModel[index], '$apCurrency', finderData);
        });
  }

  Widget buildProductCard(BuildContext context, WishListDataModel products,
      String apCurrency, StoreFinderData finderData) {
    if (cartItemd != null && cartItemd.length > 0) {
      int ind1 = cartItemd.indexOf(CartItemData('', '', '', '', '',
          '${products.varient_id}', '', '', '', '', '', '', '', ''));
      if (ind1 >= 0) {
        products.qty = cartItemd[ind1].qty;
      }
    }
    return GestureDetector(
      onTap: () {
        if (finderData != null) {
          ProductDataModel modelP = ProductDataModel(
              pId: products.varient_id,
              productImage: products.varient_image,
              productName: products.product_name,
              tags: [],
              varients: <ProductVarient>[
                ProductVarient(
                    varientId: products.varient_id,
                    description: products.description,
                    price: products.price,
                    mrp: products.mrp,
                    varientImage: products.varient_image,
                    unit: products.unit,
                    quantity: products.quantity,
                    stock: 1,
                    storeId: products.store_id)
              ]);
          Navigator.pushNamed(context, PageRoutes.product, arguments: {
            'pdetails': modelP,
            'storedetails': finderData,
            'isInWish': true,
          });
        }
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
                              imageUrl: '${products.varient_image}',
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
                              child: Text(products.product_name,
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
                                if (int.parse('${products.qty}') > 0 && !progressadd) {
                                  int idd = wishModel.indexOf(products);
                                  addtocart2(
                                      '${products.store_id}',
                                      '${products.varient_id}',
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
                              style: Theme.of(context).textTheme.subtitle1),
                          SizedBox(
                            width: 8,
                          ),
                          buildIconButton(Icons.add, context,
                              type: 1,
                              onpressed: () {
                                if ((int.parse('${products.qty}') + 1) <=
                                    int.parse('${products.stock}') && !progressadd) {
                                  int idd = wishModel.indexOf(products);
                                  addtocart2(
                                      '${products.store_id}',
                                      '${products.varient_id}',
                                      (int.parse('${products.qty}') + 1),
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
          ),
        ),
      ),
    );
  }

  GridView buildGridShView() {
    return GridView.builder(
        padding: EdgeInsets.symmetric(vertical: 10),
        // physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        primary: false,
        itemCount: 10,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.80,
          crossAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          return buildProductShCard(context);
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
              wishModel[index].qty = data1.cart_items[dii].qty;
            } else {
              wishModel[index].qty = 0;
            }
            _counter = data1.cart_items.length;
            cartCounterProvider.hitCartCounter(_counter);
          });
        } else {
          setState(() {
            wishModel[index].qty = 0;
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

