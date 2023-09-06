import 'package:amio/utils/component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

class DashboardPageMobile extends StatefulWidget {
  const DashboardPageMobile({super.key});

  @override
  State<DashboardPageMobile> createState() => _DashboardPageMobileState();
}

class _DashboardPageMobileState extends State<DashboardPageMobile> {
  int selectedIndex = 0;

  final List icons = [
    PhosphorIcons.storefront_fill,
    PhosphorIcons.shopping_bag_open_fill,
    // PhosphorIcons.storefront,
    PhosphorIcons.shopping_cart_simple_fill,
    PhosphorIcons.users_three_fill,
    // PhosphorIcons.storefront,
    PhosphorIcons.file_text_fill,
    PhosphorIcons.question_fill,
    PhosphorIcons.printer_fill,
  ];
  final List<String> title = [
    'Toko',
    'Produk',
    // 'Inventori',
    'Transaksi',
    'Akun',
    // 'Keuangan',
    'Laporan',
    'Bantuan',
    'Printer',
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        floatingActionButton: GestureDetector(
          onTap: () {
            showModalBottomSheet(
                // isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                context: context,
                builder: (context) {
                  return Container(
                    padding:
                        EdgeInsets.fromLTRB(size32, size12, size32, size32),
                    decoration: BoxDecoration(
                        color: bnw100,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(size16),
                            topRight: Radius.circular(size16))),
                    child: Stack(
                      alignment: AlignmentDirectional.bottomEnd,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            dividerShowdialog(),
                            SizedBox(height: size24),
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: (icons.length / 4).ceil(),
                              itemBuilder:
                                  (BuildContext context, int rowIndex) {
                                final int startIndex = rowIndex * 4;
                                final int endIndex = (rowIndex + 1) * 4;
                                final List rowIcons = icons.sublist(
                                    startIndex,
                                    endIndex < icons.length
                                        ? endIndex
                                        : icons.length);

                                while (rowIcons.length < 4) {
                                  rowIcons.add(null);
                                }
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: rowIcons.map((icon) {
                                    return icon != null
                                        ? Container(
                                            margin:
                                                EdgeInsets.only(bottom: size16),
                                            height: size64,
                                            width: size64,
                                            padding: EdgeInsets.all(size8),
                                            child: Column(
                                              children: [
                                                Icon(
                                                  icon,
                                                  color: primary500,
                                                  size: size24,
                                                ),
                                                SizedBox(height: size4),
                                                Text(
                                                  title[rowIndex],
                                                  style: body3(FontWeight.w600,
                                                      bnw900, 'Outfit'),
                                                )
                                              ],
                                            ),
                                          )
                                        : Opacity(
                                            opacity: 0,
                                            child: Container(
                                              height: size64,
                                              width: size64,
                                              padding: EdgeInsets.all(size8),
                                              child: Column(
                                                children: [
                                                  Icon(
                                                    PhosphorIcons
                                                        .storefront_fill,
                                                    color: primary500,
                                                    size: size24,
                                                  ),
                                                  SizedBox(height: size4),
                                                  Text(
                                                    '',
                                                    style: body3(
                                                        FontWeight.w600,
                                                        bnw900,
                                                        'Outfit'),
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                  }).toList(),
                                );
                              },
                            ),
                            SizedBox(height: size56),
                          ],
                        ),
                        Positioned(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                                child: Container(
                              width: 80,
                              height: 80,
                              padding: EdgeInsets.all(size16),
                              decoration: ShapeDecoration(
                                color: bnw300,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(60),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    PhosphorIcons.x_fill,
                                    size: size24,
                                    color: bnw900,
                                  ),
                                  Text(
                                    'Tutup',
                                    style: body3(
                                      FontWeight.w600,
                                      bnw900,
                                      'Outfit',
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ),
                        ),
                      ],
                    ),
                  );
                });
          },
          child: Container(
            height: size48,
            child: buttonL(
              Center(
                  child: Row(
                children: [
                  Icon(PhosphorIcons.squares_four_fill,
                      color: bnw100, size: size24),
                  SizedBox(width: size12),
                  Text(
                    'Menu',
                    style: heading3(FontWeight.w600, bnw100, 'Outfit'),
                  ),
                ],
              )),
              primary500,
              primary500,
            ),
          ),
        ),
        body: Column(
          children: [
            Container(color: red200),
          ],
        ),
      ),
    );
  }
}

class IconTile extends StatelessWidget {
  final IconData icon;
  final String label;

  IconTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(icon, size: 48.0),
        SizedBox(height: 8.0),
        Text(label),
      ],
    );
  }
}
