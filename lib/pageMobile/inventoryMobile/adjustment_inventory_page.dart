import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:unipos_app_335/pageMobile/dashboardMobile.dart';

class AdjustmentTab extends StatefulWidget {
  final String token;
  final String merchantId;

  AdjustmentTab({
    Key? key,
    required this.token,
    required this.merchantId,
  }) : super(key: key);

  @override
  _AdjustmentTabState createState() => _AdjustmentTabState();
}

class _AdjustmentTabState extends State<AdjustmentTab> {
  bool _isLoading = true;
  List<dynamic> _adjustments = [];

  @override
  void initState() {
    super.initState();
    _fetchAdjustments();
  }

  Future<Map<String, dynamic>?> _getAdjustmentList() async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/inventory/adjustment'),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({
          "deviceid": identifier,
          "merchant_id": widget.merchantId.isEmpty ? null : widget.merchantId,
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

  Future<Map<String, dynamic>?> _getAdjustmentDetail(String groupId) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/inventory/adjustment/detail'),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({
          "deviceid": identifier,
          "group_id": groupId,
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

  Future<Map<String, dynamic>?> _deleteAdjustment(List<String> groupIds) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/inventory/adjustment/delete'),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({
          "deviceid": identifier,
          "group_id": groupIds,
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

  Future<void> _fetchAdjustments() async {
    setState(() => _isLoading = true);
    try {
      final data = await _getAdjustmentList();
      setState(() {
        _adjustments = data?['data'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showOptionsModal(String groupId) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
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
              SizedBox(height: 20),
              ListTile(
                leading: Icon(PhosphorIcons.pencil, color: primary500),
                title: Text('Update', style: heading3(FontWeight.w600, bnw900, 'Outfit')),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToUpdateAdjustment(groupId);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(PhosphorIcons.trash, color: Colors.red),
                title: Text('Delete', style: heading3(FontWeight.w600, Colors.red, 'Outfit')),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(groupId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(String groupId) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return Container(
          padding: EdgeInsets.all(24),
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
              SizedBox(height: 24),
              Icon(PhosphorIcons.warning_circle, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text(
                'Konfirmasi Hapus',
                style: heading2(FontWeight.w700, bnw900, 'Outfit'),
              ),
              SizedBox(height: 8),
              Text(
                'Apakah Anda yakin ingin menghapus data penyesuaian ini?',
                textAlign: TextAlign.center,
                style: body1(FontWeight.w400, bnw600, 'Outfit'),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(modalContext),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: bnw300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Batal', style: heading3(FontWeight.w600, bnw600, 'Outfit')),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(modalContext);
                        final result = await _deleteAdjustment([groupId]);
                        print('DELETE RESPONSE: ${jsonEncode(result)}');
                        if (mounted) {
                          if (result != null && result['rc'] == '00') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result['rm'] ?? 'Berhasil menghapus data')),
                            );
                            _fetchAdjustments();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result?['rm'] ?? result?['message'] ?? 'Gagal menghapus data')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
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

  void _navigateToAddAdjustment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAdjustmentPage(
          token: widget.token,
          merchantId: widget.merchantId,
          onSuccess: _fetchAdjustments,
        ),
      ),
    );
  }

  void _navigateToUpdateAdjustment(String groupId) async {
    final detail = await _getAdjustmentDetail(groupId);
    if (detail != null && detail['rc'] == '00') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddAdjustmentPage(
            token: widget.token,
            merchantId: widget.merchantId,
            onSuccess: _fetchAdjustments,
            groupId: groupId,
            existingData: detail['data'],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddAdjustment,
        backgroundColor: primary500,
        icon: Icon(PhosphorIcons.plus, color: Colors.white),
        label: Text('Sesuaikan', style: heading4(FontWeight.w600, Colors.white, 'Outfit')),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _adjustments.isEmpty
              ? Center(
                  child: Text(
                    'Tidak ada data penyesuaian',
                    style: heading3(FontWeight.w400, bnw500, 'Outfit'),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _adjustments.length,
                  itemBuilder: (context, index) {
                    final adjustment = _adjustments[index];
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
                                  adjustment['title'] ?? '',
                                  style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  adjustment['activity_date'] ?? '',
                                  style: body2(FontWeight.w400, bnw500, 'Outfit'),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => _showOptionsModal(adjustment['group_id']),
                            child: Icon(PhosphorIcons.pencil_simple, color: bnw600, size: 20),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

// Add/Update Adjustment Page
class AddAdjustmentPage extends StatefulWidget {
  final String token;
  final String merchantId;
  final VoidCallback onSuccess;
  final String? groupId;
  final Map<String, dynamic>? existingData;

  AddAdjustmentPage({
    Key? key,
    required this.token,
    required this.merchantId,
    required this.onSuccess,
    this.groupId,
    this.existingData,
  }) : super(key: key);

  @override
  _AddAdjustmentPageState createState() => _AddAdjustmentPageState();
}

class _AddAdjustmentPageState extends State<AddAdjustmentPage> {
  final TextEditingController _titleController = TextEditingController();
  DateTime? _selectedDate;
  List<Map<String, dynamic>> _selectedMaterials = [];
  List<dynamic> _allMaterials = [];
  List<dynamic> _unitConversions = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Load materials
    final materialsData = await _getMaterialInventory();
    setState(() {
      _allMaterials = materialsData?['data'] ?? [];
    });

    // Load unit conversions
    final conversionsData = await _getUnitConversions();
    setState(() {
      _unitConversions = conversionsData?['data'] ?? [];
    });

    // If editing, load existing data
    if (widget.existingData != null) {
      _titleController.text = widget.existingData!['title'] ?? '';
      
      // Parse date
      try {
        final dateStr = widget.existingData!['date'];
        if (dateStr != null) {
          final parts = dateStr.split('-');
          if (parts.length == 3) {
            _selectedDate = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
        }
      } catch (e) {
        print('Error parsing date: $e');
      }

      // Load existing materials
      final details = widget.existingData!['detail'] as List?;
      if (details != null) {
        setState(() {
          _selectedMaterials = details.map((item) {
            return {
              'id': item['item_id'],
              'name': item['name_item'],
              'unit_name': item['unit_name'],
              'unit_abbreviation': item['unit_abbreviation'],
              'qty': double.tryParse(item['qty_after_activity'].toString()) ?? 0,
              'unit_conversion_id': item['unit_conversion_id'],
              'unit_conversion_name': item['unit_conversion_name'] ?? item['unit_abbreviation'],
              'conversion_factor': double.tryParse(item['conversion_factor'].toString()) ?? 1,
            };
          }).toList();
        });
      }
    }
  }

  Future<Map<String, dynamic>?> _getMaterialInventory() async {
    try {
      final response = await http.post(
        Uri.parse(getMasterDataLink),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({
          "deviceid": identifier,
          "merchant_id": widget.merchantId.isEmpty ? null : widget.merchantId,
          "isMinimize": false,
          "name": "",
          "order_by": "",
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

  Future<Map<String, dynamic>?> _getUnitConversions() async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/unit-conversion/'),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({
          "deviceid": identifier,
          "merchant_id": widget.merchantId.isEmpty ? null : widget.merchantId,
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

  void _showMaterialPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: EdgeInsets.all(20),
            child: Column(
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
                SizedBox(height: 20),
                Text(
                  'Tambah Pemakaian',
                  style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                ),
                Text(
                  'Pilih bahan yang sudah terpakai',
                  style: body2(FontWeight.w400, bnw500, 'Outfit'),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: _allMaterials.length,
                    itemBuilder: (context, index) {
                      final material = _allMaterials[index];
                      final isSelected = _selectedMaterials.any((m) => m['id'] == material['id']);
                      
                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (checked) {
                          if (checked == true) {
                            _showMaterialDetailInput(material, setModalState);
                          } else {
                            // Uncheck - remove from selected materials
                            setState(() {
                              _selectedMaterials.removeWhere((m) => m['id'] == material['id']);
                            });
                            setModalState(() {});
                          }
                        },
                        title: Text(
                          material['name_item'] ?? '',
                          style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                        ),
                        subtitle: Text(
                          material['unit_name'] ?? '',
                          style: body2(FontWeight.w400, bnw500, 'Outfit'),
                        ),
                        activeColor: primary500,
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: primary500),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('Batal', style: heading3(FontWeight.w600, primary500, 'Outfit')),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary500,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('Simpan', style: heading3(FontWeight.w600, Colors.white, 'Outfit')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showMaterialDetailInput(Map<String, dynamic> material, Function setParentModalState) {
    final TextEditingController qtyController = TextEditingController();
    String? selectedConversionId;
    String selectedConversionName = material['unit_abbreviation'] ?? '';
    double conversionFactor = 1.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          double calculatedQty = (double.tryParse(qtyController.text) ?? 0) * conversionFactor;
          
          return Container(
            height: MediaQuery.of(context).size.height * 0.5,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  SizedBox(height: 20),
                  Text(
                    'Tambah Pemakaian',
                    style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                  ),
                  Text(
                    'Pilih bahan yang sudah terpakai',
                    style: body2(FontWeight.w400, bnw500, 'Outfit'),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(PhosphorIcons.check_circle, color: primary500, size: 24),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              material['name_item'] ?? '',
                              style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                            ),
                            Text(
                              material['unit_name'] ?? '',
                              style: body2(FontWeight.w400, bnw500, 'Outfit'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primary500.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Qty',
                                style: body2(FontWeight.w400, bnw900, 'Outfit'),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: qtyController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.right,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '0',
                                ),
                                style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                                onChanged: (value) => setModalState(() {}),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        if (calculatedQty > 0)
                          Text(
                            '${qtyController.text} qty = ${calculatedQty.toStringAsFixed(0)} ${material['unit_abbreviation']}',
                            style: body2(FontWeight.w400, bnw600, 'Outfit'),
                          ),
                        Divider(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Unit Konversi',
                                style: body2(FontWeight.w400, bnw900, 'Outfit'),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  _showUnitConversionPicker(
                                    context,
                                    material,
                                    (conversionId, conversionName, factor) {
                                      setModalState(() {
                                        selectedConversionId = conversionId;
                                        selectedConversionName = conversionName;
                                        conversionFactor = factor;
                                      });
                                    },
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: bnw300),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        selectedConversionName,
                                        style: heading4(FontWeight.w500, bnw900, 'Outfit'),
                                      ),
                                      Icon(Icons.arrow_drop_down, color: bnw900),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: primary500),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('Batal', style: heading3(FontWeight.w600, primary500, 'Outfit')),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final qty = double.tryParse(qtyController.text) ?? 0;
                            
                            if (qty > 0) {
                              setState(() {
                                _selectedMaterials.add({
                                  'id': material['id'],
                                  'name': material['name_item'],
                                  'unit_name': material['unit_name'],
                                  'unit_abbreviation': material['unit_abbreviation'],
                                  'qty': qty,
                                  'unit_conversion_id': selectedConversionId,
                                  'unit_conversion_name': selectedConversionName,
                                  'conversion_factor': conversionFactor,
                                });
                              });
                              setParentModalState(() {});
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Material berhasil ditambahkan'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary500,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('Simpan', style: heading3(FontWeight.w600, Colors.white, 'Outfit')),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showUnitConversionPicker(
    BuildContext context,
    Map<String, dynamic> material,
    Function(String?, String, double) onSelected,
  ) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
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
              SizedBox(height: 20),
              Text(
                'Pilih Unit Konversi',
                style: heading2(FontWeight.w700, bnw900, 'Outfit'),
              ),
              SizedBox(height: 20),
              // Default unit
              ListTile(
                title: Text(
                  material['unit_abbreviation'] ?? '',
                  style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                ),
                onTap: () {
                  onSelected(null, material['unit_abbreviation'] ?? '', 1.0);
                  Navigator.pop(context);
                },
              ),
              Divider(),
              // Unit conversions
              ..._unitConversions.map((conversion) {
                return ListTile(
                  title: Text(
                    conversion['conversion_name'] ?? '',
                    style: heading4(FontWeight.w600, bnw900, 'Outfit'),
                  ),
                  subtitle: Text(
                    'Factor: ${conversion['conversion_factor']}',
                    style: body2(FontWeight.w400, bnw500, 'Outfit'),
                  ),
                  onTap: () {
                    onSelected(
                      conversion['id'],
                      conversion['conversion_name'] ?? '',
                      double.tryParse(conversion['conversion_factor'].toString()) ?? 1.0,
                    );
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveAdjustment() async {
    if (_titleController.text.isEmpty || _selectedDate == null || _selectedMaterials.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mohon lengkapi semua data')),
      );
      return;
    }

    final dateStr = DateFormat('dd-MM-yyyy').format(_selectedDate!);
    final usageInventory = _selectedMaterials.map((material) {
      return {
        'inventory_master_id': material['id'],
        'qty': material['qty'],
        'price': null,
        'unit_conversion_id': material['unit_conversion_id'],
      };
    }).toList();

    Map<String, dynamic>? result;
    
    if (widget.groupId != null) {
      // Update
      result = await _updateAdjustment(dateStr, _titleController.text, usageInventory);
    } else {
      // Create
      result = await _createAdjustment(dateStr, _titleController.text, usageInventory);
    }

    if (result != null && result['rc'] == '00') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['rm'] ?? 'Berhasil menyimpan data')),
      );
      widget.onSuccess();
      Navigator.pop(context);
    } else {
      print('SAVE RESPONSE: ${jsonEncode(result)}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result?['rm'] ?? 'Gagal menyimpan data')),
      );
    }
  }

  Future<Map<String, dynamic>?> _createAdjustment(
    String date,
    String title,
    List<Map<String, dynamic>> usageInventory,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/inventory/adjustment/create'),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({
          "deviceid": identifier,
          "date": date,
          "title": title,
          "usage_inventory": usageInventory,
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

  Future<Map<String, dynamic>?> _updateAdjustment(
    String date,
    String title,
    List<Map<String, dynamic>> usageInventory,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$url/api/inventory/adjustment/update'),
        headers: {'token': widget.token, 'Content-Type': 'application/json'},
        body: jsonEncode({
          "deviceid": identifier,
          "group_id": widget.groupId,
          "date": date,
          "title": title,
          "usage_inventory": usageInventory,
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
        title: Text(
          'Tambah Penyesuaian',
          style: heading1(FontWeight.w700, bnw900, 'Outfit'),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Judul', style: heading4(FontWeight.w600, bnw900, 'Outfit')),
                SizedBox(width: 4),
                Text('*', style: heading4(FontWeight.w600, Colors.red, 'Outfit')),
              ],
            ),
            SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Cth: Pembelian Matcha',
                hintStyle: body1(FontWeight.w400, bnw400, 'Outfit'),
                filled: false,
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: bnw300),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: bnw300),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: primary500, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              style: body1(FontWeight.w400, bnw900, 'Outfit'),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Text('Tanggal', style: heading4(FontWeight.w600, bnw900, 'Outfit')),
                SizedBox(width: 4),
                Text('*', style: heading4(FontWeight.w600, Colors.red, 'Outfit')),
              ],
            ),
            SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: bnw300)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate != null
                          ? DateFormat('dd-MM-yyyy').format(_selectedDate!)
                          : 'Pilih tanggal',
                      style: body1(FontWeight.w400, _selectedDate != null ? bnw900 : bnw400, 'Outfit'),
                    ),
                    Icon(PhosphorIcons.calendar_blank, color: bnw600),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Penyesuaian yang akan disesuaikan',
              style: heading4(FontWeight.w600, bnw900, 'Outfit'),
            ),
            SizedBox(height: 16),
            if (_selectedMaterials.isEmpty)
              InkWell(
                onTap: _showMaterialPicker,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: bnw300),
                  ),
                  child: Column(
                    children: [
                      Icon(PhosphorIcons.package, size: 48, color: bnw400),
                      SizedBox(height: 12),
                      Text(
                        'Masukan data pembelian',
                        style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._selectedMaterials.asMap().entries.map((entry) {
                final index = entry.key;
                final material = entry.value;
                
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: bnw300),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              material['name'],
                              style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                            ),
                            Text(
                              material['unit_conversion_name'],
                              style: body2(FontWeight.w400, bnw500, 'Outfit'),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${material['qty'].toStringAsFixed(0)}x',
                        style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                      ),
                      SizedBox(width: 12),
                      IconButton(
                        icon: Icon(PhosphorIcons.x, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _selectedMaterials.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(
              onPressed: _showMaterialPicker,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: primary500),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Penyesuaian', style: heading3(FontWeight.w600, primary500, 'Outfit')),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: primary500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Save & Add New', style: heading3(FontWeight.w600, primary500, 'Outfit')),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveAdjustment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary500,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Create', style: heading3(FontWeight.w600, Colors.white, 'Outfit')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
