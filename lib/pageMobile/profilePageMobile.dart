import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:otp_text_field/otp_field.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/pageMobile/pageHelperMobile/loginRegisMobile/loginPageMobile.dart';
import 'package:unipos_app_335/pageTablet/home/sidebar/akunPage/lihatAkun.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_button.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_loading.dart';
import 'package:unipos_app_335/utils/component/component_showModalBottom.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_snackbar.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/component/providerModel/timerModel.dart';
import 'package:unipos_app_335/utils/utilities.dart';

class ProfilPageMobile extends StatefulWidget {
  final String nama;
  final String role;
  final String nomor;
  final String inisial;

  const ProfilPageMobile({
    super.key,
    required this.nama,
    required this.role,
    required this.nomor,
    required this.inisial,
  });

  @override
  State<ProfilPageMobile> createState() => _ProfilPageMobileState();
}

class _ProfilPageMobileState extends State<ProfilPageMobile> {
  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('deviceid');
    checkToken = '';

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPageMobile()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: bnw100,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔹 Avatar + Nama + Role + No HP
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar bulat
                  imageProfile == null
                      ? CircleAvatar(
                          backgroundColor: primary200,
                          radius: 50,
                          child: Center(
                            child: Text(
                              getInitials().toUpperCase(),
                              style: heading1(
                                FontWeight.w600,
                                bnw900,
                                'Outfit',
                              ),
                            ),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(120),
                          child: Image.network(
                            imageProfile,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Center(child: loading());
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return CircleAvatar(
                                backgroundColor: primary200,
                                radius: 50,
                                child: Center(
                                  child: Text(
                                    getInitials().toUpperCase(),
                                    style: heading1(
                                      FontWeight.w600,
                                      bnw900,
                                      'Outfit',
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                  const SizedBox(width: 16),

                  // Info teks
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nameProfile ?? widget.nama,
                          style: heading1(FontWeight.w600, bnw900, 'Outfit'),
                        ),
                        Text(
                          widget.role,
                          style: heading2(FontWeight.w400, bnw900, 'Outfit'),
                        ),
                        Text(
                          widget.nomor,
                          style: heading2(FontWeight.w400, bnw900, 'Outfit'),
                        ),
                      ],
                    ),
                  ),

                  // Tombol edit
                  IconButton(
                    icon: Icon(
                      PhosphorIcons.pencil_line_fill,
                      color: primary500,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilEditPageMobile(
                            inisial: widget.inisial,
                            namaLengkap: widget.nama,
                            tipeAkun: merchantType ?? '',
                            akses: "-",
                            // akses: "Administrator",
                            email: emailProfile ?? '-',
                            telepon: widget.nomor,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // 🔹 Tombol Keluar Akun
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
                          style: heading1(FontWeight.w600, bnw900, 'Outfit'),
                        ),
                        SizedBox(height: size8),
                        Text(
                          'Jika kamu keluar, kamu harus memasukkan akun lagi untuk melakukkan transaksi.',
                          style: heading2(FontWeight.w400, bnw900, 'Outfit'),
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
                                      style: heading3(
                                        FontWeight.w600,
                                        primary500,
                                        'Outfit',
                                      ),
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

                                  logout(context);

                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.remove('token');
                                  prefs.remove('deviceid');
                                  prefs.remove('notifications');
                                  prefs.remove('roleAccount');
                                  prefs.remove('typeAccount');
                                  prefs.clear();
                                  checkToken = '';

                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) => LoginPageMobile(),
                                    ),
                                    (Route<dynamic> route) => false,
                                  );
                                },
                                child: buttonXL(
                                  Center(
                                    child: Text(
                                      'Iya, Keluar',
                                      style: heading3(
                                        FontWeight.w600,
                                        bnw100,
                                        'Outfit',
                                      ),
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
                child: SizedBox(
                  width: double.infinity,
                  child: buttonLoutlineColor(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          PhosphorIcons.sign_out_fill,
                          color: bnw900,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Keluar Akun',
                          style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                        ),
                      ],
                    ),
                    bnw100,
                    bnw900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 🔹 Halaman Edit Profil (bisa di-scroll)
class ProfilEditPageMobile extends StatelessWidget {
  final String inisial;
  final String namaLengkap;
  final String tipeAkun;
  final String akses;
  final String email;
  final String telepon;

  ProfilEditPageMobile({
    super.key,
    required this.inisial,
    required this.namaLengkap,
    required this.tipeAkun,
    required this.akses,
    required this.email,
    required this.telepon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bnw100,
      appBar: AppBar(
        backgroundColor: bnw100,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: bnw900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profil',
          style: heading2(FontWeight.w700, bnw900, 'Outfit'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Center(
              child: Column(
                children: [
                  imageProfile == null
                      ? CircleAvatar(
                          backgroundColor: primary200,
                          radius: 50,
                          child: Center(
                            child: Text(
                              getInitials().toUpperCase(),
                              style: heading1(
                                FontWeight.w600,
                                bnw900,
                                'Outfit',
                              ),
                            ),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(120),
                          child: Image.network(
                            imageProfile,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Center(child: loading());
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return CircleAvatar(
                                backgroundColor: primary200,
                                radius: 50,
                                child: Center(
                                  child: Text(
                                    getInitials().toUpperCase(),
                                    style: heading1(
                                      FontWeight.w600,
                                      bnw900,
                                      'Outfit',
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                  SizedBox(height: size12),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Upload foto belum aktif"),
                        ),
                      );
                    },
                    child: Text(
                      'Tambah Foto Profil',
                      style: heading4(FontWeight.w600, primary500, 'Outfit'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Personal Info',
                style: heading3(FontWeight.w700, bnw900, 'Outfit'),
              ),
            ),
            const SizedBox(height: 16),

            _infoItem('Nama Lengkap', namaLengkap, 'Ubah'),
            _divider(),
            _infoItem('Tipe Akun', tipeAkun, 'Ubah'),
            _divider(),
            _infoItem('Akses', akses, 'Ubah'),
            _divider(),
            _infoItem(
              'Email',
              email,
              statusVerified.toString() == '1'
                  ? 'Ubah'
                  : emailProfile == null
                  ? 'Tambah'
                  : 'Verifikasi',
              withEdit: true,
              onEdit: () {
                statusVerified == '1'
                    ? verifikasiDiriKamuShowdialog(context)
                    : verifEmailField(context);
                // setState(() {});
                // initState();
              },
              context: context,
            ),
            _divider(),
            _infoItem(
              'Nomor Telepon *',
              telepon,
              'Ubah',
              withEdit: true,
              onEdit: () {
                showError(context, false, false, true);
              },
            ),
            _divider(),

            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Keamanan',
                style: heading3(FontWeight.w700, bnw900, 'Outfit'),
              ),
            ),
            const SizedBox(height: 16),
            _infoItem(
              'Kata Sandi',
              '********',
              'Ubah',
              withEdit: true,
              onEdit: () {
                statusPw.toString() == '1'
                    ? verifikasiDiriKamuSandiShowdialog(context)
                    : showError(context, true, false, false);
              },
            ),
          ],
        ),
      ),
    );
  }

  clearForm() {
    otpControllerFix.text = '';
    errorText = '';
  }

  Future<dynamic> otpPhone(BuildContext context, bool phone) {
    isKeyboardActive = false;

    return showModalBottomSheet(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      context: context,
      builder: (context) => Consumer<TimerProvider>(
        builder: (context, timerProvider, _) => StatefulBuilder(
          builder: (context, setState) => IntrinsicHeight(
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
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
                                style: heading1(
                                  FontWeight.w700,
                                  bnw900,
                                  'Outfit',
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(
                                  context,
                                ).popUntil((route) => route.isFirst),
                                child: Icon(
                                  PhosphorIcons.x_fill,
                                  color: bnw900,
                                  size: size32,
                                ),
                              ),
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
                                      Text(
                                        'Masukkan Kode Verifikasi (OTP)',
                                        style: heading2(
                                          FontWeight.w600,
                                          bnw900,
                                          'Outfit',
                                        ),
                                      ),
                                      Text(
                                        phone
                                            ? 'Kode Verifikasi telah dikirimkan ke telepon kamu'
                                            : 'Kode Verifikasi telah dikirimkan ke email kamu',
                                        style: heading3(
                                          FontWeight.w400,
                                          bnw900,
                                          'Outfit',
                                        ),
                                      ),
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
                                          textStyle: heading1(
                                            FontWeight.w700,
                                            bnw900,
                                            'Outfit',
                                          ),
                                          onCompleted: (pin) async {
                                            print("Completed: " + pin);
                                            valOtpEmailtahap1(
                                              context,
                                              checkToken,
                                              phone ? 'whatsapp' : 'email',
                                              pin,
                                            ).then((value) {
                                              value == '00'
                                                  ? changeEmailField(
                                                      context,
                                                      phone ? true : false,
                                                    )
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
                                              "Allowing to paste $text",
                                            );
                                            return false;
                                          },
                                        ),
                                        SizedBox(
                                          height: errorText.isNotEmpty
                                              ? size16
                                              : 0,
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            errorText.isNotEmpty
                                                ? errorText
                                                : '',
                                            style: heading4(
                                              FontWeight.w500,
                                              red500,
                                              'Outfit',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: errorText.isNotEmpty ? size16 : 0,
                                  ),
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
                                          style: heading4(
                                            FontWeight.w400,
                                            bnw900,
                                            'Outfit',
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {},
                                          child:
                                              timerProvider.timerText ==
                                                  '00: 00'
                                              ? GestureDetector(
                                                  onTap: () {
                                                    valOtpEmail(
                                                      context,
                                                      checkToken,
                                                      phone
                                                          ? 'whatsapp'
                                                          : 'email',
                                                    );
                                                    timerProvider
                                                        .startTimeout();
                                                  },
                                                  // onTap: () => registerAgain(),
                                                  child: Text(
                                                    'Kirim Ulang Code',
                                                    style: heading4(
                                                      FontWeight.w600,
                                                      primary500,
                                                      'Outfit',
                                                    ),
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
                                                        'Outfit',
                                                      ),
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
                              style: heading3(
                                FontWeight.w600,
                                bnw900,
                                'Outfit',
                              ),
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

  var controllerPass = TextEditingController();
  var controllerConfirmPass = TextEditingController();
  var controllerChangeEmail = TextEditingController();
  var controllerChangePass = TextEditingController();

  Future<dynamic> verifikasiDiriKamuShowdialog(BuildContext context) {
    return showModalBottomSheet(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
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
                Center(child: dividerShowdialog()),
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
                    ),
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
                                  onTap: () async {
                                    timerProvider.startTimeout();
                                    final response = await http.post(
                                      Uri.parse(valOtpEmailLink),
                                      headers: {
                                        'token': checkToken,
                                        'Content-Type': 'application/json',
                                      },
                                      body: jsonEncode({
                                        'deviceid': identifier,
                                        'typeotp': 'whatsapp',
                                      }),
                                    );
                                    print('Response Body: ${response.body}');

                                    otpPhone(context, true);
                                    // : otpPhone(context, false);
                                    clearForm();
                                  },
                                  child: buttonXLoutline(
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          PhosphorIcons.whatsapp_logo_fill,
                                          color: primary500,
                                        ),
                                        SizedBox(width: size16),
                                        Text(
                                          'Nomor Telepon',
                                          style: heading3(
                                            FontWeight.w600,
                                            primary500,
                                            'Outfit',
                                          ),
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
                                    valOtpEmail(context, checkToken, 'email');
                                    // otpPhone(context, false);
                                    clearForm();
                                    // setState(() {});
                                  },
                                  child: buttonXLoutline(
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          PhosphorIcons.envelope_fill,
                                          color: primary500,
                                        ),
                                        SizedBox(width: size16),
                                        Text(
                                          'Email',
                                          style: heading3(
                                            FontWeight.w600,
                                            primary500,
                                            'Outfit',
                                          ),
                                        ),
                                      ],
                                    ),
                                    MediaQuery.of(context).size.width,
                                    primary500,
                                  ),
                                ),
                          ),
                        ),
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

  Future<dynamic> otpEmail(BuildContext context, bool phone) {
    isKeyboardActive = false;
    clearForm();
    return showModalBottomSheet(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      context: context,
      builder: (context) => Consumer<TimerProvider>(
        builder: (context, timerProvider, _) => StatefulBuilder(
          builder: (context, setState) => IntrinsicHeight(
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
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
                                style: heading1(
                                  FontWeight.w700,
                                  bnw900,
                                  'Outfit',
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(
                                  context,
                                ).popUntil((route) => route.isFirst),
                                child: Icon(
                                  PhosphorIcons.x_fill,
                                  color: bnw900,
                                  size: size32,
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: size16),
                                  Text(
                                    'Masukkan Kode Verifikasi (OTP)',
                                    style: heading2(
                                      FontWeight.w600,
                                      bnw900,
                                      'Outfit',
                                    ),
                                  ),
                                  Text(
                                    'Kode Verifikasi telah dikirimkan ke email baru kamu',
                                    style: heading3(
                                      FontWeight.w400,
                                      bnw900,
                                      'Outfit',
                                    ),
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
                                              keyboardType:
                                                  TextInputType.number,
                                              textStyle: heading1(
                                                FontWeight.w700,
                                                bnw900,
                                                'Outfit',
                                              ),
                                              onCompleted: (pin) async {
                                                setState(() {
                                                  changeEmailtahap2(
                                                    context,
                                                    checkToken,
                                                    phone
                                                        ? 'whatsapp'
                                                        : 'email',
                                                    pin,
                                                  ).then((value) async {
                                                    // value == '00'
                                                    //     ? Navigator.of(context).popUntil(
                                                    //         (route) => route.isFirst)
                                                    //     : null;
                                                    if (value == '00') {
                                                      setState(() {});
                                                      await Future.delayed(
                                                        Duration(seconds: 1),
                                                      );
                                                      Navigator.of(
                                                        context,
                                                      ).popUntil(
                                                        (route) =>
                                                            route.isFirst,
                                                      );
                                                      // initState();
                                                    }
                                                  });
                                                });

                                                // initState();
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
                                                  "Allowing to paste $text",
                                                );
                                                return false;
                                              },
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: errorText.isNotEmpty
                                              ? size16
                                              : 0,
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            errorText.isNotEmpty
                                                ? errorText
                                                : '',
                                            style: heading4(
                                              FontWeight.w500,
                                              red500,
                                              'Outfit',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: errorText.isNotEmpty ? size16 : 0,
                                  ),
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
                                            FontWeight.w400,
                                            bnw900,
                                            'Outfit',
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {},
                                          child:
                                              timerProvider.timerText ==
                                                  '00: 00'
                                              ? GestureDetector(
                                                  onTap: () {
                                                    timerProvider
                                                        .startTimeout();
                                                    changeEmail(
                                                      context,
                                                      checkToken,
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
                                                      'Outfit',
                                                    ),
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
                                                        'Outfit',
                                                      ),
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
                              style: heading3(
                                FontWeight.w600,
                                bnw900,
                                'Outfit',
                              ),
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

  Future<dynamic> otpUbahSandi(BuildContext context, bool phone) {
    isKeyboardActive = false;

    return showModalBottomSheet(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      context: context,
      builder: (context) => Consumer<TimerProvider>(
        builder: (context, timerProvider, child) => StatefulBuilder(
          builder: (context, setState) => IntrinsicHeight(
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
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
                                style: heading1(
                                  FontWeight.w700,
                                  bnw900,
                                  'Outfit',
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(
                                  context,
                                ).popUntil((route) => route.isFirst),
                                child: Icon(
                                  PhosphorIcons.x_fill,
                                  color: bnw900,
                                  size: size32,
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: size16),
                                  Text(
                                    'Masukkan Kode Verifikasi (OTP)',
                                    style: heading2(
                                      FontWeight.w600,
                                      bnw900,
                                      'Outfit',
                                    ),
                                  ),
                                  Text(
                                    phone
                                        ? 'Kode Verifikasi telah dikirimkan ke telepon kamu'
                                        : 'Kode Verifikasi telah dikirimkan ke email kamu',
                                    style: heading3(
                                      FontWeight.w400,
                                      bnw900,
                                      'Outfit',
                                    ),
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
                                          textStyle: heading1(
                                            FontWeight.w700,
                                            bnw900,
                                            'Outfit',
                                          ),
                                          onCompleted: (pin) {
                                            setState(() {
                                              validasiOtpSandi(
                                                context,
                                                checkToken,
                                                pin,
                                                phone ? 'whatsapp' : 'email',
                                              ).then((value) {
                                                value == '00'
                                                    ? ubahSandiShowdialog(
                                                        context,
                                                        phone ? true : false,
                                                      )
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
                                            debugPrint(
                                              "Allowing to paste $text",
                                            );
                                            return false;
                                          },
                                        ),
                                        SizedBox(
                                          height: errorText.isNotEmpty
                                              ? size16
                                              : 0,
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            errorText.isNotEmpty
                                                ? errorText
                                                : '',
                                            style: heading4(
                                              FontWeight.w500,
                                              red500,
                                              'Outfit',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: errorText.isNotEmpty ? size16 : 0,
                                  ),
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
                                            FontWeight.w400,
                                            bnw900,
                                            'Outfit',
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {},
                                          child:
                                              timerProvider.timerText ==
                                                  '00: 00'
                                              ? GestureDetector(
                                                  onTap: () {
                                                    getOtpSandi(
                                                      context,
                                                      checkToken,
                                                      phone
                                                          ? 'whatsapp'
                                                          : 'email',
                                                    );
                                                    timerProvider
                                                        .startTimeout();
                                                  },
                                                  // onTap: () => registerAgain(),
                                                  child: Text(
                                                    'Kirim Ulang Code',
                                                    style: heading4(
                                                      FontWeight.w600,
                                                      primary500,
                                                      'Outfit',
                                                    ),
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
                                                        'Outfit',
                                                      ),
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
                              style: heading3(
                                FontWeight.w600,
                                bnw900,
                                'Outfit',
                              ),
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

  Future<dynamic> changeEmailField(BuildContext context, bool phone) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    isKeyboardActive = false;
    errorText = '';
    return showModalBottomSheet(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      context: context,
      builder: (context) => Consumer<TimerProvider>(
        builder: (context, timerProvider, _) => StatefulBuilder(
          builder: (context, setState) => IntrinsicHeight(
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
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
                              style: heading1(
                                FontWeight.w700,
                                bnw900,
                                'Outfit',
                              ),
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
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              'Email Baru',
                              style: heading4(
                                FontWeight.w400,
                                bnw900,
                                'Outfit',
                              ),
                            ),
                            Text(
                              '*',
                              style: heading4(
                                FontWeight.w400,
                                danger500,
                                'Outfit',
                              ),
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
                              errorText: errorText.isNotEmpty
                                  ? errorText
                                  : null,
                              hintText: controllerEmail.text,
                              hintStyle: heading3(
                                FontWeight.w500,
                                bnw500,
                                'Outfit',
                              ),
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
                              checkToken,
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
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  String errorShowKonfirmasiText = '';
  String currentText = "";
  late TextEditingController controllerName = TextEditingController(
    text: nameProfile,
  );
  late TextEditingController controllerPhone = TextEditingController(
    text: phoneProfile,
  );
  late TextEditingController controllerEmail = TextEditingController(
    text: emailProfile,
  );

  Future<dynamic> verifEmailField(BuildContext context) {
    return showModalBottomSheet(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => IntrinsicHeight(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
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
                          ),
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
                            style: heading4(
                              FontWeight.w400,
                              danger500,
                              'Outfit',
                            ),
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
                            hintStyle: heading3(
                              FontWeight.w500,
                              bnw500,
                              'Outfit',
                            ),
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

  Future<dynamic> showError(BuildContext context, bool checkShow, sandi, ubah) {
    return showModalBottomSheet(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
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
                                style: heading1(
                                  FontWeight.w600,
                                  bnw900,
                                  'Outfit',
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: size8),
                              Text(
                                sandi == true
                                    ? 'Agar kamu dapat menggunakan kata sandi saat masuk akun. Kamu harus membuat kata sandi terlebih dahulu. '
                                    : emailProfile == null
                                    ? 'Untuk membuat kata sandi, kamu harus menambahkan email terlebih dahulu.'
                                    : 'Untuk membuat kata sandi, kamu harus verifikasi email terlebih dahulu.',
                                style: heading2(
                                  FontWeight.w400,
                                  bnw500,
                                  'Outfit',
                                ),
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
                              style: heading1(
                                FontWeight.w600,
                                bnw900,
                                'Outfit',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: size8),
                            Text(
                              'Silahkan menghubungi customer service unipos untuk info lebih lanjut.',
                              style: heading2(
                                FontWeight.w400,
                                bnw500,
                                'Outfit',
                              ),
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
                                      style: heading3(
                                        FontWeight.w600,
                                        primary500,
                                        'Outfit',
                                      ),
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
                                        FontWeight.w600,
                                        bnw100,
                                        'Outfit',
                                      ),
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
                                    FontWeight.w600,
                                    bnw100,
                                    'Outfit',
                                  ),
                                ),
                              ),
                              MediaQuery.of(context).size.width,
                            ),
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

  //! verifikasi sandi
  Future<dynamic> verifikasiEmailField(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    isKeyboardActive = false;
    return showModalBottomSheet(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => IntrinsicHeight(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
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
                          ),
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
                            style: heading4(
                              FontWeight.w400,
                              danger500,
                              'Outfit',
                            ),
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
                            hintStyle: heading3(
                              FontWeight.w500,
                              bnw500,
                              'Outfit',
                            ),
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

  bool isKeyboardActive = false;
  bool _obscureText = true;
  bool _obscureText2 = true;
  refreshField() {
    // conOldPass.text = '';
    controllerChangePass.text = '';
    controllerConfirmPass.text = '';
  }

  Future<dynamic> verifikasiDiriKamuSandiShowdialog(BuildContext context) {
    return showModalBottomSheet(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
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
                Center(child: dividerShowdialog()),
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
                    ),
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
                                  onTap: () async {
                                    timerProvider.startTimeout();
                                    final response = await http.post(
                                      Uri.parse(getOtpSandiLink),
                                      headers: {
                                        'token': checkToken,
                                        'Content-Type':
                                            'application/x-www-form-urlencoded',
                                      },
                                      body: {
                                        'deviceid': identifier,
                                        'typeotp': 'whatsapp',
                                      },
                                    );

                                    final jsonResponse = jsonDecode(
                                      response.body,
                                    );

                                    print('Response: $jsonResponse');
                                    otpUbahSandi(context, true);
                                    clearForm();
                                  },
                                  child: buttonXLoutline(
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          PhosphorIcons.whatsapp_logo_fill,
                                          color: primary500,
                                        ),
                                        SizedBox(width: size16),
                                        Text(
                                          'Nomor Telepon',
                                          style: heading3(
                                            FontWeight.w600,
                                            primary500,
                                            'Outfit',
                                          ),
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
                                    getOtpSandi(context, checkToken, 'email');
                                    otpUbahSandi(context, false);
                                    clearForm();
                                  },
                                  child: buttonXLoutline(
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          PhosphorIcons.envelope_fill,
                                          color: primary500,
                                        ),
                                        SizedBox(width: size16),
                                        Text(
                                          'Email',
                                          style: heading3(
                                            FontWeight.w600,
                                            primary500,
                                            'Outfit',
                                          ),
                                        ),
                                      ],
                                    ),
                                    MediaQuery.of(context).size.width,
                                    primary500,
                                  ),
                                ),
                          ),
                        ),
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
      constraints: const BoxConstraints(maxWidth: double.infinity),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => IntrinsicHeight(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
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
                              style: heading1(
                                FontWeight.w700,
                                bnw900,
                                'Outfit',
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Text(
                                  'Kata Sandi ',
                                  style: heading4(
                                    FontWeight.w400,
                                    bnw900,
                                    'Outfit',
                                  ),
                                ),
                                Text(
                                  '*',
                                  style: heading4(
                                    FontWeight.w400,
                                    danger500,
                                    'Outfit',
                                  ),
                                ),
                              ],
                            ),
                            TextFormField(
                              style: heading2(
                                FontWeight.w600,
                                bnw900,
                                'Outfit',
                              ),
                              controller: controllerChangePass,
                              obscureText: _obscureText,
                              obscuringCharacter: '*',
                              onChanged: (value) {
                                setState(() {});
                              },
                              decoration: InputDecoration(
                                focusColor: primary500,
                                errorText: errorText.isNotEmpty
                                    ? errorText
                                    : null,
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
                                hintStyle: heading2(
                                  FontWeight.w600,
                                  bnw400,
                                  'Outfit',
                                ),
                              ),
                            ),
                            SizedBox(height: size8),
                            Row(
                              children: [
                                Text(
                                  'Konfirmasi Kata Sandi ',
                                  style: heading4(
                                    FontWeight.w400,
                                    bnw900,
                                    'Outfit',
                                  ),
                                ),
                                Text(
                                  '*',
                                  style: heading4(
                                    FontWeight.w400,
                                    danger500,
                                    'Outfit',
                                  ),
                                ),
                              ],
                            ),
                            TextFormField(
                              style: heading2(
                                FontWeight.w600,
                                bnw900,
                                'Outfit',
                              ),
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
                                  FontWeight.w600,
                                  bnw400,
                                  'Outfit',
                                ),
                              ),
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
                                checkToken,
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
                  SizedBox(height: size16),
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
      constraints: const BoxConstraints(maxWidth: double.infinity),
      // barrierColor: Colors.transparent,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      context: context,
      builder: (context) => Consumer<TimerProvider>(
        builder: (context, timerProvider, _) => StatefulBuilder(
          builder: (context, setState) => IntrinsicHeight(
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
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
                              style: heading1(
                                FontWeight.w700,
                                bnw900,
                                'Outfit',
                              ),
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
                              style: heading4(
                                FontWeight.w400,
                                bnw900,
                                'Outfit',
                              ),
                            ),
                            Text(
                              '*',
                              style: heading4(
                                FontWeight.w400,
                                danger500,
                                'Outfit',
                              ),
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
                              errorText: errorText.isNotEmpty
                                  ? errorText
                                  : null,
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
                              hintStyle: heading2(
                                FontWeight.w600,
                                bnw400,
                                'Outfit',
                              ),
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
                                    FontWeight.w600,
                                    primary500,
                                    'Outfit',
                                  ),
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
                                    checkToken,
                                    controllerEmail.text,
                                    controllerPass.text,
                                  ).then((value) {
                                    log(value);
                                    if (value == '00') {
                                      timerProvider.startTimeout();
                                      errorText = '';
                                      otpBuatSandi(context);
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
                                    FontWeight.w600,
                                    bnw100,
                                    'Outfit',
                                  ),
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

  Future<dynamic> verifikasiEmailFieldBuatSandi(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    isKeyboardActive = false;
    return showModalBottomSheet(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => IntrinsicHeight(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
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
                          ),
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
                            style: heading4(
                              FontWeight.w400,
                              danger500,
                              'Outfit',
                            ),
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
                            hintStyle: heading3(
                              FontWeight.w500,
                              bnw500,
                              'Outfit',
                            ),
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
      constraints: const BoxConstraints(maxWidth: double.infinity),
      // barrierColor: Colors.transparent,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      context: context,
      builder: (context) => Consumer<TimerProvider>(
        builder: (context, timerProvider, _) => StatefulBuilder(
          builder: (context, setState) => IntrinsicHeight(
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
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
                              style: heading1(
                                FontWeight.w700,
                                bnw900,
                                'Outfit',
                              ),
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
                              style: heading4(
                                FontWeight.w400,
                                bnw900,
                                'Outfit',
                              ),
                            ),
                            Text(
                              '*',
                              style: heading4(
                                FontWeight.w400,
                                danger500,
                                'Outfit',
                              ),
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
                              errorText: errorText.isNotEmpty
                                  ? errorText
                                  : null,
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
                              hintStyle: heading2(
                                FontWeight.w600,
                                bnw400,
                                'Outfit',
                              ),
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
                                    FontWeight.w600,
                                    primary500,
                                    'Outfit',
                                  ),
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
                                    checkToken,
                                    controllerEmail.text,
                                    controllerPass.text,
                                  ).then((value) {
                                    log(value);
                                    if (value == '00') {
                                      errorText = '';
                                      timerProvider.startTimeout();
                                      otpBuatSandi(context);
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
                                    FontWeight.w600,
                                    bnw100,
                                    'Outfit',
                                  ),
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

  OtpFieldController otpController = OtpFieldController();
  TextEditingController otpControllerFix = TextEditingController();
  late String otpText;

  Future<dynamic> otpBuatSandi(BuildContext context) {
    isKeyboardActive = false;

    return showModalBottomSheet(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      context: context,
      builder: (context) => Consumer<TimerProvider>(
        builder: (context, timerProvider, child) => IntrinsicHeight(
          child: StatefulBuilder(
            builder: (context, setState) => Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
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
                                  style: heading1(
                                    FontWeight.w700,
                                    bnw900,
                                    'Outfit',
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.of(
                                    context,
                                  ).popUntil((route) => route.isFirst),
                                  child: Icon(
                                    PhosphorIcons.x_fill,
                                    color: bnw900,
                                    size: size32,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Masukkan Kode Verifikasi (OTP)',
                                  style: heading2(
                                    FontWeight.w600,
                                    bnw900,
                                    'Outfit',
                                  ),
                                ),
                                Text(
                                  'Kode Verifikasi telah dikirimkan ke email kamu',
                                  style: heading3(
                                    FontWeight.w400,
                                    bnw900,
                                    'Outfit',
                                  ),
                                ),
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
                                          FontWeight.w700,
                                          bnw900,
                                          'Outfit',
                                        ),
                                        onCompleted: (pin) {
                                          setState(() {
                                            verifiedEmailbyOTP(
                                              context,
                                              checkToken,
                                              pin,
                                            ).then((value) {
                                              if (value == '00') {
                                                Navigator.of(context).popUntil(
                                                  (route) => route.isFirst,
                                                );
                                                showSnackBarComponent(
                                                  context,
                                                  'Berhasil verifikasi email',
                                                  '00',
                                                );
                                              } else {
                                                showSnackBarComponent(
                                                  context,
                                                  'Gagal verifikasi email',
                                                  '14',
                                                );
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
                                    height: errorText.isNotEmpty ? size16 : 0,
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      errorText.isNotEmpty ? errorText : '',
                                      style: heading4(
                                        FontWeight.w500,
                                        red500,
                                        'Outfit',
                                      ),
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
                                        FontWeight.w400,
                                        bnw900,
                                        'Outfit',
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {},
                                      child: timerProvider.timerText == '00: 00'
                                          ? GestureDetector(
                                              onTap: () {
                                                verifiedEmail(
                                                  context,
                                                  checkToken,
                                                  controllerEmail.text,
                                                  controllerPass.text,
                                                );
                                                timerProvider.startTimeout();
                                              },
                                              // onTap: () => registerAgain(),
                                              child: Text(
                                                'Kirim Ulang Code',
                                                style: heading4(
                                                  FontWeight.w600,
                                                  primary500,
                                                  'Outfit',
                                                ),
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
                                                    'Outfit',
                                                  ),
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
                              style: heading3(
                                FontWeight.w600,
                                bnw900,
                                'Outfit',
                              ),
                            ),
                          ),
                          MediaQuery.of(context).size.width,
                          bnw300,
                        ),
                      ),
                    ),
                    SizedBox(height: size16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider() => const Divider(thickness: 1, height: 20);

  Widget _infoItem(
    String label,
    String value,
    String ubahText, {
    bool withEdit = false,
    VoidCallback? onEdit,
    context,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: heading4(FontWeight.w400, bnw700, 'Outfit')),
              const SizedBox(height: 4),
              Text(value, style: heading3(FontWeight.w600, bnw900, 'Outfit')),
            ],
          ),
        ),
        if (withEdit)
          GestureDetector(
            onTap:
                onEdit ??
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ubah $label belum aktif')),
                  );
                },
            child: Text(
              ubahText,
              style: heading4(FontWeight.w600, primary500, 'Outfit'),
            ),
          ),
      ],
    );
  }
}
