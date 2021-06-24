import 'package:flutter/material.dart';
import 'package:grocery/Auth/Login/lang_selection.dart';
import 'package:grocery/Auth/Login/sign_in.dart';
import 'package:grocery/Auth/Login/sign_up.dart';
import 'package:grocery/Auth/Login/verification.dart';

import 'package:grocery/Components/cardstripe.dart';
import 'package:grocery/Pages/Checkout/Address.dart';
import 'package:grocery/Pages/Checkout/ConfirmOrder.dart';
import 'package:grocery/Pages/Checkout/PaymentMode.dart';
import 'package:grocery/Pages/Checkout/my_orders.dart';
import 'package:grocery/Pages/Checkout/orderdetailpage.dart';
import 'package:grocery/Pages/DrawerPages/invoicepage.dart';
import 'package:grocery/Pages/Other/add_address.dart';
import 'package:grocery/Pages/Other/category_products.dart';
import 'package:grocery/Pages/Other/edit_address.dart';
import 'package:grocery/Pages/Other/home_page.dart';
import 'package:grocery/Pages/Other/offers.dart';
import 'package:grocery/Pages/Other/product_info.dart';
import 'package:grocery/Pages/Other/productbytags.dart';
import 'package:grocery/Pages/Other/reviews.dart';
import 'package:grocery/Pages/Other/seller_info.dart';
import 'package:grocery/Pages/Search/cart.dart';
import 'package:grocery/Pages/Search/search_history.dart';
import 'package:grocery/Pages/Search/searchean.dart';
import 'package:grocery/Pages/categorypage/cat_sub_product.dart';
import 'package:grocery/Pages/categorypage/categorypage.dart';
import 'package:grocery/forgotpassword/changepassword.dart';
import 'package:grocery/forgotpassword/otpverifity.dart';
import 'package:grocery/forgotpassword/resetpasswordNumber.dart';
import 'package:grocery/Pages/productpage.dart';

class PageRoutes {
  static const String signInRoot = 'signIn/';
  static const String signUp = 'signUp';
  static const String verification = 'verification';
  static const String restpassword1 = 'restpassword1';
  static const String restpassword2 = 'restpassword2';
  static const String restpassword3 = 'restpassword3';

  static const String sidebar = '/side_bar';
  static const String viewall = '/viewall';
  static const String homePage = '/home_page';
  static const String all_category = '/all_category';
  static const String cat_product = '/cat_product';
  static const String product = '/product';
  // static const String cart = '/cart';
  static const String search = '/search';
  static const String searchhistory = '/searchhistory';
  static const String cat_sub_p = '/catsubp';
  static const String tagproduct = '/tagproduct';
  static const String reviewsall = '/reviewsall';
//  static const String confirmOrder = 'confirm_order';
  static const String cartPage = 'checkout';
  static const String selectAddress = 'selectAddress';
  static const String editAddress = 'editAddress';
  static const String paymentMode = 'paymentMode';
  static const String confirmOrder = 'confirmOrder';
  static const String orderdetailspage = 'orderdetailspage';
  static const String myorder = 'myorder';
  static const String addaddressp = 'addaddressp';
  static const String stripecard = 'stripecard';
  static const String invoice = 'invoice';
  static const String langnewf = '/langnewf';
  static const String sellerinfo = '/sellerinfo';
  static const String offerpage = '/offerpage';

  Map<String, WidgetBuilder> routes() {
    return {
      homePage: (context) => HomePage(),
      all_category: (context) => AllCategory(),
      cat_product: (context) => CategoryProduct(),
      product: (context) => ProductInfo(),
      // cart: (context) => CheckOutNavigator(),
      search: (context) => SearchEan(),
      searchhistory: (context) => SearchHistory(),
      cat_sub_p: (context) => CategorySubProduct(),
      tagproduct: (context) => TagsProduct(),
      reviewsall: (context) => Reviews(),
      cartPage: (context) => CartPage(),
      selectAddress: (context) => AddressPage(),
      editAddress: (context) => EditAddressPage(),
      orderdetailspage: (context) => OrderDeatilsPage(),
      paymentMode: (context) => PaymentModePage(),
      confirmOrder: (context) => ConfirmOrderPage(),
      myorder: (context) => MyOrders(),
      addaddressp: (context) => AddAddressPage(),
      stripecard: (context) => MyStripeCard(),
      invoice: (context) => MyInvoicePdf(),
      signInRoot: (context) => SignIn(),
      signUp: (context) => SignUp(),
      verification: (context) => VerificationPage(),
      restpassword1: (context) => NumberScreenRestPassword(),
      restpassword2: (context) => ResetOtpVerify(),
      restpassword3: (context) => ChangePassword(),
      viewall: (context) => ViewAllProduct(),
      langnewf: (context) => ChooseLanguageNew(),
      sellerinfo: (context) => SellerInfo(),
     offerpage: (context) => OffersPage(),
    };
  }
}
