import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../constant.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import '../model/add_to_cart_model.dart';
import '../model/print_transaction_model.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:http/http.dart' as http;

import 'package:image/image.dart' as img;

// import 'package:esc_pos_utils/esc_pos_utils.dart';
final printerProviderNotifier = ChangeNotifierProvider((ref) => Printer());

class Printer extends ChangeNotifier {
  List availableBluetoothDevices = [];

  Future<void> getBluetooth() async {
    final List? bluetooths = await BluetoothThermalPrinter.getBluetooths;
    availableBluetoothDevices = bluetooths!;
    notifyListeners();
  }

  Future<bool> setConnect(String mac) async {
    print("connet");
    bool status = false;
    try {
      print("scsdsa");
      final String? result = await BluetoothThermalPrinter.connect(mac);
      if (result == "true") {

        print("sddsfdsfdsfdsfdsfds");
        connected = true;
        status = true;
      }
    } catch (e) {
      print( "connect error"+e.toString());
    }
    notifyListeners();
    return status;
  }

  Future<bool> printTicket(
      {required PrintTransactionModel printTransactionModel,
      required List<AddToCartModel>? productList}) async {
    bool isPrinted = false;
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<int> bytes = await getTicket(
          printTransactionModel: printTransactionModel,
          productList: productList);
      if (productList!.isNotEmpty) {
        await BluetoothThermalPrinter.writeBytes(bytes);
      } else {
        toast('No Product Found');
      }
      isPrinted = true;
    } else {
      isPrinted = false;
    }
    notifyListeners();
    return isPrinted;
  }

  Future<Uint8List> imagePathToUint8List(String path) async {
//converting to Uint8List to pass to printer

    ByteData data = await rootBundle.load(path);
    Uint8List imageBytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    return imageBytes;
  }

  Future<List<int>> getTicket(
      {required PrintTransactionModel printTransactionModel,
      required List<AddToCartModel>? productList}) async {
    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    File f = await convertUriToFile(
        printTransactionModel.personalInformationModel.pictureUrl);

    final Uint8List bytess = await File(f.path).readAsBytes();
    final img.Image? image = img.decodeImage(bytess);

    bytes += generator.image(image!, align: PosAlign.center);
    // generator.imageRaster(image);
    // generator.imageRaster(image, imageFn: PosImageFn.graphics);

    bytes += generator.text(
        printTransactionModel.personalInformationModel.companyName ?? '',
        styles: PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
            fontType: PosFontType.fontA),
        linesAfter: 1);
    if (printTransactionModel.personalInformationModel.gstenable == true)
      bytes += generator.text(
        'GSTIN : ${printTransactionModel.personalInformationModel.gstnumber ?? ''}',
        styles: const PosStyles(
          align: PosAlign.center,
        ),
      );
    // printTransactionModel.transitionModel!.sellerName.isEmptyOrNull
    //     ? bytes += generator.text('Seller : Admin',
    //         styles: const PosStyles(align: PosAlign.center))
    //     : bytes += generator.text(
    //         'Seller :${printTransactionModel.transitionModel!.sellerName}',
    //         styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text(
        printTransactionModel.personalInformationModel.countryName ?? '',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text(
        'Mob: ${printTransactionModel.personalInformationModel.phoneNumber ?? ''}',
        styles: const PosStyles(align: PosAlign.center),
        linesAfter: 1);
    bytes += generator.text(
        'Name: ${printTransactionModel.transitionModel?.customerName ?? 'Guest'}',
        styles: const PosStyles(align: PosAlign.left));
    if (printTransactionModel.transitionModel?.customerPhone != "" ||
        printTransactionModel.transitionModel?.customerPhone != null)
      bytes += generator.text(
          'Mobile: ${printTransactionModel.transitionModel?.customerPhone ?? 'Not Provided'}',
          styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text(
      'Invoice No: ${printTransactionModel.transitionModel?.invoiceNumber ?? 'Not Provided'}',
      styles: const PosStyles(align: PosAlign.left),
    );
    bytes += generator.row([
      PosColumn(
          text: 'Item',
          width: 7,
          styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: 'Qty',
          width: 1,
          styles: const PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(
          text: 'Price',
          width: 2,
          styles: const PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(
          text: 'Total',
          width: 2,
          styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.hr();
    List.generate(productList?.length ?? 1, (index) {
      return bytes += generator.row([
        PosColumn(
            text:"" ?? 'Not Defined',
            width: 7,
            styles: PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
            text: productList?[index].quantity.toString() ?? 'Not Defined',
            width: 1,
            styles: const PosStyles(align: PosAlign.center)),
        PosColumn(
            text: productList?[index].subTotal ?? 'Not Defined',
            width: 2,
            styles: const PosStyles(
              align: PosAlign.center,
            )),
        PosColumn(
            text:
                "${(double.parse(productList?[index].subTotal) * productList![index].quantity.toInt()).toDouble().round().toString()}",
            width: 2,
            styles: const PosStyles(align: PosAlign.right)),
      ]);
    });
    // bytes += generator.row([
    //   PosColumn(
    //       text: "Sada Dosa",
    //       width: 5,
    //       styles: PosStyles(
    //         align: PosAlign.left,
    //       )),
    //   PosColumn(
    //       text: "30",
    //       width: 2,
    //       styles: PosStyles(
    //         align: PosAlign.center,
    //       )),
    //   PosColumn(text: "1", width: 2, styles: PosStyles(align: PosAlign.center)),
    //   PosColumn(text: "30", width: 3, styles: PosStyles(align: PosAlign.right)),
    // ]);
    //
    // bytes += generator.row([
    //   PosColumn(
    //       text: "Masala Dosa",
    //       width: 5,
    //       styles: PosStyles(
    //         align: PosAlign.left,
    //       )),
    //   PosColumn(
    //       text: "50",
    //       width: 2,
    //       styles: PosStyles(
    //         align: PosAlign.center,
    //       )),
    //   PosColumn(text: "1", width: 2, styles: PosStyles(align: PosAlign.center)),
    //   PosColumn(text: "50", width: 3, styles: PosStyles(align: PosAlign.right)),
    // ]);
    //
    // bytes += generator.row([
    //   PosColumn(
    //       text: "Rova Dosa",
    //       width: 5,
    //       styles: PosStyles(
    //         align: PosAlign.left,
    //       )),
    //   PosColumn(
    //       text: "70",
    //       width: 2,
    //       styles: PosStyles(
    //         align: PosAlign.center,
    //       )),
    //   PosColumn(text: "1", width: 2, styles: PosStyles(align: PosAlign.center)),
    //   PosColumn(text: "70", width: 3, styles: PosStyles(align: PosAlign.right)),
    // ]);
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(
          text: 'Subtotal',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text:
              '${(printTransactionModel.transitionModel!.totalAmount!.toDouble() + printTransactionModel.transitionModel!.discountAmount!.toDouble() - printTransactionModel.transitionModel!.vat!).round().toString()}',
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Discount',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: printTransactionModel.transitionModel?.discountAmount!
                  .toDouble()
                  .round()
                  .toString() ??
              '',
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    if (printTransactionModel.personalInformationModel.gstenable == true)
      bytes += generator.row([
        PosColumn(
            text: 'GST',
            width: 8,
            styles: const PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
            text:
                '${printTransactionModel.transitionModel!.vat!.toDouble().round().toString()}',
            width: 4,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
      ]);
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(
          text: 'TOTAL',
          width: 8,
          styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text:
              // '${printTransactionModel.transitionModel!.totalAmount!.toDouble() - printTransactionModel.transitionModel!.discountAmount!.toDouble() + printTransactionModel.transitionModel!.vat!.toDouble()}',
              '${printTransactionModel.transitionModel!.totalAmount!..toDouble().round().toString()}',
          width: 4,
          styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.hr();
    // bytes += generator.hr(ch: '=', linesAfter: 1);
    // bytes += generator.hr();

    bytes += generator.row([
      PosColumn(
          text: 'Payment Type:',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text: printTransactionModel.transitionModel?.paymentType ?? 'Cash',
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Payment Amount:',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text:
              ' ${(printTransactionModel.transitionModel!.returnAmount! > 1) ? (printTransactionModel.transitionModel!.totalAmount! - printTransactionModel.transitionModel!.vat!.toDouble() + printTransactionModel.transitionModel!.returnAmount!).toDouble().round().toString() : (printTransactionModel.transitionModel!.totalAmount! - printTransactionModel.transitionModel!.dueAmount!.toDouble()).toDouble().round().toString()}',
          // '${printTransactionModel.transitionModel!.totalAmount!.toDouble() - printTransactionModel.transitionModel!.dueAmount!.toDouble() - printTransactionModel.transitionModel!.discountAmount!.toDouble() + printTransactionModel.transitionModel!.vat!.toDouble()}',
          // '${printTransactionModel.transitionModel!.totalAmount!.toDouble() - printTransactionModel.transitionModel!.dueAmount!.toDouble()}',
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Return amount:',
          width: 8,
          styles: const PosStyles(
            align: PosAlign.left,
          )),
      PosColumn(
          text:
              '${(printTransactionModel.transitionModel!.paidamountamount! - printTransactionModel.transitionModel!.totalAmount!) < 0 ? 0 : (printTransactionModel.transitionModel!.paidamountamount! - printTransactionModel.transitionModel!.totalAmount!).toDouble().round().toString()}',

          // text: printTransactionModel.transitionModel!.returnAmount.toString(),
          width: 4,
          styles: const PosStyles(
            align: PosAlign.right,
          )),
    ]);
    if (printTransactionModel.transitionModel!.dueAmount! > 0)
      bytes += generator.row([
        PosColumn(
            text: 'Due Amount:',
            width: 8,
            styles: const PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
            text: printTransactionModel.transitionModel!.dueAmount!
                .toDouble()
                .round()
                .toString(),
            width: 4,
            styles: const PosStyles(
              align: PosAlign.right,
            )),
      ]);
    bytes += generator.hr(ch: '=');

    // ticket.feed(2);
    bytes += generator.text('Thank you visit Again!',
        styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text(
        DateFormat('dd-MM-yyyy h:mm a').format(DateTime.parse(
            printTransactionModel.transitionModel!.purchaseDate)),
        styles: const PosStyles(align: PosAlign.center),
        linesAfter: 1);
    bytes += generator.text('Note:',
        styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text(
        printTransactionModel.personalInformationModel.note.toString(),
        styles: const PosStyles(align: PosAlign.left, bold: false),
        linesAfter: 1);
    bytes += generator.hr();
    
    File qrf = await convertUriToFile(
        printTransactionModel.personalInformationModel.pictureUrlqr);
    final Uint8List bytessqr = await File(qrf.path).readAsBytes();
    final img.Image? imageqr = img.decodeImage(bytessqr);
    bytes += generator.image(imageqr!, align: PosAlign.center);
    bytes += generator.hr();
   
    generator.text("",
        styles: const PosStyles(align: PosAlign.center, bold: false),
        linesAfter: 1);

    bytes += generator.text('Developed By: bestBills(DigiBazar)',
        styles: const PosStyles(align: PosAlign.center), linesAfter: 2);
    // bytes += generator.cut(mode: PosCutMode.partial);
    return bytes;
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  convertUriToFile(url) async {
    try {
      final http.Response responseData = await http.get(Uri.parse(url));
      Uint8List uint8list = responseData.bodyBytes;
      var buffer = uint8list.buffer;
      ByteData byteData = ByteData.view(buffer);
      var tempDir = await getTemporaryDirectory();
      File file = await File('${tempDir.path}/img').writeAsBytes(
          buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      // Converting uri to file

      // Save the thumbnail as a PNG.
      // img.Image imagedata = await convertFileToImage(file) as img.Image;
      // img.Image finalimage = img.copyResize(imagedata);
      return file;
    } catch (e) {
      print(e); // Exception
    }
  }

  Future<Image> convertFileToImage(File picture) async {
    List<int> imageBase64 = picture.readAsBytesSync();
    String imageAsString = base64Encode(imageBase64);
    Uint8List uint8list = base64.decode(imageAsString);
    Image image = Image.memory(uint8list);
    return image;
  }
}
