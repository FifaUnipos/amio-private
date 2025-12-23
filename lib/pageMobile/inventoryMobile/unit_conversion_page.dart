import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';

class UnitConversionTab extends StatefulWidget {
  final String token;
  final String merchantId;

  UnitConversionTab({
    Key? key,
    required this.token,
    required this.merchantId,
  }) : super(key: key);

  @override
  _UnitConversionTabState createState() => _UnitConversionTabState();
}

class _UnitConversionTabState extends State<UnitConversionTab> {
  bool _isLoading = true;
  List<dynamic> _conversions = [];

  @override
  void initState() {
    super.initState();
    _fetchUnitConversions();
  }

  Future<void> _fetchUnitConversions() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$url/api/unit-conversion/'),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({
          "merchant_id": widget.merchantId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _conversions = data['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error _fetchUnitConversions: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<Map<String, dynamic>?> _deleteUnitConversion(String id) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/unit-conversion/delete'),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({
          "unit_conversion_id": id,
          "merchant_id": widget.merchantId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  void _showOptionsModal(String id) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(PhosphorIcons.pencil, color: primary500),
                title: Text('Update', style: heading3(FontWeight.w600, bnw900, 'Outfit')),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToAddPage(unitConversionId: id);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(PhosphorIcons.trash, color: Colors.red),
                title: Text('Delete', style: heading3(FontWeight.w600, Colors.red, 'Outfit')),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(id);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(String id) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (modalContext) {
        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              SizedBox(height: 24),
              Icon(PhosphorIcons.warning_circle, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text('Konfirmasi Hapus', style: heading2(FontWeight.w700, bnw900, 'Outfit')),
              SizedBox(height: 8),
              Text('Apakah Anda yakin ingin menghapus data ini?', textAlign: TextAlign.center, style: body1(FontWeight.w400, bnw600, 'Outfit')),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(modalContext),
                      style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16), side: BorderSide(color: bnw300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: Text('Batal', style: heading3(FontWeight.w600, bnw600, 'Outfit')),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(modalContext);
                        final result = await _deleteUnitConversion(id);
                        if (mounted) {
                          if (result != null && result['rc'] == '00') {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berhasil menghapus data')));
                            _fetchUnitConversions();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result?['rm'] ?? 'Gagal menghapus data')));
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: Text('Hapus', style: heading3(FontWeight.w600, Colors.white, 'Outfit')),
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

  void _navigateToAddPage({String? unitConversionId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddUnitConversionPage(
          token: widget.token,
          merchantId: widget.merchantId,
          unitConversionId: unitConversionId,
          onSuccess: _fetchUnitConversions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddPage(),
        backgroundColor: primary500,
        icon: Icon(PhosphorIcons.plus, color: Colors.white),
        label: Text('Unit Conversi', style: heading4(FontWeight.w600, Colors.white, 'Outfit')),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _conversions.isEmpty
              ? Center(child: Text('Tidak ada data Unit Conversi', style: heading3(FontWeight.w400, bnw500, 'Outfit')))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _conversions.length,
                  itemBuilder: (context, index) {
                    final item = _conversions[index];
                    return _buildCard(item);
                  },
                ),
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bnw200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? '',
                  style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                ),
                SizedBox(height: 4),
                Text(
                  'Faktor: ${item['conversion_factor'] ?? '0'}',
                  style: body2(FontWeight.w400, bnw500, 'Outfit'),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _showOptionsModal(item['id']),
            child: Icon(PhosphorIcons.pencil_simple, color: bnw600, size: 20),
          ),
        ],
      ),
    );
  }
}

class AddUnitConversionPage extends StatefulWidget {
  final String token;
  final String merchantId;
  final String? unitConversionId;
  final VoidCallback onSuccess;

  AddUnitConversionPage({
    Key? key,
    required this.token,
    required this.merchantId,
    this.unitConversionId,
    required this.onSuccess,
  }) : super(key: key);

  @override
  _AddUnitConversionPageState createState() => _AddUnitConversionPageState();
}

class _AddUnitConversionPageState extends State<AddUnitConversionPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _factorController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.unitConversionId != null) {
      _fetchSingle();
    }
  }

  Future<void> _fetchSingle() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$url/api/unit-conversion/single'),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({
          "unit_conversion_id": widget.unitConversionId,
          "merchant_id": widget.merchantId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        setState(() {
          _nameController.text = data['name'] ?? '';
          _factorController.text = data['conversion_factor']?.toString() ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error _fetchSingle: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSave({bool stayOnPage = false}) async {
    if (_nameController.text.isEmpty || _factorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nama dan Faktor Konversi harus diisi')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final isUpdate = widget.unitConversionId != null;
      final endpoint = isUpdate ? 'api/unit-conversion/update' : 'api/unit-conversion/create';
      
      final body = {
        if (isUpdate) "unit_conversion_id": widget.unitConversionId,
        if (isUpdate) "inventory_master_id": "",
        "name": _nameController.text,
        "conversion_factor": double.tryParse(_factorController.text) ?? 1.0,
        "merchant_id": widget.merchantId,
      };

      final response = await http.post(
        Uri.parse('$url/$endpoint'),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final result = jsonDecode(response.body);
      
      if (result['rc'] == '00') {
        widget.onSuccess();
        if (stayOnPage) {
          setState(() {
            _nameController.clear();
            _factorController.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['rm'] ?? 'Berhasil menyimpan data')));
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['rm'] ?? 'Berhasil menyimpan data')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['rm'] ?? 'Gagal menyimpan data')));
      }
    } catch (e) {
      print('Error _handleSave: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.unitConversionId == null ? 'Tambah Konversi' : 'Edit Konversi', style: heading2(FontWeight.w700, bnw900, 'Outfit')),
        leading: IconButton(icon: Icon(PhosphorIcons.arrow_left), onPressed: () => Navigator.pop(context)),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: _isLoading ? Center(child: CircularProgressIndicator()) : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   RichText(
                    text: TextSpan(
                      text: 'Nama Konversi ',
                      style: body1(FontWeight.w400, bnw900, 'Outfit'),
                      children: [TextSpan(text: '*', style: TextStyle(color: Colors.red))],
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Cth: Box',
                      border: UnderlineInputBorder(),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: bnw300)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primary500)),
                    ),
                    style: body1(FontWeight.w400, bnw900, 'Outfit'),
                  ),
                  SizedBox(height: 24),
                  RichText(
                    text: TextSpan(
                      text: 'Konversi Faktor ',
                      style: body1(FontWeight.w400, bnw900, 'Outfit'),
                      children: [TextSpan(text: '*', style: TextStyle(color: Colors.red))],
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _factorController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'Cth: 12',
                      border: UnderlineInputBorder(),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: bnw300)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primary500)),
                    ),
                    style: body1(FontWeight.w400, bnw900, 'Outfit'),
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, -4))],
            ),
            padding: EdgeInsets.all(20),
            child: widget.unitConversionId == null 
              ? Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          await _handleSave(stayOnPage: true);
                        },
                        child: Text('Save & Add New', style: heading3(FontWeight.w600, primary500, 'Outfit')),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: primary500),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleSave,
                        child: Text('Create', style: heading3(FontWeight.w600, Colors.white, 'Outfit')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary500,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                )
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleSave,
                    child: Text('Update', style: heading3(FontWeight.w600, Colors.white, 'Outfit')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary500,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
