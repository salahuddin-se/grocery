import 'package:grocery/beanmodel/category/topcategory.dart';
import 'package:grocery/beanmodel/deal/dealproduct.dart';
import 'package:grocery/beanmodel/productbean/productwithvarient.dart';
import 'package:grocery/beanmodel/whatsnew/whatsnew.dart';

import 'banner/bannerdeatil.dart';

class SingleApiHomePage {
  String status;
  String message;
  List<BannerDataModel> banner;
  List<TopCategoryDataModel> topCat;
  List<TabsD> tabs;
  // List<WhatsNewDataModel> recentselling;
  // List<WhatsNewDataModel> topselling;
  // List<WhatsNewDataModel> newwhats;
  // List<DealProductDataModel> dealProduct;

  // this.recentselling,
  // this.topselling,
  // this.newwhats,
  // this.dealProduct

  SingleApiHomePage(
      {this.status,
      this.message,
      this.banner,
      this.topCat,
      this.tabs});

  SingleApiHomePage.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['banner'] != null) {
      banner = new List<BannerDataModel>();
      json['banner'].forEach((v) {
        banner.add(new BannerDataModel.fromJson(v));
      });
    }
    if (json['top_cat'] != null) {
      topCat = new List<TopCategoryDataModel>();
      json['top_cat'].forEach((v) {
        topCat.add(new TopCategoryDataModel.fromJson(v));
      });
    }
    if (json['tabs'] != null) {
      tabs = new List<TabsD>();
      json['tabs'].forEach((v) {
        var jd = v['data'] as List;
        if(jd!=null && jd.length>0){
          tabs.add(new TabsD.fromJson(v));
        }
      });
    }
    // if (json['recentselling'] != null) {
    //   recentselling = new List<WhatsNewDataModel>();
    //   json['recentselling'].forEach((v) {
    //     recentselling.add(new WhatsNewDataModel.fromJson(v));
    //   });
    // }
    // if (json['topselling'] != null) {
    //   topselling = new List<WhatsNewDataModel>();
    //   json['topselling'].forEach((v) {
    //     topselling.add(new WhatsNewDataModel.fromJson(v));
    //   });
    // }
    // if (json['new'] != null) {
    //   newwhats = new List<WhatsNewDataModel>();
    //   json['new'].forEach((v) {
    //     newwhats.add(new WhatsNewDataModel.fromJson(v));
    //   });
    // }
    // if (json['deal_product'] != null) {
    //   dealProduct = new List<DealProductDataModel>();
    //   json['deal_product'].forEach((v) {
    //     dealProduct.add(new DealProductDataModel.fromJson(v));
    //   });
    // }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.banner != null) {
      data['banner'] = this.banner.map((v) => v.toJson()).toList();
    }
    if (this.topCat != null) {
      data['top_cat'] = this.topCat.map((v) => v.toJson()).toList();
    }
    if (this.tabs != null) {
      data['tabs'] = this.tabs.map((v) => v.toJson()).toList();
    }
    // if (this.recentselling != null) {
    //   data['recentselling'] =
    //       this.recentselling.map((v) => v.toJson()).toList();
    // }
    // if (this.topselling != null) {
    //   data['topselling'] = this.topselling.map((v) => v.toJson()).toList();
    // }
    // if (this.newwhats != null) {
    //   data['new'] = this.newwhats.map((v) => v.toJson()).toList();
    // }
    // if (this.dealProduct != null) {
    //   data['deal_product'] = this.dealProduct.map((v) => v.toJson()).toList();
    // }
    return data;
  }
}

class TabsD {
  String type;
  List<ProductDataModel> data;

  TabsD({this.type, this.data});

  TabsD.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    if (json['data'] != null) {
      data = new List<ProductDataModel>();
      json['data'].forEach((v) {
        data.add(new ProductDataModel.fromJson(v));
      });
      if(data!=null && data.length>0){
        data.add(ProductDataModel(productName: 'See all'));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
