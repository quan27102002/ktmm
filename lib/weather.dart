import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ktmm/weather_data.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class WeatherDashboard extends StatefulWidget {
  const WeatherDashboard({super.key});

  @override
  State<WeatherDashboard> createState() => _WeatherDashboardState();
}

class _WeatherDashboardState extends State<WeatherDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Timer _timer;
  late Database _database;

  DatabaseReference temp = FirebaseDatabase.instance.ref('/user').child('temp');
  DatabaseReference humi = FirebaseDatabase.instance.ref('/user').child('humi');
  DatabaseReference light = FirebaseDatabase.instance.ref('/user').child('lux');

  double temperature = 0;
  double humidity = 0;
  double lux = 0;
  List<WeatherData> _chartData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initData();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    await _initDatabase();
    await _insertFakeData();
    await _loadChartData();
    _timer = Timer.periodic(const Duration(hours: 24), (timer) {
      _saveDataToDatabase();
    });
  }

  Future<void> _initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'weather_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE weather_data(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, temperature REAL, humidity REAL, lux REAL)',
        );
      },
      version: 1,
    );
  }

  void _initData() {
    temp.onValue.listen((event) {
      var data = event.snapshot.value;
      setState(() {
        temperature = double.parse(data.toString());
      });
    });
    humi.onValue.listen((event) {
      var data = event.snapshot.value;
      setState(() {
        humidity = double.parse(data.toString());
      });
    });
    light.onValue.listen((event) {
      var data = event.snapshot.value;
      setState(() {
        lux = double.parse(data.toString());
      });
    });
  }

  Future<void> _saveDataToDatabase() async {
    await _database.insert(
      'weather_data',
      {
        'temperature': temperature,
        'humidity': humidity,
        'lux': lux,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _loadChartData();
  }

  Future<void> _insertFakeData() async {
    await _database.delete('weather_data');

    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd');
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      await _database.insert(
        'weather_data',
        {
          'date': dateFormat.format(date),
          'temperature': 20 + Random().nextInt(15),
          'humidity': 40 + Random().nextInt(41),
          'lux': 100 + Random().nextInt(901),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> _loadChartData() async {
    final List<Map<String, dynamic>> maps =
        await _database.query('weather_data', orderBy: 'date DESC');
    setState(() {
      _chartData = List.generate(maps.length, (i) {
        return WeatherData(
          DateFormat('yyyy-MM-dd').parse(maps[i]['date']),
          maps[i]['temperature'],
          maps[i]['humidity'],
          maps[i]['lux'],
        );
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timer.cancel();
    _database.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Nhiệt độ'),
            Tab(text: 'Độ ẩm'),
            Tab(text: 'Cường độ ánh sáng'),
            Tab(text: 'Biểu đồ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTemperatureGauge(),
          _buildHumidityGauge(),
          _buildLightIntensityGauge(),
          _buildChart()
        ],
      ),
    );
  }

  Widget _buildChart() {
    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        title: AxisTitle(text: 'Ngày'),
        dateFormat: DateFormat('dd/MM'),
        intervalType: DateTimeIntervalType.days,
        interval: 1,
      ),
      primaryYAxis: NumericAxis(title: AxisTitle(text: 'Giá trị')),
      legend: Legend(isVisible: true, position: LegendPosition.bottom),
      tooltipBehavior: TooltipBehavior(enable: true),
      zoomPanBehavior: ZoomPanBehavior(
        enablePinching: true,
        enableDoubleTapZooming: true,
        enablePanning: true,
      ),
      series: [
        LineSeries<WeatherData, DateTime>(
          name: 'Nhiệt độ (°C)',
          dataSource: _chartData,
          xValueMapper: (WeatherData weather, _) => weather.time,
          yValueMapper: (WeatherData weather, _) => weather.temperature,
          color: Colors.red,
        ),
        LineSeries<WeatherData, DateTime>(
          name: 'Độ ẩm (%)',
          dataSource: _chartData,
          xValueMapper: (WeatherData weather, _) => weather.time,
          yValueMapper: (WeatherData weather, _) => weather.humidity,
          color: Colors.blue,
        ),
        LineSeries<WeatherData, DateTime>(
          name: 'Ánh sáng (lx)',
          dataSource: _chartData,
          xValueMapper: (WeatherData weather, _) => weather.time,
          yValueMapper: (WeatherData weather, _) => weather.lux,
          color: Colors.yellow,
        ),
      ],
    );
  }

  Widget _buildTemperatureGauge() {
    return Center(
      child: SfRadialGauge(
        title: const GaugeTitle(
          text: 'Nhiệt độ',
          textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        axes: <RadialAxis>[
          RadialAxis(minimum: -20, maximum: 50, ranges: <GaugeRange>[
            GaugeRange(startValue: -20, endValue: 0, color: Colors.blue),
            GaugeRange(startValue: 0, endValue: 20, color: Colors.green),
            GaugeRange(startValue: 20, endValue: 35, color: Colors.orange),
            GaugeRange(startValue: 35, endValue: 50, color: Colors.red),
          ], pointers: <GaugePointer>[
            NeedlePointer(value: temperature),
          ], annotations: <GaugeAnnotation>[
            GaugeAnnotation(
                widget: Container(
                  child: Text(
                    '${temperature.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
                angle: 90,
                positionFactor: 0.5)
          ])
        ],
      ),
    );
  }

  Widget _buildHumidityGauge() {
    return Center(
      child: SfRadialGauge(
        title: const GaugeTitle(
          text: 'Độ ẩm',
          textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        axes: <RadialAxis>[
          RadialAxis(minimum: 0, maximum: 100, ranges: <GaugeRange>[
            GaugeRange(startValue: 0, endValue: 30, color: Colors.red),
            GaugeRange(startValue: 30, endValue: 60, color: Colors.orange),
            GaugeRange(startValue: 60, endValue: 100, color: Colors.blue),
          ], pointers: <GaugePointer>[
            RangePointer(
              value: humidity,
              width: 0.2,
              sizeUnit: GaugeSizeUnit.factor,
              gradient: SweepGradient(
                  colors: [Colors.blue[50]!, Colors.blue], stops: [0.25, 0.75]),
            ),
            MarkerPointer(value: humidity)
          ], annotations: <GaugeAnnotation>[
            GaugeAnnotation(
                widget: Container(
                  child: Text(
                    '${humidity.toStringAsFixed(1)}%',
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
                angle: 90,
                positionFactor: 0.5)
          ])
        ],
      ),
    );
  }

  Widget _buildLightIntensityGauge() {
    return Center(
      child: SfRadialGauge(
        title: const GaugeTitle(
          text: 'Cường độ ánh sáng',
          textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        axes: <RadialAxis>[
          RadialAxis(minimum: 0, maximum: 1000, ranges: <GaugeRange>[
            GaugeRange(startValue: 0, endValue: 300, color: Colors.red),
            GaugeRange(startValue: 300, endValue: 600, color: Colors.orange),
            GaugeRange(startValue: 600, endValue: 1000, color: Colors.yellow),
          ], pointers: <GaugePointer>[
            NeedlePointer(value: lux),
          ], annotations: <GaugeAnnotation>[
            GaugeAnnotation(
                widget: Container(
                  child: Text(
                    '${lux.toStringAsFixed(1)} lx',
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
                angle: 90,
                positionFactor: 0.5)
          ])
        ],
      ),
    );
  }
}
