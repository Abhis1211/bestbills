import 'dart:io';
import 'dart:convert';
import 'brands_list.dart';
import '../Home/home.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../Home/home_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../Provider/profile_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../GlobalComponents/category_list.dart';
import 'package:mobile_pos/model/product_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:firebase_database/firebase_database.dart';
import '../../GlobalComponents/Model/category_model.dart';
import 'package:mobile_pos/Provider/product_provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
// ignore_for_file: unused_result

// ignore: must_be_immutable
class UpdateProduct extends StatefulWidget {
  UpdateProduct({Key? key, this.productModel}) : super(key: key);

  ProductModel? productModel;

  @override
  // ignore: library_private_types_in_public_api
  _UpdateProductState createState() => _UpdateProductState();
}

class _UpdateProductState extends State<UpdateProduct> {
  late String productKey;
  ProductModel? updatedProductModel;
  GetCategoryAndVariationModel data =
      GetCategoryAndVariationModel(variations: [], categoryName: '');
  bool showProgress = false;
  final ImagePicker _picker = ImagePicker();
  XFile? pickedImage;
  File imageFile = File('No File');
  String imagePath = 'No Data';
  List<String> codeList = [];
  List<String> productNameList = [];
  TextEditingController vatPercentageEditingController =
      TextEditingController();
  TextEditingController vatAmountEditingController = TextEditingController();
  double percentage = 0;
  int loop = 0;
  // double vatAmount = 0;
  double GStamount = 0.0;
  var dropdownvalue = '0';
  var productcode = "";
  // List of items in our dropdown menu
  var items = ['0', '3', '5', '12', '18', '28'];
  String productPicture =
      'https://firebasestorage.googleapis.com/v0/b/maanpos.appspot.com/o/Customer%20Picture%2FNo_Image_Available.jpeg?alt=media&token=3de0d45e-0e4a-4a7b-b115-9d6722d5031f';

