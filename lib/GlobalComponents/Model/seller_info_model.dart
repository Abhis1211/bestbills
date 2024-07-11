class SellerInfoModel {
  SellerInfoModel({
    this.phoneNumber,
    this.altphoneNumber,
    this.companyName,
    this.pictureUrl,
    this.businessCategory,
    this.language,
    this.countryName,
    this.userID,
    this.subscriptionName,
    this.subscriptionDate,
    this.subscriptionMethod,
    this.activeStatus,
    this.profileSetup,
    this.created_date,
    this.email,
    this.timestamp,
    this.password,
  });

  SellerInfoModel.fromJson(dynamic json) {
    altphoneNumber = json['altphoneNumber'];
    phoneNumber = json['phoneNumber'];
    companyName = json['companyName'];
    pictureUrl = json['pictureUrl'];
    businessCategory = json['businessCategory'];
    language = json['language'];
    countryName = json['countryName'];
    userID = json['userId'];
    subscriptionName = json['subscriptionName'];
    subscriptionDate = json['subscriptionDate'];
    subscriptionMethod = json['subscriptionMethod'];
    activeStatus = json['activeStatus'];
    profileSetup = json['profileSetup'];
    created_date = json['created_date'];
    email = json['email'];
    timestamp = json['timestamp'];
    password = json['password'];
  }
  dynamic phoneNumber;
  dynamic altphoneNumber;
  String? companyName;
  String? pictureUrl;
  String? businessCategory;
  String? language;
  String? countryName;
  String? userID;
  String? subscriptionName;
  String? subscriptionDate;
  String? subscriptionMethod;
  int? activeStatus;
  int? profileSetup;
  String? email;
  String? created_date;
  String? timestamp;
  String? password;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['phoneNumber'] = phoneNumber;
    map['altphoneNumber'] = altphoneNumber;
    map['companyName'] = companyName;
    map['pictureUrl'] = pictureUrl;
    map['businessCategory'] = businessCategory;
    map['language'] = language;
    map['countryName'] = countryName;
    map['userId'] = userID;
    map['subscriptionName'] = subscriptionName;
    map['subscriptionDate'] = subscriptionDate;
    map['subscriptionMethod'] = subscriptionMethod;
    map['activeStatus'] = activeStatus;
    map['profileSetup'] = profileSetup;
    map['email'] = email;
    map['created_date'] = created_date;
    map['timestamp'] = timestamp;
    map['password'] = password;
    return map;
  }
}
