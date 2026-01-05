import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:unipos_app_335/models/userModel.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';

class FormUserMobile extends StatefulWidget {
  final String token, merchantId;
  final UserModel? userItem; // If null, then Create mode.

  const FormUserMobile({Key? key, required this.token, required this.merchantId, this.userItem})
    : super(key: key);

  @override
  State<FormUserMobile> createState() => _FormUserMobileState();
}

class _FormUserMobileState extends State<FormUserMobile> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _selectedRole = "user"; // admin, user, cashier
  bool _isLoadingDetail = false;
  String? _base64Image;

  final List<Map<String, String>> _roleOptions = [
    {"label": "Admin", "value": "admin"},
    {"label": "Pengguna", "value": "user"},
    {"label": "Kasir", "value": "cashier"},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.merchantId == null) {
      myprofile(widget.token);
    }
    if (widget.userItem != null) {
      _loadDetail();
    }
  }

  Future<void> _loadDetail() async {
    setState(() => _isLoadingDetail = true);
    try {
      final detail = await getSingleUserAccount(
        context,
        widget.token,
        widget.userItem!.userid!,
      );
      if (detail != null) {
        _fullNameController.text = detail.fullname ?? "";
        _emailController.text = detail.email ?? "";
        _phoneController.text = detail.phonenumber ?? "";
        _selectedRole = detail.role?.toLowerCase() ?? "user";
        // image? account_image is URL.
        // For editing, we usually don't show the base64 unless changed.
      }
    } catch (e) {
      print("Error loading user detail: $e");
    } finally {
      if (mounted) setState(() => _isLoadingDetail = false);
    }
  }

  void _onSave(bool addNew) async {
    if (_fullNameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Nama Lengkap dan Nomor Telepon wajib diisi")),
      );
      return;
    }

    String rc;
    if (widget.userItem == null) {
      // Create
      // We need merchantid. Assuming we use widget.merchantId from apimethod.dart
      rc = await createUserAccount(
        context,
        widget.token,
        widget.merchantId,
        _fullNameController.text,
        _phoneController.text,
        _emailController.text,
        _selectedRole,
        _base64Image ?? "",
      );
    } else {
      // Update
      rc = await updateUserAccount(
        context,
        widget.token,
        widget.userItem!.userid!,
        _fullNameController.text,
        _phoneController.text,
        _emailController.text,
        _selectedRole,
        widget.userItem!.status ?? "1",
        _base64Image ?? "",
      );
    }

    if (rc == '00') {
      if (addNew && widget.userItem == null) {
        _fullNameController.clear();
        _emailController.clear();
        _phoneController.clear();
        setState(() {
          _selectedRole = "user";
          _base64Image = null;
        });
      } else {
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      setState(() {
        _base64Image = base64Encode(bytes);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isUpdate = widget.userItem != null;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrow_left, color: bnw900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isUpdate ? "Ubah Akun" : "Tambah Akun",
          style: heading2(FontWeight.w700, bnw900, 'Outfit'),
        ),
      ),
      body: _isLoadingDetail
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Logo / Foto Toko",
                          style: body1(FontWeight.w600, bnw900, 'Outfit'),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(color: bnw300),
                                  borderRadius: BorderRadius.circular(12),
                                  image: _base64Image != null
                                      ? DecorationImage(
                                          image: MemoryImage(
                                            base64Decode(_base64Image!),
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : (isUpdate &&
                                                widget.userItem?.accountImage !=
                                                    null &&
                                                widget
                                                    .userItem!
                                                    .accountImage!
                                                    .isNotEmpty
                                            ? DecorationImage(
                                                image: NetworkImage(
                                                  widget
                                                      .userItem!
                                                      .accountImage!,
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                            : null),
                                ),
                                child:
                                    _base64Image == null &&
                                        (!isUpdate ||
                                            widget.userItem?.accountImage ==
                                                null ||
                                            widget
                                                .userItem!
                                                .accountImage!
                                                .isEmpty)
                                    ? Center(
                                        child: Icon(
                                          PhosphorIcons.plus,
                                          color: bnw900,
                                          size: 32,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                "Masukkan Foto Terbaikmu. Fotomu akan bisa dilihat siapa saja",
                                style: body2(FontWeight.w400, bnw500, 'Outfit'),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),

                        // Nama Lengkap
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Nama Lengkap",
                                style: body1(FontWeight.w600, bnw900, 'Outfit'),
                              ),
                              TextSpan(
                                text: " *",
                                style: body1(
                                  FontWeight.w600,
                                  Colors.red,
                                  'Outfit',
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _fullNameController,
                          decoration: InputDecoration(
                            hintText: "Muhammad Nabil",
                            hintStyle: body1(FontWeight.w400, bnw300, 'Outfit'),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: bnw300),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),

                        // Akses
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Akses",
                                style: body1(FontWeight.w600, bnw900, 'Outfit'),
                              ),
                              TextSpan(
                                text: " *",
                                style: body1(
                                  FontWeight.w600,
                                  Colors.red,
                                  'Outfit',
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: bnw300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedRole,
                              icon: Icon(
                                PhosphorIcons.caret_up,
                                size: 16,
                                color: bnw500,
                              ),
                              items: _roleOptions.map((opt) {
                                return DropdownMenuItem<String>(
                                  value: opt['value'],
                                  child: Text(
                                    opt['label']!,
                                    style: body1(
                                      FontWeight.w600,
                                      bnw900,
                                      'Outfit',
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null)
                                  setState(() => _selectedRole = val);
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 24),

                        // Email
                        Text(
                          "Email",
                          style: body1(FontWeight.w600, bnw900, 'Outfit'),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "nabil@email.com",
                            hintStyle: body1(FontWeight.w400, bnw300, 'Outfit'),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: bnw300),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),

                        // Nomor Telepon
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Nomor Telepon",
                                style: body1(FontWeight.w600, bnw900, 'Outfit'),
                              ),
                              TextSpan(
                                text: " *",
                                style: body1(
                                  FontWeight.w600,
                                  Colors.red,
                                  'Outfit',
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: "08123456789",
                            hintStyle: body1(FontWeight.w400, bnw300, 'Outfit'),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: bnw300),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer Buttons
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      if (!isUpdate) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _onSave(true),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: primaryColor),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              "Save & Add New",
                              style: body1(
                                FontWeight.w600,
                                primaryColor,
                                'Outfit',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _onSave(false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            isUpdate ? "Simpan" : "Create",
                            style: body1(
                              FontWeight.w600,
                              Colors.white,
                              'Outfit',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
