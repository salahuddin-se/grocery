import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery/Components/constantfile.dart';
import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Routes/routes.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:grocery/baseurl/baseurlg.dart';
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

class SearchResult extends StatefulWidget {
  final List<WishListDataModel> wishModel;
  final StoreFinderData storeDetails;
  final dynamic apCurrency;
  final String searchString;

  const SearchResult(
      this.wishModel, this.storeDetails, this.apCurrency, this.searchString);

  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  TextEditingController searchController = TextEditingController();
  List<ProductDataModel> productsd = [];
  List<WishListDataModel> wishModel = [];
  StoreFinderData storeDetails;
  bool progressadd = false;
  List<CartItemData> cartItemd = [];
  int _counter = 0;
  dynamic apCurrency;
  CartCountProvider cartCounterProvider;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    cartCounterProvider = BlocProvider.of<CartCountProvider>(context);
    wishModel.clear();
    wishModel = List.from(widget.wishModel);
    storeDetails = widget.storeDetails;
    searchController.text = widget.searchString;
    getCartList();
    getSearchList(searchController.text);
  }

  void getSearchList(dynamic searchword) async {
    setState(() {
      isLoading = true;
    });
    var http = Client();
    http.post(searchByStoreUri, body: {
      'keyword': '$searchword',
      'store_id': '${storeDetails.store_id}'
    }).then((value) {
      print(value.body);
      if (value.statusCode == 200) {
        ProductModel pData = ProductModel.fromJson(jsonDecode(value.body));
        if ('${pData.status}' == '1') {
          productsd.clear();
          setState(() {
            productsd = List.from(pData.data);
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
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TextFormField(
          controller: searchController,
          style: Theme.of(context)
              .textTheme
              .headline6
              .copyWith(color: Colors.black, fontSize: 18),
          onFieldSubmitted: (value) {
            getSearchList(value);
          },
          decoration: InputDecoration(
              suffixIcon: Icon(
                Icons.search,
                color: Colors.grey[400],
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
        child: (!isLoading && (productsd!=null && productsd.length>0))?ListView(
          physics: BouncingScrollPhysics(),
          children: [
            Text(
              (productsd != null && productsd.length > 0)
                  ? '${productsd.length} ' + locale.resultsFound
                  : '',
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(color: Colors.grey[400], fontSize: 16),
            ),
            SizedBox(
              height: 16,
            ),
            buildGridViewP(
                context, productsd, widget.apCurrency, wishModel, storeDetails),
          ],
        ):(isLoading)?buildGridShView():Center(
          child: Text(locale.productnotfound),
        ),
      ),
    );
  }

  GridView buildGridViewP(
      BuildContext context,
      List<ProductDataModel> products,
      apCurrency,
      List<WishListDataModel> wishModel,
      StoreFinderData storeDetails,
      {bool favourites = false}) {
    print('dd -> ${products.toString()}');
    return GridView.builder(
        padding: EdgeInsets.symmetric(vertical: 20),
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          return buildProductCard(
              context, products[index], apCurrency, wishModel, storeDetails);
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
          '${products.varients[0].varientId}', '', '', '', '', '', '', '', ''));
      if (ind1 >= 0) {
        products.qty = cartItemd[ind1].qty;
      }
    }
    print('dd ${products.mrp}');
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
          'storedetails': storeDetails,
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
                              Text('$apCurrency ${products.price}',
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
                                  child: Text('$apCurrency ${products.mrp}',
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
}
