import 'package:flutter/material.dart'; // Mengimport library Flutter untuk pengembangan UI.
import 'package:http/http.dart' as http; // Mengimport library http untuk melakukan HTTP request.
import 'package:charts_flutter/flutter.dart' as charts; // Mengimport library charts_flutter untuk membuat chart.
import 'dart:convert'; // Mengimport library dart:convert untuk encoding dan decoding JSON.

// Class untuk menyimpan data populasi setiap tahun
class PopulasiTahun {
  String tahun; // Tahun dalam bentuk string
  int populasi; // Jumlah populasi
  charts.Color barColor; // Warna untuk chart

  // Constructor
  PopulasiTahun({required this.tahun, required this.populasi, required this.barColor});
}

// Class untuk menyimpan data populasi dalam bentuk list PopulasiTahun
class Populasi {
  List<PopulasiTahun> ListPop = <PopulasiTahun>[]; // List untuk menyimpan data PopulasiTahun

  // Constructor yang mengambil data dari JSON
  Populasi(Map<String, dynamic> json) {
    var data = json["data"];
    for (var val in data) {
      var tahun = val["Year"];
      var populasi = val["Population"];
      var warna = charts.ColorUtil.fromDartColor(Colors.green); // Warna default hijau
      ListPop.add(PopulasiTahun(tahun: tahun, populasi: populasi, barColor: warna));
    }
  }

  // Factory method untuk membuat objek Populasi dari JSON
  factory Populasi.fromJson(Map<String, dynamic> json) {
    return Populasi(json);
  }
}

// Widget untuk menampilkan chart populasi
class PopulasiChart extends StatelessWidget {
  List<PopulasiTahun> listPop;

  PopulasiChart({required this.listPop});
  @override
  Widget build(BuildContext context) {
    List<charts.Series<PopulasiTahun, String>> series = [
      charts.Series(
          id: "populasi",
          data: listPop,
          domainFn: (PopulasiTahun series, _) => series.tahun,
          measureFn: (PopulasiTahun series, _) => series.populasi,
          colorFn: (PopulasiTahun series, _) => series.barColor)
    ];
    return charts.BarChart(series, animate: true); // Membuat Bar Chart dengan data series
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Chart-Http", home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  late Future<Populasi> futurePopulasi;

  String url = "https://datausa.io/api/data?drilldowns=Nation&measures=Population";

  // Method untuk fetch data dari API
  Future<Populasi> fetchData() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return Populasi.fromJson(jsonDecode(response.body)); // Decode JSON response ke objek Populasi
    } else {
      throw Exception('Gagal load');
    }
  }

  @override
  void initState() {
    super.initState();
    futurePopulasi = fetchData(); // Memanggil method fetchData saat initState dipanggil
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('chart - http'),
      ),
      body: FutureBuilder<Populasi>(
        future: futurePopulasi,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(
                child: PopulasiChart(listPop: snapshot.data!.ListPop)); // Menampilkan chart jika data sudah tersedia
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}'); // Menampilkan pesan error jika terjadi kesalahan
          }
          return const CircularProgressIndicator(); // Menampilkan indikator loading saat data sedang diambil
        },
      ),
    );
  }
}
