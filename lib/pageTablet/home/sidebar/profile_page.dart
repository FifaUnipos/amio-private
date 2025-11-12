import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:io' as Io;
import 'dart:typed_data';
import 'package:unipos_app_335/utils/component/component_snackbar.dart';

import '../../../pagehelper/masukakun.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import '../../../../utils/component/component_size.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import '../../../../utils/component/component_showModalBottom.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart';
import '../../../pagehelper/loginregis/login_page.dart';
import '../../../services/apimethod.dart';
import '../../../services/checkConnection.dart';
import '../../../utils/component/component_loading.dart';
import '../../../utils/component/providerModel/timerModel.dart';
import '../../tokopage/dashboardtoko.dart';
import '../../../../utils/component/component_button.dart';
import '../../../../utils/component/component_color.dart';

class ProfilePage extends StatefulWidget {
  String token;
  ProfilePage({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  late TextEditingController controllerName =
      TextEditingController(text: nameProfile);
  late TextEditingController controllerPhone =
      TextEditingController(text: phoneProfile);
  late TextEditingController controllerEmail =
      TextEditingController(text: emailProfile);

  var controllerPass = TextEditingController();
  var controllerConfirmPass = TextEditingController();
  var controllerChangeEmail = TextEditingController();
  var controllerChangePass = TextEditingController();

  var conOldPass = TextEditingController();
  var conNewPass = TextEditingController();
  var conConPass = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  String errorShowKonfirmasiText = '';
  String currentText = "";

  bool isKeyboardActive = false;
  bool _obscureText = true;
  bool _obscureText2 = true;

  String imageError = 'false';

  File? myImage;
  Uint8List? bytes;
  String? img64;
  List<String> images = [];

  ValueNotifier<String> myValue = ValueNotifier<String>('');

  Future<void> getImage() async {
    var picker = ImagePicker();
    PickedFile? image;

    image = await picker.getImage(
      source: ImageSource.gallery,
      maxHeight: 900,
      maxWidth: 900,
    );
    if (image!.path.isEmpty == false) {
      myImage = File(image.path);

      bytes = await Io.File(myImage!.path).readAsBytes();
      setState(() {
        img64 = base64Encode(bytes!);
        images.add(img64!);
        myValue.value = 'getImage';
      });
      // Clipboard.setData(ClipboardData(text: img64));
    } else {
      print('Error Image');
    }
  }

  OtpFieldController otpController = OtpFieldController();
  TextEditingController otpControllerFix = TextEditingController();
  late String otpText;

  FocusNode focusNode = FocusNode();

  clearForm() {
    otpControllerFix.text = '';
    errorText = '';
  }

  @override
  void initState() {
    checkEmail(widget.token, setState);
    checkConnection(context);
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        myprofile(widget.token);

        nameProfile;
        statusProfile;
        emailProfile;
        phoneProfile;
        imageProfile;

        myImage;

        emailChecker;
        checkEmail(widget.token, setState);
        setState(() {});
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    controllerName.dispose();
    nameProfile.dispose();
    controllerPhone.dispose();
    phoneProfile.dispose();
    controllerEmail.dispose();
    emailProfile.dispose();
    controllerPass.dispose();
    controllerConfirmPass.dispose();
    controllerChangeEmail.dispose();
    controllerChangePass.dispose();
    conOldPass.dispose();
    conNewPass.dispose();
    conConPass.dispose();
    focusNode.dispose();
    otpControllerFix.dispose();

    super.dispose();
  }

  void _reloadPage() {
    setState(() {});
  }

  refreshField() {
    conOldPass.text = '';
    controllerChangePass.text = '';
    controllerConfirmPass.text = '';
  }

  @override
  Widget build(BuildContext context) {
    if (nameProfile == null) {
      return CircularProgressIndicator();
    }
    return WillPopScope(
      onWillPop: () async {
        showModalBottomExit(context);
        return false;
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(size16),
        margin: EdgeInsets.fromLTRB(size16, size48, size16, size16),
        decoration: BoxDecoration(
          color: bnw100,
          borderRadius: BorderRadius.circular(size16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile Anda',
                        style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                      ),
                      Text(
                        'Hai, $nameProfile',
                        style: heading3(FontWeight.w300, bnw500, 'Outfit'),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomProfile(
                        // shape:  RoundedRectangleBorder(
                        //   borderRadius: BorderRadius.only(
                        //     topRight: Radius.circular(12),
                        //     topLeft: Radius.circular(12),
                        //   ),
                        // ),

                        context,
                        MediaQuery.of(context).size.height / 2.8,
                        Column(
                          children: [
                            dividerShowdialog(),
                            SizedBox(height: size16),
                            Text(
                              'Kamu yakin ingin keluar akun?',
                              style:
                                  heading1(FontWeight.w600, bnw900, 'Outfit'),
                            ),
                            SizedBox(height: size8),
                            Text(
                              'Jika kamu keluar, kamu harus memasukkan akun lagi untuk melakukkan transaksi.',
                              style:
                                  heading2(FontWeight.w400, bnw900, 'Outfit'),
                            ),
                            SizedBox(height: size32),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: buttonXLoutline(
                                      Center(
                                        child: Text(
                                          'Gak Jadi',
                                          style: heading3(FontWeight.w600,
                                              primary500, 'Outfit'),
                                        ),
                                      ),
                                      MediaQuery.of(context).size.width,
                                      primary500,
                                    ),
                                  ),
                                ),
                                SizedBox(width: size16),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      // Isolate.current.kill(priority: Isolate.immediate);
                                      // runApp();

                                      logout(
                                        widget.token,
                                        identifier,
                                        context,
                                        LoginPage(),
                                      );

                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      prefs.remove('token');
                                      prefs.remove('deviceid');
                                      prefs.remove('notifications');
                                      prefs.remove('roleAccount');
                                      prefs.remove('typeAccount');
                                      prefs.clear();

                                      selectedIndexSideBar = false;
                                      showingMenuSidebar == true;

                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (context) => MasukAkunPage(),
                                        ),
                                        (Route<dynamic> route) => false,
                                      );
                                    },
                                    child: buttonXL(
                                      Center(
                                        child: Text(
                                          'Iya, Keluar',
                                          style: heading3(FontWeight.w600,
                                              bnw100, 'Outfit'),
                                        ),
                                      ),
                                      MediaQuery.of(context).size.width,
                                      // primary500,
                                      // primary500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    child: buttonXXLoutline(
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              PhosphorIcons.sign_out_bold,
                              color: bnw900,
                              size: size32,
                            ),
                            SizedBox(width: size16),
                            Text(
                              'Keluar Akun',
                              style:
                                  heading3(FontWeight.w600, bnw900, 'Outfit'),
                            ),
                          ],
                        ),
                        0,
                        bnw900),
                  ),
                ],
              ),
            ),
            SizedBox(height: size16),
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(size16),
                decoration: BoxDecoration(
                  color: bnw100,
                  border: Border.all(color: bnw300),
                  borderRadius: BorderRadius.circular(size16),
                ),
                child: RefreshIndicator(
                  color: bnw100,
                  backgroundColor: primary500,
                  onRefresh: () async {
                    initState();
                    setState(() {});
                  },
                  child: ListView(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    padding: EdgeInsets.zero,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                imageProfile == null
                                    ? Container(
                                        height: 227,
                                        width: 227,
                                        child: CircleAvatar(
                                          backgroundColor: primary200,
                                          radius: 50,

                                          // backgroundImage: NetworkImage(imageUrl),
                                          child: Center(
                                            child: Text(
                                              getInitials().toUpperCase(),
                                              style: heading1(FontWeight.w600,
                                                  bnw900, 'Outfit'),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(120),
                                          // border: Border.all(),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(120),
                                          child: Image.network(imageProfile,
                                              height: 227,
                                              width: 227,
                                              fit: BoxFit.cover, loadingBuilder:
                                                  (context, child,
                                                      loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }

                                            return Center(child: loading());
                                          }, errorBuilder:
                                                  (context, error, stackTrace) {
                                            imageError = 'true';
                                            return SizedBox(
                                              height: 227,
                                              width: 227,
                                              child: CircleAvatar(
                                                backgroundColor: primary200,
                                                radius: 50,

                                                // backgroundImage: NetworkImage(imageUrl),
                                                child: Center(
                                                  child: Text(
                                                    getInitials().toUpperCase(),
                                                    style: heading1(
                                                        FontWeight.w600,
                                                        bnw900,
                                                        'Outfit'),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                      ),
                                SizedBox(height: size16),
                                GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                        constraints: const BoxConstraints(
                                          maxWidth: double.infinity,
                                        ),
                                        isScrollControlled: true,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        context: context,
                                        builder: (context) => IntrinsicHeight(
                                          child: Container(
                                            padding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                    .viewInsets
                                                    .bottom),
                                            decoration: BoxDecoration(
                                              color: bnw100,
                                              borderRadius: BorderRadius.only(
                                                topRight:
                                                    Radius.circular(size8),
                                                topLeft: Radius.circular(size8),
                                              ),
                                            ),
                                            child: ValueListenableBuilder(
                                              valueListenable: myValue,
                                              builder: (context, value, _) =>
                                                  Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    size32,
                                                    size16,
                                                    size32,
                                                    size32),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      margin:
                                                          EdgeInsets.all(size8),
                                                      height: 4,
                                                      width: 140,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    size8),
                                                        color: bnw300,
                                                      ),
                                                    ),
                                                    myValue.value != 'getImage'
                                                        ? Column(
                                                            children: [
                                                              SizedBox(
                                                                  height:
                                                                      size8),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    'Foto Profil',
                                                                    style: heading1(
                                                                        FontWeight
                                                                            .w600,
                                                                        bnw900,
                                                                        'Outfit'),
                                                                  ),
                                                                  GestureDetector(
                                                                    onTap: () =>
                                                                        Navigator.pop(
                                                                            context),
                                                                    child: Icon(
                                                                        PhosphorIcons
                                                                            .x_fill,
                                                                        size:
                                                                            size32,
                                                                        color:
                                                                            bnw900),
                                                                  ),
                                                                ],
                                                              ),
                                                              imageProfile ==
                                                                      null
                                                                  ? Container(
                                                                      margin: EdgeInsets
                                                                          .only(
                                                                              top: size12),
                                                                      height:
                                                                          180,
                                                                      width:
                                                                          180,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(120),
                                                                        color:
                                                                            bnw300,
                                                                      ),
                                                                      child: myValue.value !=
                                                                              'getImage'
                                                                          ? CircleAvatar(
                                                                              backgroundColor: primary200,
                                                                              radius: 50,
                                                                              // backgroundImage: NetworkImage(imageUrl),
                                                                              child: Center(
                                                                                child: Text(
                                                                                  getInitials().toUpperCase(),
                                                                                  style: heading1(FontWeight.w600, bnw900, 'Outfit'),
                                                                                ),
                                                                              ),
                                                                            )
                                                                          : ClipRRect(
                                                                              borderRadius: BorderRadius.circular(120),
                                                                              child: Image.memory(
                                                                                base64Decode(img64.toString()),
                                                                                // myImage!,
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                            ),
                                                                    )
                                                                  : Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(120),
                                                                        // border: Border.all(),
                                                                      ),
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(120),
                                                                        child: Image
                                                                            .network(
                                                                          imageProfile,
                                                                          height:
                                                                              227,
                                                                          width:
                                                                              227,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          loadingBuilder: (context,
                                                                              child,
                                                                              loadingProgress) {
                                                                            if (loadingProgress ==
                                                                                null) {
                                                                              return child;
                                                                            }

                                                                            return Center(child: loading());
                                                                          },
                                                                          errorBuilder: (context, error, stackTrace) =>
                                                                              Container(
                                                                            margin:
                                                                                EdgeInsets.only(top: 10),
                                                                            height:
                                                                                180,
                                                                            width:
                                                                                180,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(120),
                                                                              color: bnw300,
                                                                            ),
                                                                            child: myValue.value != 'getImage'
                                                                                ? CircleAvatar(
                                                                                    backgroundColor: primary200,
                                                                                    radius: 50,
                                                                                    // backgroundImage: NetworkImage(imageUrl),
                                                                                    child: Center(
                                                                                      child: Text(
                                                                                        getInitials().toUpperCase(),
                                                                                        style: heading1(FontWeight.w600, bnw900, 'Outfit'),
                                                                                      ),
                                                                                    ),
                                                                                  )
                                                                                : ClipRRect(
                                                                                    borderRadius: BorderRadius.circular(120),
                                                                                    child: Image.memory(
                                                                                      base64Decode(img64.toString()),
                                                                                      // myImage!,
                                                                                      fit: BoxFit.cover,
                                                                                    ),
                                                                                  ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                            ],
                                                          )
                                                        : Column(
                                                            children: [
                                                              SizedBox(
                                                                  height:
                                                                      size16),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    'Foto Profil',
                                                                    style: heading1(
                                                                        FontWeight
                                                                            .w600,
                                                                        bnw900,
                                                                        'Outfit'),
                                                                  ),
                                                                  GestureDetector(
                                                                    onTap: () =>
                                                                        Navigator.pop(
                                                                            context),
                                                                    child: Icon(
                                                                      PhosphorIcons
                                                                          .x_fill,
                                                                      size:
                                                                          size32,
                                                                      color:
                                                                          bnw900,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        top:
                                                                            size12),
                                                                height: 180,
                                                                width: 180,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              120),
                                                                  color: bnw300,
                                                                ),
                                                                child: myValue !=
                                                                        'getImage'
                                                                    ? CircleAvatar(
                                                                        backgroundColor:
                                                                            primary200,
                                                                        radius:
                                                                            50,
                                                                        // backgroundImage: NetworkImage(imageUrl),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Text(
                                                                            getInitials().toUpperCase(),
                                                                            style: heading1(
                                                                                FontWeight.w600,
                                                                                bnw900,
                                                                                'Outfit'),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(120),
                                                                        child: Image
                                                                            .memory(
                                                                          base64Decode(
                                                                              img64.toString()),
                                                                          // myImage!,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                      ),
                                                              ),
                                                            ],
                                                          ),
                                                    SizedBox(height: size16),
                                                    Column(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () async {
                                                            await getImage()
                                                                .then(
                                                              (value) =>
                                                                  changePhoto(
                                                                widget.token,
                                                                identifier,
                                                                context,
                                                                img64,
                                                                _reloadPage,
                                                              ).then((value) {
                                                                imageError =
                                                                    'false';
                                                                initState();
                                                              }),
                                                            );
                                                          },
                                                          child: SizedBox(
                                                            child:
                                                                TextFormField(
                                                              enabled: false,
                                                              style: heading3(
                                                                  FontWeight
                                                                      .w400,
                                                                  bnw900,
                                                                  'Outfit'),
                                                              decoration:
                                                                  InputDecoration(
                                                                      focusColor:
                                                                          primary500,
                                                                      prefixIcon:
                                                                          Icon(
                                                                        PhosphorIcons
                                                                            .plus,
                                                                        color:
                                                                            bnw900,
                                                                      ),
                                                                      hintText:
                                                                          'Tambah Foto',
                                                                      hintStyle: heading3(
                                                                          FontWeight
                                                                              .w400,
                                                                          bnw900,
                                                                          'Outfit')),
                                                            ),
                                                          ),
                                                        ),
                                                        imageError == 'false'
                                                            ? GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  changePhoto(
                                                                    widget
                                                                        .token,
                                                                    identifier,
                                                                    context,
                                                                    '',
                                                                    _reloadPage,
                                                                  ).then(
                                                                      (value) {
                                                                    imageError =
                                                                        'false';
                                                                    initState();
                                                                  });
                                                                },
                                                                child: SizedBox(
                                                                  child:
                                                                      TextFormField(
                                                                    enabled:
                                                                        false,
                                                                    style: heading3(
                                                                        FontWeight
                                                                            .w400,
                                                                        bnw900,
                                                                        'Outfit'),
                                                                    decoration:
                                                                        InputDecoration(
                                                                      focusColor:
                                                                          primary500,
                                                                      prefixIcon:
                                                                          Icon(
                                                                        PhosphorIcons
                                                                            .trash,
                                                                        color:
                                                                            bnw900,
                                                                      ),
                                                                      hintText:
                                                                          'Hapus Foto',
                                                                      hintStyle:
                                                                          heading3(
                                                                        FontWeight
                                                                            .w400,
                                                                        bnw900,
                                                                        'Outfit',
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            : SizedBox(),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: imageError == 'true'
                                        ? SizedBox(
                                            width: double.infinity,
                                            child: buttonXLoutline(
                                                Center(
                                                  child: Text(
                                                      'Tambah Foto Profil',
                                                      style: heading3(
                                                          FontWeight.w600,
                                                          primary500,
                                                          'Outfit')),
                                                ),
                                                double.infinity,
                                                primary500))
                                        : SizedBox(
                                            width: double.infinity,
                                            child: buttonXL(
                                              Center(
                                                child: Text('Ganti Foto Profil',
                                                    style: heading3(
                                                        FontWeight.w600,
                                                        bnw100,
                                                        'Outfit')),
                                              ),
                                              double.infinity,
                                            ),
                                          )),
                              ],
                            ),
                          ),
                          SizedBox(width: size16),
                          Flexible(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Personal Info',
                                  style: heading2(
                                      FontWeight.w700, bnw900, 'Outfit'),
                                ),
                                ubahNamaLengkapField(context),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 2.2,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 136,
                                        child: Text(
                                          'Status',
                                          style: heading3(FontWeight.w400,
                                              bnw900, 'Outfit'),
                                        ),
                                      ),
                                      SizedBox(width: size16),
                                      Expanded(
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3.3,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                child: Text(
                                                    statusProfile ==
                                                            'Group_Merchant'
                                                        ? 'Grup Toko'
                                                        : 'Toko',
                                                    style: heading3(
                                                        FontWeight.w600,
                                                        bnw900,
                                                        'Outfit')),
                                              ),
                                              // SizedBox(width: 40),
                                              SizedBox(
                                                child: Text('',
                                                    style: heading3(
                                                        FontWeight.w600,
                                                        bnw900,
                                                        'Outfit')),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                editPhoneField(context),
                                editEmailField(context),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 40),
                                    Text(
                                      'Keamanan',
                                      style: heading2(
                                          FontWeight.w700, bnw900, 'Outfit'),
                                    ),
                                    editPasswordField(context),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ubahNamaLengkapField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: size16),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 136,
                child: Text('Nama Lengkap',
                    style: heading3(FontWeight.w400, bnw900, 'Outfit')),
              ),
              SizedBox(width: size16),
              Expanded(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          child: Text(
                            nameProfile,
                            style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              constraints: const BoxConstraints(
                                maxWidth: double.infinity,
                              ),
                              isScrollControlled: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              context: context,
                              builder: (context) => IntrinsicHeight(
                                child: Container(
                                  padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom),
                                  // height: MediaQuery.of(context).size.height / 1,
                                  decoration: BoxDecoration(
                                    color: bnw100,
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(12),
                                      topLeft: Radius.circular(12),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        size32, size16, size32, size32),
                                    child: Column(
                                      children: [
                                        dividerShowdialog(),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: size16),
                                            Text(
                                              'Ubah Nama Lengkap',
                                              style: heading1(FontWeight.w700,
                                                  bnw900, 'Outfit'),
                                            ),
                                            SizedBox(height: size16),
                                            Row(
                                              children: [
                                                Text(
                                                  'Nama Lengkap ',
                                                  style: heading4(
                                                      FontWeight.w400,
                                                      bnw900,
                                                      'Outfit'),
                                                ),
                                                Text(
                                                  '*',
                                                  style: heading4(
                                                      FontWeight.w400,
                                                      danger500,
                                                      'Outfit'),
                                                ),
                                              ],
                                            ),
                                            FocusScope(
                                              child: Focus(
                                                onFocusChange: (value) {
                                                  isKeyboardActive = value;
                                                  setState(() {});
                                                },
                                                child: TextFormField(
                                                  style: heading2(
                                                    FontWeight.w600,
                                                    bnw900,
                                                    'Outfit',
                                                  ),
                                                  controller: controllerName,
                                                  decoration: InputDecoration(
                                                      focusColor: primary500,
                                                      hintText:
                                                          'Cth : Muhammad Nabil Musyaffa',
                                                      hintStyle: heading2(
                                                        FontWeight.w600,
                                                        bnw400,
                                                        'Outfit',
                                                      )),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: size32),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: buttonXLoutline(
                                                  Center(
                                                    child: Text(
                                                      'Batal',
                                                      style: heading3(
                                                          FontWeight.w600,
                                                          primary500,
                                                          'Outfit'),
                                                    ),
                                                  ),
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  primary500,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: size16),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  whenLoading(context);
                                                  changeName(
                                                    widget.token,
                                                    identifier,
                                                    context,
                                                    controllerName.text,
                                                  ).then(
                                                    (value) async {
                                                      if (value == '00') {
                                                        setState(() {});
                                                        await Future.delayed(
                                                            Duration(
                                                                seconds: 1));
                                                        Navigator.of(context)
                                                            .popUntil((route) =>
                                                                route.isFirst);
                                                        initState();
                                                      }
                                                    },
                                                  );
                                                  errorText = '';
                                                  setState(() {});
                                                  initState();
                                                },
                                                child: buttonXL(
                                                  Center(
                                                    child: Text(
                                                      'Simpan',
                                                      style: heading3(
                                                          FontWeight.w600,
                                                          bnw100,
                                                          'Outfit'),
                                                    ),
                                                  ),
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                ),
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
                          child: Text(
                            'Ubah',
                            style:
                                heading3(FontWeight.w400, primary500, 'Outfit'),
                          ),
                        ),
                      ]),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: size16),
      ],
    );
  }

  editPhoneField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: size16),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 136,
                child: Text('Nomor Telepon',
                    style: heading3(FontWeight.w400, bnw900, 'Outfit')),
              ),
              SizedBox(width: size16),
              Expanded(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 3.3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(phoneProfile ?? '',
                            style: heading3(FontWeight.w600, bnw900, 'Outfit')),
                      ),
                      GestureDetector(
                        onTap: () {
                          showError(context, false, false, true);
                        },
                        child: Text(
                          'Ubah',
                          style:
                              heading3(FontWeight.w400, primary500, 'Outfit'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        //  SizedBox(height: size16),
      ],
    );
  }

  Future<dynamic> showError(BuildContext context, bool checkShow, sandi, ubah) {
    return showModalBottomSheet(
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
      ),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      context: context,
      builder: (context) => IntrinsicHeight(
        child: Container(
          // height: MediaQuery.of(context).size.height / 1,
          padding: EdgeInsets.fromLTRB(size32, size16, size32, size32),
          decoration: BoxDecoration(
            color: bnw100,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(12),
              topLeft: Radius.circular(12),
            ),
          ),
          child: Column(
            children: [
              dividerShowdialog(),
              SizedBox(height: size16),
              Column(
                children: [
                  checkShow == true
                      ? Center(
                          child: Column(
                            children: [
                              SvgPicture.asset(
                                'assets/illustration/errorPayment.svg',
                                height:
                                    MediaQuery.of(context).size.height / 2.2,
                              ),
                              Text(
                                sandi == true
                                    ? 'Maaf, kamu belum membuat kata sandi.'
                                    : emailProfile == null
                                        ? 'Maaf, kamu belum menambahkan email.'
                                        : 'Maaf, kamu belum verifikasi email.',
                                style:
                                    heading1(FontWeight.w600, bnw900, 'Outfit'),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: size8),
                              Text(
                                sandi == true
                                    ? 'Agar kamu dapat menggunakan kata sandi saat masuk akun. Kamu harus membuat kata sandi terlebih dahulu. '
                                    : emailProfile == null
                                        ? 'Untuk membuat kata sandi, kamu harus menambahkan email terlebih dahulu.'
                                        : 'Untuk membuat kata sandi, kamu harus verifikasi email terlebih dahulu.',
                                style:
                                    heading2(FontWeight.w400, bnw500, 'Outfit'),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            SvgPicture.asset(
                              'assets/illustration/errorPayment.svg',
                              height: MediaQuery.of(context).size.height / 2.2,
                            ),
                            Text(
                              'Maaf, kamu ngga bisa mengubah nomor telepon.',
                              style:
                                  heading1(FontWeight.w600, bnw900, 'Outfit'),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: size8),
                            Text(
                              'Silahkan menghubungi customer service unipos untuk info lebih lanjut.',
                              style:
                                  heading2(FontWeight.w400, bnw500, 'Outfit'),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                  SizedBox(height: size32),
                  checkShow == true
                      ? Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: buttonXLoutline(
                                  Center(
                                    child: Text(
                                      'Nanti Aja',
                                      style: heading3(FontWeight.w600,
                                          primary500, 'Outfit'),
                                    ),
                                  ),
                                  MediaQuery.of(context).size.width,
                                  primary500,
                                ),
                              ),
                            ),
                            SizedBox(width: size16),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  // buatSandiShowdialog(context);
                                  sandi != true
                                      ? verifikasiEmailField(context)
                                      : buatSandiShowdialog(context);
                                },
                                child: buttonXL(
                                  Center(
                                    child: Text(
                                      sandi == true
                                          ? 'Buat Kata Sandi'
                                          : emailProfile == null
                                              ? 'Menambahkan Email'
                                              : 'Verifikasi Email',
                                      style: heading3(
                                          FontWeight.w600, bnw100, 'Outfit'),
                                    ),
                                  ),
                                  MediaQuery.of(context).size.width,
                                ),
                              ),
                            ),
                          ],
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: buttonXL(
                                Center(
                                  child: Text(
                                    'Oke',
                                    style: heading3(
                                        FontWeight.w600, bnw100, 'Outfit'),
                                  ),
                                ),
                                MediaQuery.of(context).size.width),
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  editEmailField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: size16),
        Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: [
                SizedBox(
                  width: 136,
                  child: Text('Email',
                      style: heading3(FontWeight.w400, bnw900, 'Outfit')),
                ),
                SizedBox(width: size16),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(emailProfile ?? '',
                            style: heading3(FontWeight.w600, bnw900, 'Outfit')),
                      ),
                      Container(
                        child: GestureDetector(
                          onTap: () {
                            // ? verifikasiDiriKamuShowdialog(context)
                            statusVerified == '1'
                                ? verifikasiDiriKamuShowdialog(context)
                                : verifEmailField(context);
                            setState(() {});
                            initState();
                          },
                          child: Text(
                            statusVerified.toString() == '1'
                                ? 'Ubah'
                                : emailProfile == null
                                    ? 'Tambah'
                                    : 'Verifikasi',
                            style:
                                heading3(FontWeight.w400, primary500, 'Outfit'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
      ],
    );
  }

  editPasswordField(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: size16),
        Container(
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              SizedBox(
                width: 136,
                // color: bnw300,
                child: Text('Kata Sandi',
                    style: heading3(FontWeight.w400, bnw900, 'Outfit')),
              ),
              SizedBox(width: size16),
              Expanded(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Text(
                            statusPw.toString() == '1' ? '*********' : '-',
                            style: heading3(FontWeight.w600, bnw900, 'Outfit')),
                      ),
                      GestureDetector(
                        onTap: () {
                          statusPw.toString() == '1'
                              ? verifikasiDiriKamuSandiShowdialog(context)
                              : showError(context, true, false, false);
                        },
                        child: Text(
                          statusPw.toString() == '1' ? 'Ubah' : 'Buat',
                          style:
                              heading3(FontWeight.w400, primary500, 'Outfit'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        //  SizedBox(height: size16),
      ],
    );
  }

  Future<dynamic> verifEmailField(BuildContext context) {
    return showModalBottomSheet(
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
      ),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => IntrinsicHeight(
          child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            // height: MediaQuery.of(context).size.height / 1,
            decoration: BoxDecoration(
              color: bnw100,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(size12),
                topLeft: Radius.circular(size12),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(size32, size16, size32, size32),
              child: Column(
                children: [
                  dividerShowdialog(),
                  SizedBox(height: size16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            emailProfile == null
                                ? 'Tambah Email'
                                : 'Verifikasi Email',
                            style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              PhosphorIcons.x_fill,
                              color: bnw900,
                              size: size32,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: size16),
                      Row(
                        children: [
                          Text(
                            'Email',
                            style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                          ),
                          Text(
                            '*',
                            style:
                                heading4(FontWeight.w400, danger500, 'Outfit'),
                          ),
                        ],
                      ),
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                          onChanged: (value) {
                            setState(() {});
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Form tidak boleh kosong!';
                            } else if (!value.contains('@') ||
                                !value.contains('.')) {
                              return 'Masukkan format email dengan benar';
                            }
                            return null;
                          },
                          controller: controllerEmail,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            focusColor: primary500,
                            hintText: emailProfile == null
                                ? 'Cth: Nabil@gmail.com'
                                : controllerEmail.text,
                            hintStyle:
                                heading3(FontWeight.w500, bnw500, 'Outfit'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size32),
                  GestureDetector(
                    onTap: () {
                      if (controllerEmail.text.isNotEmpty) {
                        if (_formKey.currentState!.validate()) {
                          showError(context, true, true, true);
                        }
                      }
                      setState(() {});
                    },
                    child: buttonXLonOff(
                      Center(
                        child: Text(
                          'Selanjutnya',
                          style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                        ),
                      ),
                      MediaQuery.of(context).size.width,
                      controllerEmail.text.isEmpty ? bnw300 : primary500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> verifEmailFieldTanpaError(BuildContext context) {
    return showModalBottomSheet(
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
      ),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => IntrinsicHeight(
          child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            // height: MediaQuery.of(context).size.height / 1,
            decoration: BoxDecoration(
              color: bnw100,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12),
                topLeft: Radius.circular(12),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(size32, size16, size32, size32),
              child: Column(
                children: [
                  dividerShowdialog(),
                  SizedBox(height: size16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            emailProfile == null
                                ? 'Tambah Email'
                                : 'Verifikasi Email',
                            style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              PhosphorIcons.x_fill,
                              color: bnw900,
                              size: size32,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            'Email',
                            style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                          ),
                          Text(
                            '*',
                            style:
                                heading4(FontWeight.w400, danger500, 'Outfit'),
                          ),
                        ],
                      ),
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                          onChanged: (value) {
                            setState(() {});
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Form tidak boleh kosong!';
                            } else if (!value.contains('@') ||
                                !value.contains('.')) {
                              return 'Masukkan format email dengan benar';
                            }
                            return null;
                          },
                          controller: controllerEmail,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            focusColor: primary500,
                            hintText: controllerEmail.text,
                            hintStyle:
                                heading3(FontWeight.w500, bnw500, 'Outfit'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size32),
                  GestureDetector(
                    onTap: () {
                      if (controllerEmail.text.isNotEmpty) {
                        if (_formKey.currentState!.validate()) {
                          // showError(context, true, true, true);
                          buatSandiShowdialog(context);
                        }
                      }
                      setState(() {});
                    },
                    child: buttonXLonOff(
                      Center(
                        child: Text(
                          'Selanjutnya',
                          style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                        ),
                      ),
                      MediaQuery.of(context).size.width,
                      controllerEmail.text.isEmpty ? bnw300 : primary500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> verifikasiDiriKamuShowdialog(BuildContext context) {
    return showModalBottomSheet(
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
      ),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      context: context,
      builder: (context) => IntrinsicHeight(
        child: Container(
          // height: MediaQuery.of(context).size.height / 1,
          decoration: BoxDecoration(
            color: bnw100,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(12),
              topLeft: Radius.circular(12),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(size32, size16, size32, size32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Center(
                  child: dividerShowdialog(),
                ),
                SizedBox(height: size16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Verifikasi Diri Kamu',
                      style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        PhosphorIcons.x_fill,
                        color: bnw900,
                        size: size32,
                      ),
                    )
                  ],
                ),
                SizedBox(height: size16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih satu metode untuk dikirim Kode Verifikasi (OTP), Kami mau memastikan pengubah kata sandi adalah kamu. :)',
                      style: heading3(FontWeight.w400, bnw500, 'Outfit'),
                    ),
                    SizedBox(height: size16),
                    Row(
                      children: [
                        Expanded(
                          child: Consumer<TimerProvider>(
                            builder: (context, timerProvider, _) =>
                                GestureDetector(
                              onTap: () {
                                timerProvider.startTimeout();
                                valOtpEmail(context, widget.token, 'whatsapp');
                                otpPhone(context, true);
                                // : otpPhone(context, false);
                                clearForm();
                              },
                              child: buttonXLoutline(
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(PhosphorIcons.whatsapp_logo_fill,
                                        color: primary500),
                                    SizedBox(width: size16),
                                    Text(
                                      'Nomor Telepon',
                                      style: heading3(FontWeight.w600,
                                          primary500, 'Outfit'),
                                    ),
                                  ],
                                ),
                                MediaQuery.of(context).size.width,
                                primary500,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: size16),
                        Expanded(
                          child: Consumer<TimerProvider>(
                            builder: (context, timerProvider, _) =>
                                GestureDetector(
                              onTap: () {
                                timerProvider.startTimeout();
                                valOtpEmail(context, widget.token, 'email');
                                otpPhone(context, false);
                                clearForm();
                                setState(() {});
                              },
                              child: buttonXLoutline(
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(PhosphorIcons.envelope_fill,
                                          color: primary500),
                                      SizedBox(width: size16),
                                      Text(
                                        'Email',
                                        style: heading3(FontWeight.w600,
                                            primary500, 'Outfit'),
                                      ),
                                    ],
                                  ),
                                  MediaQuery.of(context).size.width,
                                  primary500),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> otpPhone(BuildContext context, bool phone) {
    isKeyboardActive = false;

    return showModalBottomSheet(
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
      ),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      context: context,
      builder: (context) => Consumer<TimerProvider>(
        builder: (context, timerProvider, _) => StatefulBuilder(
          builder: (context, setState) => IntrinsicHeight(
            child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              // height: MediaQuery.of(context).size.height / 1,
              decoration: BoxDecoration(
                color: bnw100,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  topLeft: Radius.circular(12),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(size32, size16, size32, size32),
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          dividerShowdialog(),
                          SizedBox(height: size16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                phone
                                    ? 'Verifikasi Nomor Telepon'
                                    : 'Verifikasi Email',
                                style:
                                    heading1(FontWeight.w700, bnw900, 'Outfit'),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context)
                                    .popUntil((route) => route.isFirst),
                                child: Icon(
                                  PhosphorIcons.x_fill,
                                  color: bnw900,
                                  size: size32,
                                ),
                              )
                            ],
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              child: Column(
                                children: [
                                  SizedBox(height: size16),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Masukkan Kode Verifikasi (OTP)',
                                          style: heading2(FontWeight.w600,
                                              bnw900, 'Outfit')),
                                      Text(
                                          phone
                                              ? 'Kode Verifikasi telah dikirimkan ke telepon kamu'
                                              : 'Kode Verifikasi telah dikirimkan ke email kamu',
                                          style: heading3(FontWeight.w400,
                                              bnw900, 'Outfit')),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 340,
                                    child: Column(
                                      children: [
                                        PinCodeTextField(
                                          appContext: context,
                                          animationType: AnimationType.fade,
                                          length: 6,
                                          errorTextSpace: 0,
                                          pinTheme: PinTheme(
                                            activeColor: errorText.isEmpty
                                                ? primary500
                                                : red500,
                                            inactiveColor: bnw300,
                                            selectedBorderWidth: 2,
                                            inactiveBorderWidth: 1,
                                          ),
                                          cursorColor: primary500,
                                          autoDisposeControllers: false,
                                          controller: otpControllerFix,
                                          keyboardType: TextInputType.number,
                                          textStyle: heading1(FontWeight.w700,
                                              bnw900, 'Outfit'),
                                          onCompleted: (pin) async {
                                            print("Completed: " + pin);
                                            valOtpEmailtahap1(
                                                    context,
                                                    widget.token,
                                                    phone
                                                        ? 'whatsapp'
                                                        : 'email',
                                                    pin)
                                                .then((value) {
                                              value == '00'
                                                  ? changeEmailField(context,
                                                      phone ? true : false)
                                                  : null;
                                            });
                                            setState(() {});
                                          },
                                          onChanged: (value) {
                                            debugPrint(value);
                                            errorText = '';
                                            setState(() {
                                              currentText = value;
                                            });
                                          },
                                          beforeTextPaste: (text) {
                                            debugPrint(
                                                "Allowing to paste $text");
                                            return false;
                                          },
                                        ),
                                        SizedBox(
                                            height: errorText.isNotEmpty
                                                ? size16
                                                : 0),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            errorText.isNotEmpty
                                                ? errorText
                                                : '',
                                            style: heading4(FontWeight.w500,
                                                red500, 'Outfit'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          errorText.isNotEmpty ? size16 : 0),
                                  SizedBox(
                                    width: 340,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          timerProvider.timerText == '00:00'
                                              ? ''
                                              : 'Waktu kirim ulang : ',
                                          style: heading4(FontWeight.w400,
                                              bnw900, 'Outfit'),
                                        ),
                                        GestureDetector(
                                          onTap: () {},
                                          child: timerProvider.timerText ==
                                                  '00: 00'
                                              ? GestureDetector(
                                                  onTap: () {
                                                    valOtpEmail(
                                                        context,
                                                        widget.token,
                                                        phone
                                                            ? 'whatsapp'
                                                            : 'email');
                                                    timerProvider
                                                        .startTimeout();
                                                  },
                                                  // onTap: () => registerAgain(),
                                                  child: Text(
                                                    'Kirim Ulang Code',
                                                    style: heading4(
                                                        FontWeight.w600,
                                                        primary500,
                                                        'Outfit'),
                                                  ),
                                                )
                                              : Row(
                                                  children: [
                                                    SizedBox(
                                                      height: size8,
                                                      width: size8,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      timerProvider.timerText,
                                                      style: body1(
                                                          FontWeight.w400,
                                                          bnw900,
                                                          'Outfit'),
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: size32),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Spacer(),

                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: buttonXLoutline(
                          Center(
                            child: Text(
                              'Ganti Metode Verifikasi',
                              style:
                                  heading3(FontWeight.w600, bnw900, 'Outfit'),
                            ),
                          ),
                          MediaQuery.of(context).size.width,
                          bnw300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> otpEmail(BuildContext context, bool phone) {
    isKeyboardActive = false;
    clearForm();
    return showModalBottomSheet(
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
      ),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      context: context,
      builder: (context) => Consumer<TimerProvider>(
        builder: (context, timerProvider, _) => IntrinsicHeight(
          child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            // height: MediaQuery.of(context).size.height / 1,
            decoration: BoxDecoration(
              color: bnw100,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12),
                topLeft: Radius.circular(12),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(size32, size16, size32, size32),
              child: Column(
                children: [
                  dividerShowdialog(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Verifikasi Email Baru',
                              style:
                                  heading1(FontWeight.w700, bnw900, 'Outfit'),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.of(context)
                                  .popUntil((route) => route.isFirst),
                              child: Icon(
                                PhosphorIcons.x_fill,
                                color: bnw900,
                                size: size32,
                              ),
                            )
                          ],
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: size16),
                                Text('Masukkan Kode Verifikasi (OTP)',
                                    style: heading2(
                                        FontWeight.w600, bnw900, 'Outfit')),
                                Text(
                                    'Kode Verifikasi telah dikirimkan ke email baru kamu',
                                    style: heading3(
                                        FontWeight.w400, bnw900, 'Outfit')),
                                SizedBox(
                                  width: 340,
                                  child: Column(
                                    children: [
                                      Focus(
                                        child: FocusScope(
                                          onFocusChange: (value) {
                                            isKeyboardActive = value;
                                            setState(() {});
                                          },
                                          child: PinCodeTextField(
                                            appContext: context,
                                            animationType: AnimationType.fade,
                                            length: 6,
                                            errorTextSpace: 0,
                                            pinTheme: PinTheme(
                                              activeColor: errorText.isEmpty
                                                  ? primary500
                                                  : red500,
                                              inactiveColor: bnw300,
                                              selectedBorderWidth: 2,
                                              inactiveBorderWidth: 1,
                                            ),
                                            cursorColor: primary500,
                                            autoDisposeControllers: false,
                                            controller: otpControllerFix,
                                            keyboardType: TextInputType.number,
                                            textStyle: heading1(FontWeight.w700,
                                                bnw900, 'Outfit'),
                                            onCompleted: (pin) async {
                                              setState(() {
                                                changeEmailtahap2(
                                                  context,
                                                  widget.token,
                                                  phone ? 'whatsapp' : 'email',
                                                  pin,
                                                ).then((value) async {
                                                  // value == '00'
                                                  //     ? Navigator.of(context).popUntil(
                                                  //         (route) => route.isFirst)
                                                  //     : null;
                                                  if (value == '00') {
                                                    setState(() {});
                                                    await Future.delayed(
                                                        Duration(seconds: 1));
                                                    Navigator.of(context)
                                                        .popUntil((route) =>
                                                            route.isFirst);
                                                    initState();
                                                  }
                                                });
                                              });

                                              initState();
                                            },
                                            onChanged: (value) {
                                              debugPrint(value);
                                              errorText = '';
                                              setState(() {
                                                currentText = value;
                                              });
                                            },
                                            beforeTextPaste: (text) {
                                              debugPrint(
                                                  "Allowing to paste $text");
                                              return false;
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          height: errorText.isNotEmpty
                                              ? size16
                                              : 0),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          errorText.isNotEmpty ? errorText : '',
                                          style: heading4(FontWeight.w500,
                                              red500, 'Outfit'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                    height: errorText.isNotEmpty ? size16 : 0),
                                SizedBox(
                                  width: 340,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        timerProvider.timerText == '00: 00'
                                            ? ''
                                            : 'Waktu kirim ulang : ',
                                        style: heading4(
                                            FontWeight.w400, bnw900, 'Outfit'),
                                      ),
                                      GestureDetector(
                                        onTap: () {},
                                        child: timerProvider.timerText ==
                                                '00: 00'
                                            ? GestureDetector(
                                                onTap: () {
                                                  timerProvider.startTimeout();
                                                  changeEmail(
                                                    context,
                                                    widget.token,
                                                    controllerEmail.text,
                                                    phone
                                                        ? 'whatsapp'
                                                        : 'email',
                                                  );
                                                },
                                                // onTap: () => registerAgain(),
                                                child: Text(
                                                  'Kirim Ulang Code',
                                                  style: heading4(
                                                      FontWeight.w600,
                                                      primary500,
                                                      'Outfit'),
                                                ),
                                              )
                                            : Row(
                                                children: [
                                                  SizedBox(
                                                    height: size8,
                                                    width: size8,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    timerProvider.timerText,
                                                    style: body1(
                                                        FontWeight.w400,
                                                        bnw900,
                                                        'Outfit'),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: size32),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: buttonXLoutline(
                        Center(
                          child: Text(
                            'Ganti Email',
                            style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                          ),
                        ),
                        MediaQuery.of(context).size.width,
                        bnw300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> otpUbahSandi(BuildContext context, bool phone) {
    isKeyboardActive = false;

    return showModalBottomSheet(
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
      ),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      context: context,
      builder: (context) => Consumer<TimerProvider>(
        builder: (context, timerProvider, child) => IntrinsicHeight(
          child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            // height: MediaQuery.of(context).size.height / 1,
            decoration: BoxDecoration(
              color: bnw100,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12),
                topLeft: Radius.circular(12),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(size32, size16, size32, size32),
              child: Column(
                children: [
                  dividerShowdialog(),
                  SizedBox(height: size16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              phone
                                  ? 'Verifikasi Nomor Telepon'
                                  : 'Verifikasi Email',
                              style:
                                  heading1(FontWeight.w700, bnw900, 'Outfit'),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.of(context)
                                  .popUntil((route) => route.isFirst),
                              child: Icon(
                                PhosphorIcons.x_fill,
                                color: bnw900,
                                size: size32,
                              ),
                            )
                          ],
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: size16),
                                Text('Masukkan Kode Verifikasi (OTP)',
                                    style: heading2(
                                        FontWeight.w600, bnw900, 'Outfit')),
                                Text(
                                    phone
                                        ? 'Kode Verifikasi telah dikirimkan ke telepon kamu'
                                        : 'Kode Verifikasi telah dikirimkan ke email kamu',
                                    style: heading3(
                                        FontWeight.w400, bnw900, 'Outfit')),
                                SizedBox(
                                  width: 340,
                                  child: Column(
                                    children: [
                                      PinCodeTextField(
                                        appContext: context,
                                        animationType: AnimationType.fade,
                                        length: 6,
                                        errorTextSpace: 0,
                                        pinTheme: PinTheme(
                                          activeColor: errorText.isEmpty
                                              ? primary500
                                              : red500,
                                          inactiveColor: bnw300,
                                          selectedBorderWidth: 2,
                                          inactiveBorderWidth: 1,
                                        ),
                                        cursorColor: primary500,
                                        autoDisposeControllers: false,
                                        controller: otpControllerFix,
                                        keyboardType: TextInputType.number,
                                        textStyle: heading1(
                                            FontWeight.w700, bnw900, 'Outfit'),
                                        onCompleted: (pin) {
                                          setState(() {
                                            validasiOtpSandi(
                                                    context,
                                                    widget.token,
                                                    pin,
                                                    phone
                                                        ? 'whatsapp'
                                                        : 'email')
                                                .then((value) {
                                              value == '00'
                                                  ? ubahSandiShowdialog(context,
                                                      phone ? true : false)
                                                  : null;
                                            });
                                          });
                                        },
                                        onChanged: (value) {
                                          debugPrint(value);
                                          errorText = '';
                                          setState(() {
                                            currentText = value;
                                          });
                                        },
                                        beforeTextPaste: (text) {
                                          debugPrint("Allowing to paste $text");
                                          return false;
                                        },
                                      ),
                                      SizedBox(
                                          height: errorText.isNotEmpty
                                              ? size16
                                              : 0),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          errorText.isNotEmpty ? errorText : '',
                                          style: heading4(FontWeight.w500,
                                              red500, 'Outfit'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                    height: errorText.isNotEmpty ? size16 : 0),
                                SizedBox(
                                  width: 340,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        timerProvider.timerText == '00: 00'
                                            ? ''
                                            : 'Waktu kirim ulang : ',
                                        style: heading4(
                                            FontWeight.w400, bnw900, 'Outfit'),
                                      ),
                                      GestureDetector(
                                        onTap: () {},
                                        child: timerProvider.timerText ==
                                                '00: 00'
                                            ? GestureDetector(
                                                onTap: () {
                                                  getOtpSandi(
                                                      context,
                                                      widget.token,
                                                      phone
                                                          ? 'whatsapp'
                                                          : 'email');
                                                  timerProvider.startTimeout();
                                                },
                                                // onTap: () => registerAgain(),
                                                child: Text(
                                                  'Kirim Ulang Code',
                                                  style: heading4(
                                                      FontWeight.w600,
                                                      primary500,
                                                      'Outfit'),
                                                ),
                                              )
                                            : Row(
                                                children: [
                                                  SizedBox(
                                                    height: size8,
                                                    width: size8,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    timerProvider.timerText,
                                                    style: body1(
                                                        FontWeight.w400,
                                                        bnw900,
                                                        'Outfit'),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: size32),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        otpControllerFix.text = "";
                      },
                      child: buttonXLoutline(
                        Center(
                          child: Text(
                            // 'Ganti Metode Verifikasi',
                            'Kembali',
                            style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                          ),
                        ),
                        MediaQuery.of(context).size.width,
                        bnw300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> otpBuatSandi(BuildContext context) {
    isKeyboardActive = false;

    return showModalBottomSheet(
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
      ),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      context: context,
      builder: (context) => Consumer<TimerProvider>(
        builder: (context, timerProvider, child) => IntrinsicHeight(
          child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            // height: MediaQuery.of(context).size.height / 1,
            decoration: BoxDecoration(
              color: bnw100,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12),
                topLeft: Radius.circular(12),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size16),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(size8),
                    height: 4,
                    width: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(size8),
                      color: bnw300,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Verifikasi Email',
                                style:
                                    heading1(FontWeight.w700, bnw900, 'Outfit'),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context)
                                    .popUntil((route) => route.isFirst),
                                child: Icon(
                                  PhosphorIcons.x_fill,
                                  color: bnw900,
                                  size: size32,
                                ),
                              )
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Masukkan Kode Verifikasi (OTP)',
                                  style: heading2(
                                      FontWeight.w600, bnw900, 'Outfit')),
                              Text(
                                  'Kode Verifikasi telah dikirimkan ke email kamu',
                                  style: heading3(
                                      FontWeight.w400, bnw900, 'Outfit')),
                            ],
                          ),
                          SizedBox(
                            width: 340,
                            child: Column(
                              children: [
                                Focus(
                                  child: FocusScope(
                                    onFocusChange: (value) {
                                      isKeyboardActive = value;
                                      setState(() {});
                                    },
                                    child: PinCodeTextField(
                                      appContext: context,
                                      animationType: AnimationType.fade,
                                      length: 6,
                                      errorTextSpace: 0,
                                      pinTheme: PinTheme(
                                        activeColor: errorText.isEmpty
                                            ? primary500
                                            : red500,
                                        inactiveColor: bnw300,
                                        selectedBorderWidth: 2,
                                        inactiveBorderWidth: 1,
                                      ),
                                      cursorColor: primary500,
                                      autoDisposeControllers: false,
                                      controller: otpControllerFix,
                                      keyboardType: TextInputType.number,
                                      textStyle: heading1(
                                          FontWeight.w700, bnw900, 'Outfit'),
                                      onCompleted: (pin) {
                                        setState(() {
                                          verifiedEmailbyOTP(
                                                  context, widget.token, pin)
                                              .then((value) {
                                            if (value == '00') {
                                              Navigator.of(context).popUntil(
                                                  (route) => route.isFirst);
                                              showSnackBarComponent(
                                                  context,
                                                  'Berhasil verifikasi email',
                                                  '00');
                                            } else {
                                              showSnackBarComponent(
                                                  context,
                                                  'Gagal verifikasi email',
                                                  '14');
                                            }
                                          });
                                        });
                                      },
                                      onChanged: (value) {
                                        debugPrint(value);
                                        errorText = '';
                                        setState(() {
                                          currentText = value;
                                        });
                                      },
                                      beforeTextPaste: (text) {
                                        debugPrint("Allowing to paste $text");
                                        return false;
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    height: errorText.isNotEmpty ? size16 : 0),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    errorText.isNotEmpty ? errorText : '',
                                    style: heading4(
                                        FontWeight.w500, red500, 'Outfit'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: errorText.isNotEmpty ? size16 : 0),
                          StreamBuilder(
                            builder: (context, setState) => SizedBox(
                              width: 330,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    timerProvider.timerText == '00: 00'
                                        ? ''
                                        : 'Waktu kirim ulang : ',
                                    style: heading4(
                                        FontWeight.w400, bnw900, 'Outfit'),
                                  ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: timerProvider.timerText == '00: 00'
                                        ? GestureDetector(
                                            onTap: () {
                                              verifiedEmail(
                                                context,
                                                widget.token,
                                                controllerEmail.text,
                                                controllerPass.text,
                                              );
                                              timerProvider.startTimeout();
                                            },
                                            // onTap: () => registerAgain(),
                                            child: Text(
                                              'Kirim Ulang Code',
                                              style: heading4(FontWeight.w600,
                                                  primary500, 'Outfit'),
                                            ),
                                          )
                                        : Row(
                                            children: [
                                              SizedBox(
                                                height: size8,
                                                width: size8,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                timerProvider.timerText,
                                                style: body1(FontWeight.w400,
                                                    bnw900, 'Outfit'),
                                              ),
                                            ],
                                          ),
                                  ),
                                ],
                              ),
                            ),
                            stream: null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Spacer(),
                  SizedBox(height: size16),

                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: buttonXLoutline(
                        Center(
                          child: Text(
                            'Kembali',
                            // 'Ganti Metode Verifikasi',
                            style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                          ),
                        ),
                        MediaQuery.of(context).size.width,
                        bnw300,
                      ),
                    ),
                  ),
                  SizedBox(height: size16)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> changeEmailField(BuildContext context, bool phone) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    isKeyboardActive = false;
    errorText = '';
    return showModalBottomSheet(
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
      ),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      context: context,
      builder: (context) => Consumer<TimerProvider>(
        builder: (context, timerProvider, _) => IntrinsicHeight(
          child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            decoration: BoxDecoration(
              color: bnw100,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12),
                topLeft: Radius.circular(12),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(size32, size16, size32, size32),
              child: Column(
                children: [
                  Container(
                    height: 4,
                    width: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(size8),
                      color: bnw300,
                    ),
                  ),
                  SizedBox(height: size16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ubah Email',
                            style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              PhosphorIcons.x_fill,
                              color: bnw900,
                              size: size32,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            'Email Baru',
                            style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                          ),
                          Text(
                            '*',
                            style:
                                heading4(FontWeight.w400, danger500, 'Outfit'),
                          ),
                        ],
                      ),
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                          controller: controllerEmail,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Form tidak boleh kosong!';
                            } else if (!value.contains('@') ||
                                !value.contains('.')) {
                              return 'Masukkan format email dengan benar!';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {});
                          },
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            focusColor: primary500,
                            errorText: errorText.isNotEmpty ? errorText : null,
                            hintText: controllerEmail.text,
                            hintStyle:
                                heading3(FontWeight.w500, bnw500, 'Outfit'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size32),
                  GestureDetector(
                    onTap: () {
                      if (controllerEmail.text.isNotEmpty) {
                        if (_formKey.currentState!.validate()) {
                          changeEmail(
                            context,
                            widget.token,
                            controllerEmail.text,
                            phone ? 'whatsapp' : 'email',
                          ).then((value) {
                            print(value);
                            if (value == '00') {
                              timerProvider.startTimeout();
                              // otpBuatSandi(context);
                              otpEmail(context, phone ? true : false);
                            } else {
                              setState(() {
                                errorText = value;
                              });
                            }
                          });
                        }
                      }

                      // verifikasiEmail(context);

                      setState(() {});
                      // initState();
                    },
                    child: buttonXLonOff(
                      Center(
                        child: Text(
                          'Selanjutnya',
                          style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                        ),
                      ),
                      MediaQuery.of(context).size.width,
                      controllerEmail.text.isEmpty ? bnw300 : primary500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> verifikasiEmailField(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    isKeyboardActive = false;
    return showModalBottomSheet(
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
      ),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => IntrinsicHeight(
          child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            decoration: BoxDecoration(
              color: bnw100,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12),
                topLeft: Radius.circular(12),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(size32, size16, size32, size32),
              child: Column(
                children: [
                  dividerShowdialog(),
                  SizedBox(height: size16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            emailProfile == null
                                ? 'Tambah Email'
                                : 'Verifikasi Email',
                            style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              PhosphorIcons.x_fill,
                              color: bnw900,
                              size: size32,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            'Email Baru',
                            style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                          ),
                          Text(
                            '*',
                            style:
                                heading4(FontWeight.w400, danger500, 'Outfit'),
                          ),
                        ],
                      ),
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                          controller: controllerEmail,
                          onChanged: (value) {
                            setState(() {});
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Form tidak boleh kosong!';
                            } else if (!value.contains('@') ||
                                !value.contains('.')) {
                              return 'Masukkan format email dengan benar!';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            focusColor: primary500,
                            hintText: emailProfile == null
                                ? 'Cth: Nabil@gmail.com'
                                : controllerEmail.text,
                            hintStyle:
                                heading3(FontWeight.w500, bnw500, 'Outfit'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size32),
                  GestureDetector(
                    onTap: () {
                      if (controllerEmail.text.isNotEmpty) {
                        if (_formKey.currentState!.validate()) {
                          buatSandiShowdialog(context);
                        }
                      }

                      // verifikasiEmail(context);

                      setState(() {});
                      // initState();
                    },
                    child: buttonXLonOff(
                      Center(
                        child: Text(
                          'Selanjutnya',
                          style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                        ),
                      ),
                      MediaQuery.of(context).size.width,
                      controllerEmail.text.isEmpty ? bnw300 : primary500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> verifikasiDiriKamuSandiShowdialog(BuildContext context) {
    return showModalBottomSheet(
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
      ),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      context: context,
      builder: (context) => IntrinsicHeight(
        child: Container(
          // height: MediaQuery.of(context).size.height / 1,
          decoration: BoxDecoration(
            color: bnw100,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(12),
              topLeft: Radius.circular(12),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(size32, size16, size32, size32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Center(
                  child: dividerShowdialog(),
                ),
                SizedBox(height: size16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Verifikasi Diri Kamu',
                      style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        PhosphorIcons.x_fill,
                        color: bnw900,
                        size: size32,
                      ),
                    )
                  ],
                ),
                SizedBox(height: size16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih satu metode untuk dikirim Kode Verifikasi (OTP), Kami mau memastikan pengubah kata sandi adalah kamu. :)',
                      style: heading3(FontWeight.w400, bnw500, 'Outfit'),
                    ),
                    SizedBox(height: size16),
                    Row(
                      children: [
                        Expanded(
                          child: Consumer<TimerProvider>(
                            builder: (context, timerProvider, child) =>
                                GestureDetector(
                              onTap: () {
                                timerProvider.startTimeout();
                                getOtpSandi(context, widget.token, 'whatsapp');
                                otpUbahSandi(context, true);
                                clearForm();
                              },
                              child: buttonXLoutline(
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(PhosphorIcons.whatsapp_logo_fill,
                                        color: primary500),
                                    SizedBox(width: size16),
                                    Text(
                                      'Nomor Telepon',
                                      style: heading3(FontWeight.w600,
                                          primary500, 'Outfit'),
                                    ),
                                  ],
                                ),
                                MediaQuery.of(context).size.width,
                                primary500,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: size16),
                        Expanded(
                          child: Consumer<TimerProvider>(
                            builder: (context, timerProvider, child) =>
                                GestureDetector(
                              onTap: () {
                                timerProvider.startTimeout();
                                getOtpSandi(context, widget.token, 'email');
                                otpUbahSandi(context, false);
                                clearForm();
                              },
                              child: buttonXLoutline(
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(PhosphorIcons.envelope_fill,
                                          color: primary500),
                                      SizedBox(width: size16),
                                      Text(
                                        'Email',
                                        style: heading3(FontWeight.w600,
                                            primary500, 'Outfit'),
                                      ),
                                    ],
                                  ),
                                  MediaQuery.of(context).size.width,
                                  primary500),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> ubahSandiShowdialog(BuildContext context, bool phone) {
    isKeyboardActive = false;
    errorText = '';
    Navigator.of(context).popUntil((route) => route.isFirst);
    return showModalBottomSheet(
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
      ),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => IntrinsicHeight(
          child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            // height: MediaQuery.of(context).size.height / 1,
            decoration: BoxDecoration(
              color: bnw100,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12),
                topLeft: Radius.circular(12),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size16),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(size8),
                    height: 4,
                    width: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(size8),
                      color: bnw300,
                    ),
                  ),
                  Expanded(
                    child: ScrollConfiguration(
                      behavior: ScrollBehavior().copyWith(overscroll: false),
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ubah Kata Sandi',
                              style:
                                  heading1(FontWeight.w700, bnw900, 'Outfit'),
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Text(
                                  'Kata Sandi ',
                                  style: heading4(
                                      FontWeight.w400, bnw900, 'Outfit'),
                                ),
                                Text(
                                  '*',
                                  style: heading4(
                                      FontWeight.w400, danger500, 'Outfit'),
                                ),
                              ],
                            ),
                            TextFormField(
                              style:
                                  heading2(FontWeight.w600, bnw900, 'Outfit'),
                              controller: controllerChangePass,
                              obscureText: _obscureText,
                              obscuringCharacter: '*',
                              onChanged: (value) {
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                focusColor: primary500,
                                errorText:
                                    errorText.isNotEmpty ? errorText : null,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    !_obscureText
                                        ? PhosphorIcons.eye_closed
                                        : PhosphorIcons.eye,
                                    color: bnw900,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                      print(_obscureText);
                                    });
                                  },
                                ),
                                hintText: 'Masukkan Kata Sandi Baru',
                                hintStyle:
                                    heading2(FontWeight.w600, bnw400, 'Outfit'),
                              ),
                            ),
                            SizedBox(height: size8),
                            Row(
                              children: [
                                Text(
                                  'Konfirmasi Kata Sandi ',
                                  style: heading4(
                                      FontWeight.w400, bnw900, 'Outfit'),
                                ),
                                Text(
                                  '*',
                                  style: heading4(
                                      FontWeight.w400, danger500, 'Outfit'),
                                ),
                              ],
                            ),
                            TextFormField(
                              style:
                                  heading2(FontWeight.w600, bnw900, 'Outfit'),
                              controller: controllerConfirmPass,
                              obscureText: _obscureText2,
                              obscuringCharacter: '*',
                              validator: (value) {
                                if (value!.length >= 8) {
                                  if (controllerConfirmPass.text !=
                                      controllerChangePass.text) {
                                    return 'Kata sandi tidak sama';
                                  } else {
                                    errorShowKonfirmasiText = '';
                                  }
                                }
                              },
                              onChanged: (value) {
                                if (value.length >= 8) {
                                  if (controllerConfirmPass.text !=
                                      controllerChangePass.text) {
                                    errorShowKonfirmasiText =
                                        'Kata sandi harus sama';
                                  } else {
                                    errorShowKonfirmasiText = '';
                                  }
                                }
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                  focusColor: primary500,
                                  hintText: 'Ketik Ulang Kata Sandi Baru',
                                  errorText: errorShowKonfirmasiText.isNotEmpty
                                      ? errorShowKonfirmasiText
                                      : null,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      !_obscureText2
                                          ? PhosphorIcons.eye_closed
                                          : PhosphorIcons.eye,
                                      color: bnw900,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureText2 = !_obscureText2;
                                        print(_obscureText2);
                                      });
                                    },
                                  ),
                                  hintStyle: heading2(
                                      FontWeight.w600, bnw400, 'Outfit')),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Spacer(),
                  SizedBox(height: size16),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        (controllerChangePass.text.isEmpty &&
                                controllerConfirmPass.text.isEmpty)
                            ? null
                            : changePassword(
                                context,
                                widget.token,
                                controllerChangePass.text,
                                controllerConfirmPass.text,
                                phone ? 'whatsapp' : 'email',
                              ).then((value) {
                                if (value == '00') {
                                  refreshField();
                                  errorText = '';
                                  // Navigator.of(context)
                                  //     .popUntil((route) => route.isFirst);
                                } else {
                                  setState(() {
                                    errorText = value;
                                  });
                                }
                              });
                      });
                    },
                    child: buttonXLonOff(
                      Center(
                        child: Text(
                          'Simpan',
                          style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                        ),
                      ),
                      MediaQuery.of(context).size.width,
                      (controllerChangePass.text.isEmpty &&
                              controllerConfirmPass.text.isEmpty)
                          ? bnw300
                          : primary500,
                    ),
                  ),
                  SizedBox(height: size16)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> buatSandiShowdialog(BuildContext context) {
    isKeyboardActive = false;
    errorText = '';
    // Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.popUntil(context, (route) => route.isFirst);
    return showModalBottomSheet(
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
      ),
      // barrierColor: Colors.transparent,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      context: context,
      builder: (context) => Consumer<TimerProvider>(
        builder: (context, timerProvider, _) => StatefulBuilder(
          builder: (context, setState) => IntrinsicHeight(
            child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              // height: MediaQuery.of(context).size.height / 1,
              decoration: BoxDecoration(
                color: bnw100,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  topLeft: Radius.circular(12),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(size32, size16, size32, size32),
                child: Column(
                  children: [
                    dividerShowdialog(),
                    SizedBox(height: size16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Buat Kata Sandi',
                              style:
                                  heading1(FontWeight.w700, bnw900, 'Outfit'),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Icon(
                                PhosphorIcons.x_fill,
                                color: bnw900,
                                size: size32,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size16),
                        Row(
                          children: [
                            Text(
                              'Kata Sandi ',
                              style:
                                  heading4(FontWeight.w400, bnw900, 'Outfit'),
                            ),
                            Text(
                              '*',
                              style: heading4(
                                  FontWeight.w400, danger500, 'Outfit'),
                            ),
                          ],
                        ),
                        Form(
                          key: _formKey2,
                          child: TextFormField(
                            style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                            controller: controllerPass,
                            obscureText: _obscureText,
                            obscuringCharacter: '*',
                            onChanged: (value) {
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              focusColor: primary500,
                              errorText:
                                  errorText.isNotEmpty ? errorText : null,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  !_obscureText
                                      ? PhosphorIcons.eye_closed
                                      : PhosphorIcons.eye,
                                  color: bnw900,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                    print(_obscureText);
                                  });
                                },
                              ),
                              hintText: 'Masukkan Kata Sandi',
                              hintStyle:
                                  heading2(FontWeight.w600, bnw400, 'Outfit'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size32),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              // Navigator.of(context).popUntil((route) => route.isFirst);
                              // verifEmailFieldTanpaError(context);
                              // verifEmailField(context);
                              verifikasiEmailFieldBuatSandi(context);
                            },
                            child: buttonXLoutline(
                              Center(
                                child: Text(
                                  'Kembali',
                                  style: heading3(
                                      FontWeight.w600, primary500, 'Outfit'),
                                ),
                              ),
                              MediaQuery.of(context).size.width,
                              primary500,
                            ),
                          ),
                        ),
                        SizedBox(width: size16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              if (controllerPass.text.isNotEmpty) {
                                if (_formKey2.currentState!.validate()) {
                                  verifiedEmail(
                                    context,
                                    widget.token,
                                    controllerEmail.text,
                                    controllerPass.text,
                                  ).then((value) {
                                    log(value);
                                    if (value == '00') {
                                      timerProvider.startTimeout();
                                      errorText = '';
                                      otpBuatSandi(
                                        context,
                                      );
                                    } else {
                                      setState(() {
                                        errorText = value;
                                      });
                                    }
                                  });
                                }
                              }
                              setState(() {});
                            },
                            child: buttonXLonOff(
                              Center(
                                child: Text(
                                  'Simpan',
                                  style: heading3(
                                      FontWeight.w600, bnw100, 'Outfit'),
                                ),
                              ),
                              MediaQuery.of(context).size.width,
                              controllerPass.text.isEmpty ? bnw300 : primary500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

//!
  Future<dynamic> verifikasiEmailFieldBuatSandi(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    isKeyboardActive = false;
    return showModalBottomSheet(
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
      ),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => IntrinsicHeight(
          child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            decoration: BoxDecoration(
              color: bnw100,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12),
                topLeft: Radius.circular(12),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(size32, size16, size32, size32),
              child: Column(
                children: [
                  dividerShowdialog(),
                  SizedBox(height: size16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            emailProfile == null
                                ? 'Tambah Email'
                                : 'Verifikasi Email',
                            style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              PhosphorIcons.x_fill,
                              color: bnw900,
                              size: size32,
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            'Email Baru',
                            style: heading4(FontWeight.w400, bnw900, 'Outfit'),
                          ),
                          Text(
                            '*',
                            style:
                                heading4(FontWeight.w400, danger500, 'Outfit'),
                          ),
                        ],
                      ),
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                          controller: controllerEmail,
                          onChanged: (value) {
                            setState(() {});
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Form tidak boleh kosong!';
                            } else if (!value.contains('@') ||
                                !value.contains('.')) {
                              return 'Masukkan format email dengan benar!';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            focusColor: primary500,
                            hintText: controllerEmail.text,
                            hintStyle:
                                heading3(FontWeight.w500, bnw500, 'Outfit'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size32),
                  GestureDetector(
                    onTap: () {
                      if (controllerEmail.text.isNotEmpty) {
                        if (_formKey.currentState!.validate()) {
                          // buatSandiShowdialog(context);
                          buatSandiShowdialogBuatSandi(context);
                        }
                      }

                      // verifikasiEmail(context);

                      setState(() {});
                      // initState();
                    },
                    child: buttonXLonOff(
                      Center(
                        child: Text(
                          'Selanjutnya',
                          style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                        ),
                      ),
                      MediaQuery.of(context).size.width,
                      controllerEmail.text.isEmpty ? bnw300 : primary500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> buatSandiShowdialogBuatSandi(BuildContext context) {
    isKeyboardActive = false;
    errorText = '';
    // Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.popUntil(context, (route) => route.isFirst);
    return showModalBottomSheet(
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
      ),
      // barrierColor: Colors.transparent,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      context: context,
      builder: (context) => Consumer<TimerProvider>(
        builder: (context, timerProvider, _) => StatefulBuilder(
          builder: (context, setState) => IntrinsicHeight(
            child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              // height: MediaQuery.of(context).size.height / 1,
              decoration: BoxDecoration(
                color: bnw100,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  topLeft: Radius.circular(12),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(size32, size16, size32, size32),
                child: Column(
                  children: [
                    dividerShowdialog(),
                    SizedBox(height: size16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Buat Kata Sandi',
                              style:
                                  heading1(FontWeight.w700, bnw900, 'Outfit'),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Icon(
                                PhosphorIcons.x_fill,
                                color: bnw900,
                                size: size32,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size16),
                        Row(
                          children: [
                            Text(
                              'Kata Sandi ',
                              style:
                                  heading4(FontWeight.w400, bnw900, 'Outfit'),
                            ),
                            Text(
                              '*',
                              style: heading4(
                                  FontWeight.w400, danger500, 'Outfit'),
                            ),
                          ],
                        ),
                        Form(
                          key: _formKey2,
                          child: TextFormField(
                            style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                            controller: controllerPass,
                            obscureText: _obscureText,
                            onChanged: (value) {
                              setState(() {});
                            },
                            obscuringCharacter: '*',
                            decoration: InputDecoration(
                              focusColor: primary500,
                              errorText:
                                  errorText.isNotEmpty ? errorText : null,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  !_obscureText
                                      ? PhosphorIcons.eye_closed
                                      : PhosphorIcons.eye,
                                  color: bnw900,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                    print(_obscureText);
                                  });
                                },
                              ),
                              hintText: 'Masukkan Kata Sandi',
                              hintStyle:
                                  heading2(FontWeight.w600, bnw400, 'Outfit'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size32),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              // Navigator.of(context).popUntil((route) => route.isFirst);
                              // verifEmailFieldTanpaError(context);
                              verifEmailField(context);
                            },
                            child: buttonXLoutline(
                              Center(
                                child: Text(
                                  'Kembali',
                                  style: heading3(
                                      FontWeight.w600, primary500, 'Outfit'),
                                ),
                              ),
                              MediaQuery.of(context).size.width,
                              primary500,
                            ),
                          ),
                        ),
                        SizedBox(width: size16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              if (controllerPass.text.isNotEmpty) {
                                if (_formKey2.currentState!.validate()) {
                                  verifiedEmail(
                                    context,
                                    widget.token,
                                    controllerEmail.text,
                                    controllerPass.text,
                                  ).then((value) {
                                    log(value);
                                    if (value == '00') {
                                      errorText = '';
                                      timerProvider.startTimeout();
                                      otpBuatSandi(
                                        context,
                                      );
                                    } else {
                                      setState(() {
                                        errorText = value;
                                      });
                                    }
                                  });
                                }
                              }
                              setState(() {});
                            },
                            child: buttonXLonOff(
                              Center(
                                child: Text(
                                  'Simpan',
                                  style: heading3(
                                      FontWeight.w600, bnw100, 'Outfit'),
                                ),
                              ),
                              MediaQuery.of(context).size.width,
                              controllerPass.text.isEmpty ? bnw300 : primary500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
