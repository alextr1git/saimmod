import 'package:flutter/material.dart';
import 'package:lw_1/divider_widget.dart';
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
  TextEditingController aController = TextEditingController();
  TextEditingController r0Controller = TextEditingController();
  TextEditingController mController = TextEditingController();
  TextEditingController auController = TextEditingController();
  TextEditingController buontroller = TextEditingController();
  TextEditingController mxController = TextEditingController();
  TextEditingController sdController = TextEditingController();
  TextEditingController lyController = TextEditingController();
  TextEditingController nyController = TextEditingController();
  TextEditingController buController = TextEditingController();

  final int n = 100000;

  double mathExp = 0;
  double dispersion = 0;
  double standardDeviation = 0;
  double ly = 0;
  double ny = 0;
  int periodLength = 0;
  int apereodicInterval = 0;
  bool istriangleMin = false;
  bool isLehmersAlgorithm = false;
  int a = 0;
  int b = 0;
  int m = 0;
  int r0 = 0;
  double au = 0;
  double bu = 0;
  double rn_1 = 0;
  double rn = 0;

  List<double> numbers = [];
  List<DiagramData> chartData = [];

  void calculate(int selectedMethod) {
    numbers = [];
    a = int.tryParse(aController.text) ?? 0;
    rn = double.tryParse(r0Controller.text) ?? 1;
    m = int.tryParse(mController.text) ?? 0;
    isLehmersAlgorithm = false;
    switch (selectedMethod) {
      case 1:
        isLehmersAlgorithm = true;
        break;
      case 2: //uniform distribution
        au = double.tryParse(auController.text) ?? 1;
        bu = double.tryParse(buController.text) ?? 1;
        break;
      case 3: //gaussian distribution
        standardDeviation = double.tryParse(sdController.text) ?? 1;
        mathExp = double.tryParse(mxController.text) ?? 1;
        break;
      case 4: //exponential distribution
        ly = double.tryParse(lyController.text) ?? 1;
        break;
      case 5:
        //gamma distribution
        ly = double.tryParse(lyController.text) ?? 1;
        ny = double.tryParse(nyController.text) ?? 1;
        break;
      case 6:
        //triangle distribution
        au = double.tryParse(auController.text) ?? 1;
        bu = double.tryParse(buController.text) ?? 1;
        break;
      case 7:
        //simpson distribution
        au = double.tryParse(auController.text) ?? 1;
        bu = double.tryParse(buController.text) ?? 1;
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
        return roundDouble(uniformDistribution(), 6);
      case 3:
        return roundDouble(gaussianDistribution(), 6);
      case 4:
        return roundDouble(exponentialDistribution(), 6);
      case 5:
        return roundDouble(gammaDistribution(), 6);
      //gamma
      case 6:
        //triangle
        return roundDouble(triangleDistribution(), 6);
      case 7:
        //simpson
        return roundDouble(simpsonDistribution(), 6);
      default:
        return 0;
    }
  }

  void calculateExtras(int selectedDistribution) {
    switch (selectedDistribution) {
      case 1:
        lehmersAlgorithmExtras();
        periodLength = getPeriodLength();
        apereodicInterval = getApereodicInterval();
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
        triangleDistribution();
        break;
      case 7:
        //simpson
        simpsonDistributionExtras();
        break;
      default:
        mathExp = 0;
        dispersion = 0;
        break;
    }
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
    return au + (bu - au) * r1;
  }

  void uniformDistributionExtras() {
    mathExp = (au + bu) / 2;
    dispersion = (bu - au) * (bu - au) / 12;
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
      x = au + (bu - au) * min(r1, r2);
    } else {
      x = au + (bu - au) * max(r1, r2);
    }
    return x;
  }

  void triangleDistributionExtras() {
    lehmersAlgorithmExtras();
  }

  double roundDouble(double value, int places) {
    double mod = pow(10.0, places) as double;
    return ((value * mod).round().toDouble() / mod);
  }

  double simpsonDistribution() {
    double r1 = lehmersAlgorithm();
    double r2 = lehmersAlgorithm();
    return (max(au, bu) - min(au, bu)) * (r1 + r2) / 2 + au;
  }

  void simpsonDistributionExtras() {
    lehmersAlgorithmExtras();
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
                    "Lemer's generator",
                  ),
                  TextField(
                    controller: aController..text = "52583",
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Enter Lehmers "a"'),
                  ),
                  TextField(
                    controller: mController..text = "51913",
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Enter Lehmers "m"'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: r0Controller..text = "1",
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Enter "R0"'),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                    onPressed: () => calculate(1),
                    child: const Text('Lehmers'),
                  ),
                  TextField(
                    controller: auController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Enter "a"'),
                  ),
                  TextField(
                    controller: buController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Enter "b"'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => calculate(2),
                        child: const Text('Uniform'),
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => calculate(6),
                            child: const Text('Triangle'),
                          ),
                          Column(
                            children: [
                              Checkbox(
                                  value: istriangleMin,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      istriangleMin = value!;
                                    });
                                  }),
                              const Text(
                                'min',
                              )
                            ],
                          )
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => calculate(7),
                        child: const Text('Simpson'),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextField(
                    controller: mxController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Enter "mx"'),
                  ),
                  TextField(
                    controller: sdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Enter "sd"'),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                    onPressed: () => calculate(3),
                    child: const Text('Gaussian'),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextField(
                    controller: lyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Enter "ly"'),
                  ),
                  TextField(
                    controller: nyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Enter "ny"'),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => calculate(4),
                            child: const Text('Exponential'),
                          ),
                          ElevatedButton(
                            onPressed: () => calculate(5),
                            child: const Text('Gamma'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Math Expectation: $mathExp'),
                  Text('Dispersion: $dispersion'),
                  Text('Standard Deviation: $standardDeviation'),
                  if (isLehmersAlgorithm)
                    Column(
                      children: [
                        Text('Period Length: $periodLength'),
                        Text('Apereodic Interval: $apereodicInterval'),
                      ],
                    ),
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
