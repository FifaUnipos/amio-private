import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_button.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_showModalBottom.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unipos_app_335/pageMobile/pageHelperMobile/loginRegisMobile/loginPageMobile.dart';
import 'package:unipos_app_335/utils/component/component_loading.dart';
import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/utils/utilities.dart';

class SettingsTab extends StatefulWidget {
  final String token;
  final String merchantId;

  const SettingsTab({Key? key, required this.token, required this.merchantId})
    : super(key: key);

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  bool _isLoading = true;
  String? _receiptLogoUrl;
  final ImagePicker _picker = ImagePicker();
  bool get isCashier => roleProfile?.toLowerCase() == 'cashier';

  @override
  void initState() {
    super.initState();
    _loadReceiptLogo();
  }

  Future<void> _loadReceiptLogo() async {
    setState(() => _isLoading = true);
    try {
      final data = await getReceiptLogo(widget.token, widget.merchantId);
      if (data != null && data['data'] != null) {
        setState(() {
          _receiptLogoUrl = data['data']['struk_printer'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _receiptLogoUrl = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading receipt logo: $e");
      setState(() {
        _receiptLogoUrl = null;
        _isLoading = false;
      });
    }
  }

  File? myImage;
  Uint8List? bytes;
  String? img64;
  List<String> images = [];

  Future<void> getImage() async {
    var picker = ImagePicker();
    PickedFile? image;

    image = await picker.getImage(
      source: ImageSource.gallery,
      // imageQuality: 50,
      maxHeight: 900,
      maxWidth: 900,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      final rc = await uploadReceiptLogo(
        context,
        widget.token,
        widget.merchantId,
        base64Image,
      );

      if (rc == '00') {
        await _loadReceiptLogo();
      }
    } else {
      print('Error Image');
    }
  }

  Future<void> _deleteReceiptLogo() async {
    final rc = await deleteReceiptLogo(
      context,
      widget.token,
      widget.merchantId,
    );

    if (rc == '00') {
      await _loadReceiptLogo();
    }
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('deviceid');
    checkToken = '';

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPageMobile()),
      (route) => false,
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size12),
          ),
          title: Text(
            'Konfirmasi Keluar',
            style: heading2(FontWeight.w700, bnw900, 'Outfit'),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari akun ini?',
            style: heading3(FontWeight.w400, bnw700, 'Outfit'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: heading3(FontWeight.w600, bnw600, 'Outfit'),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _logout(context);
              },
              child: Text(
                'Keluar',
                style: heading3(FontWeight.w600, danger500, 'Outfit'),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    List<String> names = name.split(" ");
    String initials = "";
    int numWords = 2;
    if (names.length < numWords) numWords = names.length;
    for (var i = 0; i < numWords; i++) {
      if (names[i].isNotEmpty) {
        initials += names[i][0];
      }
    }
    return initials.toUpperCase();
  }

  void _showLogoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: bnw100,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.all(size16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: size16),
                  decoration: BoxDecoration(
                    color: bnw300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Logo Struk',
                style: heading2(FontWeight.w700, bnw900, 'Outfit'),
              ),
              SizedBox(height: size16),
              ListTile(
                leading: Icon(PhosphorIcons.image, color: bnw900),
                title: Text(
                  'Pilih dari galeri',
                  style: heading3(FontWeight.w400, bnw900, 'Outfit'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  getImage();
                },
              ),
              if (_receiptLogoUrl != null)
                ListTile(
                  leading: Icon(PhosphorIcons.trash, color: danger500),
                  title: Text(
                    'Hapus foto',
                    style: heading3(FontWeight.w400, danger500, 'Outfit'),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteReceiptLogo();
                  },
                ),
              SizedBox(height: size16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(size16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Card 1: User Profile
          !isCashier
              ? SizedBox()
              : Container(
                  padding: EdgeInsets.all(size16),
                  decoration: BoxDecoration(
                    color: bnw100,
                    borderRadius: BorderRadius.circular(size16),
                    boxShadow: [
                      BoxShadow(
                        color: bnw900.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: bnw200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profil Pengguna',
                        style: heading4(FontWeight.w600, bnw600, 'Outfit'),
                      ),
                      SizedBox(height: size16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          imageProfile == null || imageProfile == ''
                              ? CircleAvatar(
                                  backgroundColor: primary100,
                                  radius: 35,
                                  child: Center(
                                    child: Text(
                                      _getInitials(nameProfile ?? "User"),
                                      style: heading1(
                                        FontWeight.w600,
                                        primary500,
                                        'Outfit',
                                      ),
                                    ),
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(70),
                                  child: Image.network(
                                    imageProfile,
                                    height: 70,
                                    width: 70,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return Center(child: loading());
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return CircleAvatar(
                                        backgroundColor: primary100,
                                        radius: 35,
                                        child: Center(
                                          child: Text(
                                            _getInitials(nameProfile ?? "User"),
                                            style: heading1(
                                              FontWeight.w600,
                                              primary500,
                                              'Outfit',
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nameProfile ?? "Nama Pengguna",
                                  style: heading2(
                                    FontWeight.w700,
                                    bnw900,
                                    'Outfit',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  roleProfile ?? "Kasir",
                                  style: heading4(
                                    FontWeight.w400,
                                    bnw700,
                                    'Outfit',
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  phoneProfile ?? "-",
                                  style: heading4(
                                    FontWeight.w400,
                                    bnw700,
                                    'Outfit',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

          SizedBox(height: size20),

          // 🔹 Card 2: Receipt Settings
          Container(
            padding: EdgeInsets.all(size16),
            decoration: BoxDecoration(
              color: bnw100,
              borderRadius: BorderRadius.circular(size16),
              boxShadow: [
                BoxShadow(
                  color: bnw900.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: bnw200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pengaturan Struk',
                  style: heading4(FontWeight.w600, bnw600, 'Outfit'),
                ),
                SizedBox(height: size16),
                Center(
                  child: GestureDetector(
                    onTap: _showLogoOptions,
                    child: Container(
                      padding: EdgeInsets.all(size16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: bnw100,
                        borderRadius: BorderRadius.circular(size12),
                        border: Border.all(
                          color: bnw200,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        children: [
                          _isLoading
                              ? const CircularProgressIndicator()
                              : _receiptLogoUrl != null
                              ? Column(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          size8,
                                        ),
                                        border: Border.all(color: bnw200),
                                      ),
                                      child: Image.network(
                                        _receiptLogoUrl!,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Icon(
                                                PhosphorIcons.receipt,
                                                size: 60,
                                                color: bnw400,
                                              );
                                            },
                                      ),
                                    ),
                                    SizedBox(height: size12),
                                    Text(
                                      'Logo Terhubung',
                                      style: heading3(
                                        FontWeight.w600,
                                        bnw900,
                                        'Outfit',
                                      ),
                                    ),
                                    Text(
                                      'Klik untuk mengganti logo',
                                      style: heading4(
                                        FontWeight.w400,
                                        bnw600,
                                        'Outfit',
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Icon(
                                      PhosphorIcons.receipt,
                                      size: 80,
                                      color: bnw300,
                                    ),
                                    SizedBox(height: size12),
                                    Text(
                                      'Logo Belum Terhubung',
                                      style: heading3(
                                        FontWeight.w600,
                                        bnw900,
                                        'Outfit',
                                      ),
                                    ),
                                    Text(
                                      'Klik untuk mengunggah logo',
                                      style: heading4(
                                        FontWeight.w400,
                                        bnw600,
                                        'Outfit',
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

          SizedBox(height: size32),
          !isCashier
              ? SizedBox()
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
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
                              style: heading1(
                                FontWeight.w600,
                                bnw900,
                                'Outfit',
                              ),
                            ),
                            SizedBox(height: size8),
                            Text(
                              'Jika kamu keluar, kamu harus memasukkan akun lagi untuk melakukkan transaksi.',
                              style: heading2(
                                FontWeight.w400,
                                bnw900,
                                'Outfit',
                              ),
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
                                      Future<void> logout(
                                        BuildContext context,
                                      ) async {
                                        SharedPreferences prefs =
                                            await SharedPreferences.getInstance();
                                        prefs.remove('token');
                                        prefs.remove('deviceid');
                                        checkToken = '';

                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginPageMobile(),
                                          ),
                                          (route) => false,
                                        );
                                      }
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
                                          builder: (context) =>
                                              LoginPageMobile(),
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
                    icon: Icon(PhosphorIcons.sign_out, color: bnw100),
                    label: Text(
                      'Keluar Akun',
                      style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: danger500,
                      padding: EdgeInsets.symmetric(vertical: size16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(size12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
          SizedBox(height: size32),
        ],
      ),
    );
  }
}
