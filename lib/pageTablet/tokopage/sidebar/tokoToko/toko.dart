import 'dart:developer';
import 'package:amio/utils/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:amio/utils/component.dart';
import '../../../../../main.dart';
import '../../../../../models/tokomodel.dart';
import '../../../../../services/apimethod.dart';
import '../../../../services/checkConnection.dart';
import '../../../home/sidebar/tokoPage/ubahToko.dart';
import 'ubahTokoToko.dart';

class TokoPageToko extends StatefulWidget {
  String token;
  TokoPageToko({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<TokoPageToko> createState() => _TokoPageTokoState();
}

class _TokoPageTokoState extends State<TokoPageToko> {
  PageController _pageController = PageController();
  TextEditingController hapusController = TextEditingController();

  List<ModelDataToko>? datas;

  String image = "",
      name = "",
      type = "",
      address = "",
      provinsi = "",
      kabupaten = "",
      kecamatan = "",
      kelurahan = "",
      kode = "",
      merchid = "";

  @override
  void initState() {
    checkConnection(context);
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        datas = await getAllToko(context, widget.token, '', '');

        //   datas;
        setState(() {});

        _pageController = PageController(
          initialPage: 0,
          keepPage: true,
          viewportFraction: 1,
        );
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    hapusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(size16),
          padding: EdgeInsets.all(size16),
          decoration: BoxDecoration(
            color: bnw100,
            borderRadius: BorderRadius.circular(size16),
          ),
          child: PageView(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            pageSnapping: true,
            reverse: false,
            physics: NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              print('$index');
            },
            children: [
              mainPageToko(),
              ChangeMerchantToko(
                token: widget.token,
                pageController: _pageController,
                merchantid: merchid,
              ),
            ],
          ),
        ),
      ),
    );
  }

  mainPageToko() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Toko',
                  style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                ),
                Text(
                  'Tempat usaha yang dimiliki',
                  style: heading3(FontWeight.w400, bnw900, 'Outfit'),
                ),
              ],
            ),
          ],
        ),
        datas == null
            ? SkeletonCard()
            : Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size16),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          initState();
                          setState(() {});
                        },
                        child: GridView.builder(
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            mainAxisExtent: 130,
                            // childAspectRatio: 2.977,
                            crossAxisCount: 2,
                            crossAxisSpacing: size16,
                            mainAxisSpacing: size16,
                          ),
                          itemCount: datas!.length,
                          itemBuilder: (context, i) => Container(
                            padding: EdgeInsets.all(size16),
                            margin: EdgeInsets.only(right: size8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(size16),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(1000),
                                      child: SizedBox(
                                        height: 60,
                                        width: 60,
                                        child: datas![i].logomerchant_url !=
                                                null
                                            ? Image.network(
                                                datas![i]
                                                    .logomerchant_url
                                                    .toString(),
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    SizedBox(
                                                        child: Icon(
                                                  PhosphorIcons.storefront_fill,
                                                  size: 60,
                                                  color: bnw900,
                                                )),
                                              )
                                            : Icon(
                                                Icons.person,
                                                size: 60,
                                              ),
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            datas![i].name ?? '',
                                            style: heading2(FontWeight.w700,
                                                bnw900, 'Outfit'),
                                          ),
                                          Text(
                                            '${datas![i].address}',
                                            style: body1(FontWeight.w400,
                                                bnw800, 'Outfit'),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    whenLoading(context);
                                    getSingleMerch(
                                      context,
                                      widget.token,
                                      datas![i].merchantid.toString(),
                                    ).then((value) {
                                      if (value['rc'] == '00') {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                        _pageController.nextPage(
                                            duration:
                                                Duration(milliseconds: 10),
                                            curve: Curves.ease);
                                      } else {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                      }
                                    });

                                    setState(() {});
                                  },
                                  child: Container(
                                    height: 40,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: bnw100,
                                      border: Border.all(color: bnw300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(PhosphorIcons.pencil_line),
                                        SizedBox(width: size16),
                                        Text(
                                          'Ubah',
                                          style: heading4(
                                            FontWeight.w600,
                                            bnw900,
                                            'Outfit',
                                          ),
                                        ),
                                      ],
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
              )
      ],
    );
  }
}
