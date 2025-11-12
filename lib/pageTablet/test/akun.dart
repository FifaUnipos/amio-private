import 'dart:developer';
import 'package:flutter/material.dart';
import '../../services/apimethod.dart';

Color maainColor = const Color.fromARGB(255, 255, 255, 255);

class AkunPage extends StatelessWidget {
  const AkunPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(12),
          padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Akun',
                      ),
                      Text(
                        'Atur akun karyawan di setiap toko',
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 420,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SizedBox(
                            width: 600,
                            child: TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search),
                                hintText: 'Cari',
                                fillColor: Colors.grey.shade200,
                                filled: true,
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey, width: 0.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(8)),
                          width: 162,
                          height: 60,
                          child: Center(
                            child: DropdownButton<String>(
                              hint: Text(
                                'DropDown',
                              ),
                              underline: const SizedBox(),
                              isExpanded: true,
                              items: <String>[
                                // 'Berdasarkan Nama A ke Z',
                                // 'Berdasarkan Nama Z ke A',
                                // 'Berdasarkan Toko Terbaru',
                                // 'Berdasarkan Toko Terlama'
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                log(newValue.toString());
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                              bottom: 18,
                              right: 430,
                              left: 430,
                            ),
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  textAlignVertical: TextAlignVertical.center,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.search),
                                    hintText: 'Cari',
                                    fillColor: Colors.grey.shade200,
                                    filled: true,
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey, width: 0.0),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Container(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(8)),
                                width: 112,
                                height: 42,
                                child: DropdownButton<String>(
                                  hint: Text(
                                    'Urutkan',
                                  ),
                                  underline: const SizedBox(),
                                  isExpanded: true,
                                  items: <String>[
                                    'Berdasarkan Nama A ke Z',
                                    'Berdasarkan Nama Z ke A',
                                    'Berdasarkan Toko Terbaru',
                                    'Berdasarkan Toko Terlama'
                                  ].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    log(newValue.toString());
                                  },
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 10),
                                height: 40,
                                width: 74,
                                decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Center(child: Text('Pilih')),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Pilih Toko',
                          ),
                          // Expanded(
                          //   child: ListView(
                          //     children: [],
                          //   ),
                          // ),
                          Expanded(
                            child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: MediaQuery.of(context)
                                        .size
                                        .width /
                                    (MediaQuery.of(context).size.height / 0.54),
                              ),
                              itemCount: 6,
                              itemBuilder: (context, index) => Container(
                                padding: const EdgeInsets.all(16),
                                margin: EdgeInsets.all(8),
                                height: 216,
                                width: 333,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: Colors.grey.shade300)),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 70,
                                          // width: 106,
                                          child: CircleAvatar(
                                            backgroundColor:
                                                maainColor.withOpacity(0.2),
                                            child:
                                                Image.asset('assets/logo_test.png'),
                                          ),
                                        ),
                                        SizedBox(width: 20),
                                        Flexible(
                                          child: Column(
                                            children: [
                                              Text(
                                                'King Dragon Roll Jakarta',
                                              ),
                                              Text(
                                                'Jl. Pramuka No.81, RT.001/RW.002, Marga Wisata Kec. Setu ...',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    GestureDetector(
                                      // onTap: () => showError(context),
                                      child: Container(
                                        height: 56,
                                        width: 301,
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: primaryColor),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Lihat Akun',
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
