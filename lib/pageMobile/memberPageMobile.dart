import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:unipos_app_335/main.dart'; // For identifiers/tokens if needed
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_button.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_snackbar.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';

// -----------------------------------------------------------------------------
// Models & Service
// -----------------------------------------------------------------------------

class MemberModel {
  String memberid;
  String merchantid;
  String namaMember;
  String alamatMember;
  String phonenumber;
  String? email;
  int saldo;

  MemberModel({
    required this.memberid,
    required this.merchantid,
    required this.namaMember,
    required this.alamatMember,
    required this.phonenumber,
    this.email,
    required this.saldo,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      memberid: json['memberid'] ?? '',
      merchantid: json['merchantid'] ?? '',
      namaMember: json['nama_member'] ?? '',
      alamatMember: json['alamat_member'] ?? '',
      phonenumber: json['phonenumber'] ?? '',
      email: json['email'],
      saldo: int.tryParse(json['saldo'].toString()) ?? 0,
    );
  }
}

class MemberService {
  // Replace this with your actual base URL

  static Future<List<MemberModel>?> getMembers(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse(getPelanggantUrl), // Common domain seen in printerPage
       headers: {'token': checkToken, 'Content-Type': 'application/json'},
        body: jsonEncode({
          "deviceid": identifier, // from main.dart
          "orderby": "upDownNama",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null) {
          List<MemberModel> members = [];
          for (var item in data['data']) {
            members.add(MemberModel.fromJson(item));
          }
          return members;
        }
      }
    } catch (e) {
      print("Error fetching members: $e");
    }
    return null;
  }

  static Future<bool> createMember(
    BuildContext context,
    String nama,
    String alamat,
    String phone,
    String email,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(createPelangganUrl),
        headers: {'token': checkToken, 'Content-Type': 'application/json'},
        body: jsonEncode({
          "deviceid": identifier,
          "nama_member": nama,
          "alamat_member": alamat,
          "phonenumber": phone,
          "email": email,
        }),
      );



      debugPrint("Create Member Response: ${response.body}");
      final data = jsonDecode(response.body);
      if (data['message'] == 'success' || data['rc'] == '00') {
        // diverse success checks
        return true;
      }
    } catch (e) {
      print("Error create member: $e");
    }
    return false;
  }

  static Future<bool> editMember(
    BuildContext context,
    String memberId,
    String nama,
    String alamat,
    String phone,
    String email,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(editPelangganUrl),
       headers: {'token': checkToken, 'Content-Type': 'application/json'},
        body: jsonEncode({
          "deviceid": identifier,
          "memberid": memberId,
          "nama_member": nama,
          "alamat_member": alamat,
          "phonenumber": phone,
          "email": email,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['message'] == 'success' || data['rc'] == '00') {
        return true;
      }
    } catch (e) {
      print("Error edit member: $e");
    }
    return false;
  }

  static Future<bool> deleteMember(
    BuildContext context,
    String memberId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(deletePelangganUrl),
       headers: {'token': checkToken, 'Content-Type': 'application/json'},
        body: jsonEncode({
          "deviceid": identifier,
          "memberid": [memberId],
        }),
      );

      final data = jsonDecode(response.body);
      if (data['message'] == 'success' || data['rc'] == '00') {
        return true;
      }
    } catch (e) {
      print("Error delete member: $e");
    }
    return false;
  }
}

// -----------------------------------------------------------------------------
// Main Member Page
// -----------------------------------------------------------------------------

class MemberPageMobile extends StatefulWidget {
  const MemberPageMobile({Key? key}) : super(key: key);

  @override
  State<MemberPageMobile> createState() => _MemberPageMobileState();
}

