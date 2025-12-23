import '../../pageMobile/pageHelperMobile/masukAkunMobile.dart';
import 'package:flutter/material.dart';import 'package:unipos_app_335/utils/component/component_textHeading.dart';import '../../../../utils/component/component_size.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'content_model.dart';

import '../../../../utils/component/component_color.dart';
import '../../pageMobile/pageHelperMobile/loginRegisMobile/loginPageMobile.dart';
import '../masukakun.dart';import '../../../../../utils/component/component_button.dart';

class Onbording extends StatefulWidget {
  bool isTablet;
  Onbording({
    Key? key,
    required this.isTablet,
  }) : super(key: key);
  @override
  _OnbordingState createState() => _OnbordingState();
}

class _OnbordingState extends State<Onbording> {
  int currentIndex = 0;
  PageController? _controller;

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: size12, horizontal: size32),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: contents.length,
                onPageChanged: (int index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (_, i) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(child: SvgPicture.asset(contents[i].image)),
                      SizedBox(height: size32),
                      Text(
                        contents[i].title,
                        textAlign: TextAlign.center,
                        style: heading1(FontWeight.w700, bnw900, 'Outfit'),
                      ),
                      // SizedBox(height: size12),
                      // Text(
                      //   contents[i].discription,
                      //   textAlign: TextAlign.center,
                      //   style: heading2(FontWeight.w500, bnw900, 'Outfit'),
                      // )
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: size16),
            GestureDetector(
              onTap: () async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        widget.isTablet ? MasukAkunPage() : MasukAkunPageMobile(),
                  ),
                );
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('onboard', 'true');
              },
              child: Container(
                child: buttonXXL(
                  Center(
                    child: Text(
                      'Gabung Sekarang',
                      style: heading2(FontWeight.w600, bnw100, 'Outfit'),
                    ),
                  ),
                  MediaQuery.of(context).size.width,
                ),
              ),
            ),
            SizedBox(height: size16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    _controller!.previousPage(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeIn,
                    );
                  },
                  child: currentIndex == 0
                      ? Padding(
                          padding: EdgeInsets.fromLTRB(
                              size20, size12, size20, size12),
                          child: Text(
                            'Kembali',
                            style: heading2(FontWeight.w600, bnw100, 'Outfit'),
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.fromLTRB(
                              size20, size12, size20, size12),
                          child: Text(
                            currentIndex == 0 ? "" : "Kembali",
                            style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                          ),
                        ),
                ),
                Row(
                  children: List.generate(
                    contents.length,
                    (index) => buildDot(index, context),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    if (currentIndex == contents.length - 1) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => widget.isTablet
                              ? MasukAkunPage()
                              : MasukAkunPageMobile(),
                        ),
                      );
                    }
                    _controller!.nextPage(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeIn,
                    );
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString('onboard', 'true');
                  },
                  child: Container(
                    padding:
                        EdgeInsets.fromLTRB(size20, size12, size20, size12),
                    child: Text(
                      currentIndex == contents.length - 1
                          ? "Selesai"
                          : "Lanjut",
                      style: heading2(FontWeight.w600, bnw900, 'Outfit'),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: size16),
          ],
        ),
      ),
    );
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 8,
      width: currentIndex == index ? size24 : size12,
      margin: EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: currentIndex == index ? primary500 : bnw300,
      ),
    );
  }
}
