import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:firebase_database/firebase_database.dart';

class WeatherDashboard extends StatefulWidget {
  const WeatherDashboard({super.key});

  @override
  State<WeatherDashboard> createState() => _WeatherDashboardState();
}

class _WeatherDashboardState extends State<WeatherDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  DatabaseReference temp = FirebaseDatabase.instance.ref('/user').child('temp');
  DatabaseReference humi = FirebaseDatabase.instance.ref('/user').child('humi');
  DatabaseReference light = FirebaseDatabase.instance.ref('/user').child('lux');

  double temperature = 0;
  double humidity = 0;
  double lux = 0;

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

  @override
  void initState() {
    _initData();
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTemperatureGauge(),
          _buildHumidityGauge(),
          _buildLightIntensityGauge(),
        ],
      ),
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
