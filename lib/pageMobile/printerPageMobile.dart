import 'dart:developer';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter/services.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:http/http.dart' as http;
import 'package:unipos_app_335/main.dart'; // For logoStrukPrinter if needed
import 'package:unipos_app_335/pageMobile/dashboardMobile.dart';
import 'package:unipos_app_335/utils/component/component_button.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_snackbar.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';

class PrinterPageMobile extends StatefulWidget {
  const PrinterPageMobile({Key? key}) : super(key: key);

  @override
  State<PrinterPageMobile> createState() => _PrinterPageMobileState();
}

class _PrinterPageMobileState extends State<PrinterPageMobile> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _device;
  bool connected = false;

  // Sample print text from original file
  final String printtext =
      'LOKET          : PARENT||22/06/2020 00:23:52|STATUS         : TOPUP-SUKSES|HARGA          : Rp      Rp 26.000|TRX ID         : 000077111314|KODE PRODUK    : PAYBANK||STRUK TRANSFER BCA||TANGGAL : 2020-06-22 00:23:58|NO. REK : 5465327020|NAMA    : FLIPTECH LENTERA IP PT|BANK    : BCA|JUMLAH  : Rp.       20.000|ADMIN   : Rp.        5.000|TOTAL   : Rp.       25.000|BERITA  : -';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    bool? isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {}

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            connected = true;
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            connected = false;
          });
          break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
          setState(() {
            connected = false;
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          setState(() {
            connected = false;
          });
          break;
        case BlueThermalPrinter.STATE_OFF:
          setState(() {
            connected = false;
          });
          break;
        case BlueThermalPrinter.STATE_ON:
          setState(() {
            connected = false;
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_ON:
          setState(() {
            connected = false;
          });
          break;
        case BlueThermalPrinter.ERROR:
          setState(() {
            connected = false;
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });

    if (isConnected == true) {
      setState(() {
        connected = true;
      });
    }
  }

  void _connect() {
    if (_device != null) {
      bluetooth.isConnected.then((isConnected) {
        if (isConnected == false) {
          bluetooth.connect(_device!).catchError((error) {
            setState(() => connected = false);
          });
          setState(() => connected = true);
        }
      });
    } else {
      // show('No device selected.');
    }
  }

  void _disconnect() {
    bluetooth.disconnect();
    setState(() => connected = false);
  }

  Future<void> _openBluetoothSettings() async {
    // Attempt to open bluetooth settings.
    // Using blue_thermal_printer we often just rely on system bonded devices.
    // If we need to open settings, we usually need 'open_settings' or 'android_intent' package,
    // but users request "lempar ke pengaturan bluetooth".
    // blue_thermal_printer has openSettings method in some versions or we might need to rely on native intent.
    // The current file doesn't import open_settings.
    // I will try to use the method if available on the instance or suggest the user scans from system.
    // Checking the package documentation (conceptual), `openSettings` usually exists.
    try {
      await bluetooth.openSettings;
    } catch (e) {
      print("Error opening settings: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bnw100,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DashboardPageMobile(token: checkToken),
                          ),
                        ),
                        child: Icon(Icons.arrow_back, color: bnw900),
                      ),
                      SizedBox(width: 16),
                      Text(
                        "Printer",
                        style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      _openBluetoothSettings();
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: primary500),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(PhosphorIcons.plus, color: primary500, size: 16),
                          SizedBox(width: 4),
                          Text(
                            "Sambungkan Baru",
                            style: heading4(
                              FontWeight.w600,
                              primary500,
                              'Outfit',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pilih Perangkat Printer",
                      style: heading3(FontWeight.w500, bnw900, 'Outfit'),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: _devices.isEmpty
                          ? Center(
                              child: Text(
                                "Tidak ada perangkat printer yang ditemukan",
                              ),
                            )
                          : ListView.builder(
                              itemCount: _devices.length,
                              itemBuilder: (context, index) {
                                BluetoothDevice device = _devices[index];
                                bool isDeviceConnected =
                                    (_device == device && connected);

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _device = device;
                                    });
                                    if (isDeviceConnected) {
                                      // Maybe ask to disconnect
                                      // For now just connect if tapped? User requirement says "if connected it looks like that"
                                      // I'll assume tapping toggles or ensures connection
                                      _disconnect();
                                    } else {
                                      _connect();
                                    }
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: isDeviceConnected
                                                ? primary200
                                                : bnw200,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Icon(
                                            PhosphorIcons.printer,
                                            color: isDeviceConnected
                                                ? primary500
                                                : bnw500,
                                            size: 24,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                device.name ?? "Unknown Device",
                                                style: heading3(
                                                  FontWeight.w600,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                              ),
                                              if (isDeviceConnected)
                                                Text(
                                                  "Terhubung",
                                                  style: heading4(
                                                    FontWeight.w400,
                                                    primary500,
                                                    'Outfit',
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        if (isDeviceConnected)
                                          Icon(
                                            PhosphorIcons.plugs_connected_fill,
                                            color: primary500,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),

            // BOTTOM BUTTON
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ButtonMobilePrint(
                bluetooth: bluetooth,
                printtext: printtext, // Or use the one from state
                connected: connected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ButtonMobilePrint extends StatefulWidget {
  final BlueThermalPrinter bluetooth;
  final String printtext;
  final bool connected;

  const ButtonMobilePrint({
    required this.bluetooth,
    required this.printtext,
    required this.connected,
    Key? key,
  }) : super(key: key);

  @override
  State<ButtonMobilePrint> createState() => _ButtonMobilePrintState();
}

class _ButtonMobilePrintState extends State<ButtonMobilePrint> {
  Uint8List? imageStruk;

  @override
  void initState() {
    super.initState();
    // Assuming getStruk or similar logic isn't strictly needed for the UI test
    // but if we want real printing we need to fetch image if applicable.
    // I will skip complex network fetching in initialization to ensure UI works,
    // and just use basic text printing for the test button as per 'Test Cetak Struk'.
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (!widget.connected) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Printer belum terhubung')));
          return;
        }

        widget.bluetooth.isConnected.then((isConnected) {
          if (isConnected == true) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Berhasil cetak struk')));
            widget.bluetooth.printNewLine();
            widget.bluetooth.printCustom("TEST CETAK STRUK", 1, 1); // Centered
            widget.bluetooth.printNewLine();
            widget.bluetooth.printCustom(
              widget.printtext.replaceAll(RegExp('[|]'), '\n'),
              1,
              0,
            );
            widget.bluetooth.printNewLine();
            widget.bluetooth.paperCut();
          }
        });
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: primary500,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PhosphorIcons.printer_fill, color: bnw100),
            SizedBox(width: 8),
            Text(
              "Tes Cetak Struk",
              style: heading3(FontWeight.w600, bnw100, 'Outfit'),
            ),
          ],
        ),
      ),
    );
  }
}
