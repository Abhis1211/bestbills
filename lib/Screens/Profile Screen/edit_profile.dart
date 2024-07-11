import 'dart:io';
import '../../constant.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../Provider/profile_provider.dart';
import '../../model/shop_category_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../Provider/shop_category_provider.dart';
import '../../model/personal_information_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile_pos/GlobalComponents/button_global.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
// ignore_for_file: unused_result

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key, required this.profile}) : super(key: key);

  final PersonalInformationModel profile;

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String dropdownLangValue = 'English';
  String initialCountry = '';
  String invoicenote = '';
  String gstnumber = '';
  String dropdownValue = '';
  String companyName = 'nodata',
      phoneNumber = 'nodata',
      altNumber = '',
      email = '';
  double progress = 0.0;
  int invoiceNumber = 0;
  int invoiceNumberdue = 0;
  int invoiceNumberpurchase = 0;
  bool showProgress = false;
  String profilePicture = 'nodata';
  String profilePictureqr = 'nodata';
  int openingBalance = 0;
  int remainingShopBalance = 0;

  // ignore: prefer_typing_uninitialized_variables
  var dialogContext;
  final ImagePicker _picker = ImagePicker();
  XFile? pickedImage;
  XFile? pickedImageqr;
  File imageFile = File('No File');
  File imageFileqr = File('No File');
  String imagePath = 'No Data';
  String imagePathqr = 'No Data';

  int loopCount = 0;

  Future<void> uploadFile(String filePath) async {
    File file = File(filePath);
    try {
      EasyLoading.show(
        status: 'Uploading... ',
        dismissOnTap: false,
      );
      final ref = FirebaseStorage.instance
          .ref('Profile Picture/${DateTime.now().millisecondsSinceEpoch}');

      var snapshot = await ref.putFile(file);
      var url = await snapshot.ref.getDownloadURL();
      setState(() {
        profilePicture = url.toString();
      });
      print("profile of picture"+profilePicture.toString());
    } on firebase_core.FirebaseException catch (e) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.code.toString())));
    }
  }
  Future<void> uploadFileqr(String filePath) async {
    File file = File(filePath);
    try {
      EasyLoading.show(
        status: 'Uploading... ',
        dismissOnTap: false,
      );
      final ref = FirebaseStorage.instance
          .ref('Profile qr/${DateTime.now().millisecondsSinceEpoch}');

      var snapshot = await ref.putFile(file);
      var url = await snapshot.ref.getDownloadURL();
      setState(() {
        profilePictureqr = url.toString();
      });
      print("profile picture"+ profilePictureqr.toString());
    } on firebase_core.FirebaseException catch (e) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.code.toString())));
    }
  }

  DropdownButton<String> getCategory(
      {required String category, required List<ShopCategoryModel> list}) {
    List<String> categories = [];
    bool inNotInList = true;
    for (var element in list) {
      categories.add(element.categoryName ?? '');
      if (element.categoryName == dropdownValue) {
        inNotInList = false;
      }
    }

    List<DropdownMenuItem<String>> dropDownItems = [];
    if (inNotInList) {
      dropDownItems = [
        DropdownMenuItem(
          value: category,
          child: Text(category),
        ),
      ];
    }
    for (String category in categories) {
      var item = DropdownMenuItem(
        value: category,
        child: Text(category),
      );
      dropDownItems.add(item);
    }
    return DropdownButton(
      items: dropDownItems,
      value: category,
      onChanged: (value) {
        setState(() {
          dropdownValue = value!;
        });
      },
    );
  }

  DropdownButton<String> getLanguage(String lang) {
    List<DropdownMenuItem<String>> dropDownLangItems = [];
    for (String lang in language) {
      var item = DropdownMenuItem(
        value: lang,
        child: Text(lang),
      );
      dropDownLangItems.add(item);
    }
    return DropdownButton(
      items: dropDownLangItems,
      value: lang,
      onChanged: (value) {
        setState(() {
          dropdownLangValue = value!;
        });
      },
    );
  }

  @override
  void initState() {
    dropdownValue = widget.profile.businessCategory ?? '';
    dropdownLangValue = widget.profile.language ?? '';
    profilePicture = widget.profile.pictureUrl ?? '';
    profilePictureqr = widget.profile.pictureUrlqr ?? '';
    // profileRepo.getDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          lang.S.of(context).updateProfile,
          style: GoogleFonts.inter(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Consumer(builder: (context, ref, child) {
          AsyncValue<PersonalInformationModel> userProfileDetails =
              ref.watch(profileDetailsProvider);
          AsyncValue<List<ShopCategoryModel>> categoryList =
              ref.watch(shopCategoryProvider);

          return categoryList.when(data: (categoryList) {
            return Column(

              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "Update your profile to connect your customer with better impression",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: kGreyTextColor,
                      fontSize: 15.0,
                    ),
                  ),
                ),
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
                                        if (pickedImage != null) {
                                          final decodedImage =
                                              await decodeImageFromList(
                                                  await pickedImage!
                                                      .readAsBytes());
                                          print("width" +
                                              decodedImage.width.toString());
                                          print("height" +
                                              decodedImage.height.toString());

                                          if (decodedImage.height > 300 ||
                                              decodedImage.width > 300) {
                                                setState(() {
                                                  
                                                pickedImage = null;
                                                });
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        "Image size Must be is less then 300*300")));
                                          } else {
                                            setState(() {
                                              imageFile =
                                                  File(pickedImage!.path);
                                              imagePath = pickedImage!.path;
                                            });
                                          }
                                          Future.delayed(
                                              const Duration(
                                                  milliseconds: 100), () {
                                            Navigator.pop(context);
                                          });
                                        }
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
                                            
                                        if (pickedImage != null) {
                                          final decodedImage =
                                              await decodeImageFromList(
                                                  await pickedImage!
                                                      .readAsBytes());
                                          print("width" +
                                              decodedImage.width.toString());
                                          print("height" +
                                              decodedImage.height.toString());

                                          if (decodedImage.height > 300 ||
                                              decodedImage.width > 300) {
                                                setState(() {
                                                  
                                                pickedImage = null;
                                                });
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        "Image size Must be is less then 300*300")));
                                          } else {
                                            setState(() {
                                              imageFile =
                                                  File(pickedImage!.path);
                                              imagePath = pickedImage!.path;
                                            });
                                          }}
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
                                            'Camera',
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
                    // showDialog(
                    //     context: context,
                    //     builder: (BuildContext context) {
                    //       return Dialog(
                    //         shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(12.0),
                    //         ),
                    //         // ignore: sized_box_for_whitespace
                    //         child: Container(
                    //           height: 200.0,
                    //           width: MediaQuery.of(context).size.width - 80,
                    //           child: Center(
                    //             child: Row(
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               children: [
                    //                 GestureDetector(
                    //                   onTap: () async {
                    //                     pickedImage = await _picker.pickImage(source: ImageSource.gallery);
                    //                     setState(() {
                    //                       imageFile = File(pickedImage!.path);
                    //                       imagePath = pickedImage!.path;
                    //                     });
                    //                     Future.delayed(const Duration(milliseconds: 100), () {
                    //                       Navigator.pop(context);
                    //                     });
                    //                   },
                    //                   child: Column(
                    //                     mainAxisAlignment: MainAxisAlignment.center,
                    //                     children: [
                    //                       const Icon(
                    //                         Icons.photo_library_rounded,
                    //                         size: 60.0,
                    //                         color: kMainColor,
                    //                       ),
                    //                       Text(
                    //                         'Gallery',
                    //                         style: GoogleFonts.inter(
                    //                           fontSize: 20.0,
                    //                           color: kMainColor,
                    //                         ),
                    //                       ),
                    //                     ],
                    //                   ),
                    //                 ),
                    //                 const SizedBox(
                    //                   width: 40.0,
                    //                 ),
                    //                 GestureDetector(
                    //                   onTap: () async {
                    //                     pickedImage = await _picker.pickImage(source: ImageSource.camera);
                    //                     setState(() {
                    //                       imageFile = File(pickedImage!.path);
                    //                       imagePath = pickedImage!.path;
                    //                     });
                    //                     Future.delayed(const Duration(milliseconds: 100), () {
                    //                       Navigator.pop(context);
                    //                     });
                    //                   },
                    //                   child: Column(
                    //                     mainAxisAlignment: MainAxisAlignment.center,
                    //                     children: [
                    //                       const Icon(
                    //                         Icons.camera,
                    //                         size: 60.0,
                    //                         color: kGreyTextColor,
                    //                       ),
                    //                       Text(
                    //                         'Camera',
                    //                         style: GoogleFonts.inter(
                    //                           fontSize: 20.0,
                    //                           color: kGreyTextColor,
                    //                         ),
                    //                       ),
                    //                     ],
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //       );
                    //     });
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
                                  image: NetworkImage(profilePicture),
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
               
               
                const SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    height: 60.0,
                    child: FormField(
                      builder: (FormFieldState<dynamic> field) {
                        return InputDecorator(
                          decoration: InputDecoration(
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              labelText: lang.S.of(context).businessCat,
                              labelStyle: GoogleFonts.inter(
                                color: Colors.black,
                                fontSize: 20.0,
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0))),
                          child: DropdownButtonHideUnderline(
                              child: getCategory(
                                  category: dropdownValue,
                                  list: categoryList)),
                        );
                      },
                    ),
                  ),
                ),
                userProfileDetails.when(data: (details) {
                  invoiceNumber = details.invoiceCounter!;
                  invoiceNumberdue = details.invoiceCounterdue!;
                  invoiceNumberpurchase = details.invoiceCounterpurchase!;
                  openingBalance = details.shopOpeningBalance;
                  // invoicenote = details.note!;
                  remainingShopBalance = details.remainingShopBalance;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          initialValue: details.companyName,
                          onChanged: (value) {
                            setState(() {
                              companyName = value;
                            });
                          }, // Optional
                          textFieldType: TextFieldType.NAME,
                          decoration: InputDecoration(
                            labelText: lang.S.of(context).businessName,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SizedBox(
                          height: 60.0,
                          child: AppTextField(
                            readOnly: false,
                            textFieldType: TextFieldType.PHONE,
                            initialValue: details.phoneNumber,
                            onChanged: (value) {
                              setState(() {
                                phoneNumber = value;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: lang.S.of(context).phone,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SizedBox(
                          height: 60.0,
                          child: AppTextField(
                            readOnly: false,
                            textFieldType: TextFieldType.PHONE,
                            initialValue: details.altphoneNumber,
                            onChanged: (value) {
                              setState(() {
                                altNumber = value;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: "Alternate phone number",
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          initialValue: details.countryName,
                          onChanged: (value) {
                            setState(() {
                              initialCountry = value;
                            });
                          }, // Optional
                          textFieldType: TextFieldType.NAME,
                          decoration: InputDecoration(
                            labelText: lang.S.of(context).address,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          initialValue: details.note,
                          maxLines: 100,
                          keyboardType: TextInputType.multiline,
                          // maxLength: 50,
                          textInputAction: TextInputAction.newline,
                          onChanged: (value) {
                            setState(() {
                              invoicenote = value;
                            });
                          }, // Optional
                          textFieldType: TextFieldType.NAME,
                          decoration: InputDecoration(
                            labelText: "Invoice Note",
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
 SizedBox(height: 10),
                Text(
                    "Upload Qr",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                  ).paddingSymmetric(horizontal: 10),
                  SizedBox(height: 10),
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
                                        pickedImageqr = await _picker.pickImage(
                                            source: ImageSource.gallery);
                                        if (pickedImageqr != null) {
                                          final decodedImage =
                                              await decodeImageFromList(
                                                  await pickedImageqr!
                                                      .readAsBytes());
                                          print("width" +
                                              decodedImage.width.toString());
                                          print("height" +
                                              decodedImage.height.toString());

                                          if (decodedImage.height > 1000 ||
                                              decodedImage.width > 1000) {
                                                setState(() {
                                                  
                                                pickedImageqr = null;
                                                });
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        "Image size Must be is less then 300*300")));
                                          } else {
                                            setState(() {
                                              imageFileqr =
                                                  File(pickedImageqr!.path);
                                              imagePathqr = pickedImageqr!.path;
                                            });
                                          }
                                          Future.delayed(
                                              const Duration(
                                                  milliseconds: 100), () {
                                            Navigator.pop(context);
                                          });
                                        }
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
                                        pickedImageqr = await _picker.pickImage(
                                            source: ImageSource.camera);
                                            
                                        if (pickedImageqr != null) {
                                          final decodedImage =
                                              await decodeImageFromList(
                                                  await pickedImageqr!
                                                      .readAsBytes());
                                          print("width" +
                                              decodedImage.width.toString());
                                          print("height" +
                                              decodedImage.height.toString());

                                          if (decodedImage.height > 300 ||
                                              decodedImage.width > 300) {
                                                setState(() {
                                                  
                                                pickedImageqr = null;
                                                });
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        "Image size Must be is less then 300*300")));
                                          } else {
                                            setState(() {
                                              imageFileqr =
                                                  File(pickedImageqr!.path);
                                              imagePathqr = pickedImageqr!.path;
                                            });
                                          }}
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
                                            'Camera',
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
                    // showDialog(
                    //     context: context,
                    //     builder: (BuildContext context) {
                    //       return Dialog(
                    //         shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(12.0),
                    //         ),
                    //         // ignore: sized_box_for_whitespace
                    //         child: Container(
                    //           height: 200.0,
                    //           width: MediaQuery.of(context).size.width - 80,
                    //           child: Center(
                    //             child: Row(
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               children: [
                    //                 GestureDetector(
                    //                   onTap: () async {
                    //                     pickedImage = await _picker.pickImage(source: ImageSource.gallery);
                    //                     setState(() {
                    //                       imageFile = File(pickedImage!.path);
                    //                       imagePath = pickedImage!.path;
                    //                     });
                    //                     Future.delayed(const Duration(milliseconds: 100), () {
                    //                       Navigator.pop(context);
                    //                     });
                    //                   },
                    //                   child: Column(
                    //                     mainAxisAlignment: MainAxisAlignment.center,
                    //                     children: [
                    //                       const Icon(
                    //                         Icons.photo_library_rounded,
                    //                         size: 60.0,
                    //                         color: kMainColor,
                    //                       ),
                    //                       Text(
                    //                         'Gallery',
                    //                         style: GoogleFonts.inter(
                    //                           fontSize: 20.0,
                    //                           color: kMainColor,
                    //                         ),
                    //                       ),
                    //                     ],
                    //                   ),
                    //                 ),
                    //                 const SizedBox(
                    //                   width: 40.0,
                    //                 ),
                    //                 GestureDetector(
                    //                   onTap: () async {
                    //                     pickedImage = await _picker.pickImage(source: ImageSource.camera);
                    //                     setState(() {
                    //                       imageFile = File(pickedImage!.path);
                    //                       imagePath = pickedImage!.path;
                    //                     });
                    //                     Future.delayed(const Duration(milliseconds: 100), () {
                    //                       Navigator.pop(context);
                    //                     });
                    //                   },
                    //                   child: Column(
                    //                     mainAxisAlignment: MainAxisAlignment.center,
                    //                     children: [
                    //                       const Icon(
                    //                         Icons.camera,
                    //                         size: 60.0,
                    //                         color: kGreyTextColor,
                    //                       ),
                    //                       Text(
                    //                         'Camera',
                    //                         style: GoogleFonts.inter(
                    //                           fontSize: 20.0,
                    //                           color: kGreyTextColor,
                    //                         ),
                    //                       ),
                    //                     ],
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //       );
                    //     });
                  },
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black54, width: 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          image: imagePathqr == 'No Data'
                              ? DecorationImage(
                                  image: NetworkImage(profilePictureqr),
                                  fit: BoxFit.cover,
                                )
                              : DecorationImage(
                                  image: FileImage(imageFileqr),
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
                  ).paddingSymmetric(horizontal: 10),
                ),
               
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: AppTextField(
                          initialValue: details.gstnumber,

                          onChanged: (value) {
                            setState(() {
                              gstnumber = value;
                            });
                          }, // Optional
                          textFieldType: TextFieldType.NAME,
                          decoration: InputDecoration(
                            labelText: "GST Number",
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),

                      // Padding(
                      //   padding: const EdgeInsets.all(10.0),
                      //   child: SizedBox(
                      //     height: 60.0,
                      //     child: FormField(
                      //       builder: (FormFieldState<dynamic> field) {
                      //         return InputDecorator(
                      //           decoration: InputDecoration(
                      //               floatingLabelBehavior:
                      //                   FloatingLabelBehavior.always,
                      //               labelText: lang.S.of(context).language,
                      //               labelStyle: GoogleFonts.inter(
                      //                 color: Colors.black,
                      //                 fontSize: 20.0,
                      //               ),
                      //               border: OutlineInputBorder(
                      //                   borderRadius:
                      //                       BorderRadius.circular(5.0))),
                      //           child: DropdownButtonHideUnderline(
                      //               child: getLanguage(dropdownLangValue)),
                      //         );
                      //       },
                      //     ),
                      //   ),
                      // ),

                      SizedBox(
                        height: 40.0,
                      ),
                      ButtonGlobal(
                        iconWidget: Icons.arrow_forward,
                        buttontext: lang.S.of(context).continueButton,
                        iconColor: Colors.white,
                        buttonDecoration:
                            kButtonDecoration.copyWith(color: kMainColor),
                        onPressed: () async {
                          if (profilePicture == 'nodata') {
                            setState(() {
                              profilePicture = userProfileDetails
                                  .value!.pictureUrl
                                  .toString();
                            });
                          }
                          if (profilePictureqr == 'nodata') {
                            setState(() {
                              profilePictureqr = userProfileDetails
                                  .value!.pictureUrlqr
                                  .toString();
                            });
                          }
                          if (companyName == 'nodata') {
                            setState(() {
                              companyName = userProfileDetails
                                  .value!.companyName
                                  .toString();
                            });
                          }
                          if (phoneNumber == 'nodata') {
                            setState(() {
                              phoneNumber = userProfileDetails
                                  .value!.phoneNumber
                                  .toString();
                            });
                          }
                          try {
                            EasyLoading.show(
                                status: 'Loading...', dismissOnTap: false);
                            imagePath == 'No Data'
                                ? null
                                : await uploadFile(imagePath);
                            imagePathqr == 'No Data'
                                ? null
                                : await uploadFileqr(imagePathqr);
                            // ignore: no_leading_underscores_for_local_identifiers
                            final DatabaseReference _personalInformationRef =
                                FirebaseDatabase.instance
                                    .ref()
                                    .child(constUserId)
                                    .child('Personal Information');
                            _personalInformationRef.keepSynced(true);
                            PersonalInformationModel personalInformation =
                                PersonalInformationModel(
                              businessCategory: dropdownValue,
                              companyName: companyName,
                              phoneNumber: phoneNumber,
                              countryName: initialCountry == ""
                                  ? widget.profile.countryName
                                  : initialCountry,
                              email: widget.profile.email,
                              altphoneNumber: altNumber == ""
                                  ? widget.profile.altphoneNumber
                                  : altNumber,
                              invoiceCounter: invoiceNumber,
                              invoiceCounterdue: invoiceNumberdue,
                              invoiceCounterpurchase: invoiceNumberpurchase,
                              gstenable:
                                  details.gstenable == true ? true : false,
                              gstnumber: gstnumber == ""
                                  ? widget.profile.gstnumber
                                  : gstnumber,
                              note: invoicenote == ""
                                  ? widget.profile.note
                                  : invoicenote,
                              language: dropdownLangValue,
                              pictureUrl: profilePicture,
                              pictureUrlqr: profilePictureqr,
                              remainingShopBalance: remainingShopBalance,
                              shopOpeningBalance: openingBalance,
                            );
                            _personalInformationRef
                                .set(personalInformation.toJson());

                            EasyLoading.showSuccess('Updated Successfully',
                                duration: const Duration(milliseconds: 1000));
                            // ignore: use_build_context_synchronously
                            await ref.refresh(profileDetailsProvider);
                            Navigator.pushNamed(context, '/home');
                          } catch (e) {
                            EasyLoading.dismiss();
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())));
                          }
                          // Navigator.pushNamed(context, '/otp');
                        },
                      ),
                    ],
                  );
                }, error: (e, stack) {
                  return Text(e.toString());
                }, loading: () {
                  return const CircularProgressIndicator();
                }),
              ],
            );
          }, error: (e, stack) {
            return Center(
              child: Text(e.toString()),
            );
          }, loading: () {
            return const Center(
              child: CircularProgressIndicator(),
            );
          });
        }),
      ),
    );
  }
}
