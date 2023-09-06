import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DataModel {
  final String title;
  final String description;

  DataModel({required this.title, required this.description});

  factory DataModel.fromJson(Map<String, dynamic> json) {
    return DataModel(
      title: json['title'],
      description: json['description'],
    );
  }
}

class SearchBarExample extends StatefulWidget {
  @override
  _SearchBarExampleState createState() => _SearchBarExampleState();
}

class _SearchBarExampleState extends State<SearchBarExample> {
  TextEditingController _searchController = TextEditingController();
  List<DataModel> _dataList = [];
  List<DataModel> _searchResultList = [];

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('https://api.example.com/data'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        _dataList = List<DataModel>.from(
            jsonData.map((data) => DataModel.fromJson(data)));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void _runSearch(String searchText) {
    _searchResultList.clear();
    if (searchText.isEmpty) {
      setState(() {
        _searchResultList.addAll(_dataList);
      });
    } else {
      _dataList.forEach((data) {
        if (data.title.toLowerCase().contains(searchText.toLowerCase())) {
          setState(() {
            _searchResultList.add(data);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onChanged: _runSearch,
          decoration: InputDecoration(
            hintText: 'Cari...',
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _searchResultList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_searchResultList[index].title),
            subtitle: Text(_searchResultList[index].description),
          );
        },
      ),
    );
  }
}
