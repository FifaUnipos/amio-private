import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:unipos_app_335/models/tokomodel.dart';
import 'package:unipos_app_335/pageMobile/pageTokoMobile/pageUbahTokoMobile.dart';
import 'package:unipos_app_335/services/apimethod.dart';
import 'package:unipos_app_335/utils/component/component_button.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';

class TokoPageMobile extends StatefulWidget {
  final String token;
  TokoPageMobile({super.key, required this.token});

  @override
  State<TokoPageMobile> createState() => _TokoPageState();
}

class _TokoPageState extends State<TokoPageMobile> {
  List<ModelDataToko> listToko = [];
  bool isLoading = true;
  String search = '';
  String orderby = 'asc';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    final data = await getAllToko(context, widget.token, search, orderby);
    setState(() {
      listToko = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Toko", style: heading1(FontWeight.w700, bnw900, 'Outfit')),
        centerTitle: false,
        backgroundColor: bnw100,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrow_left, color: bnw900),
          onPressed: () => Navigator.pop(context),
        ),
        actionsPadding: EdgeInsets.symmetric(
          horizontal: size16,
          vertical: size8,
        ),
        // actions: [
        //   buttonXS(
        //     Center(
        //       child: Text(
        //         'Tambah',
        //         style: heading3(FontWeight.w600, bnw100, 'Outfit'),
        //       ),
        //     ),
        //   ),
        // ],
      ),
      backgroundColor: bnw100,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(size16),
              child: Column(
                children: [
                  // 🔍 Search field
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: "Cari",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: bnw300, width: 1),
                      ),
                    ),
                    onChanged: (value) => search = value,
                    onSubmitted: (_) => loadData(),
                  ),
                  SizedBox(height: size12),

                  // 🔹 Filter & Info
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: bnw100,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: bnw300),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                orderby = orderby == 'asc' ? 'desc' : 'asc';
                              });
                              loadData();
                            },
                            child: Text(
                              "Urutkan",
                              style: TextStyle(color: bnw900),
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: bnw100,
                              border: Border.all(color: bnw300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Total Toko : ${listToko.length}",
                              style: TextStyle(
                                color: bnw900,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {},
                          child: Text(
                            "Pilih Sekaligus",
                            style: heading3(
                              FontWeight.w600,
                              primary500,
                              'Outfit',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size32),

                  // 📋 Daftar Toko
                  Expanded(
                    child: ListView.builder(
                      itemCount: listToko.length,
                      itemBuilder: (context, index) {
                        final toko = listToko[index];
                        merchantId = toko.merchantid ?? '';
                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: bnw100,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: bnw300,
                                blurRadius: 2,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ✅ Baris foto + info
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        toko.logomerchant_url ?? '',
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, _, __) =>
                                            Container(
                                              width: 60,
                                              height: 60,
                                              color: Colors.grey[200],
                                              child: Icon(
                                                Icons.storefront,
                                                color: Colors.grey,
                                              ),
                                            ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            toko.name ?? '',
                                            style: heading2(
                                              FontWeight.w600,
                                              bnw900,
                                              'Outfit',
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            toko.address ?? '',
                                            style: body1(
                                              FontWeight.w500,
                                              bnw500,
                                              'Outfit',
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 12),

                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  UbahTokoPageMobile(
                                                    token: widget.token,
                                                  ),
                                            ),
                                          );
                                          result;
                                        },
                                        child: buttonXLoutline(
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                PhosphorIcons.pencil_fill,
                                                color: bnw900,
                                                size: size24,
                                              ),
                                              SizedBox(width: size12),
                                              Text(
                                                'Ubah',
                                                style: body3(
                                                  FontWeight.w600,
                                                  bnw900,
                                                  'Outfit',
                                                ),
                                              ),
                                            ],
                                          ),
                                          double.infinity,
                                          bnw300,
                                        ),
                                      ),
                                    ),
                                    // SizedBox(width: size12),
                                    // SizedBox(
                                    //   child: buttonXLoutline(
                                    //     Center(
                                    //       child: Icon(
                                    //         PhosphorIcons.trash_fill,
                                    //         color: danger500,
                                    //       ),
                                    //     ),
                                    //     double.infinity,
                                    //     danger500,
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
