import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'SAIMMOD 4 33b'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final int nB = 2;
  final int m = 3;
  final int lambda = 12;
  final double mu = 5.7;
  final double muA = 11.4;
  final int nA = 1;

  double x = 0;
  double po = 0;
  double potkz = 0;
  double k = 0;
  double r = 0; // Loc -  среднее число завяок в очереди
  double z = 0; // Lc - среднее число завяок в системе
  double ts = 0; //Wc  - среднее время в системе
  double toc = 0; //Woc - среднее время в очереди
  double p_npm = 0; //Potkz - вероятность отказа

  double xA = 0;
  double poA = 0;
  double potkzA = 0;
  double kA = 0;
  double rA = 0; // Loc -  среднее число завяок в очереди
  double zA = 0; // Lc - среднее число завяок в системе
  double tsA = 0; //Wc  - среднее время в системе
  double tocA = 0; //Woc - среднее время в очереди
  double p_npmA = 0; //Potkz - вероятность отказа

  void calculate(int n, double mu) {
    po = lambda / mu;
    x = lambda / (n * mu);

    potkz = calcPotkz(n, po, x);

    p_npm = (pow(po, n + m) / (pow(n, m) * factorial(n))) * potkz;

    k = po * (1 - p_npm);
    r = (pow(po, n + 1) * potkz / (n * factorial(n))) *
        ((1 - (m + 1) * pow(x, m) + pow(x, m + 1) * m) / (pow(1 - x, 2)));
    z = r + k;

    toc = r / lambda;
    ts = z / lambda;
  }

  void calculateA(int n, double mu) {
    poA = lambda / mu;
    xA = lambda / (n * mu);

    potkzA = calcPotkz(n, poA, xA);

    p_npmA = (pow(poA, n + m) / (pow(n, m) * factorial(n))) * potkzA;

    kA = poA * (1 - p_npmA);
    rA = (pow(poA, n + 1) * potkzA / (n * factorial(n))) *
        ((1 - (m + 1) * pow(xA, m) + pow(xA, m + 1) * m) / (pow(1 - xA, 2)));
    zA = rA + kA;

    tocA = rA / lambda;
    tsA = zA / lambda;
  }

  double calcPotkz(int n, double po, double x) {
    double potkzTemp = 0;
    double sum = 1;
    for (int i = 1; i <= n; i++) {
      sum += (pow(po, i) / factorial(i));
    }
    double left = pow(po, n + 1) / (n * factorial(n));
    double right = ((1 - pow(x, m)) / (1 - x));
    sum += left * right;
    potkzTemp = 1 / sum;
    return potkzTemp;
  }

  int factorial(int k) {
    if (k < 0) {
      throw ArgumentError.value(k);
    }
    if (k == 0) {
      return 1;
    }
    var result = k;
    k--;
    while (k > 1) {
      result *= k;
      k--;
    }
    return result;
  }

  void setStateByCalculations() {
    setState(() {
      calculate(nB, mu);
      calculateA(nA, muA);
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Before:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'After:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [const Text("n:"), Text(nB.toString())],
                      ),
                      Row(
                        children: [const Text("m:"), Text(m.toString())],
                      ),
                      Row(
                        children: [
                          const Text("lambda:"),
                          Text(lambda.toString())
                        ],
                      ),
                      Row(
                        children: [const Text("mu:"), Text(mu.toString())],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [const Text("Loc(r):"), Text(r.toString())],
                      ),
                      Row(
                        children: [const Text("Lc(z):"), Text(z.toString())],
                      ),
                      Row(
                        children: [
                          const Text("Woc(toc):"),
                          Text(toc.toString())
                        ],
                      ),
                      Row(
                        children: [const Text("Wc(ts):"), Text(ts.toString())],
                      ),
                      Row(
                        children: [
                          const Text("Potkz(p_npm):"),
                          Text(p_npm.toString())
                        ],
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [const Text("n:"), Text(nA.toString())],
                      ),
                      Row(
                        children: [const Text("m:"), Text(m.toString())],
                      ),
                      Row(
                        children: [
                          const Text("lambda:"),
                          Text(lambda.toString())
                        ],
                      ),
                      Row(
                        children: [const Text("mu:"), Text(muA.toString())],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [const Text("Loc(r):"), Text(rA.toString())],
                      ),
                      Row(
                        children: [const Text("Lc(z):"), Text(zA.toString())],
                      ),
                      Row(
                        children: [
                          const Text("Woc(toc):"),
                          Text(tocA.toString())
                        ],
                      ),
                      Row(
                        children: [const Text("Wc(ts):"), Text(tsA.toString())],
                      ),
                      Row(
                        children: [
                          const Text("Potkz(p_npm):"),
                          Text(p_npmA.toString())
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () => setStateByCalculations(),
                  child: const Text('Calculate')),
            ],
          ),
        ),
      ),
    );
  }
}
