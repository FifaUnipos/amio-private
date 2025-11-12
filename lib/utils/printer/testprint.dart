import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'printerenum.dart';

///Test printing
class TestPrint {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  sample() async {
    final String printtext =
        'LOKET          : PARENT||22/06/2020 00:23:52|STATUS         : TOPUP-SUKSES|HARGA          : Rp      Rp 26.000|TRX ID         : 000077111314|KODE PRODUK    : PAYBANK||STRUK TRANSFER BCA||TANGGAL : 2020-06-22 00:23:58|NO. REK : 5465327020|NAMA    : FLIPTECH LENTERA IP PT|BANK    : BCA|JUMLAH  : Rp.       20.000|ADMIN   : Rp.        5.000|TOTAL   : Rp.       25.000|BERITA  : -';

    ///image from Network
    var response = await http.get(Uri.parse(
        "https://pentes.cashplus.id:3501/get_img?file=logo_print.png"));
    Uint8List bytesNetwork = response.bodyBytes;
    Uint8List imageBytesFromNetwork = bytesNetwork.buffer
        .asUint8List(bytesNetwork.offsetInBytes, bytesNetwork.lengthInBytes);

    bluetooth.isConnected.then((isConnected) {
      if (isConnected == true) {
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printImageBytes(imageBytesFromNetwork); //image from Network
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printCustom(printtext.replaceAll(RegExp('[|]'), '\n'),
            Size.bold.val, Align.left.val);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth
            .paperCut(); //some printer not supported (sometime making image not centered)
        //bluetooth.drawerPin2(); // or you can use bluetooth.drawerPin5();
      }
    });
  }
}
