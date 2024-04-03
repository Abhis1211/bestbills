class PersonalInformationModel {
  PersonalInformationModel({
    this.phoneNumber,
    this.altphoneNumber,
    this.companyName,
    this.pictureUrl,
    this.businessCategory,
    this.language,
    this.countryName,
    this.invoiceCounter,
    this.invoiceCounterdue,
    this.invoiceCounterpurchase,
    this.gstenable,
    required this.shopOpeningBalance,
    required this.remainingShopBalance,
    this.email,
    this.note,
    this.gstnumber,
  });

  PersonalInformationModel.fromJson(dynamic json) {
    phoneNumber = json['phoneNumber'];
    altphoneNumber = json['altphoneNumber'];
    companyName = json['companyName'];
    pictureUrl = json['pictureUrl'];
    businessCategory = json['businessCategory'];
    language = json['language'];
    countryName = json['countryName'];
    invoiceCounter = json['invoiceCounter'];
    invoiceCounterdue = json['invoiceCounterdue'];
    invoiceCounterpurchase = json['invoiceCounterpurchase'];
    gstenable = json['gstenable'];
    shopOpeningBalance = json['shopOpeningBalance'];
    remainingShopBalance = json['remainingShopBalance'];
    email = json['email'];
    note = json['note'];
    gstnumber = json['gstnumber'];
  }
  dynamic phoneNumber;
  dynamic altphoneNumber;
  String? companyName;
  String? pictureUrl;
  String? businessCategory;
  String? language;
  String? countryName;
  String? note;
  String? gstnumber;
  dynamic email;
  int? invoiceCounter;
  int? invoiceCounterdue;
  int? invoiceCounterpurchase;
  bool? gstenable;
  late int shopOpeningBalance;
  late int remainingShopBalance;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['phoneNumber'] = phoneNumber;
    map['altphoneNumber'] = altphoneNumber;
    map['companyName'] = companyName;
    map['pictureUrl'] = pictureUrl;
    map['businessCategory'] = businessCategory;
    map['language'] = language;
    map['countryName'] = countryName;
    map['invoiceCounter'] = invoiceCounter;
    map['invoiceCounterdue'] = invoiceCounterdue;
    map['invoiceCounterpurchase'] = invoiceCounterpurchase;
    map['gstenable'] = gstenable;
    map['shopOpeningBalance'] = shopOpeningBalance;
    map['remainingShopBalance'] = remainingShopBalance;
    map['email'] = email;
    map['note'] = note;
    map['gstnumber'] = gstnumber;
    return map;
  }
}
