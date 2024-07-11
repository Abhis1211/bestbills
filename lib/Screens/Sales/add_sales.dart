// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import '../Customers/add_customer.dart';
import '../Home/home.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../../subscription.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../Provider/printer_provider.dart';
import '../../Provider/product_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Customers/Model/customer_model.dart';
import '../../model/print_transaction_model.dart';
import '../../Provider/seles_report_provider.dart';
import 'package:mobile_pos/Provider/add_to_cart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/model/transition_model.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:firebase_database/firebase_database.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Provider/customer_provider.dart';
import 'package:mobile_pos/Screens/Sales/sales_screen.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile_pos/Provider/transactions_provider.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

// ignore_for_file: unused_result, use_build_context_synchronously
// ignore: must_be_immutable
class AddSalesScreen extends StatefulWidget {
  AddSalesScreen({Key? key, required this.customerModel}) : super(key: key);

  CustomerModel customerModel;

  @override
  State<AddSalesScreen> createState() => _AddSalesScreenState();
}

class _AddSalesScreenState extends State<AddSalesScreen> {
  TextEditingController paidText = TextEditingController();
  int invoice = 0;
  double paidAmount = 0;
  double discountAmount = 0;
  double returnAmount = 0;
  double dueAmount = 0;
  double subTotal = 0;
  double netTotal = 0;
  String? dropdownValue = 'Cash';
  String? guestname = '';
  String? selectedPaymentType;
  TextEditingController vatPercentageEditingController =
      TextEditingController();
  TextEditingController vatAmountEditingController = TextEditingController();
  TextEditingController paidamount = TextEditingController();
  double percentage = 0;
  double vatAmount = 0;
  double totalamount = 0;
  bool isClicked = false;
  CustomerModel? selected_customer;
  double calculateSubtotal({required double total, vatamout}) {
    print("vatamout" + vatAmount.toString());
    print("totalamout" + total.toString());
    subTotal = total - discountAmount;
    netTotal = total + vatamout - discountAmount;
    return total + vatamout - discountAmount;
  }

  double calculateReturnAmount({required double total}) {
    print("paidAmount" + paidAmount.toString());
    print("totalamout" + total.toString());
    returnAmount = total - paidAmount;
    print("returnAmount " + returnAmount.toString());
    dueAmount = 0;
    // return paidAmount <= 0 || paidAmount <= subTotal ? 0 : total - paidAmount;
    return paidAmount <= 0 || paidAmount <= netTotal
        ? 0
        : netTotal - paidAmount;
  }

  double calculateDueAmount({required double total}) {
    print("total====> " + total.toString());
    if (total < 0) {
      dueAmount = 0;
    } else if (paidamount.text.isEmpty) {
      dueAmount = 0;
      returnAmount = 0;
    } else if (paidAmount == 0) {
      dueAmount = netTotal;
      returnAmount = 0;
    } else {
      dueAmount = netTotal - paidAmount;
    }
    print("total====>dueAmount " + dueAmount.toString());
    print("total====>returnAmount " + returnAmount.toString());
    return dueAmount <= 0 ? 0 : netTotal - paidAmount;
  }

  late SaleTransactionModel transitionModel = SaleTransactionModel(
    customerName: widget.customerModel.customerName,
    customerPhone: widget.customerModel.phoneNumber,
    customerType: widget.customerModel.type,
    invoiceNumber: invoice.toString(),
    purchaseDate: DateTime.now().toString(),
  );
  DateTime selectedDate = DateTime.now();

  var islaod = true;
  var isaddguest = true;
  var isfromaddcustomer = false;

  @override
  void initState() {
    setState(() {
      guestname = widget.customerModel.customerName;
    });

    super.initState();
  }

