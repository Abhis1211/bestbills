import '../../currency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../Provider/add_to_cart.dart';
import 'package:mobile_pos/constant.dart';
import '../../model/add_to_cart_model.dart';
import '../../Provider/profile_provider.dart';
import 'package:flutter_cart/flutter_cart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import '../../Provider/category,brans,units_provide.dart';
import 'package:mobile_pos/Provider/product_provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:mobile_pos/Screens/Customers/Model/customer_model.dart';
import 'dart:convert';
import '../../model/product_model.dart';
import 'package:firebase_database/firebase_database.dart';
// ignore: must_be_immutable
class SaleProducts extends StatefulWidget {
  SaleProducts({Key? key, @required this.catName, this.customerModel})
      : super(key: key);

  // ignore: prefer_typing_uninitialized_variables
  var catName;
  CustomerModel? customerModel;

  @override
  // ignore: library_private_types_in_public_api
  _SaleProductsState createState() => _SaleProductsState();
}

class _SaleProductsState extends State<SaleProducts> {
  final searchController = TextEditingController();
    String productPicture =
      'https://firebasestorage.googleapis.com/v0/b/maanpos.appspot.com/o/Customer%20Picture%2FNo_Image_Available.jpeg?alt=media&token=3de0d45e-0e4a-4a7b-b115-9d6722d5031f';
 
  String dropdownValue = '';
  String productCode = '0000';

  var salesCart = FlutterCart();
  String productPrice = '0';
  String sentProductPrice = '';
  String currentproductcategory = '';
  int currentselectioncategory = -1;

