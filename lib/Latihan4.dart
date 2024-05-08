import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UniversityProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universitas ASEAN',
      home: UniversitiesPage(),
    );
  }
}

class UniversityProvider with ChangeNotifier {
  List<dynamic> _universities = [];
  String _selectedCountry = 'Indonesia';

  List<dynamic> get universities => _universities;
  String get selectedCountry => _selectedCountry;

  void fetchUniversities() async {
    var url = Uri.parse(
        'http://universities.hipolabs.com/search?country=$_selectedCountry');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        _universities = json.decode(response.body);
      } else {
        _universities = []; // Hapus data jika pengambilan tidak berhasil
        throw Exception('Gagal memuat universitas');
      }
      notifyListeners();
    } catch (e) {
      _universities = [];
      notifyListeners();
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
            child: Consumer<UniversityProvider>(
              builder: (context, provider, _) => provider.universities.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: provider.universities.length,
                      itemBuilder: (context, index) {
                        var university = provider.universities[index];
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
    var provider = Provider.of<UniversityProvider>(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButton<String>(
        value: provider.selectedCountry,
        onChanged: (value) {
          if (value != null) {
            provider.changeCountry(value);
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
    );
  }
}
