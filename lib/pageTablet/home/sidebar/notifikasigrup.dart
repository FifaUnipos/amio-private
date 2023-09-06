import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

import '../../../models/tokomodel.dart';
import '../../../utils/component.dart';

class NotifikasiGrup extends StatefulWidget {
  NotifikasiGrup({Key? key}) : super(key: key);

  @override
  State<NotifikasiGrup> createState() => _NotifikasiGrupState();
}

class _NotifikasiGrupState extends State<NotifikasiGrup> {
  List<ModelDataToko>? datas;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(21),
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: bnw100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pemberitahuan',
            style: heading1(FontWeight.w700, bnw900, 'Outfit'),
          ),
          Text(
            'King Dragon Roll Jakarta',
            style: heading3(FontWeight.w300, bnw900, 'Outfit'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              notifikasiCard(
                context,
                "Daftar Pesanan",
                Icon(
                  PhosphorIcons.shopping_cart_simple_fill,
                  size: 40,
                  color: primary500,
                ),
              ),
              notifikasiCard(
                context,
                "Pesanan Habis",
                Icon(
                  PhosphorIcons.archive_box_fill,
                  size: 40,
                  color: primary500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(16),
              ),
              child: NotifikasiBox(
                datas: datas ?? [],
              ),
            ),
          )
        ],
      ),
    );
  }

  Container notifikasiCard(BuildContext context, String title, Icon icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(right: 12),
      width: MediaQuery.of(context).size.width / 4.10,
      decoration: BoxDecoration(
        color: bnw100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bnw300),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.only(right: 16),
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: primary200,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: bnw200),
            ),
            child: Center(child: icon),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: heading3(FontWeight.w600, bnw900, 'Outfit'),
              ),
              Text(
                "0",
                style: heading1(FontWeight.w700, primary500, 'Outfit'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NotifikasiBox extends StatefulWidget {
  List<ModelDataToko>? datas;
  NotifikasiBox({
    Key? key,
    required this.datas,
  }) : super(key: key);
  @override
  _NotifikasiBoxState createState() => _NotifikasiBoxState();
}

class _NotifikasiBoxState extends State<NotifikasiBox> {
  bool isSelectionMode = false;

  List<ModelDataToko>? staticData;
  Map<int, bool> selectedFlag = {};
  // Map<int, bool> selectedFlag = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bnw100,
      body: newnew(widget.datas),
      // floatingActionButton: _buildSelectAllButton(),
    );
  }

  newnew(List<ModelDataToko>? datas) {
    bool isFalseAvailable = selectedFlag.containsValue(false);
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: bnw100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _selectAll,
                      child: const SizedBox(
                        width: 50,
                        child: Icon(
                          Icons.check_box_outline_blank,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: Text(
                        'Notifikasi',
                        style: heading3(FontWeight.w600, bnw900, 'Outfit'),
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              buttonLoutline(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        PhosphorIcons.trash,
                        color: red500,
                      ),
                      Text(
                        'Hapus Semua',
                        style: body1(FontWeight.w600, red500, 'Outfit'),
                      ),
                    ],
                  ),
                  
                  red500)
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: bnw100,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: ListView.builder(
              itemBuilder: (builder, index) {
                ModelDataToko data = datas[index];
                selectedFlag[index] = selectedFlag[index] ?? false;
                bool? isSelected = selectedFlag[index];
                return Row(
                  children: [
                    InkWell(
                      // onTap: () => onTap(isSelected, index),
                      onTap: () {
                        onTap(isSelected, index);
                        log(data.name.toString());
                      },
                      child: SizedBox(
                        width: 50,
                        child: _buildSelectIcon(isSelected!, data),
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: Text(
                        datas[index].name ?? '',
                        style: heading2(FontWeight.w700, bnw900, 'Outfit'),
                      ),
                    ),
                  ],
                );
              },
              itemCount: datas!.length,
            ),
          ),
        ),
      ],
    );
  }

  void onTap(bool isSelected, int index) {
    setState(() {
      selectedFlag[index] = !isSelected;
      isSelectionMode = selectedFlag.containsValue(true);
    });
    // if (isSelectionMode) {
    // } else {
    //   // Open Detail Page
    // }
  }

  void onLongPress(bool isSelected, int index) {
    setState(() {
      selectedFlag[index] = !isSelected;
      isSelectionMode = selectedFlag.containsValue(true);
    });
  }

  Widget _buildSelectIcon(bool isSelected, ModelDataToko data) {
    return Icon(
      isSelected ? Icons.check_box : Icons.check_box_outline_blank,
      color: Theme.of(context).primaryColor,
    );
    // if (isSelectionMode) {
    // } else {
    //   return CircleAvatar(
    //     child: Text('${data['id']}'),
    //   );
    // }
  }

  // FloatingActionButton? _buildSelectAllButton() {
  //   bool isFalseAvailable = selectedFlag.containsValue(false);
  //   if (isSelectionMode) {
  //     return FloatingActionButton(
  //       onPressed: _selectAll,
  //       child: Icon(
  //         isFalseAvailable ? Icons.done_all : Icons.remove_done,
  //       ),
  //     );
  //   } else {
  //     return null;
  //   }
  // }

  void _selectAll() {
    bool isFalseAvailable = selectedFlag.containsValue(false);
    // If false will be available then it will select all the checkbox
    // If there will be no false then it will de-select all
    selectedFlag.updateAll((key, value) => isFalseAvailable);
    setState(() {
      isSelectionMode = selectedFlag.containsValue(true);
    });
  }
}
