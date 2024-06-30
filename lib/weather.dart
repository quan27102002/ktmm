import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class WeatherDashboard extends StatelessWidget {
  final double temperature;
  final double humidity;

  const WeatherDashboard({
    super.key,
    required this.temperature,
    required this.humidity,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin thời tiết'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SfRadialGauge(
              title: GaugeTitle(text: 'Nhiệt độ'),
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: -20,
                  maximum: 50,
                  ranges: <GaugeRange>[
                    GaugeRange(startValue: -20, endValue: 0, color: Colors.blue),
                    GaugeRange(startValue: 0, endValue: 20, color: Colors.green),
                    GaugeRange(startValue: 20, endValue: 50, color: Colors.red),
                  ],
                  pointers: <GaugePointer>[
                    NeedlePointer(value: temperature),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Text(
                        '${temperature.toStringAsFixed(1)}°C',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      angle: 90,
                      positionFactor: 0.5,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            SfRadialGauge(
              title: GaugeTitle(text: 'Độ ẩm'),
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: 100,
                  ranges: <GaugeRange>[
                    GaugeRange(startValue: 0, endValue: 30, color: Colors.red),
                    GaugeRange(startValue: 30, endValue: 70, color: Colors.green),
                    GaugeRange(startValue: 70, endValue: 100, color: Colors.blue),
                  ],
                  pointers: <GaugePointer>[
                    NeedlePointer(value: humidity),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Text(
                        '${humidity.toStringAsFixed(1)}%',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      angle: 90,
                      positionFactor: 0.5,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}