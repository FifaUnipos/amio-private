import 'package:unipos_app_335/utils/component/component_showModalBottom.dart';
import 'package:flutter/material.dart';
import 'package:unipos_app_335/utils/utilities.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import '../../../../utils/component/component_size.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../services/checkConnection.dart';
import '../../../../utils/component/component_color.dart';

class BantuanGrup extends StatefulWidget {
  BantuanGrup({super.key});

  @override
  State<BantuanGrup> createState() => _BantuanGrupState();
}

class _BantuanGrupState extends State<BantuanGrup> {
  PageController pageController = PageController();
  List<Step> _steps = [];
  List<bool> _isExpandedList = [];

  @override
  void initState() {
    checkConnection(context);
    _steps = getSteps();
    _isExpandedList = List.generate(_steps.length, (index) => false);
    super.initState();
    pageController = PageController(
      initialPage: 0,
      keepPage: true,
      viewportFraction: 1,
    );
  }

  // Use List of steps initialized once in initState

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showModalBottomExit(context);
        return false;
      },
      child: SafeArea(
        child: Container(
          margin: EdgeInsets.all(size16),
          padding: EdgeInsets.all(size16),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: bnw100,
            borderRadius: BorderRadius.circular(size16),
          ),
          child: PageView(
            physics: NeverScrollableScrollPhysics(),
            controller: pageController,
            children: [
              pagePertama(context),
              ListView(
                padding: EdgeInsets.zero,
                physics: BouncingScrollPhysics(),
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          pageController.jumpToPage(0);
                        },
                        child: Icon(
                          PhosphorIcons.arrow_left_bold,
                          size: size48,
                          color: bnw900,
                        ),
                      ),
                      SizedBox(width: size12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pertanyaan yang sering diajukan',
                            style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                          ),
                          Text(
                            'Panduan mengenai aplikasi',
                            style: heading3(FontWeight.w300, bnw900, 'Outfit'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size20),
                      Text(
                        'Kategori',
                        style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                      ),
                      SizedBox(
                        height: 160,
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 1,
                          itemBuilder: (BuildContext context, int index) {
                            return frameDash('Semua', PhosphorIcons.notebook);
                          },
                        ),
                      ),
                      Text('Pertanyaan',
                          style: heading3(FontWeight.w600, bnw900, 'Outfit')),
                      SizedBox(height: size12),
                      SingleChildScrollView(
                        padding: EdgeInsets.zero,
                        child: Container(
                          padding: EdgeInsets.only(bottom: size12),
                          child: ExpansionPanelList(
                            elevation: 1,
                            expansionCallback: (int index, bool isExpanded) {
                              setState(() {
                                _isExpandedList[index] = !_isExpandedList[
                                    index]; // Ubah status ekspansi
                              });
                            },
                            children: _steps
                                .asMap()
                                .entries
                                .map<ExpansionPanel>((entry) {
                              int index = entry.key;
                              Step step = entry.value;
                              return ExpansionPanel(
                                backgroundColor: primary100,
                                canTapOnHeader: true,
                                headerBuilder:
                                    (BuildContext context, bool isExpanded) {
                                  return ListTile(
                                    title: Text(
                                      step.title,
                                      style: heading3(
                                          FontWeight.w600, bnw900, 'Outfit'),
                                    ),
                                  );
                                },
                                body: ListTile(
                                  title: Text(
                                    step.body,
                                    style: heading4(
                                        FontWeight.w400, bnw900, 'Outfit'),
                                  ),
                                ),
                                isExpanded: _isExpandedList[
                                    index], // Status ekspansi berdasarkan index
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  pagePertama(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bantuan',
              style: heading1(FontWeight.w700, bnw900, 'Outfit'),
            ),
            Text(
              'Segala informasi mengenai aplikasi',
              style: heading3(FontWeight.w300, bnw900, 'Outfit'),
            ),
          ],
        ),
        SizedBox(height: size16),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: SvgPicture.asset(
                  'assets/newIllustration/Help.svg',
                ),
              ),
              SizedBox(height: size8),
              Text(
                'Versi Aplikasi 1.5.35',
                style: heading3(FontWeight.w400, bnw900, 'Outfit'),
              ),
            ],
          ),
        ),
        SizedBox(height: size16),
        Column(
          children: [
            GestureDetector(
              onTap: () {
                helpQuestionShow(context);
              },
              child: bantuanButton(
                'Hubungi Customer Service',
                PhosphorIcons.whatsapp_logo_fill,
              ),
            ),
            GestureDetector(
              onTap: () {
                pageController.nextPage(
                    duration: Duration(milliseconds: 10), curve: Curves.easeIn);
              },
              child: bantuanButton(
                'Pertanyaan Yang Sering Ditanyakan',
                PhosphorIcons.question_fill,
              ),
            ),
            bantuanButton(
              'Info Aplikasi',
              PhosphorIcons.info_fill,
            ),
          ],
        ),
      ],
    );
  }

  Container bantuanButton(String title, IconData icon) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: bnw300),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: bnw900,
              ),
              SizedBox(width: size12),
              Text(
                title,
                style: heading3(FontWeight.w600, bnw900, 'Outfit'),
              )
            ],
          )
        ],
      ),
    );
  }
}

Container frameDash(String title, IconData icon) {
  return Container(
    margin: EdgeInsets.fromLTRB(0, size8, size8, 0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(size8),
    ),
    child: Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: size8, right: size8),
          height: 90,
          width: 90,
          decoration: BoxDecoration(
            color: primary200,
            borderRadius: BorderRadius.circular(size8),
          ),
          child: Icon(
            icon,
            color: primary500,
            size: 46,
          ),
        ),
        Text(
          title,
          style: heading3(FontWeight.w600, bnw900, 'Outfit'),
        ),
      ],
    ),
  );
}

class Step {
  Step(this.title, this.body);
  String title;
  String body;
}

List<Step> getSteps() {
  return [
    Step('Apa yang harus saya lakukan setelah berhasil masuk ke aplikasi?',
        'Jika Anda daftar sebagai akun toko, maka Anda harus mendaftar akun toko terlebih dahulu. Jika Anda mendaftar sebagai grup toko, langkahnya adalah membuat toko, membuat akun, dan menambahkan produk.'),
    Step('Ada paket lisensi apa saja untuk berlangganan aplikasi UniPOS?',
        'Paket Basic, Paket Pro, dan Paket Pro+ tersedia.'),
    Step('Apakah bisa upgrade tipe akun di UniPOS?',
        'Bisa, Anda dapat mendaftar sebagai toko, lalu meng-upgrade ke grup toko.'),
  ];
}
