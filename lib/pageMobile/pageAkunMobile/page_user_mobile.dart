import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:unipos_app_335/models/userModel.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'form_user_mobile.dart';

class PageUserMobile extends StatefulWidget {
  final String token, merchantId;
  const PageUserMobile({
    Key? key,
    required this.token,
    required this.merchantId,
  }) : super(key: key);

  @override
  State<PageUserMobile> createState() => _PageUserMobileState();
}

class _PageUserMobileState extends State<PageUserMobile> {
  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = true;
  String _searchQuery = "";
  String _selectedOrder = "upDownNama";

  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _sortOptions = [
    {"label": "Urutkan toko", "value": "upDownNama"},
    {"label": "Z-A", "value": "downUpNama"},
    {"label": "Account (Asc)", "value": "upDownAccount"},
    {"label": "Account (Desc)", "value": "downUpAccount"},
  ];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await getGroupUsers(context, widget.token, _selectedOrder);
      final scopedUsers = users.where((u) {
        if (widget.merchantId.isEmpty) return true;

        final userMerchantId = (u.merchantid ?? '').trim();
        return userMerchantId == widget.merchantId.trim();
      }).toList();

      setState(() {
        _allUsers = scopedUsers;
        _applyFilter();
      });
    } catch (e) {
      print("Error fetching users: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredUsers = List.from(_allUsers);
    } else {
      _filteredUsers = _allUsers.where((u) {
        final name = u.fullname?.toLowerCase() ?? "";
        // User request mentions "nama atau alamat", but users don't have address in response example.
        // I will search by name and phone.
        final phone = u.phonenumber ?? "";
        return name.contains(_searchQuery.toLowerCase()) ||
            phone.contains(_searchQuery);
      }).toList();
    }
  }

  Future<void> _toggleStatus(UserModel user, bool value) async {
    final newStatus = value ? "1" : "0";
    final rc = await changeUserStatus(
      context,
      widget.token,
      user.userid!,
      newStatus,
    );
    if (rc == '00') {
      setState(() {
        user.status = newStatus;
      });
    }
  }

  void _onEdit(UserModel user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormUserMobile(
          token: widget.token,
          userItem: user,
          merchantId: widget.merchantId,
        ),
      ),
    );
    if (result == true) {
      _fetchUsers();
    }
  }

  void _onDelete(UserModel user) async {
    // Confirm delete via bottom sheet or dialog?
    // User request didn't specify, but COA used bottom sheet.
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Konfirmasi Hapus",
                style: heading2(FontWeight.w700, bnw900, 'Outfit'),
              ),
              SizedBox(height: 8),
              Text(
                "Apakah Anda yakin ingin menghapus akun ini?",
                style: body1(FontWeight.w400, bnw600, 'Outfit'),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Batal",
                        style: body1(FontWeight.w600, primaryColor, 'Outfit'),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        final rc = await deleteUserAccount(
                          context,
                          widget.token,
                          [user.userid!],
                        );
                        if (rc == '00') {
                          _fetchUsers();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Hapus",
                        style: body1(FontWeight.w600, Colors.white, 'Outfit'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrow_left, color: bnw900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Akun", style: heading2(FontWeight.w700, bnw900, 'Outfit')),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormUserMobile(
                      token: widget.token,
                      merchantId: widget.merchantId,
                    ),
                  ),
                );
                if (result == true) {
                  _fetchUsers();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Tambah",
                style: body1(FontWeight.w600, Colors.white, 'Outfit'),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                  _applyFilter();
                });
              },
              decoration: InputDecoration(
                hintText: "Cari nama atau alamat",
                prefixIcon: Icon(PhosphorIcons.magnifying_glass, color: bnw500),
                filled: true,
                fillColor: bnw100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
              ),
            ),
          ),

          // Sort Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: bnw300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedOrder,
                      icon: Icon(
                        PhosphorIcons.caret_up,
                        size: 16,
                        color: bnw500,
                      ),
                      items: _sortOptions.map((opt) {
                        return DropdownMenuItem<String>(
                          value: opt['value'],
                          child: Text(
                            opt['label']!,
                            style: body2(FontWeight.w600, bnw900, 'Outfit'),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedOrder = val);
                          _fetchUsers();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                ? Center(
                    child: Text(
                      "Data kosong",
                      style: body1(FontWeight.w400, bnw500, 'Outfit'),
                    ),
                  )
                : ListView.separated(
                    itemCount: _filteredUsers.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: bnw200),
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: bnw100,
                          backgroundImage:
                              user.accountImage != null &&
                                  user.accountImage!.isNotEmpty
                              ? NetworkImage(user.accountImage!)
                              : null,
                          child:
                              user.accountImage == null ||
                                  user.accountImage!.isEmpty
                              ? Icon(PhosphorIcons.user, color: bnw500)
                              : null,
                        ),
                        title: Text(
                          user.fullname ?? "-",
                          style: body1(FontWeight.w700, bnw900, 'Outfit'),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${user.usertype ?? "Merchant"} - ${user.role ?? "User"}",
                              style: body2(FontWeight.w400, bnw500, 'Outfit'),
                            ),
                            Text(
                              user.phonenumber ?? "-",
                              style: body2(FontWeight.w400, bnw500, 'Outfit'),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Switch(
                            //   value: user.status == "1",
                            //   onChanged: (val) => _toggleStatus(user, val),
                            //   activeColor: primaryColor,
                            // ),
                            IconButton(
                              icon: Icon(
                                PhosphorIcons.pencil_line,
                                color: bnw900,
                              ),
                              onPressed: () => _onEdit(user),
                            ),
                            IconButton(
                              icon: Icon(
                                PhosphorIcons.trash,
                                color: Colors.red,
                              ),
                              onPressed: () => _onDelete(user),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