  void dispose() {
    paidAmount = 0;
    discountAmount = 0;
    returnAmount = 0;
    dueAmount = 0;
    subTotal = 0;
    netTotal = 0;
    percentage = 0;
    vatAmount = 0;
    totalamount = 0;
    dropdownValue = 'Cash';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return showAlertDialog(context, () async {
          Navigator.pop(context);
        });
      },
      child: Consumer(builder: (context, consumerRef, __) {
        final providerData = consumerRef.watch(cartNotifier);
        final printerData = consumerRef.watch(printerProviderNotifier);
        final personalData = consumerRef.watch(profileDetailsProvider);
        final customerdata = consumerRef.watch(customerProvider);

        return personalData.when(data: (data) {
          print(data.invoiceCounter.toString());
          invoice = data.invoiceCounter!.toInt();
          if (islaod == true) {
            providerData.totalgst = 0.0;
            providerData.cartItemList.clear();
            islaod = false;
          }
          // consumerRef.refresh(profileDetailsProvider);
          // personalInformationModel = data;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text(
                lang.S.of(context).addSales,
                style: GoogleFonts.inter(
                  color: Colors.black,
                ),
              ),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.black),
              elevation: 0.0,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            textFieldType: TextFieldType.NAME,
                            readOnly: true,
                            initialValue: invoice.toString(),
                            //  data.invoiceCounter.toString(),
                            decoration: InputDecoration(
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              labelText: lang.S.of(context).inv,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: AppTextField(
                            textFieldType: TextFieldType.NAME,
                            readOnly: true,
                            initialValue: transitionModel.purchaseDate,
                            decoration: InputDecoration(
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              labelText: lang.S.of(context).date,
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                onPressed: () async {
                                  final DateTime? picked = await showDatePicker(
                                    initialDate: selectedDate,
                                    firstDate: DateTime(2015, 8),
                                    lastDate: DateTime(2101),
                                    context: context,
                                  );
                                  if (picked != null &&
                                      picked != selectedDate) {
                                    setState(() {
                                      selectedDate = picked;
                                      transitionModel.purchaseDate =
                                          picked.toString();
                                    });
                                  }
                                },
                                icon: const Icon(FeatherIcons.calendar),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(lang.S.of(context).dueAmount),
                            Text(
                              widget.customerModel.dueAmount == ''
                                  ? '$currency 0'
                                  : '$currency${widget.customerModel.dueAmount}',
                              style: const TextStyle(color: Color(0xFFFF8C34)),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        customerdata.when(data: (customer) {
                          if (isaddguest == true) {
                            var contain = customer.where(
                                (element) => element.customerName == "Guest");
                            if (contain.isEmpty) {
                              customer.insert(
                                  0,
                                  CustomerModel(
                                    'Guest',
                                    '',
                                    'Guest',
                                    'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png',
                                    'Guest',
                                    'Guest',
                                    '0',
                                  ));
                              if (!isfromaddcustomer) {
                                selected_customer = customer[0];
                              } else {
                                selected_customer = customer.last;
                              }
                              isaddguest = false;
                            } else {}
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              InputDecorator(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5))),
                                  contentPadding: EdgeInsets.all(10),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<CustomerModel>(
                                    isExpanded: true,
                                    value: selected_customer,
                                    icon: Icon(Icons.keyboard_arrow_down),
                                    items: customer.map((items) {
                                      return DropdownMenuItem(
                                        value: items,
                                        alignment: Alignment.bottomRight,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                items.customerName == "Guest"
                                                    ? Text(
                                                        "Walk In Customer(${items.customerName.toString()})")
                                                    : Text(items.customerName
                                                        .toString()),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      '$currency ${items.dueAmount}',
                                                      style: GoogleFonts.inter(
                                                        color: Colors.black,
                                                        fontSize: 12.0,
                                                      ),
                                                    ),
                                                    Text(
                                                      lang.S.of(context).due,
                                                      style: GoogleFonts.inter(
                                                        color: const Color(
                                                            0xFFff5f00),
                                                        fontSize: 12.0,
                                                      ),
                                                    ),
                                                  ],
                                                ).visible(
                                                    items.dueAmount != '' &&
                                                        items.dueAmount != '0'),
                                              ],
                                            ),
                                            Divider()
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        selected_customer = newValue;
                                      });
                                      print(selected_customer!.customerName
                                          .toString());
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              GestureDetector(
                                onTap: () {
                                  const AddCustomer(
                                    type: 0,
                                  ).launch(context).then((value) {
                                    // print("retrun value"+ value.toString());
                                    if (value['value'] == true) {
                                      setState(() {
                                        isaddguest = true;
                                        isfromaddcustomer = true;
                                      });

                                      // print("retrun value"+ selected_customer.toString());
                                    }
                                  });
                                },
                                child: Text(
                                  "Add New Customer",
                                  style: const TextStyle(
                                      color: kMainColor,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );
                        }, error: (Object error, StackTrace stackTrace) {
                          return Center(
                            child: Text(error.toString()),
                          );
                        }, loading: () {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                            // AppTextField(

                            //   textFieldType: TextFieldType.NAME,
                            //   readOnly: widget.customerModel.type == 'Guest'
                            //       ? false
                            //       : true,
                            //   initialValue: widget.customerModel.customerName,
                            //   onChanged: (value) {
                            //     guestname = value;
                            //   },
                            //   decoration: InputDecoration(
                            //     floatingLabelBehavior: FloatingLabelBehavior.always,
                            //     labelText: lang.S.of(context).customerName,
                            //     border: const OutlineInputBorder(),
                            //   ),
                            // ),
                            )
                      ],
                    ),
                    const SizedBox(height: 10),

                    ///_______Added_ItemS__________________________________________________
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)),
                        border: Border.all(
                            width: 1, color: const Color(0xffEAEFFA)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: Color(0xffEAEFFA),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: SizedBox(
                                  width: context.width() / 1.35,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        lang.S.of(context).itemAdded,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        lang.S.of(context).quantity,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                          ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: providerData.cartItemList.length,
                              itemBuilder: (context, index) {
                                Future.delayed(Duration(milliseconds: 1), () {
                                  vatPercentageEditingController.text =
                                      providerData.totalgst.toString();

                                  // vatAmount = providerData.totalamount(
                                  //     discountAmount: discountAmount);
                                  vatAmount = double.parse(
                                      vatPercentageEditingController.text
                                          .toString());

                                  // vatAmountEditingController.text =
                                  //     vatAmount.toStringAsFixed(2);
                                  vatAmountEditingController.text = providerData
                                      .totalgst
                                      .toDouble()
                                      .round()
                                      .toString();

                                  providerData.calculatetotalgst(index);
                                  print("finla GSt" +
                                      providerData.finaltotalgst.toString());
                                  subTotal = providerData.calculateSubtotal(
                                      discountAmount: discountAmount);
                                  netTotal = providerData.calculateSubtotal1(
                                      discountAmount: discountAmount);
                                  // print("subtotal" + subTotal.toString());
                                  // print("subtotal" + netTotal.toString());
                                  // setState(() {});
                                });
                                // consumerRef.refresh(cartNotifier);

                                // if (providerData.cartItemList.length == 0) {
                                //   totalgst = double.parse(providerData
                                //       .cartItemList[index].productgst!
                                //       .toString());
                                //   print("total gst1" + totalgst.toString());
                                // } else {
                                //   totalgst = double.parse(providerData
                                //           .cartItemList[index].productgst!) +
                                //       double.parse(totalgst.toString());
                                //   print("total gst" + totalgst.toString());
                                // }
                                //// Future.delayed(Duration(milliseconds: 2), () {
                                //   vatAmount = (vatPercentageEditingController.text
                                //               .toDouble() /
                                //           100) *
                                //       providerData.getTotalAmount().toDouble();
                                //   vatAmountEditingController.text =
                                //       vatAmount.toString();
                                // });

                                return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(providerData
                                                    .cartItemList[index]
                                                    .productName
                                                    .toString()),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        '${providerData.cartItemList[index].quantity} X ${providerData.cartItemList[index].subTotal} = ${(double.parse(providerData.cartItemList[index].subTotal) * providerData.cartItemList[index].quantity).toStringAsFixed(2)}'),
                                                    Text(providerData.isColor(
                                                            providerData
                                                                .cartItemList[
                                                                    index]
                                                                .color) +
                                                        providerData.isSize(
                                                            providerData
                                                                .cartItemList[
                                                                    index]
                                                                .size) +
                                                        providerData.isWeight(
                                                            providerData
                                                                .cartItemList[
                                                                    index]
                                                                .weight))
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        providerData
                                                            .quantityDecrease(
                                                                index);
                                                        Future.delayed(
                                                            Duration(
                                                                milliseconds:
                                                                    1), () {
                                                          vatPercentageEditingController
                                                                  .text =
                                                              providerData
                                                                  .totalgst
                                                                  .toString();
                                                          vatAmount = providerData
                                                              .totalamount(
                                                                  discountAmount:
                                                                      discountAmount);
                                                          vatAmountEditingController
                                                                  .text =
                                                              vatAmount
                                                                  .toStringAsFixed(
                                                                      2);
                                                          subTotal = providerData
                                                              .calculateSubtotal(
                                                                  discountAmount:
                                                                      discountAmount);
                                                          netTotal = providerData
                                                              .calculateSubtotal1(
                                                                  discountAmount:
                                                                      discountAmount);
                                                          print("subtotal" +
                                                              subTotal
                                                                  .toString());
                                                          print("subtotal" +
                                                              netTotal
                                                                  .toString());
                                                          setState(() {});
                                                        });
                                                      },
                                                      child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        height: 25,
                                                        width: 25,
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: kMainColor,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          15)),
                                                        ),
                                                        child: Text(
                                                          '-',
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 7),
                                                    Text(
                                                      '${providerData.cartItemList[index].quantity}',
                                                      style: GoogleFonts.inter(
                                                        color: kGreyTextColor,
                                                        fontSize: 20.0,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 7),
                                                    GestureDetector(
                                                      onTap: () {
                                                        providerData
                                                            .quantityIncrease(
                                                                index);
                                                        Future.delayed(
                                                            Duration(
                                                                milliseconds:
                                                                    1), () {
                                                          vatPercentageEditingController
                                                                  .text =
                                                              providerData
                                                                  .totalgst
                                                                  .toString();
                                                          vatAmount = providerData
                                                              .totalamount(
                                                                  discountAmount:
                                                                      discountAmount);
                                                          vatAmountEditingController
                                                                  .text =
                                                              vatAmount
                                                                  .toStringAsFixed(
                                                                      2);
                                                          subTotal = providerData
                                                              .calculateSubtotal(
                                                                  discountAmount:
                                                                      discountAmount);
                                                          netTotal = providerData
                                                              .calculateSubtotal1(
                                                                  discountAmount:
                                                                      discountAmount);
                                                          print("subtotal" +
                                                              subTotal
                                                                  .toString());
                                                          print("subtotal" +
                                                              netTotal
                                                                  .toString());
                                                          setState(() {});
                                                        });
                                                      },
                                                      child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        height: 25,
                                                        width: 25,
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: kMainColor,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          15)),
                                                        ),
                                                        child: Text(
                                                          '+',
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(width: 10),
                                                Column(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        providerData.deleteToCart(
                                                            index,
                                                            providerData
                                                                .cartItemList[
                                                                    index]
                                                                .productGstamount);
                                                        Future.delayed(
                                                            Duration(
                                                                milliseconds:
                                                                    1), () {
                                                          vatPercentageEditingController
                                                                  .text =
                                                              providerData
                                                                  .totalgst
                                                                  .toString();
                                                          vatAmount = providerData
                                                              .totalamount(
                                                                  discountAmount:
                                                                      discountAmount);
                                                          vatAmountEditingController
                                                                  .text =
                                                              vatAmount
                                                                  .toStringAsFixed(
                                                                      2);
                                                          subTotal = providerData
                                                              .calculateSubtotal(
                                                                  discountAmount:
                                                                      discountAmount);
                                                          netTotal = providerData
                                                              .calculateSubtotal1(
                                                                  discountAmount:
                                                                      discountAmount);
                                                          print("subtotal" +
                                                              subTotal
                                                                  .toString());
                                                          print("subtotal" +
                                                              netTotal
                                                                  .toString());
                                                          setState(() {});
                                                        });
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4),
                                                        color: Colors.red
                                                            .withOpacity(0.1),
                                                        child: const Icon(
                                                          Icons.delete,
                                                          size: 20,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    GestureDetector(
                                                      onTap: () {
                                                        var result = "";
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return StatefulBuilder(
                                                                builder: (BuildContext
                                                                        context,
                                                                    StateSetter
                                                                        setState) {
                                                              return Dialog(
                                                                insetPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10)),
                                                                elevation: 16,
                                                                child:
                                                                    Container(
                                                                        padding: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                10),
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            SizedBox(height: 40),
                                                                            Text(
                                                                              'Update price',
                                                                              style: TextStyle(fontSize: 18, color: Colors.black),
                                                                            ),
                                                                            SizedBox(height: 40),
                                                                            AppTextField(
                                                                              textFieldType: TextFieldType.NAME,
                                                                              initialValue: providerData.cartItemList[index].subTotal,
                                                                              onChanged: (value) {
                                                                                setState(() {
                                                                                  providerData.cartItemList[index].subTotal = value;
                                                                                  result = value;
                                                                                });
                                                                              },
                                                                              decoration: InputDecoration(floatingLabelBehavior: FloatingLabelBehavior.always, labelText: "Product price", border: const OutlineInputBorder(), hintText: "Enter product price"),
                                                                            ),
                                                                            SizedBox(height: 40),
                                                                            InkWell(
                                                                              onTap: () {
                                                                                setState(() {
                                                                                  providerData.cartItemList[index].subTotal = result;
                                                                                });

                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: Container(
                                                                                height: 40,
                                                                                decoration: const BoxDecoration(
                                                                                  color: kMainColor,
                                                                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                                                                ),
                                                                                child: const Center(
                                                                                  child: Text(
                                                                                    'Update',
                                                                                    style: TextStyle(fontSize: 14, color: Colors.white),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              height: 20,
                                                                            )
                                                                          ],
                                                                        )),
                                                              ).paddingSymmetric(
                                                                  horizontal:
                                                                      20);
                                                            });
                                                          },
                                                        );
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4),
                                                        color: Colors.blue
                                                            .withOpacity(0.1),
                                                        child: const Icon(
                                                          Icons.edit,
                                                          size: 20,
                                                          color: Colors.blue,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ).paddingOnly(top: 5),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Divider()
                                      ],
                                    )

                                    //  ListTile(
                                    //   contentPadding: const EdgeInsets.all(0),
                                    //   title:

                                    //   Text(providerData
                                    //       .cartItemList[index].productName
                                    //       .toString()),
                                    //   subtitle: Column(
                                    //     crossAxisAlignment:
                                    //         CrossAxisAlignment.start,
                                    //     children: [
                                    //       Text(
                                    //           '${providerData.cartItemList[index].quantity} X ${providerData.cartItemList[index].subTotal} = ${(double.parse(providerData.cartItemList[index].subTotal) * providerData.cartItemList[index].quantity).toStringAsFixed(2)}'),
                                    //       Text(providerData.isColor(providerData
                                    //               .cartItemList[index].color) +
                                    //           providerData.isSize(providerData
                                    //               .cartItemList[index].size) +
                                    //           providerData.isWeight(providerData
                                    //               .cartItemList[index].weight))
                                    //     ],
                                    //   ),
                                    //   trailing: Row(
                                    //     mainAxisSize: MainAxisSize.min,
                                    //     children: [
                                    //       Row(
                                    //         mainAxisAlignment:
                                    //             MainAxisAlignment.spaceBetween,
                                    //         children: [
                                    //           GestureDetector(
                                    //             onTap: () {
                                    //               providerData
                                    //                   .quantityDecrease(index);
                                    //               Future.delayed(
                                    //                   Duration(milliseconds: 1),
                                    //                   () {
                                    //                 vatPercentageEditingController
                                    //                         .text =
                                    //                     providerData.totalgst
                                    //                         .toString();
                                    //                 vatAmount =
                                    //                     providerData.totalamount(
                                    //                         discountAmount:
                                    //                             discountAmount);
                                    //                 vatAmountEditingController
                                    //                         .text =
                                    //                     vatAmount
                                    //                         .toStringAsFixed(2);
                                    //                 subTotal = providerData
                                    //                     .calculateSubtotal(
                                    //                         discountAmount:
                                    //                             discountAmount);
                                    //                 netTotal = providerData
                                    //                     .calculateSubtotal1(
                                    //                         discountAmount:
                                    //                             discountAmount);
                                    //                 print("subtotal" +
                                    //                     subTotal.toString());
                                    //                 print("subtotal" +
                                    //                     netTotal.toString());
                                    //                 setState(() {});
                                    //               });
                                    //             },
                                    //             child: Container(
                                    //               alignment: Alignment.center,
                                    //               height: 25,
                                    //               width: 25,
                                    //               decoration: const BoxDecoration(
                                    //                 color: kMainColor,
                                    //                 borderRadius:
                                    //                     BorderRadius.all(
                                    //                         Radius.circular(15)),
                                    //               ),
                                    //               child:  Text(
                                    //                 '-',
                                    //                 style: TextStyle(
                                    //                      fontSize: 20,
                                    //                     color: Colors.white),
                                    //               ),
                                    //             ),
                                    //           ),
                                    //           const SizedBox(width: 7),
                                    //           Text(
                                    //             '${providerData.cartItemList[index].quantity}',
                                    //             style: GoogleFonts.inter(
                                    //               color: kGreyTextColor,
                                    //               fontSize: 20.0,
                                    //             ),
                                    //           ),
                                    //           const SizedBox(width: 7),
                                    //           GestureDetector(
                                    //             onTap: () {
                                    //               providerData
                                    //                   .quantityIncrease(index);
                                    //               Future.delayed(
                                    //                   Duration(milliseconds: 1),
                                    //                   () {
                                    //                 vatPercentageEditingController
                                    //                         .text =
                                    //                     providerData.totalgst
                                    //                         .toString();
                                    //                 vatAmount =
                                    //                     providerData.totalamount(
                                    //                         discountAmount:
                                    //                             discountAmount);
                                    //                 vatAmountEditingController
                                    //                         .text =
                                    //                     vatAmount
                                    //                         .toStringAsFixed(2);
                                    //                 subTotal = providerData
                                    //                     .calculateSubtotal(
                                    //                         discountAmount:
                                    //                             discountAmount);
                                    //                 netTotal = providerData
                                    //                     .calculateSubtotal1(
                                    //                         discountAmount:
                                    //                             discountAmount);
                                    //                 print("subtotal" +
                                    //                     subTotal.toString());
                                    //                 print("subtotal" +
                                    //                     netTotal.toString());
                                    //                 setState(() {});
                                    //               });
                                    //             },
                                    //             child: Container(
                                    //             alignment: Alignment.center,
                                    //               height: 25,
                                    //               width: 25,
                                    //               decoration: const BoxDecoration(
                                    //                 color: kMainColor,
                                    //                 borderRadius:
                                    //                     BorderRadius.all(
                                    //                         Radius.circular(15)),
                                    //               ),
                                    //               child: Text(
                                    //                 '+',
                                    //                 style: TextStyle(
                                    //                 fontSize: 18,
                                    //                 color: Colors.white),
                                    //               ),
                                    //             ),
                                    //           ),
                                    //         ],
                                    //       ),
                                    //       const SizedBox(width: 10),

                                    //       Column(
                                    //         children: [
                                    //           GestureDetector(
                                    //             onTap: () {
                                    //               providerData.deleteToCart(
                                    //                   index,
                                    //                   providerData.cartItemList[index]
                                    //                       .productGstamount);
                                    //               Future.delayed(
                                    //                   Duration(milliseconds: 1), () {
                                    //                 vatPercentageEditingController
                                    //                         .text =
                                    //                     providerData.totalgst
                                    //                         .toString();
                                    //                 vatAmount =
                                    //                     providerData.totalamount(
                                    //                         discountAmount:
                                    //                             discountAmount);
                                    //                 vatAmountEditingController.text =
                                    //                     vatAmount.toStringAsFixed(2);
                                    //                 subTotal = providerData
                                    //                     .calculateSubtotal(
                                    //                         discountAmount:
                                    //                             discountAmount);
                                    //                 netTotal = providerData
                                    //                     .calculateSubtotal1(
                                    //                         discountAmount:
                                    //                             discountAmount);
                                    //                 print("subtotal" +
                                    //                     subTotal.toString());
                                    //                 print("subtotal" +
                                    //                     netTotal.toString());
                                    //                 setState(() {});
                                    //               });
                                    //             },
                                    //             child: Container(
                                    //               padding: const EdgeInsets.all(4),
                                    //               color: Colors.red.withOpacity(0.1),
                                    //               child: const Icon(
                                    //                 Icons.delete,
                                    //                 size: 20,
                                    //                 color: Colors.red,
                                    //               ),
                                    //             ),
                                    //           ),
                                    //           SizedBox(height: 5),
                                    //           GestureDetector(
                                    //             onTap: () {
                                    //               var result = "";
                                    //               showDialog(
                                    //                 context: context,
                                    //                 builder: (context) {
                                    //                   return StatefulBuilder(builder:
                                    //                       (BuildContext context,
                                    //                           StateSetter setState) {
                                    //                     return Dialog(
                                    //                       insetPadding:
                                    //                           EdgeInsets.zero,
                                    //                       shape:
                                    //                           RoundedRectangleBorder(
                                    //                               borderRadius:
                                    //                                   BorderRadius
                                    //                                       .circular(
                                    //                                           10)),
                                    //                       elevation: 16,
                                    //                       child: Container(
                                    //                           padding: EdgeInsets
                                    //                               .symmetric(
                                    //                                   horizontal: 10),
                                    //                           child: Column(
                                    //                             mainAxisSize:
                                    //                                 MainAxisSize.min,
                                    //                             children: [
                                    //                               SizedBox(
                                    //                                   height: 40),
                                    //                               Text(
                                    //                                 'Update price',
                                    //                                 style: TextStyle(
                                    //                                     fontSize: 18,
                                    //                                     color: Colors
                                    //                                         .black),
                                    //                               ),
                                    //                               SizedBox(
                                    //                                   height: 40),
                                    //                               AppTextField(
                                    //                                 textFieldType:
                                    //                                     TextFieldType
                                    //                                         .NAME,
                                    //                                 initialValue:
                                    //                                     providerData
                                    //                                         .cartItemList[
                                    //                                             index]
                                    //                                         .subTotal,
                                    //                                 onChanged:
                                    //                                     (value) {
                                    //                                   setState(() {
                                    //                                     providerData
                                    //                                         .cartItemList[
                                    //                                             index]
                                    //                                         .subTotal = value;
                                    //                                         result = value;
                                    //                                   });
                                    //                                 },
                                    //                                 decoration: InputDecoration(
                                    //                                     floatingLabelBehavior:
                                    //                                         FloatingLabelBehavior
                                    //                                             .always,
                                    //                                     labelText:
                                    //                                         "Product price",
                                    //                                     border:
                                    //                                         const OutlineInputBorder(),
                                    //                                     hintText:
                                    //                                         "Enter product price"),
                                    //                               ),
                                    //                               SizedBox(
                                    //                                   height: 40),
                                    //                               InkWell(
                                    //                                 onTap: () {
                                    //                                   setState(() {
                                    //                                     providerData
                                    //                                         .cartItemList[
                                    //                                             index]
                                    //                                         .subTotal = result;

                                    //                                   });

                                    //                                   Navigator.pop(
                                    //                                         context);
                                    //                                 },
                                    //                                 child: Container(
                                    //                                   height: 40,
                                    //                                   decoration:
                                    //                                       const BoxDecoration(
                                    //                                     color:
                                    //                                         kMainColor,
                                    //                                     borderRadius:
                                    //                                         BorderRadius.all(
                                    //                                             Radius.circular(
                                    //                                                 10)),
                                    //                                   ),
                                    //                                   child:
                                    //                                       const Center(
                                    //                                     child: Text(
                                    //                                       'Update',
                                    //                                       style: TextStyle(
                                    //                                           fontSize:
                                    //                                               14,
                                    //                                           color: Colors
                                    //                                               .white),
                                    //                                     ),
                                    //                                   ),
                                    //                                 ),
                                    //                               ),
                                    //                               SizedBox(
                                    //                                 height: 20,
                                    //                               )
                                    //                             ],
                                    //                           )),
                                    //                     ).paddingSymmetric(
                                    //                         horizontal: 20);
                                    //                   });
                                    //                 },
                                    //               );

                                    //             },
                                    //             child: Container(
                                    //               padding: const EdgeInsets.all(4),
                                    //               color: Colors.blue.withOpacity(0.1),
                                    //               child: const Icon(
                                    //                 Icons.edit,
                                    //                 size: 20,
                                    //                 color: Colors.blue,
                                    //               ),
                                    //             ),
                                    //           ),
                                    //         ],
                                    //       ),

                                    //     ],
                                    //   ),

                                    );
                              }),
                        ],
                      ).visible(providerData.cartItemList.isNotEmpty),
                    ),
                    const SizedBox(height: 10),

                    ///_______Add_Button__________________________________________________
                    GestureDetector(
                      onTap: () {
                        SaleProducts(
                          catName: null,
                          customerModel: widget.customerModel,
                        ).launch(context);
                      },
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: kMainColor.withOpacity(0.1),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10))),
                        child: Center(
                            child: Text(
                          lang.S.of(context).addItems,
                          style:
                              const TextStyle(color: kMainColor, fontSize: 20),
                        )),
                      ),
                    ),
                    const SizedBox(height: 10),

                    ///_____Total______________________________
                    Container(
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          border: Border.all(
                              color: Colors.grey.shade300, width: 1)),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Color(0xffEAEFFA),
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    topLeft: Radius.circular(10))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  lang.S.of(context).subTotal,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  providerData
                                      .getTotalAmount()
                                      .round()
                                      .toString(),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  lang.S.of(context).discount,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                SizedBox(
                                  width: context.width() / 4,
                                  child: TextField(
                                    controller: paidText,
                                    onChanged: (value) {
                                      if (value == '') {
                                        setState(() {
                                          discountAmount = 0.0;
                                        });
                                        providerData.notifyListeners();
                                      } else {
                                        if (value.toInt() <=
                                            providerData.getTotalAmount()) {
                                          setState(() {
                                            discountAmount =
                                                double.parse(value);
                                          });
                                        } else {
                                          paidText.clear();
                                          setState(() {
                                            discountAmount = 0;
                                          });
                                          EasyLoading.showError(
                                              'Enter a valid Discount');
                                        }
                                      }
                                      Future.delayed(Duration(milliseconds: 1),
                                          () {
                                        vatPercentageEditingController.text =
                                            providerData.totalgst.toString();
                                        vatAmount = providerData.totalamount(
                                            discountAmount: discountAmount);
                                        vatAmountEditingController.text =
                                            vatAmount.toStringAsFixed(2);
                                        print("discountAmount1" +
                                            vatAmount.toString());
                                        subTotal =
                                            providerData.calculateSubtotal(
                                                discountAmount: discountAmount);
                                        netTotal =
                                            providerData.calculateSubtotal1(
                                                discountAmount: discountAmount);
                                        print("subtotal" + subTotal.toString());
                                        print("netTotal" + netTotal.toString());
                                        print("discountAmount" +
                                            discountAmount.toString());
                                        setState(() {});
                                        providerData.notifyListeners();
                                      });
                                    },
                                    style: const TextStyle(fontSize: 14),
                                    textAlign: TextAlign.right,
                                    decoration: const InputDecoration(
                                      hintText: '0',
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Color(0xffEAEFFA),
                              border: Border.symmetric(
                                  horizontal: BorderSide(color: Colors.black)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  lang.S.of(context).total,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  providerData
                                      .calculateSubtotal(
                                          discountAmount: discountAmount)
                                      .round()
                                      .toString(),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          if (data.gstenable == true)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'GST',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Row(
                                    children: [
                                      // SizedBox(
                                      //   width: context.width() / 4,
                                      //   height: 40.0,
                                      //   child: Center(
                                      //     child: AppTextField(
                                      //       textStyle: TextStyle(fontSize: 14),
                                      //       inputFormatters: [
                                      //         FilteringTextInputFormatter.allow(
                                      //             RegExp(r'^\d*\.?\d{0,2}'))
                                      //       ],
                                      //       controller:
                                      //           vatPercentageEditingController,
                                      //       onChanged: (value) {
                                      //         if (value == '') {
                                      //           setState(() {
                                      //             percentage = 0.0;
                                      //             vatAmountEditingController
                                      //                 .text = 0.toString();
                                      //             vatAmount = 0;
                                      //           });
                                      //         } else {
                                      //           setState(() {
                                      //             vatAmount =
                                      //                 (value.toDouble() / 100) *
                                      //                     providerData
                                      //                         .getTotalAmount()
                                      //                         .toDouble();
                                      //             vatAmountEditingController
                                      //                     .text =
                                      //                 vatAmount.toString();
                                      //           });
                                      //         }
                                      //       },
                                      //       textAlign: TextAlign.right,
                                      //       decoration: InputDecoration(
                                      //         contentPadding:
                                      //             const EdgeInsets.only(
                                      //                 right: 6.0),
                                      //         hintText: '0',
                                      //         border: const OutlineInputBorder(
                                      //             gapPadding: 0.0,
                                      //             borderSide: BorderSide(
                                      //                 color: Color(0xFFff5f00))),
                                      //         enabledBorder:
                                      //             const OutlineInputBorder(
                                      //                 gapPadding: 0.0,
                                      //                 borderSide: BorderSide(
                                      //                     color:
                                      //                         Color(0xFFff5f00))),
                                      //         disabledBorder:
                                      //             const OutlineInputBorder(
                                      //                 gapPadding: 0.0,
                                      //                 borderSide: BorderSide(
                                      //                     color:
                                      //                         Color(0xFFff5f00))),
                                      //         focusedBorder:
                                      //             const OutlineInputBorder(
                                      //                 gapPadding: 0.0,
                                      //                 borderSide: BorderSide(
                                      //                     color:
                                      //                         Color(0xFFff5f00))),
                                      //         prefixIconConstraints:
                                      //             const BoxConstraints(
                                      //                 maxWidth: 30.0,
                                      //                 minWidth: 30.0),
                                      //         prefixIcon: Container(
                                      //           padding: const EdgeInsets.only(
                                      //               top: 8.0, left: 8.0),
                                      //           height: 40,
                                      //           decoration: const BoxDecoration(
                                      //               color: Color(0xFFff5f00),
                                      //               borderRadius:
                                      //                   BorderRadius.only(
                                      //                       topLeft:
                                      //                           Radius.circular(
                                      //                               4.0),
                                      //                       bottomLeft:
                                      //                           Radius.circular(
                                      //                               4.0))),
                                      //           child: const Text(
                                      //             '%',
                                      //             style: TextStyle(
                                      //                 fontSize: 18.0,
                                      //                 color: Colors.white),
                                      //           ),
                                      //         ),
                                      //       ),
                                      //       textFieldType: TextFieldType.PHONE,
                                      //     ),
                                      //   ),
                                      // ),
                                      // const SizedBox(
                                      //   width: 4.0,
                                      // ),
                                      SizedBox(
                                        width: context.width() / 4,
                                        height: 40.0,
                                        child: Center(
                                          child: AppTextField(
                                            textStyle:
                                                const TextStyle(fontSize: 14),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'^\d*\.?\d{0,2}'))
                                            ],
                                            controller:
                                                vatAmountEditingController,
                                            onChanged: (value) {
                                              if (value == '') {
                                                setState(() {
                                                  vatAmount = 0;
                                                  vatPercentageEditingController
                                                      .clear();
                                                });
                                              } else {
                                                setState(() {
                                                  vatAmount =
                                                      double.parse(value);
                                                  vatPercentageEditingController
                                                      .text = ((vatAmount *
                                                              100) /
                                                          providerData
                                                              .getTotalAmount())
                                                      .toString();
                                                });
                                              }
                                            },
                                            textAlign: TextAlign.right,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      right: 6.0),
                                              hintText: '0',
                                              border: const OutlineInputBorder(
                                                  gapPadding: 0.0,
                                                  borderSide: BorderSide(
                                                      color: kMainColor)),
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                      gapPadding: 0.0,
                                                      borderSide: BorderSide(
                                                          color: kMainColor)),
                                              disabledBorder:
                                                  const OutlineInputBorder(
                                                      gapPadding: 0.0,
                                                      borderSide: BorderSide(
                                                          color: kMainColor)),
                                              focusedBorder:
                                                  const OutlineInputBorder(
                                                      gapPadding: 0.0,
                                                      borderSide: BorderSide(
                                                          color: kMainColor)),
                                              prefixIconConstraints:
                                                  const BoxConstraints(
                                                      maxWidth: 30.0,
                                                      minWidth: 30.0),
                                              prefixIcon: Container(
                                                alignment: Alignment.center,
                                                height: 40,
                                                decoration: const BoxDecoration(
                                                    color: kMainColor,
                                                    borderRadius: BorderRadius
                                                        .only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    4.0),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    4.0))),
                                                child: Text(
                                                  currency,
                                                  style: const TextStyle(
                                                      fontSize: 14.0,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                            textFieldType: TextFieldType.PHONE,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(height: 5),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Color(0xffEAEFFA),
                              border: Border.symmetric(
                                  horizontal: BorderSide(color: Colors.black)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  lang.S.of(context).netAmount,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  double.parse(providerData
                                          .calculateSubtotal1(
                                              discountAmount: discountAmount)
                                          .toStringAsFixed(2))
                                      .round()
                                      .toString(),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  lang.S.of(context).paidAmount,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                SizedBox(
                                  width: context.width() / 4,
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    controller: paidamount,
                                    onChanged: (value) {
                                      if (value == '') {
                                        setState(() {
                                          paidAmount = 0;
                                          dueAmount = 0;
                                        });
                                      } else {
                                        setState(() {
                                          paidAmount = double.parse(value)
                                              .round()
                                              .toDouble();
                                        });
                                      }
                                    },
                                    style: TextStyle(fontSize: 14),
                                    textAlign: TextAlign.right,
                                    decoration: InputDecoration(
                                        hintStyle: TextStyle(
                                            fontSize: 14, color: Colors.black),
                                        hintText: netTotal.round().toString()),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  lang.S.of(context).returnAmount,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  calculateReturnAmount(total: subTotal)
                                      .abs()
                                      .round()
                                      .toString(),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  lang.S.of(context).dueAmount,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  paidamount.text.isEmpty
                                      ? "0.0"
                                      : calculateDueAmount(total: netTotal)
                                          .round()
                                          .toString(),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 1,
                      width: double.infinity,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              lang.S.of(context).paymentTypes,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black54),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const Icon(
                              Icons.wallet,
                              color: Colors.green,
                            )
                          ],
                        ),
                        selected_customer!.customerName == 'Guest'
                            ? DropdownButton(
                                value: dropdownValue,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                items: paymentsTypeList1.map((String items) {
                                  return DropdownMenuItem(
                                    value: items,
                                    child: Text(items),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    dropdownValue = newValue.toString();
                                  });
                                },
                              )
                            : DropdownButton(
                                value: dropdownValue,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                items: paymentsTypeList.map((String items) {
                                  return DropdownMenuItem(
                                    value: items,
                                    child: Text(items),
                                  );
                                }).toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    dropdownValue = newValue.toString();
                                    if (dropdownValue == "Credit/Due") {
                                      paidAmount = 0;
                                      paidamount.text = "0";
                                      setState(() {});
                                    } else if (dropdownValue == "Cash") {
                                      paidAmount = netTotal;
                                      paidamount.text = "";
                                      setState(() {});
                                    }
                                  });
                                },
                              ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 1,
                      width: double.infinity,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 30),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: AppTextField(
                    //         textFieldType: TextFieldType.NAME,
                    //         onChanged: (value) {
                    //           setState(() {});
                    //         },
                    //         decoration: const InputDecoration(
                    //           floatingLabelBehavior: FloatingLabelBehavior.always,
                    //           labelText: 'Description',
                    //           hintText: 'Add Note',
                    //           border: OutlineInputBorder(),
                    //         ),
                    //       ),
                    //     ),
                    //     const SizedBox(width: 20),
                    //     Container(
                    //       height: 60,
                    //       width: 100,
                    //       decoration: BoxDecoration(
                    //           borderRadius:
                    //               const BorderRadius.all(Radius.circular(10)),
                    //           color: Colors.grey.shade200),
                    //       child: Center(
                    //         child: Row(
                    //           mainAxisSize: MainAxisSize.min,
                    //           children: [
                    //             Icon(
                    //               FeatherIcons.camera,
                    //               color: Colors.grey,
                    //             ),
                    //             SizedBox(width: 5),
                    //             Text(
                    //               'Image',
                    //               style:
                    //                   TextStyle(color: Colors.grey, fontSize: 16),
                    //             )
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ).visible(false),

                    Row(
                      children: [
                        Expanded(
                            child: GestureDetector(
                          onTap: () async {
                            const Home().launch(context);
                            // if (providerData.cartItemList.isNotEmpty) {
                            //   if (widget.customerModel.type == 'Guest' && dueAmount > 0) {
                            //     EasyLoading.showError('Due is not available for guest');
                            //   } else {
                            //     try {
                            //       EasyLoading.show(status: 'Loading...', dismissOnTap: false);
                            //
                            //       DatabaseReference ref = FirebaseDatabase.instance.ref("$constUserId/Sales Transition");
                            //
                            //       dueAmount <= 0 ? transitionModel.isPaid = true : transitionModel.isPaid = false;
                            //       dueAmount <= 0 ? transitionModel.dueAmount = 0 : transitionModel.dueAmount = dueAmount;
                            //       returnAmount < 0 ? transitionModel.returnAmount = returnAmount.abs() : transitionModel.returnAmount = 0;
                            //       transitionModel.discountAmount = discountAmount;
                            //       transitionModel.totalAmount = subTotal;
                            //       transitionModel.productList = providerData.cartItemList;
                            //       transitionModel.paymentType = dropdownValue;
                            //       isSubUser ? transitionModel.sellerName = subUserTitle : null;
                            //       transitionModel.invoiceNumber = invoice.toString();
                            //
                            //       int totalQuantity = 0;
                            //       double lossProfit = 0;
                            //       double totalPurchasePrice = 0;
                            //       double totalSalePrice = 0;
                            //       for (var element in transitionModel.productList!) {
                            //         totalPurchasePrice = totalPurchasePrice + (double.parse(element.productPurchasePrice) * element.quantity);
                            //         totalSalePrice = totalSalePrice + (double.parse(element.subTotal) * element.quantity);
                            //
                            //         totalQuantity = totalQuantity + element.quantity;
                            //       }
                            //       lossProfit = ((totalSalePrice - totalPurchasePrice.toDouble()) - double.parse(transitionModel.discountAmount.toString()));
                            //
                            //       transitionModel.totalQuantity = totalQuantity;
                            //       transitionModel.lossProfit = lossProfit;
                            //
                            //       await ref.push().set(transitionModel.toJson());
                            //
                            //       ///__________StockMange_________________________________________________-
                            //
                            //       for (var element in providerData.cartItemList) {
                            //         decreaseStock(element.productId, element.quantity);
                            //       }
                            //
                            //       ///_______invoice_Update_____________________________________________
                            //       final DatabaseReference personalInformationRef =
                            //           // ignore: deprecated_member_use
                            //           FirebaseDatabase.instance.ref().child(constUserId).child('Personal Information');
                            //
                            //       await personalInformationRef.update({'invoiceCounter': invoice + 1});
                            //
                            //       ///________Subscription_____________________________________________________
                            //       decreaseSubscriptionSale();
                            //
                            //       ///_________DueUpdate______________________________________________________
                            //       getSpecificCustomers(phoneNumber: widget.customerModel.phoneNumber, due: transitionModel.dueAmount!.toInt());
                            //       await printerData.getBluetooth();
                            //       PrintTransactionModel model = PrintTransactionModel(transitionModel: transitionModel, personalInformationModel: data);
                            //
                            //       ///_________printer________________________________________
                            //       if (isPrintEnable) {
                            //         if (connected) {
                            //           await printerData.printTicket(printTransactionModel: model, productList: providerData.cartItemList);
                            //           providerData.clearCart();
                            //           consumerRef.refresh(customerProvider);
                            //           consumerRef.refresh(productProvider);
                            //           consumerRef.refresh(salesReportProvider);
                            //           consumerRef.refresh(transitionProvider);
                            //           consumerRef.refresh(profileDetailsProvider);
                            //
                            //           EasyLoading.showSuccess('Added Successfully');
                            //           Future.delayed(const Duration(milliseconds: 500), () {
                            //             const Home().launch(context);
                            //           });
                            //         } else {
                            //           EasyLoading.showSuccess('Added Successfully');
                            //           // ignore: use_build_context_synchronously
                            //           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            //             content: Text("Please Connect The Printer First"),
                            //           ));
                            //           // EasyLoading.showInfo('Please Connect The Printer First');
                            //           showDialog(
                            //               context: context,
                            //               builder: (_) {
                            //                 return WillPopScope(
                            //                   onWillPop: () async => false,
                            //                   child: Dialog(
                            //                     child: SizedBox(
                            //                       child: Column(
                            //                         mainAxisSize: MainAxisSize.min,
                            //                         children: [
                            //                           ListView.builder(
                            //                             shrinkWrap: true,
                            //                             itemCount: printerData.availableBluetoothDevices.isNotEmpty ? printerData.availableBluetoothDevices.length : 0,
                            //                             itemBuilder: (context, index) {
                            //                               return ListTile(
                            //                                 onTap: () async {
                            //                                   String select = printerData.availableBluetoothDevices[index];
                            //                                   List list = select.split("#");
                            //                                   // String name = list[0];
                            //                                   String mac = list[1];
                            //                                   bool isConnect = await printerData.setConnect(mac);
                            //                                   if (isConnect) {
                            //                                     await printerData.printTicket(printTransactionModel: model, productList: transitionModel.productList);
                            //                                     providerData.clearCart();
                            //                                     consumerRef.refresh(customerProvider);
                            //                                     consumerRef.refresh(productProvider);
                            //                                     consumerRef.refresh(salesReportProvider);
                            //                                     consumerRef.refresh(transitionProvider);
                            //                                     consumerRef.refresh(profileDetailsProvider);
                            //                                     EasyLoading.showSuccess('Added Successfully');
                            //                                     Future.delayed(const Duration(milliseconds: 500), () {
                            //                                       const Home().launch(context);
                            //                                     });
                            //                                   }
                            //                                 },
                            //                                 title: Text('${printerData.availableBluetoothDevices[index]}'),
                            //                                 subtitle: const Text("Click to connect"),
                            //                               );
                            //                             },
                            //                           ),
                            //                           const SizedBox(height: 10),
                            //                           Container(
                            //                             height: 1,
                            //                             width: double.infinity,
                            //                             color: Colors.grey,
                            //                           ),
                            //                           const SizedBox(height: 15),
                            //                           GestureDetector(
                            //                             onTap: () {
                            //                               consumerRef.refresh(customerProvider);
                            //                               consumerRef.refresh(productProvider);
                            //                               consumerRef.refresh(salesReportProvider);
                            //                               consumerRef.refresh(transitionProvider);
                            //                               consumerRef.refresh(profileDetailsProvider);
                            //                               const Home().launch(context);
                            //                             },
                            //                             child: const Center(
                            //                               child: Text(
                            //                                 'Cancel',
                            //                                 style: TextStyle(color: kMainColor),
                            //                               ),
                            //                             ),
                            //                           ),
                            //                           const SizedBox(height: 15),
                            //                         ],
                            //                       ),
                            //                     ),
                            //                   ),
                            //                 );
                            //               });
                            //         }
                            //       } else {
                            //         providerData.clearCart();
                            //         consumerRef.refresh(customerProvider);
                            //         consumerRef.refresh(productProvider);
                            //         consumerRef.refresh(salesReportProvider);
                            //         consumerRef.refresh(transitionProvider);
                            //         consumerRef.refresh(profileDetailsProvider);
                            //         EasyLoading.showSuccess('Added Successfully');
                            //         Future.delayed(const Duration(milliseconds: 500), () {
                            //           const SalesReportScreen().launch(context);
                            //         });
                            //       }
                            //       EasyLoading.showSuccess('Added Successfully');
                            //       // const Home().launch(context, isNewTask: true);
                            //     } catch (e) {
                            //       EasyLoading.dismiss();
                            //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                            //     }
                            //   }
                            // } else {
                            //   EasyLoading.showError('Add Product first');
                            // }
                          },
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                            ),
                            child: const Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        )),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              if (providerData.cartItemList.isNotEmpty) {
                                if (selected_customer!.customerName ==
                                        'Guest' &&
                                    dueAmount > 0) {
                                  EasyLoading.showError(
                                      'Due is not available for guest');
                                } else {
                                  if (dueAmount > 0 &&
                                      dropdownValue != "Credit/Due") {
                                    EasyLoading.showError(
                                        'Please select credit due payment method');
                                    return;
                                  }
                                  if (!isClicked) {
                                    try {
                                      setState(() {
                                        isClicked = true;
                                      });
                                      EasyLoading.show(
                                          status: 'Loading...',
                                          dismissOnTap: false);

                                      DatabaseReference ref = FirebaseDatabase
                                          .instance
                                          .ref("$constUserId/Sales Transition");

                                      dueAmount <= 0
                                          ? transitionModel.isPaid = true
                                          : transitionModel.isPaid = false;
                                      dueAmount <= 0
                                          ? transitionModel.dueAmount = 0
                                          : transitionModel.dueAmount =
                                              double.parse(
                                                  dueAmount.toStringAsFixed(2));
                                      returnAmount < 0
                                          ? transitionModel.returnAmount =
                                              returnAmount.abs()
                                          : transitionModel.returnAmount = 0;
                                      transitionModel.discountAmount =
                                          double.parse(discountAmount
                                              .toStringAsFixed(2));
                                      transitionModel.totalAmount =
                                          double.parse(providerData
                                              .calculateSubtotal1(
                                                  discountAmount:
                                                      discountAmount)
                                              .toStringAsFixed(2));
                                      transitionModel.productList =
                                          providerData.cartItemList;
                                      transitionModel.paymentType =
                                          dropdownValue;
                                      transitionModel.vat = vatAmount;
                                      isSubUser
                                          ? transitionModel.sellerName =
                                              subUserTitle
                                          : null;
                                      transitionModel.invoiceNumber =
                                          invoice.toString();
                                      transitionModel.customerName =
                                          // widget.customerModel.type == 'Guest'
                                          //     ? guestname!
                                          //     : widget
                                          //         .customerModel.customerName;
                                          selected_customer!.customerName;

                                      ///__________total LossProfit & quantity________________________________________________________________

                                      int totalQuantity = 0;
                                      double lossProfit = 0;
                                      double totalPurchasePrice = 0;
                                      double totalSalePrice = 0;
                                      for (var element
                                          in transitionModel.productList!) {
                                        totalPurchasePrice =
                                            totalPurchasePrice +
                                                (double.parse(element
                                                        .productPurchasePrice) *
                                                    element.quantity);
                                        totalSalePrice = totalSalePrice +
                                            (double.parse(element.subTotal) *
                                                element.quantity);
                                        print("total purchase price" +
                                            totalPurchasePrice.toString());
                                        print("total sale price" +
                                            totalSalePrice.toString());
                                        totalQuantity =
                                            totalQuantity + element.quantity;
                                      }
                                      lossProfit = ((totalSalePrice -
                                              totalPurchasePrice.toDouble()) -
                                          double.parse(transitionModel
                                              .discountAmount
                                              .toString()));

                                      transitionModel.totalQuantity =
                                          totalQuantity;
                                      transitionModel.paidamountamount =
                                          paidAmount.round();
                                      transitionModel.lossProfit = double.parse(
                                          lossProfit.toStringAsFixed(2));
                                      ref.keepSynced(true);
                                      ref.push().set(transitionModel.toJson());

                                      ///__________StockMange_________________________________________________-

                                      for (var element
                                          in providerData.cartItemList) {
                                        print("sdadsasaddsadas");
                                        log("sdadsasaddsadas");
                                        decreaseStock(element.productId,
                                            element.quantity);
                                      }

                                      ///_______invoice_Update_____________________________________________
                                      final DatabaseReference
                                          personalInformationRef =
                                          FirebaseDatabase.instance
                                              .ref()
                                              .child(constUserId)
                                              .child('Personal Information');
                                      data.invoiceCounter = invoice + 1;
                                      data.note = data.note;
                                      personalInformationRef.keepSynced(true);

                                      personalInformationRef.set(data.toJson());
                                      // await personalInformationRef.update({'invoiceCounter': invoice + 1});

                                      ///________Subscription_____________________________________________________
                                      Subscription.decreaseSubscriptionLimits(
                                          itemType: 'saleNumber',
                                          context: context);
                                      print(
                                          "due---------------------- sasdasasadasdsadsadsafdsaf" +
                                              transitionModel.dueAmount
                                                  .toString());

                                      ///_________DueUpdate______________________________________________________
                                      getSpecificCustomers(
                                          phoneNumber:
                                              selected_customer!.phoneNumber,
                                          due: transitionModel.dueAmount!
                                              .toInt());

                                      ///________Print_______________________________________________________

                                      PrintTransactionModel model =
                                          PrintTransactionModel(
                                              transitionModel: transitionModel,
                                              personalInformationModel: data);

                                      if (isPrintEnable &&
                                          (Theme.of(context).platform ==
                                              TargetPlatform.android)) {
                                        await printerData.getBluetooth();

                                        if (connected) {
                                          await printerData.printTicket(
                                              printTransactionModel: model,
                                              productList:
                                                  providerData.cartItemList);

                                          EasyLoading.showSuccess(
                                              'Added Successfully');
                                          Future.delayed(
                                              const Duration(milliseconds: 500),
                                              () {
                                            // Navigator.pop(context);
                                            const Home().launch(context);
                                            // const SalesReportScreen()
                                            //     .launch(context);
                                          });
                                          providerData.clearCart();
                                          consumerRef.refresh(customerProvider);
                                          consumerRef.refresh(productProvider);
                                          consumerRef
                                              .refresh(salesReportProvider);
                                          consumerRef
                                              .refresh(transitionProvider);
                                          consumerRef
                                              .refresh(profileDetailsProvider);
                                        } else {
                                          EasyLoading.showSuccess(
                                              'Added Successfully');

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'Please Connect The Printer First')));

                                          showDialog(
                                              context: context,
                                              builder: (_) {
                                                return StatefulBuilder(builder:
                                                    (BuildContext context,
                                                        StateSetter setState) {
                                                  return WillPopScope(
                                                    onWillPop: () async =>
                                                        false,
                                                    child: Dialog(
                                                      child: SizedBox(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Container(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.3,
                                                              child: ListView
                                                                  .builder(
                                                                shrinkWrap:
                                                                    true,
                                                                itemCount: printerData
                                                                        .availableBluetoothDevices
                                                                        .isNotEmpty
                                                                    ? printerData
                                                                        .availableBluetoothDevices
                                                                        .length
                                                                    : 0,
                                                                itemBuilder:
                                                                    (context,
                                                                        index) {
                                                                  return ListTile(
                                                                    onTap:
                                                                        () async {
                                                                      String
                                                                          select =
                                                                          printerData
                                                                              .availableBluetoothDevices[index];
                                                                      List
                                                                          list =
                                                                          select
                                                                              .split("#");
                                                                      // String name = list[0];
                                                                      String
                                                                          mac =
                                                                          list[
                                                                              1];
                                                                      bool
                                                                          isConnect =
                                                                          await printerData
                                                                              .setConnect(mac);
                                                                      if (isConnect) {
                                                                        await printerData.printTicket(
                                                                            printTransactionModel:
                                                                                model,
                                                                            productList:
                                                                                transitionModel.productList);
                                                                        providerData
                                                                            .clearCart();
                                                                        consumerRef
                                                                            .refresh(customerProvider);
                                                                        consumerRef
                                                                            .refresh(productProvider);
                                                                        consumerRef
                                                                            .refresh(salesReportProvider);
                                                                        consumerRef
                                                                            .refresh(transitionProvider);
                                                                        consumerRef
                                                                            .refresh(profileDetailsProvider);
                                                                        EasyLoading.showSuccess(
                                                                            'Added Successfully');
                                                                        Future.delayed(
                                                                            const Duration(milliseconds: 500),
                                                                            () {
                                                                          // Navigator.pop(
                                                                          //     context);
                                                                          const Home()
                                                                              .launch(context);
                                                                        });
                                                                      }
                                                                    },
                                                                    title: Text(
                                                                        '${printerData.availableBluetoothDevices[index]}'),
                                                                    subtitle:
                                                                        const Text(
                                                                            "Click to connect"),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 10),
                                                            const Text(
                                                                'Please connect printer'),
                                                            const SizedBox(
                                                                height: 10),
                                                            Container(
                                                              height: 1,
                                                              width: double
                                                                  .infinity,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            const SizedBox(
                                                                height: 15),
                                                            GestureDetector(
                                                              onTap: () {
                                                                // consumerRef.refresh(
                                                                //     customerProvider);
                                                                consumerRef.refresh(
                                                                    productProvider);
                                                                consumerRef.refresh(
                                                                    salesReportProvider);
                                                                consumerRef.refresh(
                                                                    transitionProvider);
                                                                consumerRef.refresh(
                                                                    profileDetailsProvider);
                                                                consumerRef.refresh(
                                                                    customerProvider);

                                                                providerData
                                                                    .cartItemList
                                                                    .clear();

                                                                // Navigator.pop(
                                                                //     context);
                                                                // setState(() {
                                                                //   invoice = data
                                                                //       .invoiceCounter!
                                                                //       .toInt();
                                                                // });
                                                                print("invoiceno+" +
                                                                    invoice
                                                                        .toString());
                                                                const Home()
                                                                    .launch(
                                                                        context);
                                                              },
                                                              child:
                                                                  const Center(
                                                                child: Text(
                                                                  'Cancel',
                                                                  style: TextStyle(
                                                                      color:
                                                                          kMainColor),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 15),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                });
                                              });
                                        }
                                      } else {
                                        EasyLoading.showSuccess(
                                            'Added Successfully');
                                        Future.delayed(
                                            const Duration(milliseconds: 500),
                                            () {
                                          // Navigator.pop(context);
                                          // providerData.cartItemList.clear();
                                          // setState(() {
                                          //   invoice =
                                          //       data.invoiceCounter!.toInt();
                                          // });
                                          print("invoiceno+" +
                                              invoice.toString());
                                          const Home().launch(context);
                                        });
                                        providerData.clearCart();
                                        consumerRef.refresh(customerProvider);
                                        consumerRef.refresh(productProvider);
                                        consumerRef
                                            .refresh(salesReportProvider);
                                        consumerRef.refresh(transitionProvider);
                                        consumerRef
                                            .refresh(profileDetailsProvider);
                                      }
                                    } catch (e) {
                                      EasyLoading.dismiss();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(e.toString())));
                                    }
                                  }
                                }
                              } else {
                                EasyLoading.showError('Add product first');
                              }
                            },
                            child: Container(
                              height: 60,
                              decoration: const BoxDecoration(
                                color: kMainColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              child: const Center(
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        }, error: (e, stack) {
          return Center(
            child: Text(e.toString()),
          );
        }, loading: () {
          return const Center(child: CircularProgressIndicator());
        });
      }),
    );
  }

  void decreaseStock(String productCode, int quantity) async {
    final ref = FirebaseDatabase.instance.ref('$constUserId/Products/');
    ref.keepSynced(true);
    ref.orderByKey().get().then((value) {
      for (var element in value.children) {
        var data = jsonDecode(jsonEncode(element.value));
        if (data['productCode'] == productCode) {
          String? key = element.key;
          int previousStock =
              element.child('productStock').value.toString().toInt();
          int remainStock = previousStock - quantity;
          log("stock" + previousStock.toString());
          previousStock != "" || previousStock != null
              ? ref.child(key!).update({
                  'productStock':
                      '${element.child('productStock').value == "" ? '' : remainStock}'
                })
              : ref.child(key!).update({'productStock': ''});
        }
      }
    });

    // var data = await ref.orderByChild('productCode').equalTo(productCode).once();
    // String productPath = data.snapshot.value.toString().substring(1, 21);
    //
    // var data1 = await ref.child('$productPath/productStock').once();
    // int stock = int.parse(data1.snapshot.value.toString());
    // int remainStock = stock - quantity;
    //
    // ref.child(productPath).update({'productStock': '$remainStock'});
  }

  // void decreaseSubscriptionSale() async {
  //   final ref = FirebaseDatabase.instance.ref('$constUserId/Subscription/saleNumber');
  //   var data = await ref.once();
  //   int beforeSale = int.parse(data.snapshot.value.toString());
  //   int afterSale = beforeSale - 1;
  //   beforeSale != -202 ? FirebaseDatabase.instance.ref('$constUserId/Subscription').update({'saleNumber': afterSale}) : null;
  //
  //   final ref = FirebaseDatabase.instance.ref(constUserId).child('Subscription');
  //   ref.keepSynced(true);
  //   ref.child(itemType).get().then((value){
  //     print(value.value);
  //     int beforeAction = int.parse(value.value.toString());
  //     int afterAction = beforeAction - 1;
  //     ref.update({itemType: afterAction});
  //   });
  // }

  void getSpecificCustomers(
      {required String phoneNumber, required int due}) async {
    final ref = FirebaseDatabase.instance.ref('$constUserId/Customers/');
    ref.keepSynced(true);
    String? key;

    ref.orderByKey().get().then((value) {
      for (var element in value.children) {
        var data = jsonDecode(jsonEncode(element.value));
        if (data['phoneNumber'] == phoneNumber) {
          key = element.key;
          int previousDue = element.child('due').value.toString().toInt();
          int totalDue = previousDue + due;
          ref.child(key!).update({'due': '$totalDue'});
        }
      }
    });
    // var data1 = await ref.child('$key/due').once();
    // int previousDue = data1.snapshot.value.toString().toInt();
    //
    // int totalDue = previousDue + due;
    // ref.child(key!).update({'due': '$totalDue'});
  }

  showAlertDialog(BuildContext context, Function? ontap) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("No"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Yes"),
      onPressed: () {
        ontap!();
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Exit Sales"),
      content: Text("Are you sure want to exit"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
