// import 'package:flutter/material.dart';
//
// Widget setView(BuildContext context){
//   return Expanded(
//     child: Padding(
//       padding: EdgeInsets.only(top: 10),
//       child: (storeFinderData != null || singleLoading)
//           ? SingleChildScrollView(
//         scrollDirection: Axis.vertical,
//         primary: true,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               height: 118,
//               child: ListView.builder(
//                   physics: BouncingScrollPhysics(),
//                   shrinkWrap: true,
//                   scrollDirection: Axis.horizontal,
//                   itemCount: topCategoryList.length,
//                   itemBuilder: (contexts, index) {
//                     return buildCategoryRow(
//                         context,
//                         topCategoryList[index],
//                         storeFinderData);
//                   }),
//             ),
//             SizedBox(height: 5.0),
//             Stack(
//               children: [
//                 CarouselSlider(
//                   items: bannerList.map((i) {
//                     return Builder(
//                       builder: (BuildContext context) {
//                         return GestureDetector(
//                           onTap: () {
//                             Navigator.pushNamed(context,
//                                 PageRoutes.cat_product,
//                                 arguments: {
//                                   'title': i.title,
//                                   'storeid': storeFinderData
//                                       .store_id,
//                                   'cat_id': i.cat_id,
//                                   'storedetail':
//                                   storeFinderData,
//                                 }).then((valuef) {
//                               getCartList();
//                             });
//                           },
//                           child: Container(
//                               child: CachedNetworkImage(
//                                 imageUrl: '${i.banner_image}',
//                                 placeholder: (context, url) =>
//                                     Align(
//                                       widthFactor: 50,
//                                       heightFactor: 50,
//                                       alignment: Alignment.center,
//                                       child: Container(
//                                         padding:
//                                         const EdgeInsets.all(
//                                             5.0),
//                                         width: 50,
//                                         height: 50,
//                                         child:
//                                         CircularProgressIndicator(),
//                                       ),
//                                     ),
//                                 errorWidget:
//                                     (context, url, error) =>
//                                     Image.asset(
//                                         'assets/icon.png'),
//                               )
//                             //     Image(
//                             //   image: NetworkImage(i.banner_image),
//                             // )
//                           ),
//                         );
//                       },
//                     );
//                   }).toList(),
//                   options: CarouselOptions(
//                       autoPlay: true,
//                       viewportFraction: 1.0,
//                       enlargeCenterPage: false,
//                       onPageChanged: (index, reason) {
//                         setState(() {
//                           _current = index;
//                         });
//                       }),
//                 ),
//                 Positioned.directional(
//                   textDirection: Directionality.of(context),
//                   start: 20.0,
//                   bottom: 0.0,
//                   child: Row(
//                     children: bannerList.map((i) {
//                       int index = bannerList.indexOf(i);
//                       return Container(
//                         width: 12.0,
//                         height: 3.0,
//                         margin: EdgeInsets.symmetric(
//                             vertical: 16.0,
//                             horizontal: 4.0),
//                         decoration: BoxDecoration(
//                           shape: BoxShape.rectangle,
//                           color: _current == index
//                               ? Colors
//                               .white /*.withOpacity(0.9)*/
//                               : Colors.white
//                               .withOpacity(0.5),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 )
//               ],
//             ),
//             SizedBox(
//               height: 5,
//             ),
//             // FlatSegmentedControl(
//             //   childrenWidth:MediaQuery.of(context).size.width/2,
//             //   isChildrenSwipeable: true,
//             //   tabChildren: <Widget>[
//             //     Card(
//             //       color: kMainColor,
//             //       elevation: 0.5,
//             //       child: Container(
//             //         width: MediaQuery.of(context).size.width/2,
//             //         padding: EdgeInsets.symmetric(horizontal: 1,vertical: 20),
//             //         child: Text('Top Selling',textAlign: TextAlign.center,style: TextStyle(
//             //             fontSize: 16
//             //         ),),
//             //       ),
//             //     ),
//             //     Card(
//             //       color: kWhiteColor,
//             //       elevation: 0.5,
//             //       child: Container(
//             //         width: MediaQuery.of(context).size.width/2,
//             //         padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
//             //         child: Text('Whats New',textAlign: TextAlign.center,style: TextStyle(
//             //             fontSize: 16
//             //         ),),
//             //       ),
//             //     ),
//             //     Card(
//             //       color: Colors.grey[200],
//             //       elevation: 0.5,
//             //       child: Container(
//             //         width: MediaQuery.of(context).size.width/2,
//             //         padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
//             //         child: Text('Recent Selling',textAlign: TextAlign.center,style: TextStyle(
//             //             fontSize: 16
//             //         ),),
//             //       ),
//             //     )
//             //   ],
//             //   children: <Widget>[
//             //     ListView.builder(
//             //         itemCount:5,
//             //         shrinkWrap: true,
//             //         primary: false,
//             //         physics: NeverScrollableScrollPhysics(),
//             //         itemBuilder: (context,index){
//             //           return Container(
//             //             padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
//             //             child: Text('Recent Selling',textAlign: TextAlign.center,style: TextStyle(
//             //                 fontSize: 16
//             //             ),),
//             //           );
//             //         }),
//             //     ListView.builder(
//             //         itemCount:5,
//             //         shrinkWrap: true,
//             //         primary: false,
//             //         physics: NeverScrollableScrollPhysics(),
//             //         itemBuilder: (context,index){
//             //           return Container(
//             //             padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
//             //             child: Text('Recent Selling',textAlign: TextAlign.center,style: TextStyle(
//             //                 fontSize: 16
//             //             ),),
//             //           );
//             //         }),
//             //     ListView.builder(
//             //         itemCount:5,
//             //         shrinkWrap: true,
//             //         primary: false,
//             //         physics: NeverScrollableScrollPhysics(),
//             //         itemBuilder: (context,index){
//             //           return Container(
//             //             padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
//             //             child: Text('Recent Selling',textAlign: TextAlign.center,style: TextStyle(
//             //                 fontSize: 16
//             //             ),),
//             //           );
//             //         })
//             //   ],
//             // ),
//             Container(
//               height: 60,
//               child: ListView.builder(
//                   itemCount: tabList.length,
//                   shrinkWrap: true,
//                   scrollDirection: Axis.horizontal,
//                   itemBuilder: (context,index){
//                     return GestureDetector(
//                       onTap: (){
//                         setState(() {
//                           selectTabt = tabList[index].identifier;
//                         });
//                       },
//                       behavior: HitTestBehavior.opaque,
//                       child: Card(
//                         color: (tabList[index].identifier==selectTabt)?kMainColor:kWhiteColor,
//                         elevation: 0.5,
//                         child: Container(
//                           width: MediaQuery.of(context).size.width*0.42,
//                           alignment: Alignment.center,
//                           padding: EdgeInsets.symmetric(horizontal: 1,vertical: 5),
//                           margin: EdgeInsets.only(),
//                           child: Text(tabList[index].tabString,textAlign: TextAlign.center,style: TextStyle(
//                               fontSize: 16,
//                               color:(tabList[index].identifier==selectTabt)?kWhiteColor:kMainTextColor
//                           ),),
//                         ),
//                       ),
//                     );
//                   }),
//             ),
//             // Visibility(
//             //   visible: (selectTabt == 0),
//             //     child: ListView.builder(
//             //     itemCount:topSaleList.length,
//             //     shrinkWrap: true,
//             //     primary: false,
//             //     physics: NeverScrollableScrollPhysics(),
//             //     itemBuilder: (context,index){
//             //       return Padding(
//             //         padding: const EdgeInsets.symmetric(
//             //             vertical: 10.0, horizontal: 12),
//             //         child: Row(
//             //           crossAxisAlignment: CrossAxisAlignment.end,
//             //           children: [
//             //             ClipRRect(
//             //                 borderRadius: BorderRadius.circular(10),
//             //                 child: Image.network(
//             //                   topSaleList[index].varientImage,
//             //                   width: 90,
//             //                   height: 95,
//             //                 )),
//             //             SizedBox(
//             //               width: 15,
//             //             ),
//             //             Expanded(
//             //               child: Column(
//             //                 crossAxisAlignment: CrossAxisAlignment.start,
//             //                 mainAxisAlignment: MainAxisAlignment.start,
//             //                 children: [
//             //                   Text(
//             //                     topSaleList[index].productName,
//             //                     style: Theme.of(context).textTheme.subtitle1,
//             //                   ),
//             //                   SizedBox(
//             //                     height: 8,
//             //                   ),
//             //                   Text(
//             //                     '${topSaleList[index].quantity} ${topSaleList[index].unit}',
//             //                     style: Theme.of(context).textTheme.subtitle2,
//             //                   ),
//             //                   SizedBox(
//             //                     height: 20,
//             //                   ),
//             //                   Row(
//             //                     mainAxisAlignment: MainAxisAlignment.start,
//             //                     children: [
//             //                       buildIconButton(
//             //                           Icons.remove,context,onpressed: (){
//             //                             // addtocart(, varientid, qnty, special, context, index, listtype)
//             //                       }),
//             //                       SizedBox(
//             //                         width: 15,
//             //                       ),
//             //                       Text('${topSaleList[index].qty}',
//             //                           style: Theme.of(context)
//             //                               .textTheme
//             //                               .subtitle1),
//             //                       SizedBox(
//             //                         width: 15,
//             //                       ),
//             //                       buildIconButton(
//             //                           Icons.add,context,type: 1,),
//             //                       SizedBox(
//             //                         width: 40,
//             //                       ),
//             //                     ],
//             //                   ),
//             //                 ],
//             //               ),
//             //             ),
//             //             Text('$apCurrency ${topSaleList[index].price}',
//             //                 textAlign: TextAlign.right,
//             //                 style: Theme.of(context).textTheme.subtitle1),
//             //           ],
//             //         ),
//             //       );
//             //     })
//             // ),
//             Expanded(
//               // width: MediaQuery.of(context).size.width,
//               // height: 150,
//               child: ListView.builder(
//                   itemCount: tabDataList.length,
//                   shrinkWrap: true,
//                   physics: ClampingScrollPhysics(),
//                   scrollDirection: Axis.horizontal,
//                   primary: false,
//                   itemBuilder: (context,idi){
//                     return ListView.builder(
//                         itemCount:tabDataList[idi].data.length,
//                         shrinkWrap: true,
//                         primary: false,
//                         physics: NeverScrollableScrollPhysics(),
//                         itemBuilder: (context,index){
//                           return Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 vertical: 10.0, horizontal: 12),
//                             child: Row(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 ClipRRect(
//                                     borderRadius: BorderRadius.circular(10),
//                                     child: Image.network(
//                                       tabDataList[idi].data[index].productImage,
//                                       width: 90,
//                                       height: 95,
//                                     )),
//                                 SizedBox(
//                                   width: 15,
//                                 ),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         tabDataList[idi].data[index].productName,
//                                         style: Theme.of(context).textTheme.subtitle1,
//                                       ),
//                                       SizedBox(
//                                         height: 8,
//                                       ),
//                                       Text(
//                                         '${tabDataList[idi].data[index].quantity} ${tabDataList[idi].data[index].unit}',
//                                         style: Theme.of(context).textTheme.subtitle2,
//                                       ),
//                                       SizedBox(
//                                         height: 20,
//                                       ),
//                                       Row(
//                                         mainAxisAlignment: MainAxisAlignment.start,
//                                         children: [
//                                           buildIconButton(
//                                               Icons.remove,context,onpressed: (){
//                                             if (int.parse('${tabDataList[idi].data[index].qty}') > 0 && !progressadd) {
//                                               // int idd = topcct[listtype].products.indexOf(products);
//                                               addtocart2(tabDataList[idi].data[index].storeId, tabDataList[idi].data[index].varientId, (int.parse('${tabDataList[idi].data[index].qty}') - 1), '0', context, index, 0);
//                                             }
//                                           }),
//                                           SizedBox(
//                                             width: 15,
//                                           ),
//                                           Text('${tabDataList[idi].data[index].qty}',
//                                               style: Theme.of(context)
//                                                   .textTheme
//                                                   .subtitle1),
//                                           SizedBox(
//                                             width: 15,
//                                           ),
//                                           buildIconButton(
//                                               Icons.add,context,type: 1,
//                                               onpressed: (){
//
//                                                 if ((int.parse('${tabDataList[idi].data[index].qty}') + 1) <=
//                                                     int.parse('${tabDataList[idi].data[index].stock}') && !progressadd) {
//                                                   // int idd = topcct[listtype].products.indexOf(products);
//                                                   addtocart2(tabDataList[0].data[index].storeId, tabDataList[idi].data[index].varientId, (int.parse('${tabDataList[idi].data[index].qty}') + 1), '0', context, index, 0);
//                                                 } else {
//                                                   if(!progressadd){
//                                                     Toast.show('no more stock for this product', context,
//                                                         duration: Toast.LENGTH_SHORT,
//                                                         gravity: Toast.CENTER);
//                                                   }
//                                                 }
//                                               }),
//                                           SizedBox(
//                                             width: 40,
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Text('$apCurrency ${tabDataList[idi].data[index].price}',
//                                     textAlign: TextAlign.right,
//                                     style: Theme.of(context).textTheme.subtitle1),
//                               ],
//                             ),
//                           );
//                         });
//                   }),
//             ),
//             // Visibility(
//             //   child: ListView.builder(
//             //       itemCount:tabDataList[0].data.length,
//             //       shrinkWrap: true,
//             //       primary: false,
//             //       physics: NeverScrollableScrollPhysics(),
//             //       itemBuilder: (context,index){
//             //         return Padding(
//             //           padding: const EdgeInsets.symmetric(
//             //               vertical: 10.0, horizontal: 12),
//             //           child: Row(
//             //             crossAxisAlignment: CrossAxisAlignment.end,
//             //             children: [
//             //               ClipRRect(
//             //                   borderRadius: BorderRadius.circular(10),
//             //                   child: Image.network(
//             //                     tabDataList[0].data[index].productImage,
//             //                     width: 90,
//             //                     height: 95,
//             //                   )),
//             //               SizedBox(
//             //                 width: 15,
//             //               ),
//             //               Expanded(
//             //                 child: Column(
//             //                   crossAxisAlignment: CrossAxisAlignment.start,
//             //                   mainAxisAlignment: MainAxisAlignment.start,
//             //                   children: [
//             //                     Text(
//             //                       tabDataList[0].data[index].productName,
//             //                       style: Theme.of(context).textTheme.subtitle1,
//             //                     ),
//             //                     SizedBox(
//             //                       height: 8,
//             //                     ),
//             //                     Text(
//             //                       '${tabDataList[0].data[index].quantity} ${tabDataList[0].data[index].unit}',
//             //                       style: Theme.of(context).textTheme.subtitle2,
//             //                     ),
//             //                     SizedBox(
//             //                       height: 20,
//             //                     ),
//             //                     Row(
//             //                       mainAxisAlignment: MainAxisAlignment.start,
//             //                       children: [
//             //                         buildIconButton(
//             //                             Icons.remove,context,onpressed: (){
//             //                           if (int.parse('${tabDataList[0].data[index].qty}') > 0 && !progressadd) {
//             //                             // int idd = topcct[listtype].products.indexOf(products);
//             //                             addtocart2(tabDataList[0].data[index].storeId, tabDataList[0].data[index].varientId, (int.parse('${tabDataList[0].data[index].qty}') - 1), '0', context, index, 0);
//             //                           }
//             //                         }),
//             //                         SizedBox(
//             //                           width: 15,
//             //                         ),
//             //                         Text('${tabDataList[0].data[index].qty}',
//             //                             style: Theme.of(context)
//             //                                 .textTheme
//             //                                 .subtitle1),
//             //                         SizedBox(
//             //                           width: 15,
//             //                         ),
//             //                         buildIconButton(
//             //                             Icons.add,context,type: 1,
//             //                             onpressed: (){
//             //
//             //                               if ((int.parse('${tabDataList[0].data[index].qty}') + 1) <=
//             //                                   int.parse('${tabDataList[0].data[index].stock}') && !progressadd) {
//             //                                 // int idd = topcct[listtype].products.indexOf(products);
//             //                                 addtocart2(tabDataList[0].data[index].storeId, tabDataList[0].data[index].varientId, (int.parse('${tabDataList[0].data[index].qty}') + 1), '0', context, index, 0);
//             //                               } else {
//             //                                 if(!progressadd){
//             //                                   Toast.show('no more stock for this product', context,
//             //                                       duration: Toast.LENGTH_SHORT,
//             //                                       gravity: Toast.CENTER);
//             //                                 }
//             //                               }
//             //                             }),
//             //                         SizedBox(
//             //                           width: 40,
//             //                         ),
//             //                       ],
//             //                     ),
//             //                   ],
//             //                 ),
//             //               ),
//             //               Text('$apCurrency ${tabDataList[0].data[index].price}',
//             //                   textAlign: TextAlign.right,
//             //                   style: Theme.of(context).textTheme.subtitle1),
//             //             ],
//             //           ),
//             //         );
//             //       }),
//             // ),
//             // Visibility(
//             //     visible: (selectTabt == 1),
//             //     child: ListView.builder(
//             //         itemCount:recentSaleList.length,
//             //         shrinkWrap: true,
//             //         primary: false,
//             //         physics: NeverScrollableScrollPhysics(),
//             //         itemBuilder: (context,index){
//             //           return Padding(
//             //             padding: const EdgeInsets.symmetric(
//             //                 vertical: 10.0, horizontal: 12),
//             //             child: Row(
//             //               crossAxisAlignment: CrossAxisAlignment.end,
//             //               children: [
//             //                 ClipRRect(
//             //                     borderRadius: BorderRadius.circular(10),
//             //                     child: Image.network(
//             //                       recentSaleList[index].varientImage,
//             //                       width: 90,
//             //                       height: 95,
//             //                     )),
//             //                 SizedBox(
//             //                   width: 15,
//             //                 ),
//             //                 Expanded(
//             //                   child: Column(
//             //                     crossAxisAlignment: CrossAxisAlignment.start,
//             //                     mainAxisAlignment: MainAxisAlignment.start,
//             //                     children: [
//             //                       Text(
//             //                         recentSaleList[index].productName,
//             //                         style: Theme.of(context).textTheme.subtitle1,
//             //                       ),
//             //                       SizedBox(
//             //                         height: 8,
//             //                       ),
//             //                       Text(
//             //                         '${recentSaleList[index].quantity} ${recentSaleList[index].unit}',
//             //                         style: Theme.of(context).textTheme.subtitle2,
//             //                       ),
//             //                       SizedBox(
//             //                         height: 20,
//             //                       ),
//             //                       Row(
//             //                         mainAxisAlignment: MainAxisAlignment.start,
//             //                         children: [
//             //                           buildIconButton(
//             //                               Icons.remove,context),
//             //                           SizedBox(
//             //                             width: 15,
//             //                           ),
//             //                           Text('${recentSaleList[index].qty}',
//             //                               style: Theme.of(context)
//             //                                   .textTheme
//             //                                   .subtitle1),
//             //                           SizedBox(
//             //                             width: 15,
//             //                           ),
//             //                           buildIconButton(
//             //                               Icons.add,context,type: 1,),
//             //                           SizedBox(
//             //                             width: 40,
//             //                           ),
//             //                         ],
//             //                       ),
//             //                     ],
//             //                   ),
//             //                 ),
//             //                 Text('$apCurrency ${recentSaleList[index].price}',
//             //                     textAlign: TextAlign.right,
//             //                     style: Theme.of(context).textTheme.subtitle1),
//             //               ],
//             //             ),
//             //           );
//             //         })),
//             // Visibility(
//             //     visible: (selectTabt == 2),
//             //     child: ListView.builder(
//             //         itemCount:whatsNewList.length,
//             //         shrinkWrap: true,
//             //         primary: false,
//             //         physics: NeverScrollableScrollPhysics(),
//             //         itemBuilder: (context,index){
//             //           return Padding(
//             //             padding: const EdgeInsets.symmetric(
//             //                 vertical: 10.0, horizontal: 12),
//             //             child: Row(
//             //               crossAxisAlignment: CrossAxisAlignment.end,
//             //               children: [
//             //                 ClipRRect(
//             //                     borderRadius: BorderRadius.circular(10),
//             //                     child: Image.network(
//             //                       whatsNewList[index].varientImage,
//             //                       width: 90,
//             //                       height: 95,
//             //                     )),
//             //                 SizedBox(
//             //                   width: 15,
//             //                 ),
//             //                 Expanded(
//             //                   child: Column(
//             //                     crossAxisAlignment: CrossAxisAlignment.start,
//             //                     mainAxisAlignment: MainAxisAlignment.start,
//             //                     children: [
//             //                       Text(
//             //                         whatsNewList[index].productName,
//             //                         style: Theme.of(context).textTheme.subtitle1,
//             //                       ),
//             //                       SizedBox(
//             //                         height: 8,
//             //                       ),
//             //                       Text(
//             //                         '${whatsNewList[index].quantity} ${whatsNewList[index].unit}',
//             //                         style: Theme.of(context).textTheme.subtitle2,
//             //                       ),
//             //                       SizedBox(
//             //                         height: 20,
//             //                       ),
//             //                       Row(
//             //                         mainAxisAlignment: MainAxisAlignment.start,
//             //                         children: [
//             //                           buildIconButton(
//             //                               Icons.remove,context),
//             //                           SizedBox(
//             //                             width: 15,
//             //                           ),
//             //                           Text('${whatsNewList[index].qty}',
//             //                               style: Theme.of(context)
//             //                                   .textTheme
//             //                                   .subtitle1),
//             //                           SizedBox(
//             //                             width: 15,
//             //                           ),
//             //                           buildIconButton(
//             //                               Icons.add,context,type: 1,),
//             //                           SizedBox(
//             //                             width: 40,
//             //                           ),
//             //                         ],
//             //                       ),
//             //                     ],
//             //                   ),
//             //                 ),
//             //                 Text('$apCurrency ${whatsNewList[index].price}',
//             //                     textAlign: TextAlign.right,
//             //                     style: Theme.of(context).textTheme.subtitle1),
//             //               ],
//             //             ),
//             //           );
//             //         })),
//             // Visibility(
//             //     visible: (selectTabt == 3),
//             //     child: ListView.builder(
//             //         itemCount:dealProductList.length,
//             //         shrinkWrap: true,
//             //         primary: false,
//             //         physics: NeverScrollableScrollPhysics(),
//             //         itemBuilder: (context,index){
//             //           return Padding(
//             //             padding: const EdgeInsets.symmetric(
//             //                 vertical: 10.0, horizontal: 12),
//             //             child: Row(
//             //               crossAxisAlignment: CrossAxisAlignment.end,
//             //               children: [
//             //                 ClipRRect(
//             //                     borderRadius: BorderRadius.circular(10),
//             //                     child: Image.network(
//             //                       dealProductList[index].varient_image,
//             //                       width: 90,
//             //                       height: 95,
//             //                     )),
//             //                 SizedBox(
//             //                   width: 15,
//             //                 ),
//             //                 Expanded(
//             //                   child: Column(
//             //                     crossAxisAlignment: CrossAxisAlignment.start,
//             //                     mainAxisAlignment: MainAxisAlignment.start,
//             //                     children: [
//             //                       Text(
//             //                         dealProductList[index].product_name,
//             //                         style: Theme.of(context).textTheme.subtitle1,
//             //                       ),
//             //                       SizedBox(
//             //                         height: 8,
//             //                       ),
//             //                       Text(
//             //                         '${dealProductList[index].quantity} ${dealProductList[index].unit}',
//             //                         style: Theme.of(context).textTheme.subtitle2,
//             //                       ),
//             //                       SizedBox(
//             //                         height: 20,
//             //                       ),
//             //                       Row(
//             //                         mainAxisAlignment: MainAxisAlignment.start,
//             //                         children: [
//             //                           buildIconButton(
//             //                               Icons.remove,context),
//             //                           SizedBox(
//             //                             width: 15,
//             //                           ),
//             //                           Text('${dealProductList[index].qty}',
//             //                               style: Theme.of(context)
//             //                                   .textTheme
//             //                                   .subtitle1),
//             //                           SizedBox(
//             //                             width: 15,
//             //                           ),
//             //                           buildIconButton(
//             //                               Icons.add,context,type: 1,),
//             //                           SizedBox(
//             //                             width: 40,
//             //                           ),
//             //                         ],
//             //                       ),
//             //                     ],
//             //                   ),
//             //                 ),
//             //                 Text('$apCurrency ${dealProductList[index].price}',
//             //                     textAlign: TextAlign.right,
//             //                     style: Theme.of(context).textTheme.subtitle1),
//             //               ],
//             //             ),
//             //           );
//             //         })),
//             // TabBar(
//             //   controller: tabController,
//             //   labelPadding: EdgeInsets.all(0),
//             //   isScrollable: true,
//             //   indicatorWeight: 1,
//             //   indicatorColor: Colors.transparent,
//             //   tabs: [
//             //     Card(
//             //       color: kMainColor,
//             //       elevation: 0.5,
//             //       child: Container(
//             //         width: MediaQuery.of(context).size.width/2,
//             //         padding: EdgeInsets.symmetric(horizontal: 1,vertical: 20),
//             //         child: Text('Top Selling',textAlign: TextAlign.center,style: TextStyle(
//             //             fontSize: 16
//             //         ),),
//             //       ),
//             //     ),
//             //     Card(
//             //       color: kWhiteColor,
//             //       elevation: 0.5,
//             //       child: Container(
//             //         width: MediaQuery.of(context).size.width/2,
//             //         padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
//             //         child: Text('Whats New',textAlign: TextAlign.center,style: TextStyle(
//             //             fontSize: 16
//             //         ),),
//             //       ),
//             //     ),
//             //     Card(
//             //       color: Colors.grey[200],
//             //       elevation: 0.5,
//             //       child: Container(
//             //         width: MediaQuery.of(context).size.width/2,
//             //         padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
//             //         child: Text('Recent Selling',textAlign: TextAlign.center,style: TextStyle(
//             //             fontSize: 16
//             //         ),),
//             //       ),
//             //     )
//             //   ],
//             // ),
//             // TabBarView(
//             //     controller: tabController,
//             //     children: [
//             //       ListView.builder(
//             //           itemCount:5,
//             //           shrinkWrap: true,
//             //           primary: false,
//             //           physics: NeverScrollableScrollPhysics(),
//             //           itemBuilder: (context,index){
//             //             return Container(
//             //               padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
//             //               child: Text('Recent Selling',textAlign: TextAlign.center,style: TextStyle(
//             //                   fontSize: 16
//             //               ),),
//             //             );
//             //           }),
//             //       ListView.builder(
//             //           itemCount:5,
//             //           shrinkWrap: true,
//             //           primary: false,
//             //           physics: NeverScrollableScrollPhysics(),
//             //           itemBuilder: (context,index){
//             //             return Container(
//             //               padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
//             //               child: Text('Recent Selling',textAlign: TextAlign.center,style: TextStyle(
//             //                   fontSize: 16
//             //               ),),
//             //             );
//             //           }),
//             //       ListView.builder(
//             //           itemCount:5,
//             //           shrinkWrap: true,
//             //           primary: false,
//             //           physics: NeverScrollableScrollPhysics(),
//             //           itemBuilder: (context,index){
//             //             return Container(
//             //               padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
//             //               child: Text('Recent Selling',textAlign: TextAlign.center,style: TextStyle(
//             //                   fontSize: 16
//             //               ),),
//             //             );
//             //           })
//             //     ]),
//             // Container(
//             //   child: Column(
//             //     mainAxisSize: MainAxisSize.min,
//             //     children: [
//
//             //       Container(
//             //         height: double.minPositive,
//             //         child:
//             //       )
//             //     ],
//             //   ),
//             // ),
//             (!singleLoading && topcct!=null && topcct.length>0)
//                 ? Visibility(
//               visible: (topcct != null &&
//                   topcct.length > 0),
//               child: ListView.builder(
//                   itemCount: topcct.length,
//                   shrinkWrap: true,
//                   primary: false,
//                   itemBuilder: (context,index){
//                     return buildCompleteVerticalList(
//                         locale,
//                         context,
//                         topcct[index].products,
//                         topcct[index].title,
//                         wishModel, () {
//                       getWislist();
//                     }, storeFinderData,
//                         listtype: index);
//                   }),
//             ) : buildCompleteVerticalSHList(context),
//
//             SizedBox(height: 20.0),
//           ],
//         ),
//       )
//           : Align(
//         alignment: Alignment.center,
//         child: Text(shownMessage),
//       ),
//     ),
//   );
// }