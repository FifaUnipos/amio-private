import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LineExample extends StatefulWidget {
  const LineExample({super.key});

  @override
  State<LineExample> createState() => _LineExampleState();
}

class _LineExampleState extends State<LineExample> {
  @override
  Widget build(BuildContext context) {
    final List<ChartData> chartData = <ChartData>[
      ChartData(2010, 10.53),
      ChartData(2011, 9.5),
      ChartData(2012, 10),
      ChartData(2013, 9.4),
      ChartData(2014, 5.8),
      ChartData(2015, 4.9),
    ];

    return Scaffold(
        body: Center(
            child: Expanded(
      child: Container(
          child: SfCartesianChart(series: <CartesianSeries>[
        SplineAreaSeries<ChartData, int>(
            dataSource: chartData,
            splineType: SplineType.cardinal,
            cardinalSplineTension: 0.9,
            xValueMapper: (ChartData data, _) => data.x,
            yValueMapper: (ChartData data, _) => data.y),
      ])),
    )));
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final int x;
  final double y;
}
