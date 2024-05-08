import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universitas ASEAN',
      home: BlocProvider(
        create: (context) => UniversityCubit(),
        child: UniversitiesPage(),
      ),
    );
  }
}

class UniversityCubit extends Cubit<List<dynamic>> {
  UniversityCubit() : super([]);

  String _selectedCountry = 'Indonesia';

  String get selectedCountry => _selectedCountry;

  void fetchUniversities() async {
    var url = Uri.parse(
        'http://universities.hipolabs.com/search?country=$_selectedCountry');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        emit(json.decode(response.body));
      } else {
        emit([]); // Hapus data jika pengambilan tidak berhasil
        throw Exception('Gagal memuat universitas');
      }
    } catch (e) {
      emit([]);
      print('Error mengambil universitas: $e');
    }
  }

  void changeCountry(String country) {
    _selectedCountry = country;
    fetchUniversities();
  }
}

class UniversitiesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Universitas di ASEAN'),
      ),
      body: Column(
        children: [
          CountryDropdown(),
          Expanded(
            child: BlocBuilder<UniversityCubit, List<dynamic>>(
              builder: (context, universities) => universities.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: universities.length,
                      itemBuilder: (context, index) {
                        var university = universities[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: index % 2 == 0
                                ? Colors.grey[200]
                                : Colors.white,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          margin: EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(
                              university['name'],
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              university['web_pages'][0],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 110, 101, 101)),
                            ),
                            onTap: () => _launchURL(university['web_pages'][0]),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Tidak dapat ditampilkan $url');
    }
  }
}

class CountryDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final universityCubit =
        BlocProvider.of<UniversityCubit>(context, listen: false);
    return BlocBuilder<UniversityCubit, List<dynamic>>(
      builder: (context, selectedCountry) => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: DropdownButton<String>(
          value: universityCubit.selectedCountry,
          onChanged: (value) {
            if (value != null) {
              universityCubit.changeCountry(value);
            }
          },
          items: [
            'Indonesia',
            'Singapore',
            'Malaysia',
            'Thailand',
            'philippines',
            'Vietnam',
            'Cambodia',
            'Myanmar',
            'Brunei Darussalam'
          ]
              .map<DropdownMenuItem<String>>(
                (String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
