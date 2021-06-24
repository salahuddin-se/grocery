import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery/Components/constantfile.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Pages/Search/search_result.dart' as search;
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
import 'package:grocery/beanmodel/cart/addtocartbean.dart';
import 'package:grocery/beanmodel/cart/cartitembean.dart';
import 'package:grocery/beanmodel/category/topcategory.dart';
import 'package:grocery/beanmodel/productbean/productwithvarient.dart';
import 'package:grocery/beanmodel/storefinder/storefinderbean.dart';
import 'package:grocery/beanmodel/wishlist/wishdata.dart';
import 'package:grocery/providergrocery/cartcountprovider.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class SearchHistory extends StatefulWidget {
  @override
  _SearchHistoryState createState() => _SearchHistoryState();
}

class _SearchHistoryState extends State<SearchHistory> {
  final List<String> _searchList = [];
  List<ProductDataModel> recentSaleList = [];
  List<TopCategoryDataModel> topCategoryList = [];
  List<WishListDataModel> wishModel = [];
  StoreFinderData storeDetails;
  bool enterFirst = false;
  dynamic apCurrency;
  dynamic title = '';
  int type = 0;

  TextEditingController searchController = TextEditingController();

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
  }

  void getSharedValue() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      apCurrency = pref.getString('app_currency');
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

    Map<String, dynamic> receivedData =
        ModalRoute.of(context).settings.arguments;
    setState(() {
      if (!enterFirst) {
        enterFirst = true;
        topCategoryList = receivedData['category'];
        recentSaleList = receivedData['recentsale'];
        storeDetails = receivedData['storedetails'];
        wishModel = receivedData['wishlist'];
        title = receivedData['title'];
        type = receivedData['type'];
      }
    });
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TextField(
          controller: searchController,
          onSubmitted: (s) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => search.SearchResult(
                        wishModel, storeDetails, apCurrency, s)));
            setState(() {
              _searchList.add(s);
            });
          },
          style: Theme.of(context)
              .textTheme
              .headline6
              .copyWith(color: Colors.black, fontSize: 18),
          decoration: InputDecoration(
              hintText: '${locale.searchOnGoGrocer} $appname',
              hintStyle: Theme.of(context).textTheme.subtitle2,
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                ),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => search.SearchResult(wishModel,
                            storeDetails, apCurrency, searchController.text))),
              ),
              prefixIcon: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.grey[400],
                ),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(width: 1))),
        ),
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          _searchList.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16),
                      child: Text(
                        locale.recentlySearched,
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .copyWith(color: Colors.black),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      height: 144.0,
                      child: ListView.builder(
                        itemCount: _searchList.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: (){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => search.SearchResult(wishModel,
                                          storeDetails, apCurrency, _searchList[index])));
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 6.0,
                                    horizontal: 16.0,
                                  ),
                                  child: Icon(Icons.youtube_searched_for,
                                      color: Theme.of(context).backgroundColor),
                                ),
                                Text(
                                  _searchList[index],
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                )
              : SizedBox.shrink(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
            child: Text(
              locale.chooseCategory,
              style: Theme.of(context).textTheme.headline6.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 22),
            ),
          ),
          SizedBox(height: 6),
          Container(
            height: 118,
            child: ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: topCategoryList.length,
                itemBuilder: (context, index) {
                  return buildCategoryRow(
                      context, topCategoryList[index], storeDetails);
                }),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .copyWith(fontSize: 18)),
                // GestureDetector(
                //   onTap: () {},
                //   behavior: HitTestBehavior.opaque,
                //   child: Row(
                //     children: [
                //       Text(locale.viewAll,
                //           style: Theme.of(context)
                //               .textTheme
                //               .subtitle1
                //               .copyWith(fontSize: 16)),
                //       Icon(
                //         Icons.arrow_forward_ios,
                //         size: 15,
                //       )
                //     ],
                //   ),
                // )
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 16, top: 0, bottom: 16, right: 16),
            child: buildGridViewP(
                recentSaleList, apCurrency, wishModel, storeDetails),
          ),
        ],
      ),
    );
  }

  // GestureDetector buildCategoryRow(BuildContext context,
  //     TopCategoryDataModel categories, StoreFinderData storeFinderData) {
  //   return GestureDetector(
  //     onTap: () {
  //       Navigator.pushNamed(context, PageRoutes.cat_product, arguments: {
  //         'title': categories.title,
  //         'storeid': categories.store_id,
  //         'cat_id': categories.cat_id,
  //         'storedetail': storeFinderData,
  //       });
  //     },
  //     behavior: HitTestBehavior.opaque,
  //     child: Container(
  //       margin: EdgeInsets.only(left: 16),
  //       padding: EdgeInsets.all(10),
  //       width: 96,
  //       decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(12),
  //           color: kWhiteColor,
  //           image: DecorationImage(
  //               image: NetworkImage(categories.image), fit: BoxFit.fill)),
  //       child: Text(
  //         categories.title,
  //         style: TextStyle(color: kMainTextColor, fontWeight: FontWeight.w600),
  //       ),
  //     ),
  //   );
  // }

  GestureDetector buildCategoryRow(BuildContext context,
      TopCategoryDataModel categories, StoreFinderData storeFinderData) {
    return GestureDetector(
      onTap: () {
        if ('${categories.title}' == 'See all') {
          Navigator.pushNamed(context, PageRoutes.all_category, arguments: {
            'store_id': storeFinderData.store_id,
            'storedetail': storeFinderData,
          }).then((value) {
            getCartList();
          });
        } else {
          Navigator.pushNamed(context, PageRoutes.cat_product, arguments: {
            'title': categories.title,
            'storeid': categories.store_id,
            'cat_id': categories.cat_id,
            'storedetail': storeFinderData,
          }).then((value) {
            getCartList();
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

  GridView buildGridViewP(List<ProductDataModel> products, apCurrency,
      List<WishListDataModel> wishModel, StoreFinderData storeFinderData,
      {bool favourites = false}) {
    return GridView.builder(
        padding: EdgeInsets.only(top: 10,bottom: 20),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          return buildProductCard(
              context, products[index], apCurrency, wishModel, storeFinderData);
        });
  }

  Widget buildProductCard(
    BuildContext context,
    ProductDataModel products,
    dynamic apCurrency,
    List<WishListDataModel> wishModel,
    StoreFinderData storeFinderData,
  ) {
    if (cartItemd != null && cartItemd.length > 0) {
      int ind1 = cartItemd.indexOf(CartItemData('', '', '', '', '',
          '${products.varientId}', '', '', '', '', '', '', '', ''));
      if (ind1 >= 0) {
        products.qty = cartItemd[ind1].qty;
      }
    }
    return GestureDetector(
      onTap: () {
        if ('${products.productName}' == 'See all') {
          Navigator.pushNamed(context, PageRoutes.viewall, arguments: {
            'title': title,
            'type': type,
            'storedetail': storeFinderData,
          });
        } else {
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
            'storedetails': storeFinderData,
            'isInWish': (idd >= 0),
          });
        }
      },
      child: ('${products.productName}' == 'See all')
          ? Padding(
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
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
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
                ),
              ),
            )
          : Padding(
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
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500)),
                              ),
                              SizedBox(height: 4),
                              Container(
                                width: MediaQuery.of(context).size.width / 2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('$apCurrency ${products.price}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16)),
                                    Visibility(
                                      visible: ('${products.price}' ==
                                              '${products.mrp}')
                                          ? false
                                          : true,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                            '$apCurrency ${products.mrp}',
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w300,
                                                fontSize: 13,
                                                decoration: TextDecoration
                                                    .lineThrough)),
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
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 13)),
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
                                          int idd =
                                              recentSaleList.indexOf(products);
                                          addtocart2(
                                              '${products.storeId}',
                                              '${products.varientId}',
                                              (int.parse('${products.qty}') -
                                                  1),
                                              '0',
                                              context,
                                              idd);
                                        }
                                      }),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Text('${products.qty}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      buildIconButton(Icons.add, context,
                                          type: 1, onpressed: () {
                                        if ((int.parse('${products.qty}') +
                                                    1) <=
                                                int.parse(
                                                    '${products.stock}') &&
                                            !progressadd) {
                                          int idd =
                                              recentSaleList.indexOf(products);
                                          addtocart2(
                                              '${products.storeId}',
                                              '${products.varientId}',
                                              (int.parse('${products.qty}') +
                                                  1),
                                              '0',
                                              context,
                                              idd);
                                        } else {
                                          Toast.show(
                                              'no more stock for this product',
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
                                    style: TextStyle(
                                        fontSize: 13, color: kRedColor),
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
              recentSaleList[index].qty = data1.cart_items[dii].qty;
            } else {
              recentSaleList[index].qty = 0;
            }
            _counter = data1.cart_items.length;
            cartCounterProvider.hitCartCounter(_counter);
          });
        } else {
          setState(() {
            recentSaleList[index].qty = 0;
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