class _MemberPageMobileState extends State<MemberPageMobile> {
  List<MemberModel> members = [];
  bool isLoading = true;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => isLoading = true);
    final data = await MemberService.getMembers(context);
    setState(() {
      members = data ?? [];
      isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter logic
    List<MemberModel> filteredMembers = members;
    if (searchQuery.isNotEmpty) {
      filteredMembers = members
          .where(
            (m) =>
                m.namaMember.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }

    return Scaffold(
      backgroundColor: bnw100, // Assuming bnw100 is white
      appBar: AppBar(
        backgroundColor: bnw100,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: bnw900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Pelanggan",
          style: heading2(FontWeight.w700, bnw900, 'Outfit'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: InkWell(
                onTap: () async {
                  bool? refresh = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => CreateMemberPage()),
                  );
                  if (refresh == true) _loadMembers();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: primary500, // Assuming primary500 is blue
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Tambah",
                    style: heading4(FontWeight.w600, bnw100, 'Outfit'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : filteredMembers.isEmpty && searchQuery.isEmpty
          ? _buildEmptyState()
          : _buildListState(filteredMembers),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration would go here (using spacer or icon)
          // Text("Belum Ada Pelanggan", style... from Image 1)
          Text(
            "Belum Ada Pelanggan",
            style: heading2(FontWeight.w700, bnw900, 'Outfit'),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              "Silahkan membuat pelanggan terlebih dahulu untuk menggunakan fitur transaksi di kasir.",
              textAlign: TextAlign.center,
              style: heading4(FontWeight.w400, bnw500, 'Outfit'),
            ),
          ),
          SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: GestureDetector(
              onTap: () async {
                bool? refresh = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => CreateMemberPage()),
                );
                if (refresh == true) _loadMembers();
              },
              child: buttonXL(
                Center(
                  child: Text(
                    "Buat Pelanggan",
                    style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                  ),
                ),
                200,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListState(List<MemberModel> filteredList) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: bnw200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              decoration: InputDecoration(
                icon: Icon(PhosphorIcons.magnifying_glass, color: bnw500),
                hintText: "Cari",
                border: InputBorder.none,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
        ),

        // Sort & Total
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: bnw300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      "Urutkan",
                      style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_drop_down, color: bnw900),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: bnw300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Total Pelanggan : ${members.length}",
                  style: heading4(FontWeight.w400, bnw600, 'Outfit'),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),

        // List Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Pilih Pelanggan",
              style: heading3(FontWeight.w600, bnw900, 'Outfit'),
            ),
          ),
        ),

        SizedBox(height: 8),

        // List
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredList.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final member = filteredList[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.namaMember,
                            style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                PhosphorIcons.coin_vertical_fill,
                                color: primary500,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "${member.saldo} Fifapay Coin",
                                style: heading4(
                                  FontWeight.w400,
                                  bnw500,
                                  'Outfit',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Buttons: "Pilih" and "Pencil"
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primary500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // Select logic if needed, typically returns member
                        Navigator.pop(context, member);
                      },
                      child: Text(
                        "Pilih",
                        style: heading4(FontWeight.w600, primary500, 'Outfit'),
                      ),
                    ),
                    SizedBox(width: 12),
                    InkWell(
                      onTap: () {
                        _showEditDeleteOptions(context, member);
                      },
                      child: Icon(
                        PhosphorIcons.pencil_simple_line,
                        color: bnw500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showEditDeleteOptions(BuildContext context, MemberModel member) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: bnw300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 24),
              ListTile(
                leading: Icon(PhosphorIcons.trash, color: red500),
                title: Text(
                  "Hapus Pelanggan",
                  style: heading3(FontWeight.w600, red500, 'Outfit'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(member);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(PhosphorIcons.pencil_simple, color: bnw900),
                title: Text(
                  "Ubah Pelanggan",
                  style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                ),
                onTap: () {
                  Navigator.pop(context); // Close sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => CreateMemberPage(member: member),
                    ),
                  ).then((val) {
                    if (val == true) _loadMembers();
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(MemberModel member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Hapus Pelanggan"),
        content: Text(
          "Apakah anda yakin ingin menghapus ${member.namaMember}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              bool success = await MemberService.deleteMember(
                context,
                member.memberid,
              );
              if (success) {
                _loadMembers();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Berhasil menghapus")));
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Gagal menghapus")));
              }
            },
            child: Text("Hapus", style: TextStyle(color: red500)),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Form Page (Create & Edit)
// -----------------------------------------------------------------------------

class CreateMemberPage extends StatefulWidget {
  final MemberModel? member; // If provided, it's Edit mode
  const CreateMemberPage({Key? key, this.member}) : super(key: key);

  @override
  State<CreateMemberPage> createState() => _CreateMemberPageState();
}

class _CreateMemberPageState extends State<CreateMemberPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _addressCtrl; // Assuming generic address field
  // Note: Image 3 shows only Name, Phone, Email, Instagram.
  // API requires Address too! I will add Address field, maybe hidden or plain text if not in UI.
  // Actually, I'll add Address as a field.

  late TextEditingController
  _instagramCtrl; // UI has it, API maybe not? I'll carry it.

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.member?.namaMember ?? '');
    _phoneCtrl = TextEditingController(text: widget.member?.phonenumber ?? '');
    _emailCtrl = TextEditingController(text: widget.member?.email ?? '');
    _addressCtrl = TextEditingController(
      text: widget.member?.alamatMember ?? '-',
    ); // default dash if empty?
    _instagramCtrl = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.member != null;
    return Scaffold(
      backgroundColor: bnw100,
      appBar: AppBar(
        title: Text(
          isEdit ? "Ubah Pelanggan" : "Tambah Pelanggan",
          style: heading2(FontWeight.w700, bnw900, 'Outfit'),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: bnw900),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: bnw100,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Nama Lengkap", required: true),
              TextFormField(
                controller: _nameCtrl,
                decoration: _inputDec("Bayu Setiawan"),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              SizedBox(height: 16),

              _buildLabel("Nomor Telepon", required: true),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: _inputDec("08123456789"),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              SizedBox(height: 16),

              _buildLabel("Email", required: false),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDec("Cth : bayu@email.com"),
              ),
              SizedBox(height: 16),

              _buildLabel("Alamat", required: true),
              TextFormField(
                controller: _addressCtrl,
                decoration: _inputDec("Jl. Raya..."),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              SizedBox(height: 16),

              _buildLabel("Instagram", required: false),
              TextFormField(
                controller: _instagramCtrl,
                decoration: _inputDec("Cth : @bayu123"),
              ),
              SizedBox(height: 32),

              Row(
                children: [
                  if (!isEdit) ...[
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: primary500),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => _submit(addMore: true),
                        child: Text(
                          "Simpan & Tambah Baru",
                          style: heading3(
                            FontWeight.w600,
                            primary500,
                            'Outfit',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary500,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _submit(),
                      child: Text(
                        "Simpan",
                        style: heading3(FontWeight.w600, bnw100, 'Outfit'),
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

  Widget _buildLabel(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(text, style: heading4(FontWeight.w600, bnw900, 'Outfit')),
          if (required) Text(" *", style: TextStyle(color: red500)),
        ],
      ),
    );
  }

  InputDecoration _inputDec(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: heading3(FontWeight.w400, bnw300, 'Outfit'),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: bnw900),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: primary500, width: 2),
      ),
    );
  }

  Future<void> _submit({bool addMore = false}) async {
    if (_formKey.currentState!.validate()) {
      bool success;
      if (widget.member == null) {
        // Create
        success = await MemberService.createMember(
          context,
          _nameCtrl.text,
          _addressCtrl.text,
          _phoneCtrl.text,
          _emailCtrl.text,
        );
      } else {
        // Edit
        success = await MemberService.editMember(
          context,
          widget.member!.memberid,
          _nameCtrl.text,
          _addressCtrl.text,
          _phoneCtrl.text,
          _emailCtrl.text,
        );
      }

      if (success) {
        if (addMore) {
          _nameCtrl.clear();
          _phoneCtrl.clear();
          _emailCtrl.clear();
          _addressCtrl.clear(); // Reset to default if needed, or clear
          _instagramCtrl.clear();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Berhasil disimpan")));
        } else {
          Navigator.pop(context, true);
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal menyimpan")));
      }
    }
  }
}