  Future<void> uploadFile(String filePath) async {
    File file = File(filePath);
    try {
      EasyLoading.show(
        status: 'Uploading... ',
        dismissOnTap: false,
      );
      var snapshot = await FirebaseStorage.instance
          .ref('Product Picture/${DateTime.now().millisecondsSinceEpoch}')
          .putFile(file);
      var url = await snapshot.ref.getDownloadURL();
      setState(() {
        updatedProductModel!.productPicture = url.toString();
      });
    } on firebase_core.FirebaseException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.code.toString())));
    }
  }

  void getProductKey(String code) {
    // ignore: unused_local_variable
    List<ProductModel> productList = [];
    final ref = FirebaseDatabase.instance.ref(constUserId).child('Products');
    ref.keepSynced(true);
    ref.orderByKey().get().then((value) {
      for (var element in value.children) {
        var data = jsonDecode(jsonEncode(element.value));
        if (data['productCode'].toString() == code) {
          productKey = element.key.toString();
        }
      }
    });
  }

  void deleteProduct({required WidgetRef wRef}) {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("$constUserId/Products/$productKey");
    ref.keepSynced(true);

    ref.remove();
    wRef.refresh(productProvider);
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;
    if (codeList.contains(barcodeScanRes)) {
      EasyLoading.showError('This Product Already added!');
    } else {
      if (barcodeScanRes != '-1') {
        setState(() {
          productcode = barcodeScanRes;
        });
        // print("product bar code"+ productCode.toString());
      }
    }
  }

  @override
  void initState() {
    getProductKey(widget.productModel!.productCode);
    setState(() {
      dropdownvalue = widget.productModel!.productGst;
      productcode = widget.productModel!.productCode;
      GStamount = double.parse(widget.productModel!.productGst) *
          double.parse(widget.productModel!.productSalePrice) /
          100;
      // updatedProductModel!.productGst = widget.productModel!.productGst;
    });
    updatedProductModel = widget.productModel!;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    loop++;
    return Consumer(builder: (context, ref, __) {
      final personalData = ref.watch(profileDetailsProvider);
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          title: Text(
            lang.S.of(context).updateProduct,
            style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context1) {
                    return Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Center(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 20),
                                Text(
                                  lang.S.of(context).youWantTodeletetheProduct,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      child: ButtonGlobalWithoutIcon(
                                        buttontext: lang.S.of(context).cancel,
                                        buttonDecoration: kButtonDecoration
                                            .copyWith(color: Colors.green),
                                        onPressed: (() {
                                          Navigator.pop(context1);
                                        }),
                                        buttonTextColor: Colors.white,
                                      ),
                                    ),
                                    Expanded(
                                      child: ButtonGlobalWithoutIcon(
                                        buttontext: lang.S.of(context).delete,
                                        buttonDecoration: kButtonDecoration
                                            .copyWith(color: Colors.red),
                                        onPressed: (() {
                                          deleteProduct(wRef: ref);
                                          Future.delayed(
                                              const Duration(milliseconds: 500),
                                              () {
                                            ref.refresh(productProvider);
                                            Navigator.pop(context1);
                                            Navigator.pop(context);
                                          });
                                        }),
                                        buttonTextColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
            )
          ],
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: Column(
              children: [
                FirebaseAnimatedList(
                  shrinkWrap: true,
                  query: FirebaseDatabase.instance
                      // ignore: deprecated_member_use
                      .reference()
                      .child(constUserId)
                      .child('Products'),
                  itemBuilder: (context, snapshot, animation, index) {
                    final json = snapshot.value as Map<dynamic, dynamic>;
                    final product = ProductModel.fromJson(json);
                    if (product.productCode.isNotEmpty) {
                      codeList.add(product.productCode.toLowerCase());
                    }

                    productNameList.add(product.productName.toLowerCase());
                    return Container();
                  },
                ).visible(loop <= 1),
                const SizedBox(height: 10.0),
                Visibility(
                  visible: showProgress,
                  child: const CircularProgressIndicator(
                    color: kMainColor,
                    strokeWidth: 5.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: AppTextField(
                    initialValue: widget.productModel!.productName,
                    textFieldType: TextFieldType.NAME,
                    onChanged: (value) {
                      setState(() {
                        updatedProductModel!.productName = value;
                      });
                    },
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: lang.S.of(context).productName,
                      hintText: 'Smart Watch',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    height: 60.0,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(color: kGreyTextColor),
                    ),
                    child: InkWell(
                      onTap: () async {
                        data = await const CategoryList().launch(context);
                        setState(() {
                          widget.productModel!.productCategory =
                              data.categoryName;
                        });
                      },
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 10.0,
                          ),
                          Text(widget.productModel!.productCategory),
                          const Spacer(),
                          const Icon(Icons.keyboard_arrow_down),
                          const SizedBox(
                            width: 10.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          initialValue: widget.productModel!.size,
                          textFieldType: TextFieldType.NAME,
                          onChanged: (value) {
                            setState(() {
                              updatedProductModel!.size = value;
                            });
                          },
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Size',
                            hintText: 'M',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ).visible(widget.productModel!.size != 'Not Provided'),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          initialValue: widget.productModel!.color,
                          textFieldType: TextFieldType.NAME,
                          onChanged: (value) {
                            setState(() {
                              updatedProductModel!.color = value;
                            });
                          },
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: lang.S.of(context).color,
                            hintText: 'Green',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ).visible(widget.productModel!.color != 'Not Provided'),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          initialValue: widget.productModel!.weight,
                          textFieldType: TextFieldType.NAME,
                          onChanged: (value) {
                            setState(() {
                              updatedProductModel!.weight = value;
                            });
                          },
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: lang.S.of(context).weight,
                            hintText: '10 inc',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ).visible(widget.productModel!.weight != 'Not Provided'),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          initialValue: widget.productModel!.capacity,
                          textFieldType: TextFieldType.NAME,
                          onChanged: (value) {
                            setState(() {
                              updatedProductModel!.capacity = value;
                            });
                          },
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: lang.S.of(context).capacity,
                            hintText: '244 liter',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ).visible(widget.productModel!.capacity != 'Not Provided'),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: AppTextField(
                    initialValue: widget.productModel!.type,
                    textFieldType: TextFieldType.NAME,
                    onChanged: (value) {
                      setState(() {
                        updatedProductModel!.type = value;
                      });
                    },
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: lang.S.of(context).type,
                      hintText: 'Usb C',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ).visible(widget.productModel!.type != 'Not Provided'),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    height: 60.0,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(color: kGreyTextColor),
                    ),
                    child: InkWell(
                      onTap: () async {
                        String data = await const BrandsList().launch(context);
                        setState(() {
                          widget.productModel!.brandName = data;
                        });
                      },
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 10.0,
                          ),
                          Text(widget.productModel!.brandName),
                          const Spacer(),
                          const Icon(Icons.keyboard_arrow_down),
                          const SizedBox(
                            width: 10.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          readOnly: true,
                          textFieldType: TextFieldType.NAME,
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: lang.S.of(context).productCode,
                            hintText: productcode,
                            hintStyle: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Colors.black),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          height: 60.0,
                          width: 100.0,
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: kGreyTextColor),
                          ),
                          child: GestureDetector(
                            onTap: (){
                              scanBarcodeNormal();
                            },
                            child: const Image(
                              image: AssetImage('images/barcode.png'),
                            ),
                        ),
                      ),
                      )
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          initialValue: widget.productModel!.productStock,
                          onChanged: (value) {
                            setState(() {
                              updatedProductModel!.productStock = value;
                            });
                          },
                          textFieldType: TextFieldType.PHONE,
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: lang.S.of(context).stock,
                            hintText: '20',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          height: 60.0,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(color: kGreyTextColor),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 10.0,
                              ),
                              Text(widget.productModel!.productUnit),
                              const Spacer(),
                              const Icon(Icons.keyboard_arrow_down),
                              const SizedBox(
                                width: 10.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          initialValue:
                              widget.productModel!.productPurchasePrice,
                          textFieldType: TextFieldType.PHONE,
                          onChanged: (value) {
                            setState(() {
                              updatedProductModel!.productPurchasePrice = value;
                            });
                          },
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: lang.S.of(context).purchasePrice,
                            hintText: '$currency 300.90',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          initialValue: widget.productModel!.productSalePrice,
                          textFieldType: TextFieldType.PHONE,
                          onChanged: (value) {
                            setState(() {
                              updatedProductModel!.productSalePrice = value;
                            });
                            GStamount =
                                double.parse(updatedProductModel!.productGst) *
                                    double.parse(
                                        updatedProductModel!.productSalePrice) /
                                    100;
                            print("GStmount" + GStamount.toString());
                          },
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: lang.S.of(context).salePrice,
                            hintText: '$currency 234.09',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Row(
                //   children: [
                //     Expanded(
                //       child: Padding(
                //         padding: const EdgeInsets.all(10.0),
                //         child: AppTextField(
                //           initialValue: widget.productModel!.productWholeSalePrice,
                //           textFieldType: TextFieldType.PHONE,
                //           onChanged: (value) {
                //             setState(() {
                //               updatedProductModel.productWholeSalePrice = value;
                //             });
                //           },
                //           decoration: InputDecoration(
                //             floatingLabelBehavior: FloatingLabelBehavior.always,
                //             labelText: lang.S.of(context).wholeSalePrice,
                //             hintText: '$currency 155',
                //             border: const OutlineInputBorder(),
                //           ),
                //         ),
                //       ),
                //     ),
                //     Expanded(
                //       child: Padding(
                //         padding: const EdgeInsets.all(10.0),
                //         child: AppTextField(
                //           initialValue: widget.productModel!.productDealerPrice,
                //           textFieldType: TextFieldType.PHONE,
                //           onChanged: (value) {
                //             setState(() {
                //               updatedProductModel.productDealerPrice = value;
                //             });
                //           },
                //           decoration: InputDecoration(
                //             floatingLabelBehavior: FloatingLabelBehavior.always,
                //             labelText: lang.S.of(context).dealerPrice,
                //             hintText: '$currency 130',
                //             border: const OutlineInputBorder(),
                //           ),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                personalData.when(data: (data) {
                  if (data.gstenable == true)
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GST',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10)),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              width: MediaQuery.of(context).size.width,
                              child: DropdownButton<String>(
                                // Initial Value
                                underline: SizedBox(),
                                value: dropdownvalue,
                                // Down Arrow Icon
                                icon: Icon(Icons.keyboard_arrow_down),
                                // Array list of items
                                items: items.map((String items) {
                                  return DropdownMenuItem<String>(
                                    alignment: Alignment.centerLeft,
                                    value: items,
                                    child: Text(items + " %"),
                                  );
                                }).toList(),
                                isExpanded: true,
                                // After selecting the desired option,it will
                                // change button value to selected value
                                onChanged: (val) {
                                  print("sadsdsa");
                                  setState(() {
                                    dropdownvalue = val!;
                                    // vatPercentageEditingController.text = val;
                                    updatedProductModel!.productGst = val;
                                    GStamount = double.parse(
                                            updatedProductModel!.productGst
                                                .toString()) *
                                        double.parse(widget
                                            .productModel!.productSalePrice
                                            .toString()) /
                                        100;
                                  });

                                  print("ashd" + GStamount.toString());
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  // Padding(
                  //   padding:
                  //       EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  //       const Text(
                  //         'GST',
                  //         style: TextStyle(fontSize: 14),
                  //       ),
                  //       Row(
                  //         children: [
                  //           SizedBox(
                  //             width: context.width() / 4,
                  //             height: 40.0,
                  //             child: Center(
                  //               child: AppTextField(
                  //                 textStyle: TextStyle(fontSize: 14),
                  //                 initialValue:
                  //                     updatedProductModel.productGst,
                  //                 inputFormatters: [
                  //                   FilteringTextInputFormatter.allow(
                  //                       RegExp(r'^\d*\.?\d{0,2}'))
                  //                 ],
                  //                 // controller: vatPercentageEditingController,
                  //                 onChanged: (value) {
                  //                   if (value == '') {
                  //                     setState(() {
                  //                       percentage = 0.0;
                  //                       vatAmountEditingController.text =
                  //                           0.toString();
                  //                       vatAmount = 0;
                  //                     });
                  //                   } else {
                  //                     setState(() {
                  //                       vatAmount = (value.toDouble() / 100) *
                  //                           double.parse(updatedProductModel
                  //                               .productPurchasePrice
                  //                               .toString());
                  //                       // providerDatacart
                  //                       //     .getTotalAmount()
                  //                       //     .toDouble();
                  //                       updatedProductModel.productGst =
                  //                           value;
                  //                       vatAmountEditingController.text =
                  //                           vatAmount.toStringAsFixed(2);
                  //                     });
                  //                   }
                  //                 },
                  //                 textAlign: TextAlign.right,
                  //                 decoration: InputDecoration(
                  //                   contentPadding:
                  //                       const EdgeInsets.only(right: 6.0),
                  //                   hintText: '0',
                  //                   border: const OutlineInputBorder(
                  //                       gapPadding: 0.0,
                  //                       borderSide: BorderSide(
                  //                           color: Color(0xFFff5f00))),
                  //                   enabledBorder: const OutlineInputBorder(
                  //                       gapPadding: 0.0,
                  //                       borderSide: BorderSide(
                  //                           color: Color(0xFFff5f00))),
                  //                   disabledBorder: const OutlineInputBorder(
                  //                       gapPadding: 0.0,
                  //                       borderSide: BorderSide(
                  //                           color: Color(0xFFff5f00))),
                  //                   focusedBorder: const OutlineInputBorder(
                  //                       gapPadding: 0.0,
                  //                       borderSide: BorderSide(
                  //                           color: Color(0xFFff5f00))),
                  //                   prefixIconConstraints:
                  //                       const BoxConstraints(
                  //                           maxWidth: 30.0, minWidth: 30.0),
                  //                   prefixIcon: Container(
                  //                     padding: const EdgeInsets.only(
                  //                         top: 8.0, left: 8.0),
                  //                     height: 40,
                  //                     decoration: const BoxDecoration(
                  //                         color: Color(0xFFff5f00),
                  //                         borderRadius: BorderRadius.only(
                  //                             topLeft: Radius.circular(4.0),
                  //                             bottomLeft:
                  //                                 Radius.circular(4.0))),
                  //                     child: const Text(
                  //                       '%',
                  //                       style: TextStyle(
                  //                           fontSize: 18.0,
                  //                           color: Colors.white),
                  //                     ),
                  //                   ),
                  //                 ),
                  //                 textFieldType: TextFieldType.PHONE,
                  //               ),
                  //             ),
                  //           ),
                  //           const SizedBox(
                  //             width: 4.0,
                  //           ),
                  //           SizedBox(
                  //             width: context.width() / 4,
                  //             height: 40.0,
                  //             child: Center(
                  //               child: AppTextField(
                  //                 textStyle: const TextStyle(fontSize: 14),
                  //                 inputFormatters: [
                  //                   FilteringTextInputFormatter.allow(
                  //                       RegExp(r'^\d*\.?\d{0,2}'))
                  //                 ],
                  //                 controller: vatAmountEditingController,
                  //                 onChanged: (value) {
                  //                   if (value == '') {
                  //                     setState(() {
                  //                       vatAmount = 0;
                  //                       vatPercentageEditingController
                  //                           .clear();
                  //                     });
                  //                   } else {
                  //                     setState(() {
                  //                       vatAmount = double.parse(value);
                  //                       vatPercentageEditingController
                  //                           .text = ((vatAmount * 100) /
                  //                               double.parse(
                  //                                   updatedProductModel
                  //                                       .productPurchasePrice
                  //                                       .toString()))
                  //                           .toString();
                  //                     });
                  //                   }
                  //                 },
                  //                 textAlign: TextAlign.right,
                  //                 decoration: InputDecoration(
                  //                   contentPadding:
                  //                       const EdgeInsets.only(right: 6.0),
                  //                   hintText: '0',
                  //                   border: const OutlineInputBorder(
                  //                       gapPadding: 0.0,
                  //                       borderSide:
                  //                           BorderSide(color: kMainColor)),
                  //                   enabledBorder: const OutlineInputBorder(
                  //                       gapPadding: 0.0,
                  //                       borderSide:
                  //                           BorderSide(color: kMainColor)),
                  //                   disabledBorder: const OutlineInputBorder(
                  //                       gapPadding: 0.0,
                  //                       borderSide:
                  //                           BorderSide(color: kMainColor)),
                  //                   focusedBorder: const OutlineInputBorder(
                  //                       gapPadding: 0.0,
                  //                       borderSide:
                  //                           BorderSide(color: kMainColor)),
                  //                   prefixIconConstraints:
                  //                       const BoxConstraints(
                  //                           maxWidth: 30.0, minWidth: 30.0),
                  //                   prefixIcon: Container(
                  //                     alignment: Alignment.center,
                  //                     height: 40,
                  //                     decoration: const BoxDecoration(
                  //                         color: kMainColor,
                  //                         borderRadius: BorderRadius.only(
                  //                             topLeft: Radius.circular(4.0),
                  //                             bottomLeft:
                  //                                 Radius.circular(4.0))),
                  //                     child: Text(
                  //                       currency,
                  //                       style: const TextStyle(
                  //                           fontSize: 14.0,
                  //                           color: Colors.white),
                  //                     ),
                  //                   ),
                  //                 ),
                  //                 textFieldType: TextFieldType.PHONE,
                  //               ),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // );

                  else
                    return Container();
                }, error: (Object error, StackTrace stackTrace) {
                  return Container();
                }, loading: () {
                  return Container();
                }),
                Row(
                  children: [
                    // Expanded(
                    //     child: Padding(
                    //   padding: const EdgeInsets.all(10.0),
                    //   child: AppTextField(
                    //     textFieldType: TextFieldType.PHONE,
                    //     initialValue: widget.productModel!.productDiscount,
                    //     onChanged: (value) {
                    //       setState(() {
                    //         updatedProductModel.productDiscount = value;
                    //       });
                    //     },
                    //     decoration: InputDecoration(
                    //       floatingLabelBehavior: FloatingLabelBehavior.always,
                    //       labelText: lang.S.of(context).discount,
                    //       hintText: '$currency 34.90',
                    //       border: const OutlineInputBorder(),
                    //     ),
                    //   ),
                    // )),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          initialValue:
                              widget.productModel!.productManufacturer,
                          textFieldType: TextFieldType.NAME,
                          onChanged: (value) {
                            setState(() {
                              updatedProductModel!.productManufacturer = value;
                            });
                          },
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: lang.S.of(context).manufacturer,
                            hintText: 'Apple',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            // ignore: sized_box_for_whitespace
                            child: Container(
                              height: 200.0,
                              width: MediaQuery.of(context).size.width - 80,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        pickedImage = await _picker.pickImage(
                                            source: ImageSource.gallery);
                                        setState(() {
                                          imageFile = File(pickedImage!.path);
                                          imagePath = pickedImage!.path;
                                        });
                                        Future.delayed(
                                            const Duration(milliseconds: 100),
                                            () {
                                          Navigator.pop(context);
                                        });
                                      },
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.photo_library_rounded,
                                            size: 60.0,
                                            color: kMainColor,
                                          ),
                                          Text(
                                            'Gallery',
                                            style: GoogleFonts.inter(
                                              fontSize: 20.0,
                                              color: kMainColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 40.0,
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        pickedImage = await _picker.pickImage(
                                            source: ImageSource.camera);
                                        setState(() {
                                          imageFile = File(pickedImage!.path);
                                          imagePath = pickedImage!.path;
                                        });
                                        Future.delayed(
                                            const Duration(milliseconds: 100),
                                            () {
                                          Navigator.pop(context);
                                        });
                                      },
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.camera,
                                            size: 60.0,
                                            color: kGreyTextColor,
                                          ),
                                          Text(
                                            lang.S.of(context).camera,
                                            style: GoogleFonts.inter(
                                              fontSize: 20.0,
                                              color: kGreyTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                  },
                  child: Stack(
                    children: [
                      Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black54, width: 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(120)),
                          image: imagePath == 'No Data'
                              ? DecorationImage(
                                  image: NetworkImage(widget.productModel!
                                                  .productPicture ==
                                              "" ||
                                          widget.productModel!.productPicture ==
                                              null
                                      ? productPicture
                                      : widget.productModel!.productPicture),
                                  fit: BoxFit.cover,
                                )
                              : DecorationImage(
                                  image: FileImage(imageFile),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(120)),
                            color: kMainColor,
                          ),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ButtonGlobalWithoutIcon(
                  buttontext: lang.S.of(context).saveNPublish,
                  buttonDecoration:
                      kButtonDecoration.copyWith(color: kMainColor),
                  onPressed: () async {
                    if (updatedProductModel!.productName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter product name'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      return;
                    }

                    if (productCategory == "Select Product Category") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please Select Product Category'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      return;
                    }
                    // if (updatedProductModel.productStock.isEmpty) {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     const SnackBar(
                    //       content: Text('Please Enter Stock'),
                    //       duration: Duration(seconds: 1),
                    //     ),
                    //   );
                    //   return;
                    // }

                    if (updatedProductModel!.productUnit == "Select Unit" ||
                        updatedProductModel!.productUnit == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select unit'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      return;
                    }
                    if (double.parse(updatedProductModel!.productSalePrice) <
                        double.parse(
                            updatedProductModel!.productPurchasePrice)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'MRP price must be grater then purchase price'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      return;
                    }

                    if (updatedProductModel!.productSalePrice.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please Enter sale price'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      return;
                    }
                    try {
                      imagePath == 'No Data'
                          ? null
                          : await uploadFile(imagePath);
                      EasyLoading.show(
                          status: 'Loading...', dismissOnTap: false);
                      DatabaseReference ref = FirebaseDatabase.instance
                          .ref("$constUserId/Products/$productKey");
                      ref.keepSynced(true);
                      ref.update({
                        'productName': updatedProductModel!.productName,
                        'productCategory': updatedProductModel!.productCategory,
                        'size': updatedProductModel!.size,
                        'color': updatedProductModel!.color,
                        'weight': updatedProductModel!.weight,
                        'capacity': updatedProductModel!.capacity,
                        'type': updatedProductModel!.type,
                        'brandName': updatedProductModel!.brandName,
                        // 'productCode': updatedProductModel!.productCode,
                        'productCode': productcode,
                        'productStock': updatedProductModel!.productStock,
                        'productUnit': updatedProductModel!.productUnit,
                        'productSalePrice':
                            updatedProductModel!.productSalePrice,
                        'productPurchasePrice':
                            updatedProductModel!.productPurchasePrice,
                        'productDiscount': updatedProductModel!.productDiscount,
                        'productWholeSalePrice':
                            updatedProductModel!.productWholeSalePrice,
                        'productDealerPrice':
                            updatedProductModel!.productDealerPrice,
                        'productManufacturer':
                            updatedProductModel!.productManufacturer,
                        'productPicture': updatedProductModel!.productPicture,
                        'productGst': updatedProductModel!.productGst,
                        'productGstamount': GStamount
                      });
                      EasyLoading.showSuccess('Upadted Successfully',
                          duration: const Duration(milliseconds: 500));
                      //ref.refresh(productProvider);
                      Future.delayed(const Duration(milliseconds: 100), () {
                        const Home().launch(context, isNewTask: true);
                      });
                    } catch (e) {
                      EasyLoading.dismiss();
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  buttonTextColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
