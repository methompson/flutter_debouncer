<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

# Debouncer

Simple Flutter Debounce Widget

## Features

Debouncer is an easy-to-use Widget that allows a user to make many changes to a form, but update only after the user stops making changes. This allows a form to automatically submit or update the state without a ton of costly request for every single change made.

* Debouncer can be used to control the actions for several inputs
* Multiple debouncers can be used in conjunction with each other for more complex interactions
* Debouncer can be used to remove the need for ui elements, such as save or confirmation buttons.

## Usage

You can use Debouncer like any other widget. The Debouncer widget controls the actions that you want to take once the user is done interacting with the form. The default timeout is 500 milliseconds, but any Duration can be used.

```dart
Debouncer(
  action: () {
    // Do something when the user is finished
  },
  builder: (newContext, _) => Column(
    children: [
      TextField(
        decoration: InputDecoration(
          label: Text("Text Input"),
        ),
        controller: TextEditingController(),
        onChanged: (_) {
          // Use the execute function to activate the
          // action after the timeout
          Debouncer.execute(newContext);
        },
      ),
    ],
  ),
);
```

## Advanced Usage

Debouncer also has support for controlling multiple form elements' actions with a single instance. An entire form can be the child of a single Debouncer Widget, with each form element calling the `Debouncer.execute` function to activate a debounce timeout.

Moreover, multiple Debouncers can be used in conjunction with each other. You can activate a specific debouncer using a key (either generated or provided) or organize the project such that a form activates the first Debouncer it finds in the Widget tree, which activates another Debouncer higher up the tree. A cascading debounce, if you will.

The [example project](example/lib/main.dart) provides several examples for using Debouncer in a standard Flutter project.