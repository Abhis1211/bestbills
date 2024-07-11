import 'dart:convert';
import '../../constant.dart';
import '../../currency.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../model/product_model.dart';
import '../../Provider/product_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:firebase_database/firebase_database.dart';

class StockList extends StatefulWidget {
  const StockList({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _StockListState createState() => _StockListState();
}

class _StockListState extends State<StockList> {
  int totalStock = 0;
  double totalSalePrice = 0;
  double totalParPrice = 0;

  @override
  void initState() {
    getAllTotal();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          lang.S.of(context).stockList,
          style: GoogleFonts.inter(
              color: Colors.black, fontSize: 22.0, fontWeight: FontWeight.w500),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: Consumer(builder: (context, ref, __) {
        final providerData = ref.watch(productProvider);

        return SingleChildScrollView(
          child: Column(
            children: [
              Column(
                children: [
                  // const SizedBox(height: 10.0),
                  Container(
                    padding: const EdgeInsets.all(20),
                    color: kMainColor.withOpacity(0.2),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            lang.S.of(context).product,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            lang.S.of(context).quantity,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            lang.S.of(context).purchase,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          lang.S.of(context).sale,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  DataTable(
                    horizontalMargin: 40.0,
                    columnSpacing: 50.0,
                    headingRowColor: MaterialStateColor.resolveWith(
                        (states) => kMainColor.withOpacity(0.2)),
                    columns: const <DataColumn>[
                      DataColumn(
                        label: Text(
                          'Product',
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'QTY',
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Purchase',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Sale',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                    rows: const [],
                  ).visible(false),
                  providerData.when(data: (product) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: ListView.builder(
                          itemCount: product.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product[index].productName,
                                            textAlign: TextAlign.start,
                                            style: GoogleFonts.inter(
                                              color: product[index]
                                                          .productStock
                                                          .toInt() <
                                                      20
                                                  ? Colors.red
                                                  : Colors.black,
                                              fontSize: 16.0,
                                            ),
                                          ),
                                          Text(
                                            product[index].brandName,
                                            textAlign: TextAlign.start,
                                            style: GoogleFonts.inter(
                                              color: product[index]
                                                          .productStock
                                                          .toInt() <
                                                      20
                                                  ? Colors.red
                                                  : kGreyTextColor,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Center(
                                        child: Text(
                                          product[index].productStock,
                                          style: GoogleFonts.inter(
                                            color: product[index]
                                                        .productStock
                                                        .toInt() <
                                                    20
                                                ? Colors.red
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 2,
                                        child: Center(
                                          child: Text(
                                            '$currency${product[index].productPurchasePrice}',
                                            style: GoogleFonts.inter(
                                              color: product[index]
                                                          .productStock
                                                          .toInt() <
                                                      20
                                                  ? Colors.red
                                                  : Colors.black,
                                            ),
                                          ),
                                        )),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          '$currency${product[index].productSalePrice}',
                                          style: GoogleFonts.inter(
                                            color: product[index]
                                                        .productStock
                                                        .toInt() <
                                                    20
                                                ? Colors.red
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(
                                  thickness: 0.5,
                                )
                              ],
                            );
                          }),
                    );
                  }, error: (e, stack) {
                    return Text(e.toString());
                  }, loading: () {
                    return const Center(child: CircularProgressIndicator());
                  }),
                ],
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: kMainColor.withOpacity(0.2),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                lang.S.of(context).total,
                textAlign: TextAlign.start,
                style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                totalStock.toString(),
                style: GoogleFonts.inter(
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
                flex: 2,
                child: Text(
                  '$currency${totalParPrice.toInt().toString()}',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                  ),
                )),
            Text(
              '$currency${totalSalePrice.toInt().toString()}',
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getAllTotal() async {
    // ignore: unused_local_variable
    List<ProductModel> productList = [];
    await FirebaseDatabase.instance
        .ref(constUserId)
        .child('Products')
        .orderByKey()
        .get()
        .then((value) {
      for (var element in value.children) {
        var data = jsonDecode(jsonEncode(element.value));
        setState(() {
          totalStock = data['productStock'] != "" ? totalStock + int.parse(data['productStock']) :totalStock + 0;
          totalSalePrice = totalSalePrice +
              (int.parse(data['productSalePrice']) *
                ( data['productStock'] == "" ? 0: int.parse(data['productStock'])));
          totalParPrice = totalParPrice +
              (data['productPurchasePrice'] == null ||
                          data['productPurchasePrice'] == ""
                      ? int.parse("0")
                      : int.parse(data['productPurchasePrice'])) *
                  ( data['productStock'] == "" ? 0: int.parse(data['productStock']));
        });

        print("salesprice" + totalSalePrice.toString());
        // productList.add(ProductModel.fromJson(jsonDecode(jsonEncode(element.value))));
      }
    });
  }
}
