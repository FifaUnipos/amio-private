import 'dart:convert';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TestPageAsoy extends StatefulWidget {
  @override
  _TestPageAsoyState createState() => _TestPageAsoyState();
}

class _TestPageAsoyState extends State<TestPageAsoy> {
  List<Map<String, dynamic>> dataPemakaian = [];
  final Map<String, Map<String, dynamic>> selectedDataPemakaian = {};

  void getMasterDataTokoAndUpdateState() async {
    try {
      final result = await getMasterDataToko(
        context,
        // "OTU3ZjAyNjljNDg0ZTdkM2VmZjk3ZDY2NjQ0OThmOWI2ZGRjNWNjMzBiODM0YTczNDVmY2FjMTdkMDRlOTllYQ==",
        "",
        "",
        "",
        "",
      );
      setState(() {
        dataPemakaian = result;
      });
    } catch (e) {
      print("Error fetching data: $e");
      showSnackbar(context, {"message": e.toString()});
    }
  }

  @override
  void initState() {
    super.initState();
    getMasterDataTokoAndUpdateState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Ganti dengan tema warna Anda
      appBar: AppBar(
        title: Text("Inventory Order"),
      ),
      body: 
      dataPemakaian.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: dataPemakaian.length,
              itemBuilder: (context, index) {
                final item = dataPemakaian[index];
                return StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      children: [
                        ListTile(
                          leading: Checkbox(
                            value: selectedDataPemakaian.containsKey(item['id']),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  selectedDataPemakaian[item['id']] = {
                                    "inventory_master_id": item['id'],
                                    "qty": 0,
                                    "price": 0,
                                  };
                                } else {
                                  selectedDataPemakaian.remove(item['id']);
                                }
                              });
                            },
                          ),
                          title: Text(item['name_item']),
                          subtitle: Text(item['unit_name']),
                          trailing: Icon(selectedDataPemakaian.containsKey(item['id'])
                              ? Icons.expand_less
                              : Icons.expand_more),
                          onTap: () {
                            setState(() {
                              if (selectedDataPemakaian.containsKey(item['id'])) {
                                selectedDataPemakaian.remove(item['id']);
                              } else {
                                selectedDataPemakaian[item['id']] = {
                                  "inventory_master_id": item['id'],
                                  "qty": 0,
                                  "price": 0,
                                };
                              }
                            });
                          },
                        ),
                        if (selectedDataPemakaian.containsKey(item['id']))
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                                TextField(
                                  decoration: InputDecoration(
                                    labelText: "Quantity",
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    selectedDataPemakaian[item['id']]!['qty'] =
                                        int.tryParse(value) ?? 0;
                                  },
                                ),
                                SizedBox(height: 8),
                                TextField(
                                  decoration: InputDecoration(
                                    labelText: "Price",
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    selectedDataPemakaian[item['id']]!['price'] =
                                        int.tryParse(value) ?? 0;
                                  },
                                ),
                                SizedBox(height: 16),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () {
          final orderInventory = selectedDataPemakaian.values.toList();
          print("Saved Data: $orderInventory");
          // You can send the `orderInventory` to the server or process it further
        },
      ),
    );
  }
}
