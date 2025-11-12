import 'package:unipos_app_335/main.dart';
import 'package:unipos_app_335/utils/component/component_color.dart';
import 'package:unipos_app_335/utils/component/component_orderBy.dart';
import 'package:unipos_app_335/utils/component/component_size.dart';
import 'package:unipos_app_335/utils/component/component_textHeading.dart';
import 'package:flutter/material.dart';

class bottomShowChoice extends StatefulWidget {
  List orderBy;
  bottomShowChoice({
    required this.orderBy,
    super.key,
  });

  @override
  State<bottomShowChoice> createState() => _bottomShowChoiceState();
}

class _bottomShowChoiceState extends State<bottomShowChoice> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: List<Widget>.generate(
        widget.orderBy.length,
        (int index) {
          return Padding(
            padding: EdgeInsets.only(right: size16),
            child: ChoiceChip(
              padding: EdgeInsets.symmetric(vertical: size12),
              backgroundColor: bnw100,
              selectedColor: primary100,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: valueOrderByProduct == index ? primary500 : bnw300,
                ),
                borderRadius: BorderRadius.circular(size8),
              ),
              label: Text(orderByProductText[index],
                  style: heading4(
                      FontWeight.w400,
                      valueOrderByProduct == index ? primary500 : bnw900,
                      'Outfit')),
              selected: valueOrderByProduct == index,
              onSelected: (bool selected) {
                setState(() {
                  print(index);
                  // _value =
                  //     selected ? index : null;
                  valueOrderByProduct = index;
                });
                setState(() {});
              },
            ),
          );
        },
      ).toList(),
    );
  }
}
