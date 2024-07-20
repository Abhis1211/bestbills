import 'dart:io';
import '../Home/home.dart';
import '../../constant.dart';
import '../../currency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../Provider/add_to_cart.dart';
import '../../Provider/profile_provider.dart';
import '../../Provider/product_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_pos/model/product_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:firebase_database/firebase_database.dart';
import '../../GlobalComponents/Model/category_model.dart';
import 'package:mobile_pos/Screens/Products/unit_list.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile_pos/Screens/Products/brands_list.dart';
import 'package:mobile_pos/repository/subscription_repo.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:mobile_pos/GlobalComponents/category_list.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
// ignore_for_file: unused_result, use_build_context_synchronously

// ignore: must_be_immutable
class AddProduct extends StatefulWidget {
  AddProduct({Key? key, this.catName, this.unitsName, this.brandName})
      : super(key: key);

  // ignore: prefer_typing_uninitialized_variables
  var catName;

  // ignore: prefer_typing_uninitialized_variables
  var unitsName;

  // ignore: prefer_typing_uninitialized_variables
  var brandName;

  @override
  // ignore: library_private_types_in_public_api
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  bool _switchValuestock = false;
  GetCategoryAndVariationModel data =
      GetCategoryAndVariationModel(variations: [], categoryName: '');
  String productCategory = 'Select Product Category';
  String brandName = 'Select Brand';
  String productUnit = 'Select Unit';
  var gstenable = false;
  String productName = "",
      productStock = "",
      productSalePrice = "",
      productPurchasePrice = "",
      productCode = "";
  String productWholeSalePrice = '0';
  String productDealerPrice = '0';
  String productPicture = '';
  String productDiscount = 'Not Provided';
  String productManufacturer = 'Not Provided';
  String size = 'Not Provided';
  String color = 'Not Provided';
  String weight = 'Not Provided';
  String capacity = 'Not Provided';
  String type = 'Not Provided';
  var dropdownvalue = '0';

