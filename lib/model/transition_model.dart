import 'package:mobile_pos/model/product_model.dart';

import 'add_to_cart_model.dart';

class SaleTransactionModel {
  late String customerName,
      customerPhone,
      customerType,
      invoiceNumber,
      purchaseDate;
  double? totalAmount;
  double? dueAmount;
  double? returnAmount;
  num? vat;
  double? discountAmount;
  double? lossProfit;
  int? totalQuantity;
  int? paidamountamount;

  bool? isPaid;
  String? paymentType;
  List<AddToCartModel>? productList;
  String? sellerName;

  SaleTransactionModel({
    required this.customerName,
    required this.customerType,
    required this.customerPhone,
    required this.invoiceNumber,
    required this.purchaseDate,
    this.dueAmount,
    this.totalAmount,
    this.returnAmount,
    this.discountAmount,
    this.vat,
    this.isPaid,
    this.paymentType,
    this.productList,
    this.lossProfit,
    this.totalQuantity,
    this.sellerName,
    this.paidamountamount,
  });

  SaleTransactionModel.fromJson(Map<dynamic, dynamic> json) {
    customerName = json['customerName'] as String;
    customerPhone = json['customerPhone'].toString();
    invoiceNumber = json['invoiceNumber'].toString();
    customerType = json['customerType'].toString();
    purchaseDate = json['purchaseDate'].toString();
    lossProfit = double.parse(json['lossProfit'].toString());
    totalQuantity = json['totalQuantity'];
    vat = json['vat'] ?? 0;
    totalAmount = double.parse(json['totalAmount'].toString());
    discountAmount = double.parse(json['discountAmount'].toString());
    dueAmount = double.parse(json['dueAmount'].toString());
    returnAmount = double.parse(json['returnAmount'].toString());
    isPaid = json['isPaid'];
    sellerName = json['sellerName'];
    paymentType = json['paymentType'].toString();
    paidamountamount = json['paidamountamount'];
    if (json['productList'] != null) {
      productList = <AddToCartModel>[];
      json['productList'].forEach((v) {
        productList!.add(AddToCartModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'customerName': customerName,
        'customerPhone': customerPhone,
        'customerType': customerType,
        'invoiceNumber': invoiceNumber,
        'purchaseDate': purchaseDate,
        'totalQuantity': totalQuantity,
        'lossProfit': lossProfit,
        'vat': vat,
        'discountAmount': discountAmount,
        'totalAmount': totalAmount,
        'dueAmount': dueAmount,
        'returnAmount': returnAmount,
        'sellerName': sellerName,
        'isPaid': isPaid,
        'paymentType': paymentType,
        'paidamountamount': paidamountamount,
        'productList': productList?.map((e) => e.toJson()).toList(),
      };
}

class PurchaseTransitionModel {
  late String customerName,
      customerPhone,
      customerType,
      invoiceNumber,
      purchaseDate;
  double? totalAmount;
  double? dueAmount;
  double? returnAmount;
  // double? paidAmount;
  double? discountAmount;

  bool? isPaid;
  String? paymentType;
  List<ProductModel>? productList;
  String? sellerName;

  PurchaseTransitionModel({
    required this.customerName,
    required this.customerType,
    required this.customerPhone,
    required this.invoiceNumber,
    required this.purchaseDate,
    this.dueAmount,
    this.totalAmount,
    this.returnAmount,
    // this.paidAmount,
    this.discountAmount,
    this.isPaid,
    this.paymentType,
    this.productList,
    this.sellerName,
  });

  PurchaseTransitionModel.fromJson(Map<dynamic, dynamic> json) {
    customerName = json['customerName'] as String;
    customerPhone = json['customerPhone'].toString();
    invoiceNumber = json['invoiceNumber'].toString();
    customerType = json['customerType'].toString();
    purchaseDate = json['purchaseDate'].toString();
    sellerName = json['sellerName'].toString();
    totalAmount = double.parse(json['totalAmount'].toString());
    discountAmount = double.parse(json['discountAmount'].toString());
    dueAmount = double.parse(json['dueAmount'].toString());
    returnAmount = double.parse(json['returnAmount'].toString());
    // paidAmount = double.parse(json['paidAmount'].toString());
    isPaid = json['isPaid'];
    paymentType = json['paymentType'].toString();
    if (json['productList'] != null) {
      productList = <ProductModel>[];
      json['productList'].forEach((v) {
        productList!.add(ProductModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'customerName': customerName,
        'customerPhone': customerPhone,
        'customerType': customerType,
        'invoiceNumber': invoiceNumber,
        'purchaseDate': purchaseDate,
        'discountAmount': discountAmount,
        'totalAmount': totalAmount,
        'dueAmount': dueAmount,
        'sellerName': sellerName,
        'returnAmount': returnAmount,
        // 'paidAmount': paidAmount,
        'isPaid': isPaid,
        'paymentType': paymentType,
        'productList': productList?.map((e) => e.toJson()).toList(),
      };
}
