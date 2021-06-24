class AppInfoModel {
  dynamic status;
  dynamic message;
  dynamic lastLoc;
  dynamic phoneNumberLength;
  dynamic appName;
  dynamic appLogo;
  dynamic firebase;
  dynamic countryCode;
  dynamic firebaseIso;
  dynamic sms;
  dynamic currencySign;
  dynamic refertext;
  dynamic totalItems;
  dynamic androidAppLink;
  dynamic iosAppLink;

  AppInfoModel(
      {this.status,
        this.message,
        this.lastLoc,
        this.phoneNumberLength,
        this.appName,
        this.appLogo,
        this.firebase,
        this.countryCode,
        this.firebaseIso,
        this.sms,
        this.currencySign,
        this.refertext,
        this.totalItems,
      this.androidAppLink,
      this.iosAppLink});

  AppInfoModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    lastLoc = json['last_loc'];
    phoneNumberLength = json['phone_number_length'];
    appName = json['app_name'];
    appLogo = json['app_logo'];
    firebase = json['firebase'];
    countryCode = json['country_code'];
    firebaseIso = json['firebase_iso'];
    sms = json['sms'];
    currencySign = json['currency_sign'];
    refertext = json['refertext'];
    totalItems = json['total_items'];
    androidAppLink = json['android_app_link'];
    iosAppLink = json['ios_app_link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['last_loc'] = this.lastLoc;
    data['phone_number_length'] = this.phoneNumberLength;
    data['app_name'] = this.appName;
    data['app_logo'] = this.appLogo;
    data['firebase'] = this.firebase;
    data['country_code'] = this.countryCode;
    data['firebase_iso'] = this.firebaseIso;
    data['sms'] = this.sms;
    data['currency_sign'] = this.currencySign;
    data['refertext'] = this.refertext;
    data['total_items'] = this.totalItems;
    data['android_app_link'] = this.androidAppLink;
    data['ios_app_link'] = this.iosAppLink;
    return data;
  }

  @override
  String toString() {
    return 'AppInfoModel{status: $status, message: $message, lastLoc: $lastLoc, phoneNumberLength: $phoneNumberLength, appName: $appName, appLogo: $appLogo, firebase: $firebase, countryCode: $countryCode, firebaseIso: $firebaseIso, sms: $sms, currencySign: $currencySign, refertext: $refertext, totalItems: $totalItems, androidAppLink: $androidAppLink, iosAppLink: $iosAppLink}';
  }
}
// class AppInfoModel{
//   dynamic status;
//   dynamic message;
//   dynamic app_name;
//   dynamic app_logo;
//   dynamic firebase;
//   dynamic country_code;
//   dynamic firebase_iso;
//   dynamic sms;
//   dynamic phone_number_length;
//   dynamic currency_sign;
//   dynamic refertext;
//   dynamic last_loc;
//   dynamic app_link;
//
//
//   AppInfoModel(this.status, this.message, this.app_name, this.app_logo,
//       this.firebase, this.country_code, this.firebase_iso, this.sms, this.phone_number_length,this.currency_sign,this.refertext,this.last_loc,this.app_link);
//
//   factory AppInfoModel.fromJson(dynamic json){
//     return AppInfoModel(json['status'], json['message'], json['app_name'], json['app_logo'], json['firebase'], json['country_code'], json['firebase_iso'], json['sms'], json['phone_number_length'],json['currency_sign'],json['refertext'],json['last_loc'], json['app_link']);
//   }
//
//   @override
//   dynamic toString() {
//     return 'AppInfoModel{status: $status, message: $message, app_name: $app_name, app_logo: $app_logo, firebase: $firebase, country_code: $country_code, firebase_iso: $firebase_iso, sms: $sms, phone_number_length: $phone_number_length, currency_sign: $currency_sign, refertext: $refertext, last_loc: $last_loc, app_link: $app_link}';
//   }
// }