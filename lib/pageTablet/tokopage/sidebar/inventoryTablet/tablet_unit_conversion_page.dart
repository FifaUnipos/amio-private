import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/component/component_snackbar.dart';
import 'package:unipos_app_335/utils/utilities.dart';
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

  const UnitConversionTab({super.key, required this.token, required this.merchantId});

  @override
  UnitConversionTabState createState() => UnitConversionTabState();
}

class UnitConversionTabState extends State<UnitConversionTab> {
  bool _isLoading = true;
  List<dynamic> _conversions = [];

  @override
  void initState() {
    super.initState();
    _fetchUnitConversions();
  }

  Future<void> _fetchUnitConversions({String? query}) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$url/api/unit-conversion/'),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({"merchant_id": widget.merchantId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> list = data['data'] ?? [];
        if (query != null && query.isNotEmpty) {
          list = list.where((item) {
            final name = (item['name'] ?? '').toString().toLowerCase();
            return name.contains(query.toLowerCase());
          }).toList();
        }
        setState(() {
          _conversions = list;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void search(String value) {
    _fetchUnitConversions(query: value);
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

  void _showOptionsModal(String id, String name, String factor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      builder: (context) {
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: bnw100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                            ),
                            Text(
                              'Konversi Faktor: $factor',
                              style: heading3(FontWeight.w400, bnw500, 'Outfit'),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(PhosphorIcons.x, color: bnw900),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: bnw300),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Icon(PhosphorIcons.pencil_line, color: bnw900),
                  title: Text('Ubah Konversi Unit', style: heading3(FontWeight.w400, bnw900, 'Outfit')),
                  onTap: () {
                    Navigator.pop(context);
                    navigateToAdd(unitConversionId: id);
                  },
                ),
                Divider(height: 1, color: bnw300),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Icon(PhosphorIcons.trash, color: bnw900),
                  title: Text('Hapus Konversi Unit', style: heading3(FontWeight.w400, bnw900, 'Outfit')),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDelete(id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(String id) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: bnw100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Yakin Ingin Menghapus Konversi Unit?',
                  textAlign: TextAlign.center,
                  style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Konversi unit yang telah dihapus tidak dapat dikembalikan.',
                  textAlign: TextAlign.center,
                  style: body1(FontWeight.w400, bnw500, 'Outfit'),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          Navigator.pop(modalContext);
                          final result = await _deleteUnitConversion(id);
                          if (mounted) {
                            if (result != null && result['rc'] == '00') {
                              showSnackbar(context, result);
                              _fetchUnitConversions();
                            } else {
                              showSnackbar(context, result ?? {"message": "Gagal menghapus data"});
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: primary500),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Iya, Hapus',
                          style: heading3(
                            FontWeight.w600,
                            primary500,
                            'Outfit',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(modalContext),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary500,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Batalkan',
                          style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void navigateToAdd({String? unitConversionId}) {
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: primary500,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text('Judul', style: heading4(FontWeight.w700, bnw100, 'Outfit')),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text('Conversion Factor', style: heading4(FontWeight.w600, bnw100, 'Outfit')),
                ),
                SizedBox(width: 90, child: Text('Aksi', style: heading4(FontWeight.w600, bnw100, 'Outfit'))),
                SizedBox(width: 16),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: primary500))
                : _conversions.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada data Unit Conversi',
                          style: heading3(FontWeight.w400, bnw500, 'Outfit'),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: bnw100,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: RefreshIndicator(
                          color: bnw100,
                          backgroundColor: primary500,
                          onRefresh: () async => _fetchUnitConversions(),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: _conversions.length,
                            itemBuilder: (context, index) {
                              final item = _conversions[index];
                              return _buildRow(item);
                            },
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(Map<String, dynamic> item) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: bnw100,
        border: Border(bottom: BorderSide(color: bnw300, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(
                item['name'] ?? '',
                style: heading4(FontWeight.w500, bnw900, 'Outfit'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              double.tryParse((item['conversion_factor'] ?? '0').toString())?.toStringAsFixed(2) ?? '0.00',
              style: heading4(FontWeight.w400, bnw900, 'Outfit'),
            ),
          ),
          SizedBox(
            width: 90,
            child: GestureDetector(
              onTap: () => _showOptionsModal(
                item['id'] ?? '',
                item['name'] ?? '',
                double.tryParse((item['conversion_factor'] ?? '0').toString())?.toStringAsFixed(2) ?? '0.00',
              ),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: bnw100,
                  border: Border.all(color: bnw300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(PhosphorIcons.pencil_line_fill, color: bnw900, size: 20),
                    SizedBox(width: 4),
                    Text('Atur', style: heading4(FontWeight.w600, bnw900, 'Outfit')),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
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

  const AddUnitConversionPage({
    super.key,
    required this.token,
    required this.merchantId,
    this.unitConversionId,
    required this.onSuccess,
  });

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
      debugPrint('Error _fetchSingle: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSave({bool stayOnPage = false}) async {
    if (_nameController.text.isEmpty || _factorController.text.isEmpty) {
      showSnackbar(context, {"message": 'Nama dan Faktor Konversi harus diisi'});
      return;
    }

    setState(() => _isLoading = true);
    try {
      final isUpdate = widget.unitConversionId != null;
      final endpoint = isUpdate
          ? 'api/unit-conversion/update'
          : 'api/unit-conversion/create';

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
          if (!mounted) return;
          showSnackbar(context, result);
        } else {
          if (!mounted) return;
          Navigator.pop(context);
          showSnackbar(context, result);
        }
      } else {
        if (!mounted) return;
        showSnackbar(context, result);
      }
    } catch (e) {
      debugPrint('Error _handleSave: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: bnw100,
        appBar: AppBar(
          title: Text(
            widget.unitConversionId == null
                ? 'Tambah Konversi'
                : 'Edit Konversi',
            style: heading2(FontWeight.w700, bnw900, 'Outfit'),
          ),
          leading: IconButton(
            icon: Icon(PhosphorIcons.arrow_left, color: bnw900),
            onPressed: () => Navigator.pop(context),
          ),
          elevation: 0,
          backgroundColor: bnw100,
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
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
                              children: [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: 'Cth: Box',
                              border: UnderlineInputBorder(),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: bnw300),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: primary500),
                              ),
                            ),
                            style: body1(FontWeight.w400, bnw900, 'Outfit'),
                          ),
                          SizedBox(height: 24),
                          RichText(
                            text: TextSpan(
                              text: 'Konversi Faktor ',
                              style: body1(FontWeight.w400, bnw900, 'Outfit'),
                              children: [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _factorController,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Cth: 12',
                              border: UnderlineInputBorder(),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: bnw300),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: primary500),
                              ),
                            ),
                            style: body1(FontWeight.w400, bnw900, 'Outfit'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: bnw100,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: Offset(0, -4),
                        ),
                      ],
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
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    side: BorderSide(color: primary500),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Save & Add New',
                                    style: heading3(
                                      FontWeight.w600,
                                      primary500,
                                      'Outfit',
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _handleSave,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primary500,
                                    foregroundColor: bnw100,
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Create',
                                    style: heading3(
                                      FontWeight.w600,
                                      bnw100,
                                      'Outfit',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _handleSave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary500,
                                foregroundColor: bnw100,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Update',
                                style: heading3(
                                  FontWeight.w600,
                                  bnw100,
                                  'Outfit',
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

