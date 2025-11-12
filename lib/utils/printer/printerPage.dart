import 'dart:developer';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';

import '../../main.dart';
import '../../pageTablet/tokopage/sidebar/transaksiToko/transaksi.dart';
import '../../services/apimethod.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import '../component/component_showModalBottom.dart';
import '../component/component_size.dart';
import '../component/component_snackbar.dart';
import 'printerenum.dart';
import 'package:path_provider/path_provider.dart';

import '../../services/checkConnection.dart';

import '../component/component_button.dart';
import '../component/component_color.dart';
import 'testprint.dart';

BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
List<BluetoothDevice> _devices = [];
BluetoothDevice? _device;
bool connected = false;
TestPrint testPrint = TestPrint();

class BluetoothPage extends StatefulWidget {
  BluetoothPage({Key? key}) : super(key: key);

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  final String printtext =
      'LOKET          : PARENT||22/06/2020 00:23:52|STATUS         : TOPUP-SUKSES|HARGA          : Rp      Rp 26.000|TRX ID         : 000077111314|KODE PRODUK    : PAYBANK||STRUK TRANSFER BCA||TANGGAL : 2020-06-22 00:23:58|NO. REK : 5465327020|NAMA    : FLIPTECH LENTERA IP PT|BANK    : BCA|JUMLAH  : Rp.       20.000|ADMIN   : Rp.        5.000|TOTAL   : Rp.       25.000|BERITA  : -';

  @override
  void initState() {
    super.initState();
    initPlatformState();
    // initLogoState();
  }

  // Future<void> initLogoState() async {
  //   var response = await http.get(Uri.parse("https://pentes.cashplus.id:3501/get_img?file=logo_print.png"));
  //   Uint8List bytesNetwork = response.bodyBytes;
  //   Uint8List image = bytesNetwork.buffer.asUint8List(bytesNetwork.offsetInBytes, bytesNetwork.lengthInBytes);

  //   setState(() {
  //     img = image;
  //   });
  // }

  Future<void> initPlatformState() async {
    // TODO here add a permission request using permission_handler
    bool? isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];

    // Init logo
    // var response = await http.get(Uri.parse(
    //   "https://pentes.cashplus.id:3501/get_img?file=logo_print.png"));
    // Uint8List bytesNetwork = response.bodyBytes;