  @override
  void initState() {
    widget.catName == null
        ? dropdownValue = 'Fashion'
        : dropdownValue = widget.catName;

    super.initState();
  }
 void dispose() {
    currentproductcategory = "";
    super.dispose();
  }
  Future<void> scanBarcodeNormal(providename1, providename2, cntx) async {
 setState(() {
      currentproductcategory = "";
    });
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      productCode = barcodeScanRes;
    });
    await providename1.getbarcodeproduct(productCode, true, cntx);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      final providerData = ref.watch(cartNotifier);
      final productList = ref.watch(productProvider);
      final categoryList = ref.watch(categoryProvider);
      final personalData = ref.watch(profileDetailsProvider);
      // final categoryList = ref.watch(categoryProvider);

      return Scaffold(
        appBar: AppBar(
          title: Text(
            lang.S.of(context).addItems,
            style: GoogleFonts.inter(
              color: Colors.black,
              fontSize: 20.0,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
          // actions: [
          //   PopupMenuButton(
          //     itemBuilder: (BuildContext bc) => [
          //       const PopupMenuItem(value: "/addPromoCode", child: Text('Add Promo Code')),
          //       const PopupMenuItem(value: "clear", child: Text('Cancel All Product')),
          //       const PopupMenuItem(value: "/settings", child: Text('Vat Doesn\'t Apply')),
          //     ],
          //     onSelected: (value) {
          //       value == 'clear'
          //           ? {
          //               providerData.clearCart(),
          //               providerData.clearDiscount(),
          //               const HomeScreen().launch(context, isNewTask: true)
          //             }
          //           : Navigator.pushNamed(context, '$value');
          //     },
          //   ),
          // ],
        ),
        body: Column(
          children: [
            // Container(
            //   height: 60.0,
            //   width: MediaQuery.of(context).size.width,
            //   decoration: BoxDecoration(
            //     color: kMainColor,
            //     borderRadius: BorderRadius.circular(10.0),
            //   ),
            //   child: GestureDetector(
            //     onTap: () {
            //       // ignore: missing_required_param
            //       providerData.getTotalAmount() <= 0
            //           ? EasyLoading.showError('Cart Is Empty')
            //           : SalesDetails(
            //               customerName: widget.customerModel!.customerName,
            //             ).launch(context);
            //     },
            //     child: Row(
            //       children: [
            //         Expanded(
            //           flex: 1,
            //           child: Stack(
            //             alignment: Alignment.center,
            //             children: [
            //               const Image(
            //                 image: AssetImage('images/selected.png'),
            //               ),
            //               Text(
            //                 items.toString(),
            //                 style: GoogleFonts.inter(
            //                   fontSize: 15.0,
            //                   color: Colors.white,
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //         Expanded(
            //           flex: 2,
            //           child: Center(
            //             child: Text(
            //               providerData.getTotalAmount() <= 0
            //                   ? 'Cart is empty'
            //                   : 'Total: $currency${providerData.getTotalAmount().toString()}',
            //               style: GoogleFonts.inter(
            //                 color: Colors.white,
            //                 fontSize: 16.0,
            //               ),
            //             ),
            //           ),
            //         ),
            //         const Expanded(
            //           flex: 1,
            //           child: Icon(
            //             Icons.arrow_forward,
            //             color: Colors.white,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),

            // const SizedBox(height: 20.0),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: AppTextField(
                        controller: searchController,
                        textFieldType: TextFieldType.NAME,
                        onChanged: (value) {
                          if (value.isNotEmpty)
                            setState(() {
                              productCode = value;
                            });
                          else
                            setState(() {
                              productCode = "0000";
                              searchController.clear();
                            });
                        },
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            // border:InputBorder.none,
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            // labelText: lang.S.of(context).productCode,
                            hintText: 'Search Product Name',
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    productCode = "0000";
                                    searchController.clear();
                                  });
                                },
                                icon: Icon(Icons.clear))),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: GestureDetector(
                       onTap: () => scanBarcodeNormal(
                          providerData, personalData, context),
                      child: Container(
                        height: 50.0,
                        width: 100.0,
                        padding: const EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: kGreyTextColor),
                        ),
                        child: const Image(
                          image: AssetImage('images/barcode.png'),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Center(
              child: Text(
                "All products from",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                    color: textcolor,
                    textStyle:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500)),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                currentproductcategory.toString(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                    color: pricecolor,
                    textStyle:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500)),
              ),
            ),
            SizedBox(
              height: 20,
            ),

            searchController.text.isNotEmpty
                ? Expanded(
                    child: productList.when(data: (products) {
                      var filterlist = products
                          .where((element) =>
                              element.productName
                              .contains(searchController.text))
                          .toList();
                      return ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          // physics: const NeverScrollableScrollPhysics(),
                          itemCount:  filterlist.length,
                          itemBuilder: (_, i) {
                            if (widget.customerModel!.type
                                .contains('Retailer')) {
                              productPrice = currentproductcategory == ""
                                  ? products[i].productSalePrice
                                  : filterlist[i].productSalePrice;
                            } else if (widget.customerModel!.type
                                .contains('Dealer')) {
                              productPrice = currentproductcategory == ""
                                  ? products[i].productDealerPrice
                                  : filterlist[i].productDealerPrice;
                            } else if (widget.customerModel!.type
                                .contains('Wholesaler')) {
                              productPrice = currentproductcategory == ""
                                  ? products[i].productWholeSalePrice
                                  : filterlist[i].productWholeSalePrice;
                            } else if (widget.customerModel!.type
                                .contains('Supplier')) {
                              productPrice = currentproductcategory == ""
                                  ? products[i].productPurchasePrice
                                  : filterlist[i].productPurchasePrice;
                            } else if (widget.customerModel!.type
                                .contains('Guest')) {
                              productPrice = currentproductcategory == ""
                                  ? products[i].productSalePrice
                                  : filterlist[i].productSalePrice;
                            }
                            return ListTile(
                              onTap: () {
                                if ((currentproductcategory == ""
                                            ? products[i]
                                                .productStock
                                                .toString()
                                            : filterlist[i]
                                                .productStock
                                                .toString())
                                        .toString() !=
                                    "") {
                                  if (int.parse(currentproductcategory == ""
                                          ? products[i].productStock.toString()
                                          : filterlist[i]
                                              .productStock
                                              .toString()) <=
                                      0) {
                                    EasyLoading.showError('Out of stock');
                                    return;
                                  }
                                }
                                if (widget.customerModel!.type
                                    .contains('Retailer')) {
                                  sentProductPrice =
                                      currentproductcategory == ""
                                          ? products[i].productSalePrice
                                          : filterlist[i].productSalePrice;
                                } else if (widget.customerModel!.type
                                    .contains('Dealer')) {
                                  sentProductPrice =
                                      currentproductcategory == ""
                                          ? products[i].productDealerPrice
                                          : filterlist[i].productDealerPrice;
                                } else if (widget.customerModel!.type
                                    .contains('Wholesaler')) {
                                  sentProductPrice =
                                      currentproductcategory == ""
                                          ? products[i].productWholeSalePrice
                                          : filterlist[i].productWholeSalePrice;
                                } else if (widget.customerModel!.type
                                    .contains('Supplier')) {
                                  sentProductPrice =
                                      currentproductcategory == ""
                                          ? products[i].productPurchasePrice
                                          : filterlist[i].productPurchasePrice;
                                } else if (widget.customerModel!.type
                                    .contains('Guest')) {
                                  sentProductPrice =
                                      currentproductcategory == ""
                                          ? products[i].productSalePrice
                                          : filterlist[i].productSalePrice;
                                }
                                AddToCartModel cartItem = AddToCartModel(
                                  productName: currentproductcategory == ""
                                      ? products[i].productName
                                      : filterlist[i].productName,
                                  subTotal: sentProductPrice,
                                  productId: currentproductcategory == ""
                                      ? products[i].productCode
                                      : filterlist[i].productCode,
                                  productBrandName: currentproductcategory == ""
                                      ? products[i].brandName
                                      : filterlist[i].brandName,
                                  productPurchasePrice:
                                      currentproductcategory == ""
                                          ? products[i].productPurchasePrice
                                          : filterlist[i].productPurchasePrice,
                                  productsalePrice: currentproductcategory == ""
                                      ? products[i].productSalePrice
                                      : filterlist[i].productSalePrice,
                                  stock: (currentproductcategory == ""
                                                  ? products[i]
                                                      .productStock
                                                      .toString()
                                                  : filterlist[i]
                                                      .productStock
                                                      .toString())
                                              .toString() ==
                                          ""
                                      ? 0
                                      : int.parse(currentproductcategory == ""
                                          ? products[i].productStock.toString()
                                          : filterlist[i]
                                              .productStock
                                              .toString()),
                                  uuid: currentproductcategory == ""
                                      ? products[i].productCode.toString()
                                      : filterlist[i].productCode.toString(),
                                  productgst: currentproductcategory == ""
                                      ? products[i].productGst
                                      : filterlist[i].productGst,
                                  color: currentproductcategory == ""
                                      ? products[i].color
                                      : filterlist[i].color,
                                  size: currentproductcategory == ""
                                      ? products[i].size
                                      : filterlist[i].size,
                                  weight: currentproductcategory == ""
                                      ? products[i].weight
                                      : filterlist[i].weight,
                                  productGstamount: currentproductcategory == ""
                                      ? products[i].productGstamount
                                      : filterlist[i].productGstamount,
                                );
                                personalData.when(
                                    data: (data) {
                                      providerData.addProductsInSales(
                                          currentproductcategory == ""
                                              ? products[i]
                                              : filterlist[i],
                                          cartItem,
                                          context);
                                      providerData.addToCartRiverPod(
                                          cartItem, data.gstenable);
                                    },
                                    error: (Object error,
                                        StackTrace stackTrace) {},
                                    loading: () {});
                                // Navigator.pop(context);
                              },
                              leading: Container(
                                height: 50,
                                width: 50,
                                // decoration: BoxDecoration(
                                //     borderRadius: const BorderRadius.all(
                                //         Radius.circular(90)),
                                //     image: DecorationImage(
                                //       image: NetworkImage(
                                //         products[i].productPicture,
                                //       ),
                                //       fit: BoxFit.cover,
                                //     )),
                                child: CachedNetworkImage(
                                  imageUrl:filterlist[i].productPicture,
                                  placeholder: (context, url) => const SizedBox(
                                    height: 50,
                                    width: 50,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(50.0),
                                          child: Image.network(
                                           productPicture
                                          )),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                filterlist[i].productName,
                              ),
                              subtitle: Text(
                               filterlist[i].productCategory,
                              ),
                              trailing: Text(
                                "$currency ${productPrice}",
                                style: const TextStyle(fontSize: 18),
                              ),
                            ).visible(((filterlist[i].productName)
                                        .contains(searchController.text) ||
                                    productCode == '0000' ||
                                    productCode == '-1') &&
                                productPrice != '0');
                          });
                    }, error: (e, stack) {
                      return Text(e.toString());
                    }, loading: () {
                      return const Center(child: CircularProgressIndicator());
                    }),
                  )
                : Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 110,
                          height: MediaQuery.of(context).size.height * 1.0,
                          decoration: BoxDecoration(
                              color: categorybackground,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(20))),
                          padding: EdgeInsets.only(right: 2, left: 2, top: 5),
                          child: Column(
                            children: [
                              Expanded(
                                child: categoryList.when(data: (category) {
                                  // if (currentselectioncategory == 0) {
                                  //   currentproductcategory = category.length > 0
                                  //       ? category[0].categoryName
                                  //       : "";
                                  // }
                                  category.sort((a, b) => a.categoryName .compareTo(b.categoryName));
                                  return ListView.builder(
                                      // shrinkWrap: true,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: category.length,
                                      itemBuilder: (_, i) {
                                        return GestureDetector(
                                          onTap: (() {
                                            setState(() {
                                              currentproductcategory =
                                                  category[i].categoryName;
                                              currentselectioncategory = i;
                                            });
                                            setState(() {
                                                productCode = "0000";
                                                searchController.clear();
                                              });
                                          }),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  currentselectioncategory == i
                                                      ? bgseletedcolor
                                                      : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),

                                            // padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                            child: Column(
                                              children: [
                                                SizedBox(height: 5),
                                                Container(
                                                  height: 80,
                                                  width: 80,
                                                  padding: EdgeInsets.all(5.0),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    border: Border.all(
                                                        color: Colors.white),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    fit: BoxFit.cover,
                                                    imageUrl: category[i]
                                                        .categoryimage,
                                                    progressIndicatorBuilder: (context,
                                                            url,
                                                            downloadProgress) =>
                                                        Center(
                                                            child: CircularProgressIndicator(
                                                                value: downloadProgress
                                                                    .progress)),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                  ),
                                                ),
                                                // Container(
                                                //   decoration: BoxDecoration(
                                                //     borderRadius:
                                                //         BorderRadius.circular(15),
                                                //     image: DecorationImage(
                                                //         image: NetworkImage(
                                                //             category[i]
                                                //                 .categoryimage),
                                                //         fit: BoxFit.cover),
                                                //   ),
                                                // ),
                                                Center(
                                                  child: Text(
                                                    category[i]
                                                        .categoryName
                                                        .toString(),
                                                    style: GoogleFonts.inter(
                                                        textStyle: TextStyle(
                                                      fontSize: 13.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          currentselectioncategory ==
                                                                  i
                                                              ? Colors.white
                                                              : fontcolor,
                                                    )),
                                                  ),
                                                ).paddingSymmetric(
                                                    vertical: 5, horizontal: 2)
                                              ],
                                            ),
                                          ).paddingSymmetric(horizontal: 2),
                                        ).paddingOnly(bottom: 15);
                                      });
                                }, error: (e, stack) {
                                  return Text(e.toString());
                                }, loading: () {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }),
                              ),
                              // GestureDetector(
                              //   onTap: (() {
                              //     setState(() {
                              //       currentproductcategory = "";
                              //       currentselectioncategory = -1;
                              //     });
                              //   }),
                              //   child: Container(
                              //     // padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                              //     child: Card(
                              //       color: Colors.red,
                              //       // height: 50,
                              //       // alignment: Alignment.center,
                              //       child: Center(
                              //           child: Text(
                              //         "Reset",
                              //         style: GoogleFonts.jost(
                              //           fontSize: 16.0,
                              //           color: Colors.black,
                              //         ),
                              //       ).paddingSymmetric(horizontal: 2, vertical: 10)),
                              //     ).paddingOnly(bottom: 10),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: productList.when(data: (products) {
                            var filterlist = products
                                .where((element) =>
                                    element.productCategory ==
                                    currentproductcategory)
                                .toList();
                            return GridView.builder(
                              padding: EdgeInsets.zero,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          3, // number of items in each row
                                      mainAxisSpacing:
                                          10.0, // spacing between rows
                                      crossAxisSpacing: 8.0,
                                      childAspectRatio:
                                          0.45 // spacing between columns
                                      ),
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              itemCount: currentproductcategory == ""
                                  ? products.length
                                  : filterlist.length,
                              itemBuilder: (_, i) {
                                if (widget.customerModel!.type
                                    .contains('Retailer')) {
                                  productPrice = currentproductcategory == ""
                                      ? products[i].productSalePrice
                                      : filterlist[i].productSalePrice;
                                } else if (widget.customerModel!.type
                                    .contains('Dealer')) {
                                  productPrice = currentproductcategory == ""
                                      ? products[i].productDealerPrice
                                      : filterlist[i].productDealerPrice;
                                } else if (widget.customerModel!.type
                                    .contains('Wholesaler')) {
                                  productPrice = currentproductcategory == ""
                                      ? products[i].productWholeSalePrice
                                      : filterlist[i].productWholeSalePrice;
                                } else if (widget.customerModel!.type
                                    .contains('Supplier')) {
                                  productPrice = currentproductcategory == ""
                                      ? products[i].productPurchasePrice
                                      : filterlist[i].productPurchasePrice;
                                } else if (widget.customerModel!.type
                                    .contains('Guest')) {
                                  productPrice = currentproductcategory == ""
                                      ? products[i].productSalePrice
                                      : filterlist[i].productSalePrice;
                                }
                                return GestureDetector(
                                  onTap: () async {
                                    if ((currentproductcategory == ""
                                                ? products[i]
                                                    .productStock
                                                    .toString()
                                                : filterlist[i]
                                                    .productStock
                                                    .toString())
                                            .toString() !=
                                        "") {
                                      if (int.parse(currentproductcategory == ""
                                              ? products[i]
                                                  .productStock
                                                  .toString()
                                              : filterlist[i]
                                                  .productStock
                                                  .toString()) <=
                                          0) {
                                        EasyLoading.showError('Out of stock');
                                        return;
                                      }
                                    }

                                    if (widget.customerModel!.type
                                        .contains('Retailer')) {
                                      sentProductPrice =
                                          currentproductcategory == ""
                                              ? products[i].productSalePrice
                                              : filterlist[i].productSalePrice;
                                    } else if (widget.customerModel!.type
                                        .contains('Dealer')) {
                                      sentProductPrice =
                                          currentproductcategory == ""
                                              ? products[i].productDealerPrice
                                              : filterlist[i]
                                                  .productDealerPrice;
                                    } else if (widget.customerModel!.type
                                        .contains('Wholesaler')) {
                                      sentProductPrice =
                                          currentproductcategory == ""
                                              ? products[i]
                                                  .productWholeSalePrice
                                              : filterlist[i]
                                                  .productWholeSalePrice;
                                    } else if (widget.customerModel!.type
                                        .contains('Supplier')) {
                                      sentProductPrice =
                                          currentproductcategory == ""
                                              ? products[i].productPurchasePrice
                                              : filterlist[i]
                                                  .productPurchasePrice;
                                    } else if (widget.customerModel!.type
                                        .contains('Guest')) {
                                      sentProductPrice =
                                          currentproductcategory == ""
                                              ? products[i].productSalePrice
                                              : filterlist[i].productSalePrice;
                                    }

                                    AddToCartModel cartItem = AddToCartModel(
                                        productName: currentproductcategory == ""
                                            ? products[i].productName
                                            : filterlist[i].productName,
                                        subTotal: sentProductPrice,
                                        productId: currentproductcategory == ""
                                            ? products[i].productCode
                                            : filterlist[i].productCode,
                                        productBrandName:
                                            currentproductcategory == ""
                                                ? products[i].brandName
                                                : filterlist[i].brandName,
                                        productPurchasePrice: currentproductcategory == ""
                                            ? products[i].productPurchasePrice
                                            : filterlist[i]
                                                .productPurchasePrice,
                                        productsalePrice: currentproductcategory == ""
                                            ? products[i].productSalePrice
                                            : filterlist[i].productSalePrice,
                                        stock: (currentproductcategory == "" ? products[i].productStock.toString() : filterlist[i].productStock.toString()).toString() == ""
                                            ? 0
                                            : int.parse(
                                                currentproductcategory == ""
                                                    ? products[i]
                                                        .productStock
                                                        .toString()
                                                    : filterlist[i]
                                                        .productStock
                                                        .toString()),
                                        uuid: currentproductcategory == ""
                                            ? products[i].productCode.toString()
                                            : filterlist[i].productCode.toString(),
                                        productgst: currentproductcategory == "" ? products[i].productGst : filterlist[i].productGst,
                                        color: currentproductcategory == "" ? products[i].color : filterlist[i].color,
                                        size: currentproductcategory == "" ? products[i].size : filterlist[i].size,
                                        weight: currentproductcategory == "" ? products[i].weight : filterlist[i].weight,
                                        productGstamount: currentproductcategory == "" ? products[i].productGstamount : filterlist[i].productGstamount);
                                    personalData.when(
                                        data: (data) {
                                          providerData.addProductsInSales(
                                              currentproductcategory == ""
                                                  ? products[i]
                                                  : filterlist[i],
                                              cartItem,
                                              context);
                                          providerData.addToCartRiverPod(
                                              cartItem, data.gstenable);
                                        },
                                        error: (Object error,
                                            StackTrace stackTrace) {},
                                        loading: () {});

                                    // Navigator.pop(context);
                                  },
                                  child: ProductCard(
                                    productTitle: currentproductcategory == ""
                                        ? products[i].productName
                                        : filterlist[i].productName,
                                    productDescription:
                                        currentproductcategory == ""
                                            ? products[i].productCategory
                                            : filterlist[i].productCategory,
                                    productPrice: productPrice,
                                    productImage: currentproductcategory == ""
                                        ? products[i].productPicture
                                        : filterlist[i].productPicture,
                                  ).visible(((currentproductcategory == ""
                                                  ? products[i].productCode
                                                  : filterlist[i]
                                                      .productCode) ==
                                              productCode ||
                                          (currentproductcategory == ""
                                                  ? products[i].productName
                                                  : filterlist[i].productName)
                                              .contains(productCode) ||
                                          productCode == '0000' ||
                                          productCode == '-1') &&
                                      productPrice != '0'),
                                );
                              },
                            ).paddingSymmetric(horizontal: 10);
                          }, error: (e, stack) {
                            return Text(e.toString());
                          }, loading: () {
                            return const Center(
                                child: CircularProgressIndicator());
                          }),
                        ),
                      ],
                    ),
                  ),
         
          ],
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterFloat,
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.pop(context);
            },
            label: providerData.cartItemList.length <= 0
                ? Text(
                    "Add".toString(),
                    style: GoogleFonts.jost(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ).paddingSymmetric(horizontal: 40, vertical: 10)
                : Text(
                    "next".toString(),
                    style: GoogleFonts.jost(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ).paddingSymmetric(horizontal: 40, vertical: 10)),
        // bottomNavigationBar: ButtonGlobal(
        //   iconWidget: Icons.arrow_forward,
        //   buttontext: 'Sales List',
        //   iconColor: Colors.white,
        //   buttonDecoration: kButtonDecoration.copyWith(color: kMainColor),
        //   onPressed: () {
        //     // ignore: missing_required_param
        //     providerData.getTotalAmount() <= 0
        //         ? EasyLoading.showError('Cart Is Empty')
        //         : SalesDetails(
        //             customerName: widget.customerModel!.customerName,
        //           ).launch(context);
        //   },
        // ),
      );
    });
  }
}

