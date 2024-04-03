import 'dart:io';
import 'dart:typed_data';
import '../constant.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import '../model/add_to_cart_model.dart';
import '../model/print_transaction_model.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import '../model/personal_information_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';

final printerProviderNotifier = ChangeNotifierProvider((ref) => Printer());

class Printer extends ChangeNotifier {
  List availableBluetoothDevices = [];
  Future<void> getBluetooth() async {
    final List? bluetooths = await BluetoothThermalPrinter.getBluetooths;
    availableBluetoothDevices = bluetooths!;
    notifyListeners();
  }

  Future<bool> setConnect(String mac) async {
    bool status = false;
    final String? result = await BluetoothThermalPrinter.connect(mac);
    if (result == "true") {
      connected = true;
      status = true;
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
    // final ByteData data = await rootBundle.load('images/logo.png');
    // final Uint8List imageBytes = data.buffer.asUint8List();
    // final images.Image? imagez = decodeImage(imageBytes);
    // bytes += generator.image(imagez!);

    bytes += generator.text(
        printTransactionModel.personalInformationModel.companyName ?? '',
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
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
        'Mo: ${printTransactionModel.personalInformationModel.phoneNumber ?? ''}',
        styles: const PosStyles(align: PosAlign.center),
        linesAfter: 1);
    bytes += generator.text(
        'Name: ${printTransactionModel.transitionModel?.customerName ?? 'Guest'}',
        styles: const PosStyles(align: PosAlign.left));
    if (printTransactionModel.transitionModel?.customerPhone != "" ||
        printTransactionModel.transitionModel?.customerPhone != null)
      bytes += generator.text(
          'mobile: ${printTransactionModel.transitionModel?.customerPhone ?? 'Not Provided'}',
          styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text(
      'Invoice Number: ${printTransactionModel.transitionModel?.invoiceNumber ?? 'Not Provided'}',
      styles: const PosStyles(align: PosAlign.left),
    );

    bytes += generator.row([
      PosColumn(
          text: 'Item',
          width: 4,
          styles: const PosStyles(align: PosAlign.left, bold: true)),
      PosColumn(
          text: 'Qty',
          width: 2,
          styles: const PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(
          text: 'Price',
          width: 3,
          styles: const PosStyles(align: PosAlign.center, bold: true)),
      PosColumn(
          text: 'Total',
          width: 3,
          styles: const PosStyles(align: PosAlign.right, bold: true)),
    ]);
    bytes += generator.hr();
    List.generate(productList?.length ?? 1, (index) {
      return bytes += generator.row([
        PosColumn(
            text: productList?[index].productName ?? 'Not Defined',
            width: 4,
            styles: PosStyles(
              align: PosAlign.left,
            )),
        PosColumn(
            text: productList?[index].quantity.toString() ?? 'Not Defined',
            width: 2,
            styles: const PosStyles(align: PosAlign.center)),
        PosColumn(
            text: productList?[index].subTotal ?? 'Not Defined',
            width: 3,
            styles: const PosStyles(
              align: PosAlign.center,
            )),
        PosColumn(
            text:
                "${(double.parse(productList?[index].subTotal) * productList![index].quantity.toInt()).toDouble().round().toString()}",
            width: 3,
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
              '${(printTransactionModel.transitionModel!.totalAmount!.toDouble() + printTransactionModel.transitionModel!.discountAmount!.toDouble() - printTransactionModel.transitionModel!.vat!).toString()}',
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
                  .toDouble().round().toString() ??
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
            text: printTransactionModel.transitionModel!.dueAmount!.toDouble().round().toString(),
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
    // bytes += generator.qrcode(
    //   'https://ezyBills.com',
    //   size: QRSize.Size4,
    // );
    // final ByteData data = await rootBundle.load(
    //     "https://firebasestorage.googleapis.com/v0/b/ezybills-33844.appspot.com/o/Profile%20Picture%2F1706040091954?alt=media&token=b2c621d8-1031-4d61-a44f-d0b86068a8ce");
    // var bytess = data.buffer.asUint8List();
    // var image = decodeImage(bytess);
    // bytes += generator.image(image!, align: PosAlign.center);
    // bytes += generator.hr();
    // generator.text("",
    //     styles: const PosStyles(align: PosAlign.center, bold: false),
    //     linesAfter: 1);

    bytes += generator.text(
        'Developed By: bestbills(Digibazar Pvt. Ltd.)',
        styles: const PosStyles(align: PosAlign.center),
        linesAfter: 2);
    // bytes += generator.cut(mode: PosCutMode.partial);
    return bytes;
  }
}