    // setState(() {
    //   bytesNetwork = bytesNetwork.buffer
    //     .asUint8List(bytesNetwork.offsetInBytes, bytesNetwork.lengthInBytes);
    // });

    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {}

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            connected = true;
            print("bluetooth device state: connected");
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            connected = false;
            print("bluetooth device state: disconnected");
          });
          break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
          setState(() {
            connected = false;
            print("bluetooth device state: disconnect requested");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          setState(() {
            connected = false;
            print("bluetooth device state: bluetooth turning off");
          });
          break;
        case BlueThermalPrinter.STATE_OFF:
          setState(() {
            connected = false;
            print("bluetooth device state: bluetooth off");
          });
          break;
        case BlueThermalPrinter.STATE_ON:
          setState(() {
            connected = false;
            print("bluetooth device state: bluetooth on");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_ON:
          setState(() {
            connected = false;
            print("bluetooth device state: bluetooth turning on");
          });
          break;
        case BlueThermalPrinter.ERROR:
          setState(() {
            connected = false;
            print("bluetooth device state: error");
          });
          break;
        default:
          print(state);
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

  bool lihatSemua = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showModalBottomExit(context);
        return false;
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(size16, size48, size16, size16),
        padding: EdgeInsets.all(size16),
        decoration: BoxDecoration(
          color: bnw100,
          borderRadius: BorderRadius.circular(size16),
        ),
        child: RefreshIndicator(
          color: bnw100,
          onRefresh: () async {
            initPlatformState();
            setState(() {});
          },
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Printer',
                          style: heading1(FontWeight.w700, bnw900, 'Outfit')),
                      Text('Pengaturan printer',
                          style: heading3(FontWeight.w300, bnw500, 'Outfit')),
                    ],
                  ),
                  Row(
                    children: [
                      // buttonXLoutline(
                      //   Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //     children: [
                      //       Icon(
                      //         PhosphorIcons.plus,
                      //         color: primary500,
                      //       ),
                      //       Text(
                      //         'Sambungkan perangkat baru',
                      //         style:
                      //             heading3(FontWeight.w600, primary500, 'Outfit'),
                      //       )
                      //     ],
                      //   ),
                      //   270,
                      //   primary500,
                      // ),
                      SizedBox(width: size12),
                      SizedBox(
                        width: 200,
                        child: ButtonPrint(
                          bluetooth: bluetooth,
                          printtext: 'Test Cetak Struk Berhasil!',
                          widgetku: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(PhosphorIcons.printer_fill, color: bnw100),
                              SizedBox(width: size12),
                              Text(
                                'Test Cetak Struk',
                                style:
                                    heading3(FontWeight.w600, bnw100, 'Outfit'),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
              ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                itemCount: lihatSemua
                    ? _devices.length + 1
                    : min(_devices.length + 1, 6),
                itemBuilder: (BuildContext context, int index) {
                  if (_devices.isEmpty) {
                    return Text('NONE');
                  } else if (index == 0) {
                    return Text("Daftar Perangkat Printer:");
                  } else {
                    BluetoothDevice device = _devices[index - 1];
                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        _device = device;
                        _devices.remove(device);
                        _devices.insert(0, device);
                        // ontap = true;
                        setState(() {
                          _connect();
                          // connected ? _disconnect() : _connect();
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: size12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: primary200,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(PhosphorIcons.printer_fill,
                                          color: primary500),
                                    ),
                                    SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          device.name ?? "",
                                          style: heading3(FontWeight.w600,
                                              bnw900, 'Outfit'),
                                        ),
                                        if (_device == device)
                                          if (connected)
                                            Text(
                                              "Terhubung",
                                              style: body1(FontWeight.w400,
                                                  primary500, 'Outfit'),
                                            )
                                          else
                                            Container(),
                                      ],
                                    ),
                                  ],
                                ),
                                _device == device
                                    ? Row(
                                        children: [
                                          Text(
                                            '|',
                                            style: heading1(FontWeight.w400,
                                                bnw300, 'Outfit'),
                                          ),
                                          SizedBox(width: size12),
                                          InkWell(
                                            onTap: () {
                                              // connected ? _disconnect() : _connect();
                                              showBottomPilihan(
                                                context,
                                                Column(
                                                  children: [
                                                    Text(
                                                      'Kamu Yakin Ingin Memutus Sambungan Perangkat Printer?',
                                                      style: heading1(
                                                        FontWeight.w600,
                                                        bnw900,
                                                        'Outfit',
                                                      ),
                                                    ),
                                                    SizedBox(height: size16),
                                                    Text(
                                                      'Setelah sambungan diputus. printer tidak akan bisa mencetak struk',
                                                      style: heading2(
                                                        FontWeight.w400,
                                                        bnw900,
                                                        'Outfit',
                                                      ),
                                                    ),
                                                    SizedBox(height: size16),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child:
                                                              GestureDetector(
                                                            onTap: () async {
                                                              _disconnect();
                                                              Navigator.pop(
                                                                  context);
                                                              setState(() {});
                                                            },
                                                            child:
                                                                buttonXLoutline(
                                                              Center(
                                                                  child: Text(
                                                                'Iya, Putuskan',
                                                                style: heading3(
                                                                  FontWeight
                                                                      .w600,
                                                                  primary500,
                                                                  'Outfit',
                                                                ),
                                                              )),
                                                              MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  3,
                                                              primary500,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: size16),
                                                        Expanded(
                                                          child:
                                                              GestureDetector(
                                                            onTap: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            child: buttonXL(
                                                                Center(
                                                                    child: Text(
                                                                  'Batalkan',
                                                                  style:
                                                                      heading3(
                                                                    FontWeight
                                                                        .w600,
                                                                    bnw100,
                                                                    'Outfit',
                                                                  ),
                                                                )),
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    3),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              );
                                            },
                                            child: Padding(
                                              padding:
                                                  EdgeInsets.only(right: size8),
                                              child: Icon(
                                                PhosphorIcons.plugs,
                                                color: bnw900,
                                                size: size32,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: size12),
              GestureDetector(
                onTap: () {
                  setState(() {
                    lihatSemua = !lihatSemua;
                    print(lihatSemua);
                  });
                },
                child: SizedBox(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(size8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(size8),
                        ),
                        child: Icon(
                            lihatSemua != true
                                ? PhosphorIcons.caret_right
                                : PhosphorIcons.caret_up,
                            color: bnw900),
                      ),
                      SizedBox(width: size12),
                      Text(lihatSemua != true ? 'Lihat Semua' : 'Lihat Sedikit',
                          style: heading3(FontWeight.w600, bnw900, 'Outfit')),
                    ],
                  ),
                ),
              ),
              Container(
                height: 42,
                padding: EdgeInsets.only(left: size12),
                width: double.infinity,
                color: bnw200,
                child: Row(
                  children: [
                    Icon(
                      PhosphorIcons.info_fill,
                      color: bnw600,
                    ),
                    SizedBox(width: size12),
                    Text(
                      'Jika perangkat tidak ada dalam daftar perangkat. Silahkan untuk hubungkan perangkat baru.',
                      style: heading4(FontWeight.w400, bnw600, 'Outfit'),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showToast(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text('click print'),
        action: SnackBarAction(
            label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devices.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devices.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name ?? ""),
          value: device,
        ));
      });
    }
    return items;
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
      show('No device selected.');
    }
  }

  void _disconnect() {
    bluetooth.disconnect();
    setState(() => connected = false);
  }

  Future show(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: bnw100),
        ),
        duration: duration,
      ),
    );
  }
}

class ButtonPrint extends StatefulWidget {
  ButtonPrint({
    Key? key,
    required this.bluetooth,
    required this.printtext,
    required this.widgetku,
  }) : super(key: key);

  final BlueThermalPrinter bluetooth;
  final String printtext;
  final Widget widgetku;

  @override
  State<ButtonPrint> createState() => _ButtonPrintState();
}

class _ButtonPrintState extends State<ButtonPrint> {
  late Uint8List imageStruk;

  getStrukPhoto() async {
    var response = await http.get(Uri.parse(logoStrukPrinter!));
    Uint8List bytesNetwork = response.bodyBytes;
    Uint8List imageBytesFromNetwork = bytesNetwork.buffer
        .asUint8List(bytesNetwork.offsetInBytes, bytesNetwork.lengthInBytes);

    imageStruk = imageBytesFromNetwork;

    setState(() {});
  }

  @override
  void initState() {
    getStruk(context, checkToken, '');
    if (logoStrukPrinter != '') {
      getStrukPhoto();
    }

    logoStrukPrinter;
    widget.printtext;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        print(logoStrukPrinter);
        if (logoStrukPrinter != '') {
          getStrukPhoto();
        }

        widget.bluetooth.isConnected.then((isConnected) {
          if (isConnected == true) {
            showSnackBarComponent(context, 'Berhasil cetak struk', '00');
            // widget.bluetooth.printNewLine();
            logoStrukPrinter!.isEmpty
                ? widget.bluetooth.printNewLine()
                : bluetooth.printImageBytes(imageStruk);
            widget.bluetooth.printNewLine();
            widget.bluetooth.printCustom(
                widget.printtext.replaceAll(RegExp('[|]'), '\n'),
                Size.medium.val,
                0);
            // widget.bluetooth.printCustom(
            //     widget.printtext.replaceAll(RegExp('[|]'), '\n'),
            //     Size.bold.val,
            //     0);
            widget.bluetooth.printNewLine();
            widget.bluetooth.paperCut();
          } else {
            dialogNoPrinter(context);
          }
        });
      },
      child: buttonXL(
        widget.widgetku,
        double.infinity,
      ),
    );
    // Padding(
    //   padding:  EdgeInsets.only(left: 10.0, right: 10.0, top: 50),
    //   child: ElevatedButton(
    //     style: ElevatedButton.styleFrom(primary: Colors.brown),
    //     onPressed: () async {
    //       String filename = "logo_print.png";
    //       ByteData bytesData = await rootBundle.load("assets/bantuan.png");
    //       String dir = (await getApplicationDocumentsDirectory()).path;
    //       File file = await File('$dir/$filename').writeAsBytes(bytesData.buffer
    //           .asInt8List(bytesData.offsetInBytes, bytesData.lengthInBytes));
    //       bluetooth.isConnected.then((isConnected) {
    //         if (isConnected == true) {
    //           bluetooth.printNewLine();
    //           bluetooth.printNewLine();
    //           bluetooth.printImage(file.path);
    //           // bluetooth.printImageBytes(
    //           //     img); //image from Network
    //           bluetooth.printNewLine();
    //           bluetooth.printNewLine();
    //           bluetooth.printCustom(
    //               printtext.replaceAll(RegExp('[|]'), '\n'), Size.bold.val, 0);
    //           bluetooth.printNewLine();
    //           bluetooth.paperCut();
    //         }
    //       });
    //     },
    //     child:  Text('PRINT TEST', style: TextStyle(color: Colors.white)),
    //   ),
    // );
  }
}