// ignore: must_be_immutable
class ProductCard extends StatefulWidget {
  ProductCard(
      {Key? key,
      required this.productTitle,
      this.productbrand,
      required this.productDescription,
      required this.productPrice,
      required this.productImage})
      : super(key: key);

  // final Product product;
  String productImage, productTitle, productDescription, productPrice;
  String? productbrand;
  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int quantity = 0;
  String productPicture =
      'https://firebasestorage.googleapis.com/v0/b/maanpos.appspot.com/o/Customer%20Picture%2FNo_Image_Available.jpeg?alt=media&token=3de0d45e-0e4a-4a7b-b115-9d6722d5031f';
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      final providerData = ref.watch(cartNotifier);

      for (var element in providerData.cartItemList) {
        if (element.productName == widget.productTitle) {
          quantity = element.quantity;
        }
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(
              height: 80,
              width: 90,
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: widget.productImage,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    Center(
                        child: CircularProgressIndicator(
                            value: downloadProgress.progress)),
                errorWidget: (context, url, error) => ClipRRect(
                    child: Image.network(
                  productPicture,
                  height: 20,
                )),
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(4.0),
          //   child: Container(
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(15),
          //       image: DecorationImage(
          //           image: NetworkImage(widget.productImage),
          //           fit: BoxFit.cover),
          //     ),
          //   ),
          // ),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              widget.productTitle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                  color: bluetxtcolor,
                  textStyle:
                      TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600)),
            ),
          ),
          widget.productbrand != null
              ? Center(
                  child: Text(
                    widget.productbrand.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10.0,
                      color: kGreyTextColor,
                    ),
                  ),
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$currency${widget.productPrice}',
              style: GoogleFonts.inter(
                  color: pricecolor,
                  textStyle:
                      TextStyle(fontSize: 10.0, fontWeight: FontWeight.w600)),
              textAlign: TextAlign.center,
            ),
          ),

          // Padding(
          //   padding: const EdgeInsets.only(left: 10.0),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Row(
          //         children: [
          //           Text(
          //             widget.productTitle,
          //             style: GoogleFonts.jost(
          //               fontSize: 20.0,
          //               color: Colors.black,
          //             ),
          //           ),
          //           // const SizedBox(width: 5),
          //           // Text(
          //           //   ' X $quantity',
          //           //   style: GoogleFonts.jost(
          //           //     fontSize: 14.0,
          //           //     color: Colors.grey.shade500,
          //           //   ),
          //           // ).visible(quantity != 0),
          //         ],
          //       ),
          //       Text(
          //         widget.productDescription,
          //         style: GoogleFonts.jost(
          //           fontSize: 15.0,
          //           color: kGreyTextColor,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // const Spacer(),
          // Text(
          //   '$currency${widget.productPrice}',
          //   style: GoogleFonts.jost(
          //     fontSize: 20.0,
          //     color: Colors.black,
          //   ),
          // ),
        ],
      );
    });
  }
}
