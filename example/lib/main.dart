import 'package:flutter/material.dart';

import 'package:debouncer/debouncer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ExampleContainer(title: 'Parent Widget', child: _SliderExample2()),
            _ExampleContainer(
              title:
                  'Container Widget With Multiple Values Using the Same Debounce',
              child: _SliderContainer(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExampleContainer extends StatelessWidget {
  final String title;
  final Widget child;

  _ExampleContainer({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyText1?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      child,
    ]);
  }
}

class _SliderContainer extends StatefulWidget {
  @override
  _SliderContainerState createState() => _SliderContainerState();
}

class _SliderContainerState extends State<_SliderContainer> {
  bool saved = true;

  @override
  Widget build(BuildContext context) {
    return Debouncer(
      action: saveData,
      timeout: Duration(seconds: 1),
      child: (_) => Column(
        children: [
          Text('Data Saved: $saved'),
          _SliderExample1(parentAction: setData),
          _SliderExample1(parentAction: setData),
        ],
      ),
    );
  }

  setData() {
    setState(() {
      saved = false;
    });
  }

  saveData() {
    setState(() {
      saved = true;
    });
  }
}

class _SliderExample1 extends StatefulWidget {
  final Function() parentAction;

  _SliderExample1({required this.parentAction});

  @override
  _SliderExample1State createState() => _SliderExample1State();
}

class _SliderExample1State extends State<_SliderExample1> {
  double _currentSliderValue = 20;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Current Value: ${_currentSliderValue.toStringAsFixed(2)}'),
        Slider(
          value: _currentSliderValue,
          max: 100,
          divisions: 1000,
          label: _currentSliderValue.round().toString(),
          onChanged: (double value) {
            widget.parentAction();

            setState(() {
              _currentSliderValue = value;
            });

            Debouncer.execute(context);
          },
        ),
      ],
    );
  }
}

class _SliderExample2 extends StatefulWidget {
  @override
  _SliderExample2State createState() => _SliderExample2State();
}

class _SliderExample2State extends State<_SliderExample2> {
  double _currentSliderValue = 20;
  bool saved = true;

  @override
  Widget build(BuildContext context) {
    return Debouncer(
      action: saveData,
      child: (_context) => Column(
        children: [
          Text('Saved: $saved'),
          Text('Current Value: ${_currentSliderValue.toStringAsFixed(2)}'),
          Slider(
            value: _currentSliderValue,
            max: 100,
            divisions: 1000,
            label: _currentSliderValue.round().toString(),
            onChanged: (double value) {
              setState(() {
                saved = false;
                _currentSliderValue = value;
              });

              Debouncer.execute(_context);
            },
          ),
        ],
      ),
    );
  }

  saveData() {
    setState(() {
      saved = true;
    });
  }
}
