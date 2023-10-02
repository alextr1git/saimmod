import 'package:flutter/material.dart';
import 'dart:math';

import 'package:syncfusion_flutter_charts/charts.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Number Distribution',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //lemers section
  TextEditingController aController = TextEditingController();
  TextEditingController r0Controller = TextEditingController();
  TextEditingController mController = TextEditingController();
  TextEditingController nController = TextEditingController();
  TextEditingController mxController = TextEditingController();
  TextEditingController sdController = TextEditingController();
  TextEditingController lyController = TextEditingController();
  TextEditingController nyController = TextEditingController();

  //uniform section
  TextEditingController buController = TextEditingController();

  double mathExp = 0;
  double dispersion = 0;
  double standardDeviation = 0;
  double ly = 0;
  double ny = 0;
  int periodLength = 0;
  int apereodicInterval = 0;
  bool istriangleMin = false;

  int a = 0;
  int b = 0;
  int m = 0;
  int r0 = 0;

  double rn_1 = 0;
  double rn = 0;

  final int n = 1000000;

  List<double> numbers = [];
  List<DiagramData> chartData = [];

  void calculate(int selectedMethod) {
    numbers = [];
    a = int.tryParse(aController.text) ?? 0;
    rn = double.tryParse(r0Controller.text) ?? 1;
    m = int.tryParse(mController.text) ?? 0;
    switch (selectedMethod) {
      case 2: //uniform distribution
        standardDeviation = double.tryParse(sdController.text) ?? 1;
        mathExp = double.tryParse(mxController.text) ?? 1;
        break;
      case 3:
        standardDeviation = double.tryParse(sdController.text) ?? 1;
        mathExp = double.tryParse(mxController.text) ?? 1;
        break;
      case 4:
        ly = double.tryParse(lyController.text) ?? 1;
        break;
      case 5:
        //gamma
        ly = double.tryParse(lyController.text) ?? 1;
        ny = double.tryParse(lyController.text) ?? 1;
        break;
      case 6:
        //triangle
        break;
      case 7:
        //tompson
        break;
      default:
        break;
    }
    //get sequence by following distribution law
    for (int i = 0; i < n; i++) {
      numbers.add(getRandomNumber(selectedMethod));
    }

    setState(() {
      calculateExtras(selectedMethod);
      buildHistogram();
    });
  }

  double getRandomNumber(selectedMethod) {
    switch (selectedMethod) {
      case 1:
        return roundDouble(lehmersAlgorithm(), 6);
      case 2:
        return roundDouble(uniformDistribution(), 5);
      case 3:
        return roundDouble(gaussianDistribution(), 5);
      case 4:
        return roundDouble(exponentialDistribution(), 5);
      case 5:
        return roundDouble(gammaDistribution(), 5);
      //gamma
      case 6:
        //triangle
        return roundDouble(triangleDistribution(), 5);

      case 7:
        //simpson
        return roundDouble(simpsonDistribution(), 5);

      default:
        return 0;
    }
  }

  void calculateExtras(int selectedDistribution) {
    switch (selectedDistribution) {
      case 1:
        lehmersAlgorithmExtras();
        break;
      case 2:
        uniformDistributionExtras();
        break;
      case 3:
        dispersion = getDispersion();
        break;
      case 4:
        exponentialDistributionExtras();
        break;
      case 5:
        //gamma
        gammaDistributionExtras();
        break;
      case 6:
        //triangle
        lehmersAlgorithmExtras();
        break;
      case 7:
        //simpson
        lehmersAlgorithmExtras();
        break;
      default:
        mathExp = 0;
        dispersion = 0;
        break;
    }

    periodLength = getPeriodLength();
    apereodicInterval = getApereodicInterval();
  }

  void buildHistogram() {
    chartData = [];
    for (int j = 0; j < numbers.length; j++) {
      chartData.add(DiagramData(numbers[j]));
    }
  }

  double getMathExp() {
    double sum = 0;
    for (int j = 0; j < numbers.length; j++) {
      sum += numbers[j];
    }
    return sum / numbers.length;
  }

  double getDispersion() {
    double dispSum = 0;
    for (int j = 0; j < numbers.length; j++) {
      dispSum += pow((numbers[j] - mathExp), 2) as double;
    }

    return roundDouble(dispSum / numbers.length, 2);
  }

  int getPeriodLength() {
    int xi1 = 0;
    int xi2 = 0;
    double xLast = numbers[numbers.length - 1];
    for (int j = 0; j < numbers.length; j++) {
      if (numbers[j] == xLast) {
        xi1 = j;
        break;
      }
    }
    for (int j = xi1 + 1; j < numbers.length; j++) {
      if (numbers[j] == xLast) {
        xi2 = j;
        break;
      }
    }

    return xi2 - xi1;
  }

  int getApereodicInterval() {
    int i3 = 0;
    for (int j = 0; j < numbers.length - periodLength; j++) {
      if (numbers[j] != numbers[j + periodLength]) {
        i3++;
      } else {
        break;
      }
    }
    return i3 + periodLength;
  }

  double lehmersAlgorithm() {
    rn_1 = rn;
    rn = (a * rn_1) % m;
    return rn / m;
  }

  void lehmersAlgorithmExtras() {
    mathExp = getMathExp();
    dispersion = getDispersion();
    standardDeviation = roundDouble(sqrt(dispersion), 2);
  }

  double uniformDistribution() {
    double r1 = lehmersAlgorithm();
    return a + (b - a) * r1;
  }

  void uniformDistributionExtras() {
    mathExp = (a + b) / 2;
    dispersion = (b - a) * (b - a) / 12;
    standardDeviation = roundDouble(sqrt(dispersion), 2);
  }

  double gaussianDistribution() {
    const int n = 12;
    List<double> r1 = [];
    double sum = 0;
    for (int i = 0; i < n; i++) {
      r1.add(lehmersAlgorithm());
    }
    for (int i = 0; i < r1.length; i++) {
      sum += r1[i];
    }

    return (mathExp + standardDeviation * (sum - 6));
  }

  double exponentialDistribution() {
    double r1 = lehmersAlgorithm();
    return (-1) * log(r1) / ly;
  }

  void exponentialDistributionExtras() {
    mathExp = 1 / ly;
    dispersion = mathExp * mathExp;
    standardDeviation = mathExp;
  }

  double gammaDistribution() {
    List<double> r1 = [];
    double sum = 0;
    for (int i = 0; i < ny; i++) {
      r1.add(lehmersAlgorithm());
    }

    for (int i = 0; i < ny; i++) {
      sum += log(r1[i]);
    }

    return (-1) * sum / ly;
  }

  void gammaDistributionExtras() {
    mathExp = ny / ly;
    dispersion = ny / (ly * ly);
  }

  double triangleDistribution() {
    double r1 = lehmersAlgorithm();
    double r2 = lehmersAlgorithm();
    double x = 0;
    if (istriangleMin) {
      x = a + (b - a) * min(r1, r2);
    } else {
      x = a + (b - a) * max(r1, r2);
    }
    return x;
  }

  void triangleDistributionExtras() {}

  double roundDouble(double value, int places) {
    double mod = pow(10.0, places) as double;
    return ((value * mod).round().toDouble() / mod);
  }

  double simpsonDistribution() {
    double r1 = lehmersAlgorithm();
    double r2 = lehmersAlgorithm();
    return (max(a, b) - min(a, b)) * (r1 + r2) / 2 + a;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Random Number Distribution'),
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "Lemer's distribution",
                  ),
                  TextField(
                    controller: aController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Enter "a"'),
                  ),
                  TextField(
                    controller: r0Controller..text = "1",
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Enter "R0"'),
                  ),
                  TextField(
                    controller: mController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Enter "m"'),
                  ),
                  TextField(
                    controller: mxController..text = "0",
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Enter "mx"'),
                  ),
                  TextField(
                    controller: sdController..text = "0.2",
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Enter "sd"'),
                  ),
                  TextField(
                    controller: lyController..text = "0.5",
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Enter "ly"'),
                  ),
                  TextField(
                    controller: nyController..text = "0.5",
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Enter "ny"'),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => calculate(1),
                            child: const Text('Lehmers'),
                          ),
                          ElevatedButton(
                            onPressed: () => calculate(2),
                            child: const Text('Uniform'),
                          ),
                          ElevatedButton(
                            onPressed: () => calculate(3),
                            child: const Text('Gaussian'),
                          ),
                          ElevatedButton(
                            onPressed: () => calculate(4),
                            child: const Text('Exponential'),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => calculate(5),
                            child: const Text('Gamma'),
                          ),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () => calculate(6),
                                child: const Text('Triangle'),
                              ),
                              Checkbox(
                                  value: istriangleMin,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      istriangleMin = value!;
                                    });
                                  }),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () => calculate(7),
                            child: const Text('Simpson'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Math Expectation: $mathExp'),
                  Text('Dispersion: $dispersion'),
                  Text('Standard Deviation: $standardDeviation'),
                  Text('Period Length: $periodLength'),
                  Text('Apereodic Interval: $apereodicInterval'),
                  if (numbers.isNotEmpty)
                    SfCartesianChart(series: <ChartSeries>[
                      HistogramSeries<DiagramData, double>(
                          dataSource: chartData,
                          yValueMapper: (DiagramData data, _) => data.value,
                          binInterval: 0.05,
                          showNormalDistributionCurve: true,
                          curveColor: const Color.fromRGBO(192, 108, 132, 1),
                          borderWidth: 3),
                    ]),
                  SizedBox(
                    height: 30,
                    child: Text('Sequence: $numbers'),
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}

class DiagramData {
  DiagramData(
    this.value,
  );
  final double value;
}
