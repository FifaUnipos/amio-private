import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:flutter/material.dart';

import '../../services/apimethod.dart';

class TambahBarangInventori extends StatefulWidget {
  const TambahBarangInventori({super.key});

  @override
  State<TambahBarangInventori> createState() => _TambahBarangInventoriState();
}

class _TambahBarangInventoriState extends State<TambahBarangInventori> {
  String selectedValue = 'Urutkan';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bnw100,
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 80.0),
        child: Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Inventori',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Outfit'),
                ),
                Text(
                  'Isi data produk secara lengkap',
                  style: TextStyle(
                      color: Colors.black, fontSize: 16, fontFamily: 'Outfit'),
                ),
              ],
            )),
      ),
      body: Container(
        padding: EdgeInsets.all(32),
        margin: EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(width: 0.3),
        ),
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                  hintText: 'Nama Barang', label: Text('Nama Barang *')),
            ),
            SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: DropdownButton(
                  value: selectedValue,
                  items: const [
                    DropdownMenuItem(
                      value: 'Populer',
                      child: Text('Populer'),
                    ),
                    DropdownMenuItem(
                      value: 'Urutkan',
                      child: Text('Pilih Satu Barang'),
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
            Row(
              children: [
                buttonTambahBarang('Batal'),
                buttonTambahBarang('Simpan & Tambah Baru'),
                buttonTambahBarang(Color(0xff1363DF), 'Simpan'),
              ],
            )
          ],
        ),
      ),
    );
  }

  buttonTambahBarang([color, title]) {
    return SizedBox(
      width: 300,
      height: 48,
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(primaryColor)),
        onPressed: null,
        child: Text('Tambah'),
      ),
    );
  }
}