  // List of items in our dropdown menu
  var items = ['0', '3', '5', '12', '18', '28'];
  List<String> catItems = [];
  bool showProgress = false;
  double progress = 0.0;
  final ImagePicker _picker = ImagePicker();
  XFile? pickedImage;
  List<String> codeList = [];
  List<String> productNameList = [];
  String promoCodeHint = 'Enter Product Code';
  TextEditingController productCodeController = TextEditingController();
  var isload = true;
  int loop = 0;
  File imageFile = File('No File');
  String imagePath = 'No Data';
  TextEditingController vatPercentageEditingController =
      TextEditingController(text: "0");
  TextEditingController vatAmountEditingController = TextEditingController();
  double percentage = 0;
  double vatAmount = 0;
  double GstAmount = 0;
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
        productPicture = url.toString();
      });
    } on firebase_core.FirebaseException catch (e) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.code.toString())));
    }
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
          productCode = barcodeScanRes;
          promoCodeHint = barcodeScanRes;
          productCodeController.text = productCode;
        });
        
        print("product bar code"+ productCode.toString());
      }
    }
  }

  @override
  void initState() {
    vatPercentageEditingController.text = dropdownvalue;
    widget.catName == null
        ? productCategory = 'Select Product Category'
        : productCategory = widget.catName;
    widget.unitsName == null
        ? productUnit = 'Select Unit'
        : productUnit = widget.unitsName;
    widget.brandName == null
        ? brandName = 'Select Brands'
        : brandName = widget.brandName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    loop++;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          lang.S.of(context).addNewProduct,
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer(builder: (context, ref, __) {
        final providerData = ref.watch(productProvider);
        final providerDatacart = ref.watch(cartNotifier);
        final personalData = ref.watch(profileDetailsProvider);
        if (isload == true) {
          Future.delayed(Duration(milliseconds: 500), () {
            ref.refresh(profileDetailsProvider);
          });
          isload = false;
        }

        return SingleChildScrollView(
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
                const SizedBox(
                  height: 10.0,
                ),
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
                    textFieldType: TextFieldType.NAME,
                    onChanged: (value) {
                      setState(() {
                        productName = value;
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
                        data = await CategoryList().launch(context);

                        setState(() {
                          productCategory = data.categoryName;
                        });
                      },
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 10.0,
                          ),
                          Text(productCategory),
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
                    data.variations != null
                        ? Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: AppTextField(
                                textFieldType: TextFieldType.NAME,
                                onChanged: (value) {
                                  setState(() {
                                    size = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  labelText: lang.S.of(context).size,
                                  hintText: 'M',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ).visible(data.variations.contains('Size'))
                        : Container(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          textFieldType: TextFieldType.NAME,
                          onChanged: (value) {
                            setState(() {
                              color = value;
                            });
                          },
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: lang.S.of(context).color,
                            hintText: 'Green',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ).visible(data.variations.contains('Color')),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          textFieldType: TextFieldType.NAME,
                          onChanged: (value) {
                            setState(() {
                              weight = value;
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
                    ).visible(data.variations.contains('Weight')),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          textFieldType: TextFieldType.NAME,
                          onChanged: (value) {
                            setState(() {
                              capacity = value;
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
                    ).visible(data.variations.contains('Capacity')),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: AppTextField(
                    textFieldType: TextFieldType.NAME,
                    onChanged: (value) {
                      setState(() {
                        type = value;
                      });
                    },
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: lang.S.of(context).type,
                      hintText: 'Usb C',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ).visible(data.variations.contains('Type')),
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
                          brandName = data;
                        });
                      },
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 10.0,
                          ),
                          Text(brandName == null
                              ? "Select Brand"
                              : brandName.toString()),
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
                          controller: productCodeController,
                          textFieldType: TextFieldType.NAME,
                          onChanged: (value) {
                            setState(() {
                              productCode = value;
                              promoCodeHint = value;
                            });
                          },
                          onFieldSubmitted: (value) {
                            if (codeList.contains(value)) {
                              EasyLoading.showError(
                                  'This Product Already added!');
                              productCodeController.clear();
                            } else {
                              setState(() {
                                productCode = value;
                                promoCodeHint = value;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: lang.S.of(context).productCode,
                            hintText: promoCodeHint,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: GestureDetector(
                          onTap: () => scanBarcodeNormal(),
                          child: Container(
                            height: 60.0,
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
                ListTile(
                    title: Text(
                      "Add Stock",
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 18.0,
                      ),
                    ),

                    // Icon(
                    //   Icons.money,
                    //   color: kMainColor,
                    // ),
                    trailing: Switch.adaptive(
                      value: _switchValuestock,
                      onChanged: (bool value) async {
                        // final prefs = await SharedPreferences.getInstance();
                        // await prefs.setBool('isPrintEnable', value);
                        setState(() {
                          _switchValuestock = !_switchValuestock;
                          // updateswitchvalue == true;
                        });
                      },
                    )),
                _switchValuestock
                    ? Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          textFieldType: TextFieldType.NAME,
                          onChanged: (value) {
                            setState(() {
                              productStock = value;
                            });
                          },
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: lang.S.of(context).stock,
                            hintText: '20',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      )
                    : Container(),

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
                        String data = await const UnitList().launch(context);
                        setState(() {
                          productUnit = data;
                        });
                      },
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 10.0,
                          ),
                          Text(productUnit == null
                              ? "Select Unit"
                              : productUnit.toString()),
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
                          textFieldType: TextFieldType.PHONE,
                          onChanged: (value) {
                            setState(() {
                              productPurchasePrice = value;
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
                          textFieldType: TextFieldType.PHONE,
                          onChanged: (value) {
                            setState(() {
                              productSalePrice = value;
                            });
                          },
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: lang.S.of(context).mrp,
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
                //           textFieldType: TextFieldType.PHONE,
                //           onChanged: (value) {
                //             setState(() {
                //               productWholeSalePrice = value;
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
                //           textFieldType: TextFieldType.PHONE,
                //           onChanged: (value) {
                //             setState(() {
                //               productDealerPrice = value;
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
                  gstenable = data.gstenable!;

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
                                  setState(() {
                                    dropdownvalue = val!;
                                    vatPercentageEditingController.text = val;
                                    GstAmount = double.parse(
                                            vatPercentageEditingController
                                                .text) *
                                        double.parse(productSalePrice) /
                                        100;
                                  });
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
                  //                 inputFormatters: [
                  //                   FilteringTextInputFormatter.allow(
                  //                       RegExp(r'^\d*\.?\d{0,2}'))
                  //                 ],
                  //                 controller: vatPercentageEditingController,
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
                  //                           double.parse(productPurchasePrice
                  //                               .toString());
                  //                       // providerDatacart
                  //                       //     .getTotalAmount()
                  //                       //     .toDouble();
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
                  //                       vatPercentageEditingController.text =
                  //                           ((vatAmount * 100) /
                  //                                   double.parse(
                  //                                       productPurchasePrice
                  //                                           .toString()))
                  //                               .toString();
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
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: AppTextField(
                        textFieldType: TextFieldType.PHONE,
                        onChanged: (value) {
                          setState(() {
                            productDiscount = value;
                          });
                        },
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: lang.S.of(context).discount,
                          hintText: '$currency 34.90',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    )).visible(false),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          textFieldType: TextFieldType.NAME,
                          onChanged: (value) {
                            setState(
                              () {
                                productManufacturer = value;
                              },
                            );
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

                Column(
                  children: [
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            pickedImage =
                                                await _picker.pickImage(
                                                    source:
                                                        ImageSource.gallery);

                                            setState(() {
                                              imageFile =
                                                  File(pickedImage!.path);
                                              imagePath = pickedImage!.path;
                                            });

                                            Future.delayed(
                                                const Duration(
                                                    milliseconds: 100), () {
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
                                                lang.S.of(context).gallery,
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
                                            pickedImage =
                                                await _picker.pickImage(
                                                    source: ImageSource.camera);
                                            setState(() {
                                              imageFile =
                                                  File(pickedImage!.path);
                                              imagePath = pickedImage!.path;
                                            });
                                            Future.delayed(
                                                const Duration(
                                                    milliseconds: 100), () {
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
                              border:
                                  Border.all(color: Colors.black54, width: 1),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(120)),
                              image: imagePath == 'No Data'
                                  ? DecorationImage(
                                      image: NetworkImage(productPicture == ""
                                          ? "https://firebasestorage.googleapis.com/v0/b/maanpos.appspot.com/o/Customer%20Picture%2FNo_Image_Available.jpeg?alt=media&token=3de0d45e-0e4a-4a7b-b115-9d6722d5031f"
                                          : productPicture),
                                      fit: BoxFit.cover,
                                    )
                                  : DecorationImage(
                                      image: FileImage(imageFile),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black54, width: 1),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(120)),
                              image: DecorationImage(
                                image: FileImage(imageFile),
                                fit: BoxFit.cover,
                              ),
                            ),
                            // child: imageFile.path == 'No File' ? null : Image.file(imageFile),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 2),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(120)),
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
                    const SizedBox(height: 10),
                  ],
                ),
                ButtonGlobalWithoutIcon(
                  buttontext: lang.S.of(context).saveNPublish,
                  buttonDecoration:
                      kButtonDecoration.copyWith(color: kMainColor),
                  onPressed: () async {
                    print(productName.toString());
                    if (productName.isEmpty) {
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
                    // if (productStock.isEmpty) {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     const SnackBar(
                    //       content: Text('Please Enter Stock'),
                    //       duration: Duration(seconds: 1),
                    //     ),
                    //   );
                    //   return;
                    // }

                    if (productUnit == "Select Unit" || productUnit == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select unit'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      return;
                    }
                    if (productSalePrice.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please Enter sale price'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      return;
                    }
                    if (double.parse(productSalePrice) <
                        double.parse(productPurchasePrice)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'MRP price must be grater then purchase price'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      return;
                    }
                    print(vatPercentageEditingController.text.toString());

                    if (gstenable) {
                      if (vatPercentageEditingController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter product Gst'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        return;
                      }
                    }

                    //product Image validatin
                    // if (imagePath == "No Data") {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     const SnackBar(
                    //       content: Text('Please select product image'),
                    //       duration: Duration(seconds: 1),
                    //     ),
                    //   );
                    //   return;
                    // }
                    print("code list" + codeList.toString());

                    print("code list" + productNameList.toString());
                    providerData.when(
                        data: (products) async {
                          if (!codeList.contains(productCode.toLowerCase())) {
                            bool result =
                                await InternetConnectionChecker().hasConnection;
                            if (result) {
                              bool status =
                                  await PurchaseModel().isActiveBuyer();
                              if (status) {
                                try {
                                  EasyLoading.show(
                                      status: 'Loading...',
                                      dismissOnTap: false);

                                  imagePath == 'No Data'
                                      ? null
                                      : await uploadFile(imagePath);
                                  // ignore: no_leading_underscores_for_local_identifiers
                                  final DatabaseReference
                                      _productInformationRef = FirebaseDatabase
                                          .instance
                                          .ref()
                                          .child(constUserId)
                                          .child('Products');
                                  _productInformationRef.keepSynced(true);

                                  ProductModel productModel = ProductModel(
                                      productName,
                                      productCategory,
                                      size,
                                      color,
                                      weight,
                                      capacity,
                                      type,
                                      brandName,
                                      productCode.isEmpty
                                          ? (products.length + 1).toString()
                                          : productCode,
                                      productStock,
                                      productUnit,
                                      productSalePrice,
                                      productPurchasePrice,
                                      productDiscount,
                                      productWholeSalePrice,
                                      productDealerPrice,
                                      productManufacturer,
                                      productPicture,
                                      vatPercentageEditingController.text,
                                      GstAmount.toString());

                                  print("product code" +
                                      productModel.productCode.toString());
                                  _productInformationRef
                                      .push()
                                      .set(productModel.toJson());
                                  decreaseSubscriptionSale();
                                  EasyLoading.showSuccess('Added Successfully',
                                      duration:
                                          const Duration(milliseconds: 500));
                                  _productInformationRef.onChildAdded
                                      .listen((event) {
                                    ref.refresh(productProvider);
                                  });
                                  Future.delayed(
                                      const Duration(milliseconds: 100), () {
                                    const Home()
                                        .launch(context, isNewTask: true);
                                  });
                                } catch (e) {
                                  EasyLoading.dismiss();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())));
                                }
                              } else {
                                showLicensePage(context: context);
                              }
                            } else {
                              try {
                                EasyLoading.show(
                                    status: 'Loading...', dismissOnTap: false);
                                imagePath == 'No Data'
                                    ? null
                                    : await uploadFile(imagePath);
                                // ignore: no_leading_underscores_for_local_identifiers
                                final DatabaseReference _productInformationRef =
                                    FirebaseDatabase.instance
                                        .ref()
                                        .child(constUserId)
                                        .child('Products');

                                _productInformationRef.keepSynced(true);
                                ProductModel productModel = ProductModel(
                                    productName,
                                    productCategory,
                                    size,
                                    color,
                                    weight,
                                    capacity,
                                    type,
                                    brandName,
                                    productCode,
                                    productStock,
                                    productUnit,
                                    productSalePrice,
                                    productPurchasePrice,
                                    productDiscount,
                                    productWholeSalePrice,
                                    productDealerPrice,
                                    productManufacturer,
                                    productPicture,
                                    vatPercentageEditingController.text,
                                    GstAmount.toString());
                                _productInformationRef
                                    .push()
                                    .set(productModel.toJson());
                                decreaseSubscriptionSale();
                                GstAmount = 0;
                                EasyLoading.showSuccess('Added Successfully',
                                    duration:
                                        const Duration(milliseconds: 500));
                                _productInformationRef.onChildAdded
                                    .listen((event) {
                                  ref.refresh(productProvider);
                                });
                                Future.delayed(
                                    const Duration(milliseconds: 100), () {
                                  const Home().launch(context, isNewTask: true);
                                });
                              } catch (e) {
                                EasyLoading.dismiss();
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())));
                              }
                            }
                          } else {
                            EasyLoading.showError(
                                'Product Code or Name are already added!');
                          }
                        },
                        error: (Object error, StackTrace stackTrace) {},
                        loading: () {});
                  },
                  buttonTextColor: Colors.white,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void decreaseSubscriptionSale() async {
    final ref =
        FirebaseDatabase.instance.ref('$constUserId/Subscription/products');
    ref.keepSynced(true);
    var data = await ref.once();
    int beforeSale = int.parse(data.snapshot.value.toString());
    int afterSale = beforeSale - 1;
    beforeSale != -202
        ? FirebaseDatabase.instance
            .ref('$constUserId/Subscription')
            .update({'products': afterSale})
        : null;
  }
}
