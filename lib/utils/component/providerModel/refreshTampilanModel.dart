import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';

import '../../../models/produkmodel.dart';
import '../../../pageTablet/tokopage/sidebar/transaksiToko/pilihPelangganPage.dart';
import '../../../pageTablet/tokopage/sidebar/transaksiToko/transaksi.dart';
import '../../../services/apimethod.dart';

import '../component_color.dart';

class RefreshTampilan with ChangeNotifier {
  void getDataProduk(List<ModelDataProduk> datasProduk, context, token) async {
    datasProduk = await getProduct(
      context,
      token,
      '',
      [''],
      '',
    );

    notifyListeners();
  }

  List<dynamic>? searchList;
  List<dynamic>? searchResultList;

  void runSearch(String searchText) {
    searchResultList = searchList
        ?.where((search) =>
            search.toString().toLowerCase().contains(searchText.toLowerCase()))
        .toList();
    notifyListeners();
  }

  String namaPelanggan = '', idPelanggan = '';
  refreshPelanggan(name, id) {
    pelangganName = name;
    pelangganId = id;

    namaPelanggan = name;
    idPelanggan = id;
    notifyListeners();
  }

  Map<int, bool> selectedFlag = {};
  bool isSelectionMode = false;
  List<String> listProduct = List.empty(growable: true);

  void onTap(bool isSelected, int index, productId) {
    if (index >= 0 && index < selectedFlag.length) {
      selectedFlag[index] = !isSelected;
      isSelectionMode = selectedFlag.containsValue(true);

      if (selectedFlag[index] == true) {
        // Periksa apakah productId sudah ada di dalam listProduct sebelum menambahkannya
        if (!listProduct.contains(productId)) {
          listProduct.add(productId);
        }
      } else {
        // Hapus productId dari listProduct jika sudah ada
        listProduct.remove(productId);
      }

      notifyListeners();
    }
  }

  Widget buildSelectIcon(bool isSelected, ModelDataProduk data) {
    return Icon(
      isSelected ? PhosphorIcons.check_square_fill : PhosphorIcons.square,
      color: primary500,
    );
    // if (isSelectionMode) {
    // } else {
    //   return CircleAvatar(
    //     child: Text('${data['id']}'),
    //   );
    // }
  }
}

class RefreshSelected with ChangeNotifier {
  int? valueSelected;

  refreshTampilan(index) {
    valueSelected = index;
    notifyListeners();
  }
}
