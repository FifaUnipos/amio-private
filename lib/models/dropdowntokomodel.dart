import 'dart:convert';

import 'package:http/http.dart' as http;

import '../services/apimethod.dart';

class DataProvince {
  String? id;
  String? name;

  DataProvince({required this.id, required this.name});

  DataProvince.fromJson(Map<String, dynamic> json) {
    id = json['ID'];
    name = json['NAME'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.id;
    data['NAME'] = this.name;
    return data;
  }
}

class DataTipeUsaha {
  String? id;
  String? name;

  DataTipeUsaha({required this.id, required this.name});

  DataTipeUsaha.fromJson(Map<String, dynamic> json) {
    id = json['tipeusaha_id'];
    name = json['nama_tipe'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tipeusaha_id'] = this.id;
    data['nama_tipe'] = this.name;
    return data;
  }
}

Future getTipeUsaha(token, id) async {
  final response = await http.post(
    Uri.parse(tipeUsaha),
    // Uri.parse('http://103.155.26.20:8000/api/groupmerchant/user'),
    headers: {
      'token': token,
    },
    body: {
      "deviceid": id,
    },
  );

  if (response.statusCode == 200) {
    print('succes');

    final List<DataTipeUsaha> result = [];

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    for (Map<String, dynamic> item in decoded['data']) {
      // print(item);

      final model = DataTipeUsaha.fromJson(item);
      result.add(model);

      // print(model.toJson());
    }

    return result;
  }
}
