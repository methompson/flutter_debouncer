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
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'Debouncer Demo'),
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
        child: FractionallySizedBox(
          widthFactor: 0.9,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ExampleContainer(
                  title: 'Text Boxes Sharing a Debouncer',
                  child: _TextExample()),
              _ExampleContainer(
                  title: 'Parent Widget', child: _SliderExample2()),
              _ExampleContainer(
                title: 'Multiple Sliders Sharing a Debouncer',
                child: _SliderContainer(),
              ),
              _ExampleContainer(
                title: 'Multiple Debouncers',
                child: _MultiDebouncer(),
              ),
            ],
          ),
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
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
        ],
      ),
    );
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
      builder: (_, __) => Column(
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
      builder: (newContext, _) => Column(
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

              Debouncer.execute(newContext);
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

class _TextExample extends StatefulWidget {
  @override
  _TextExampleState createState() => _TextExampleState();
}

class _TextExampleState extends State<_TextExample> {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  bool saved = true;

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Debouncer(
      action: saveData,
      timeout: Duration(seconds: 2),
      builder: (newContext, _) => Column(
        children: [
          Text('Saved: $saved'),
          TextField(
            decoration: InputDecoration(
              label: Text("Text Input 1"),
            ),
            controller: _controller1,
            onChanged: (_) {
              setState(() {
                saved = false;
              });

              Debouncer.execute(newContext);
            },
          ),
          TextField(
            decoration: InputDecoration(
              label: Text("Text Input 2"),
            ),
            controller: _controller2,
            onChanged: (_) {
              setState(() {
                saved = false;
              });

              Debouncer.execute(newContext);
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

class _MultiDebouncer extends StatefulWidget {
  @override
  _MultiDebouncerState createState() => _MultiDebouncerState();
}

class _MultiDebouncerState extends State<_MultiDebouncer> {
  bool saved = true;
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Debouncer(
      action: saveData,
      builder: (_, theKey) => Debouncer(
        action: () {
          // Does Nothing
        },
        builder: (newContext, _) => Column(
          children: [
            Text('Saved: $saved'),
            TextField(
              decoration: InputDecoration(
                label: Text("Text Input"),
              ),
              controller: _controller,
              onChanged: (_) {
                setState(() {
                  saved = false;
                });

                Debouncer.execute(newContext, debouncerKey: theKey);
              },
            ),
          ],
        ),
      ),
    );
  }

  saveData() {
    setState(() {
      saved = true;
    });
  }
}
