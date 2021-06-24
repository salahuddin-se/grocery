import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'package:grocery/Locale/locales.dart';
import 'package:grocery/Pages/About/about_us.dart';
import 'package:grocery/Pages/About/contact_us.dart';
import 'package:grocery/Pages/DrawerPages/my_orders_drawer.dart';
import 'package:grocery/Pages/Other/home_page.dart';
import 'package:grocery/Pages/Other/select_language.dart';
import 'package:grocery/Pages/Search/cart.dart';
import 'package:grocery/Pages/User/my_account.dart';
import 'package:grocery/Pages/User/rewardcollection.dart';
import 'package:grocery/Pages/User/wishlist.dart';
import 'package:grocery/Pages/reffernearn.dart';
import 'package:grocery/Pages/tncpage/tnc_page.dart';
import 'package:grocery/Pages/wallet/walletui.dart';
import 'package:grocery/Theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';


Drawer buildDrawer(BuildContext context, userName, bool islogin,{VoidCallback onHit}) {
  var locale = AppLocalizations.of(context);
  return
    Drawer(
    child: Flex(
      direction: Axis.vertical,
      children: [
        Expanded(
          flex: 0,
          child: Container(
            height: 120.0,
            width: double.infinity,
            color:Colors.black,
            child:  Column(
              children: [
                SizedBox(height: 25.0),
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                       child:Text((userName!=null)?locale.hey + ' $userName':locale.hey + ' User',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyText1
                                      .copyWith(fontSize: 22, letterSpacing: 0.5),),
                    ),

                  ],
                ),
              ],
            ),
          ),
        ),
        Visibility(
          visible: islogin,
          child: Container(
            width:double.infinity,
            color:kMainColor,
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: (){
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MyOrdersDrawer()));
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Icon(Icons.list,size: 30.0,color: Colors.white,),
                            Container(child: Text("My Orders",style:Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 14.0,))),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: (){
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => RewardShow()));
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        child: Column(
                          children: [
                            Icon(Icons.wallet_giftcard,size: 30.0,color: Colors.white,),
                            Container(child: Text("Rewards",style:Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 14.0,))),

                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: (){
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Wallet()));
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        child: Column(
                          children: [
                            Icon(Icons.wallet_membership_rounded,size: 30.0,color: Colors.white,),
                            Container(
                                child: Text("Wallet",style:Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 14.0,))),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async{
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        Navigator.pop(context);
                        if(prefs.containsKey('islogin') && prefs.getBool('islogin')){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage()));
                        }else{
                          Toast.show(locale.loginfirst, context,gravity: Toast.CENTER,duration: Toast.LENGTH_SHORT);
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        child: Column(
                          children: [
                            Icon(Icons.shopping_cart_rounded,size: 30.0,color: Colors.white,),
                            Text("Cart",style:Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 14.0,)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child:Container(
            color: Colors.black,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      SizedBox(height: 10,),
                      buildListTile(context, Icons.home, locale.home, HomePage()),
                      Visibility(
                        visible: islogin,
                        child: buildListTile(
                            context, Icons.account_box, locale.myProfile, MyAccount()),
                      ),
                      // buildListTile(context, Icons.shopping_cart, locale.myOrders, MyOrdersDrawer()),
                      // buildListTile(
                      //     context, Icons.local_offer, locale.offers, OffersPage()),
                      Visibility(
                        visible: islogin,
                        child: buildListTile(
                            context, Icons.favorite, locale.myWishList, MyWishList()),
                      ),
                      // Visibility(
                      //   visible: islogin,
                      //   child: buildListTile(
                      //       context, Icons.account_balance_wallet_sharp, locale.mywallet, Wallet()),
                      // ),
                      buildListTile(
                          context, Icons.view_list, locale.aboutUs, AboutUsPage()),
                      buildListTile(context, Icons.admin_panel_settings_rounded,
                          locale.tnc, TNCPage()),
                      buildListTile(
                          context, Icons.chat, locale.helpCentre, ContactUsPage()),
                      buildListTile(
                          context, Icons.money, locale.inviteNEarn.toUpperCase(), RefferScreen()),
                      buildListTile(
                          context, Icons.language, locale.language, ChooseLanguage()),
                      ListTile(
                        onTap: () {
                          onHit();
                        },
                        leading: Icon(
                          Icons.subdirectory_arrow_right,
                          size: 25,
                          color: Theme.of(context).primaryColor,
                        ),
                        title: Text(
                          islogin?locale.logout:locale.login,
                          style: TextStyle(letterSpacing: 2,fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
          )
        ),
       ],
    ),
  );
}


ListTile buildListTile(
    BuildContext context, IconData icon, String title, Widget onPress) {
  return ListTile(
    onTap: () {
      Navigator.pop(context);
//      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) => onPress));
      // BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.HomePageClickedEvent);
    },
    leading: Icon(
      icon,
      color: Theme.of(context).primaryColor,
      size: 25,
    ),
    title: Text(
      title,
      style: TextStyle(letterSpacing: 2,fontSize: 15),
    ),
  );
}
