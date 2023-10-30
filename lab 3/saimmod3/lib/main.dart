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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'State machine simulation V31'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String simulationSuccess = "Simulated succesfuly!";
  final String simulationFailed = "Simulatation failed!";
  final String noSimulation = "Run the simulation!";
  int successIndicator = -1;

  int aCounter = 0;
  double a = 0;

  int qCounter = 0;
  double q = 0;

  double potk = 0;

  int locLength = 0;
  double loc = 0;

  int lcLength = 0;
  double lc = 0;
  double woc = 0;
  double wc = 0;

//probabilites
  double aP = 0;
  double qP = 0;
  double potkP = 0;
  double locP = 0;
  double lcP = 0;
  double wocP = 0;
  double wcP = 0;

  final int generatorStep = 2;
  final int amountOfTacts = 100000;
  static const double pi1 = 0;
  static const double pi2 = 0;

  Map<String, List<String>> transitions = {
    '1000': ['2000'],
    '2100': ['1001', '1000'],
    '1001': ['2100', '2101'],
    '0100': ['1101', '0101', '1100', '0100'],
    '1011': ['2101', '2111'],
    '1100': ['2100', '2101'],
    '2101': ['1100', '1001', '1011', '1101', '0100', '0101'],
    '1101': ['2101', '2111'],
    '0101': ['1101', '1111', '0111', '0101'],
    '2111': ['1111', '0111', '1101', '1011', '1021', '0101'],
    '0111': ['0121', '1121', '0111', '1111'],
    '1111': ['2121', '2111'],
    '2121': ['1121', '0111', '0121', '1111', '0121', '1021', '1121'],
    '1021': ['2121', '2111', '2121'],
    '1121': ['2121'],
    '0121': ['0121', '1121'],
  };

  final Map<String, double> stateProbabilities = {
    '2100': 0.05,
    '1001': 0.06,
    '0100': 0.1,
    '1011': 0.045,
    '1100': 0.04,
    '2101': 0.167,
    '1101': 0.043,
    '0101': 0.049,
    '2111': 0.12,
    '0111': 0.05,
    '1111': 0.034,
    '2121': 0.11,
    '1021': 0.102,
    '1121': 0.022,
    '0121': 0.014,
  };

  void simulateGenerator(Generator generator, Queue queue, Channel channelOne,
      Channel channelTwo) {
    //Generator
    if (generator.currentState == 0) {
      if (channelOne.state == false) {
        qCounter++;
        channelOne.state = true;
        generator.currentState = 2;
      }
    } else if (generator.currentState == 1) {
      if (!channelOne.state) {
        qCounter++;
        channelOne.state = true;

        generator.currentState = 2;
      } else {
        generator.currentState = 0;
      }
    } else if (generator.currentState == 2) {
      generator.currentState--;
    } else {
      throw ('Generator state overloaded!');
    }
  }

  void simulateChannelOne(
    Generator generator,
    Queue queue,
    Channel channelOne,
    Channel channelTwo,
  ) {
    if (channelOne.state) {
      int intValue = Random().nextInt(100);

      if (intValue <= channelOne.pi * 100) {
        //pi1
      } else {
        //(1-pi1)
        channelOne.state = false;
        //  if (generator.currentState == 0)
        //   simulateGenerator(generator, queue, channelOne, channelTwo);
        if (queue.capacity < 2) {
          if (channelTwo.state == false) {
            channelTwo.state = true;
          } else {
            queue.capacity++;
          }
        } else {
          //throw away
        }
      }
    } else {}
  }

  void simulateChannelTwo(Generator generator, Queue queue, Channel channelOne,
      Channel channelTwo) {
    if (channelTwo.state) {
      int intValue = Random().nextInt(100);

      if (intValue <= channelTwo.pi * 100) {
        //pi2
      } else {
        //(1-pi2)
        aCounter++;
        channelTwo.state = false;
        if (queue.capacity > 0) {
          channelTwo.state = true;
          queue.capacity--;
        }
      }
    }
  }

  String getState(Generator generator, Queue queue, Channel channelOne,
      Channel channelTwo) {
    String state = generator.currentState.toString() +
        (channelOne.state ? 1 : 0).toString() +
        queue.capacity.toString() +
        (channelTwo.state ? 1 : 0).toString();
    return state;
  }

  bool runSimulation(int amountOfTacts) {
    aCounter = 0;
    qCounter = 0;
    locLength = 0;
    lcLength = 0;

    String currentState = '2000';
    String prevState = '2000';
    bool korrektness = true;
    Generator generator = Generator(generatorStep);
    Queue queue = Queue();
    Channel channelOne = Channel(pi1);
    Channel channelTwo = Channel(pi2);

    for (int i = 0; i < amountOfTacts; i++) {
      //Channel2 -> Queue -> Channel1 -> Generato
      prevState = currentState;
      simulateChannelTwo(generator, queue, channelOne, channelTwo);
      simulateChannelOne(generator, queue, channelOne, channelTwo);
      simulateGenerator(generator, queue, channelOne, channelTwo);
      currentState = getState(generator, queue, channelOne, channelTwo);
      locLength += queue.capacity;
      lcLength += queue.capacity +
          (channelOne.state ? 1 : 0) +
          (channelTwo.state ? 1 : 0);
      // print(prevState + "-->" + currentState);
      if (transitions[currentState] == null) {
        korrektness = false;
        throw ('No such state! : $currentState, which get from: $prevState');
      } else {
        if (transitions[currentState]?.contains(prevState) == false) {
          // print('Transition from $prevState to $currentState is not possible.');
          korrektness = false;
        }
      }
    }
    a = aCounter / amountOfTacts;

    q = aCounter / qCounter;
    potk = 1 - q;
    loc = locLength / amountOfTacts;
    lc = lcLength / amountOfTacts;
    woc = locLength / qCounter;
    wc = lcLength / qCounter;

    return korrektness ? true : false;
  }

  void setStateBySimulation() {
    setState(() {
      successIndicator = runSimulation(amountOfTacts) ? 1 : 0;
      runProbabilitySimulation();
    });
  }

  void runProbabilitySimulation() {
    aP = (stateProbabilities['1001']! +
            stateProbabilities['1011']! +
            stateProbabilities['2101']! +
            stateProbabilities['1101']! +
            stateProbabilities['0101']! +
            stateProbabilities['2111']! +
            stateProbabilities['0111']! +
            stateProbabilities['1111']! +
            stateProbabilities['2121']! +
            stateProbabilities['1021']! +
            stateProbabilities['1121']! +
            stateProbabilities['0121']!) *
        (1 - pi2);

    final double lambda = 0.5 *
        (1.006 -
            stateProbabilities['0100']! +
            stateProbabilities['0101']! +
            stateProbabilities['0111']! +
            stateProbabilities['0121']!);

    qP = aP / lambda;

    potkP = 1 - qP;
    locP = stateProbabilities['0121']! * 2 +
        stateProbabilities['1121']! * 2 +
        stateProbabilities['2121']! * 2 +
        stateProbabilities['1021']! * 2 +
        stateProbabilities['0111']! * 1 +
        stateProbabilities['1111']! * 1 +
        stateProbabilities['2111']! * 1;

    lcP = stateProbabilities['0121']! * 4 +
        stateProbabilities['1121']! * 4 +
        stateProbabilities['2121']! * 4 +
        stateProbabilities['1021']! * 3 +
        stateProbabilities['0111']! * 3 +
        stateProbabilities['1111']! * 3 +
        stateProbabilities['2111']! * 3 +
        stateProbabilities['0100']! * 1 +
        stateProbabilities['1100']! * 1 +
        stateProbabilities['2101']! * 2 +
        stateProbabilities['1101']! * 2 +
        stateProbabilities['0101']! * 2 +
        stateProbabilities['2100']! * 1 +
        stateProbabilities['1011']! * 2 +
        stateProbabilities['1001']! * 1;

    wocP = locP / lambda;
    wcP = lcP / lambda;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Status: "),
              Text(successIndicator == 1
                  ? simulationSuccess
                  : successIndicator == 0
                      ? simulationFailed
                      : noSimulation),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Column(
            children: [
              const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Calculated:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Simulated:',
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
                        children: [const Text("A:"), Text(aP.toString())],
                      ),
                      Row(
                        children: [const Text("Q:"), Text(qP.toString())],
                      ),
                      Row(
                        children: [
                          const Text("Potkz:"),
                          Text(potkP.toString())
                        ],
                      ),
                      Row(
                        children: [const Text("Loc:"), Text(locP.toString())],
                      ),
                      Row(
                        children: [const Text("Lc:"), Text(lcP.toString())],
                      ),
                      Row(
                        children: [const Text("Woc:"), Text(wocP.toString())],
                      ),
                      Row(
                        children: [const Text("Wc:"), Text(wcP.toString())],
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [const Text("A:"), Text(a.toString())],
                      ),
                      Row(
                        children: [const Text("Q:"), Text(q.toString())],
                      ),
                      Row(
                        children: [const Text("Potkz:"), Text(potk.toString())],
                      ),
                      Row(
                        children: [const Text("Loc:"), Text(loc.toString())],
                      ),
                      Row(
                        children: [const Text("Lc:"), Text(lc.toString())],
                      ),
                      Row(
                        children: [const Text("Woc:"), Text(woc.toString())],
                      ),
                      Row(
                        children: [const Text("Wc:"), Text(wc.toString())],
                      )
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
              onPressed: () => setStateBySimulation(),
              child: const Text('Calculate')),
        ],
      ),
    );
  }
}

class Generator {
  int generationStep = 0;
  int currentState = 0;

  Generator(int gS) {
    generationStep = gS;
    currentState = gS;
  }
  int generateNewRequest() {
    return 1;
  }
}

class Queue {
  final int maxCapacity = 2;
  int capacity = 0;
}

class Channel {
  bool state = false;
  double pi = 0;

  Channel(double pi1) {
    pi = pi1;
  }
}
