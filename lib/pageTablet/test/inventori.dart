
import 'package:flutter/material.dart';

class InventoriPage extends StatefulWidget {
  InventoriPage({Key? key}) : super(key: key);

  @override
  State<InventoriPage> createState() => _InventoriPageState();
}

class _InventoriPageState extends State<InventoriPage> {
  String selectedValue = 'Urutkan';

  List tabBar = [
    const Tab(
      icon: null,
      text: 'Barang',
    ),
    const Tab(
      icon: null,
      text: 'Inventori Toko',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size(double.infinity, 80.0),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: SizedBox(
                child: Column(
                  children: [
                    const Text(
                      'Inventori',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Outfit'),
                    ),
                    Text('Penyimpanan bahan - bahan dari sebuah Produk')
                  ],
                ),
              ),
              actions: [
                Container(
                  width: 175,
                  height: 56,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(width: 0.4, color: Colors.black)),
                  child: ElevatedButton.icon(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.white,
                      )),
                      onPressed: null,
                      icon: const Icon(Icons.copy, color: Colors.black),
                      label: const Text('Salin Data',
                          style: TextStyle(color: Colors.black, fontSize: 20))),
                ),
                const SizedBox(width: 5),
                SizedBox(
                  width: 255,
                  height: 56,
                  child: ElevatedButton.icon(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xff1363DF),
                      )),
                      onPressed: null,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Tambah Pelanggan',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      )),
                ),
              ],
            ),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(width: 0.5, color: Colors.grey),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 3.8,
                      child: const TabBar(
                        unselectedLabelColor: Color(0xff666666),
                        labelColor: Colors.black,
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Outfit'),
                        tabs: [
                          Tab(
                            text: 'Barang',
                          ),
                          Tab(
                            text: 'Inventori Toko',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          fillColor: const Color(0xffCCCCCC),
                          prefixIcon: const Icon(Icons.search),
                          hintText: 'Cari',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      width: 112,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(style: BorderStyle.solid, width: 0.3)),
                      child: Center(
                        child: DropdownButton(
                          value: selectedValue,
                          items: const [
                            DropdownMenuItem(
                              value: 'Populer',
                              child: Text('Populer'),
                            ),
                            DropdownMenuItem(
                              value: 'Urutkan',
                              child: Text('Urutkan'),
                            ),
                            DropdownMenuItem(
                              value: 'Terkenal',
                              child: Text('Terkenal'),
                            ),
                          ],
                          onChanged: (val) => setState(() {
                            selectedValue = val as String;
                          }),
                        ),
                      ),
                    ),
                    Container(
                      width: 75,
                      height: 42,
                      padding: const EdgeInsets.fromLTRB(12, 24, 12, 24),
                      child: const Text('Pilih'),
                    )
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                child: DataTable(
                  columns: const <DataColumn>[
                    DataColumn(
                      label: Text('Nama Produk'),
                    ),
                    DataColumn(
                      label: Text('Satuan'),
                    ),
                    DataColumn(
                      label: Text('Nama'),
                    ),
                  ],
                  rows: <DataRow>[
                    DataRow(
                      selected: false,
                      cells: <DataCell>[
                        const DataCell(
                          Text('Matcha'),
                        ),
                        const DataCell(
                          Text('Kilogram'),
                        ),
                        DataCell(
                          ElevatedButton.icon(
                            onPressed: null,
                            icon: const Icon(Icons.edit),
                            label: const Text(
                              'Atur',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                    DataRow(
                      cells: <DataCell>[
                        const DataCell(
                          Text('Gula'),
                        ),
                        const DataCell(
                          Text('Kilogram'),
                        ),
                        DataCell(
                          ElevatedButton.icon(
                            onPressed: null,
                            icon: const Icon(Icons.edit),
                            label: const Text(
                              'Atur',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
