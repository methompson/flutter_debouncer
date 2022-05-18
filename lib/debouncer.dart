library debouncer;

import 'dart:async';

import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

class DebouncerException implements Exception {
  final String message;

  DebouncerException(this.message);

  @override
  String toString() {
    return message;
  }
}

class NoDebouncerFoundException extends DebouncerException {
  NoDebouncerFoundException(message) : super(message);
}

/// Provides a means to wait for an action to be activated a period of time
/// after the last input. [action] is the function that is run after the final
/// period of time has elapsed. [builder] is the input widget or widgets that are
/// acted upon and eventually executed the action. [timeout] is an optional
/// parameter that dictates how long the application ought to wait before
/// activating the action.
class Debouncer extends StatefulWidget {
  final Function() action;
  final Widget Function(BuildContext context, String debouncerKey) builder;
  final Duration timeout;
  final String debouncerKey;

  Debouncer({
    Key? key,
    required this.action,
    required this.builder,
    String? debouncerKey,
    Duration? timeout,
  })  : timeout = timeout ?? Duration(milliseconds: 500),
        debouncerKey = debouncerKey ?? Uuid().v4(),
        super(key: key);

  @override
  DebouncerState createState() => DebouncerState();

  /// Attempts to find and activate the action located in a parent widget to an
  /// input. [context] should be the BuildContext of a child widget to a
  /// Debouncer widget. [debouncerKey] is an optional key that can be used to
  /// find a specific Debouncer widget if multiple parent Debouncers exist.
  ///
  /// If there is no Debouncer widget parent, an Exception is thrown. If there
  /// are multiple Debouncer widget parents, but no debouncerKey is provided,
  /// this function activates the first Debouncer it finds.
  static execute(BuildContext context, {String? debouncerKey}) {
    // Get a debouncer state for the context passed in.
    final el = _getDebouncerStateWidget(context);
    DebouncerState? elToExecute;

    if (el != null &&
        debouncerKey != null &&
        el.widget.debouncerKey == debouncerKey) {
      // Set elToExecute to the current found value.
      elToExecute = el;
    } else if (el != null && debouncerKey == null) {
      // Set elToExecute to the current found value.
      elToExecute = el;
    } else {
      context.visitAncestorElements((parent) {
        // We use a local variable to work nicely with the scope
        final _el = _getDebouncerStateWidget(parent);

        if (_el != null &&
            debouncerKey != null &&
            _el.widget.debouncerKey == debouncerKey) {
          // Set elToExecute to the current found value.
          elToExecute = _el;
          return false;
        } else if (_el != null && debouncerKey == null) {
          // Set elToExecute to the current found value.
          elToExecute = _el;
          return false;
        }

        return true;
      });
    }

    if (elToExecute == null) {
      throw NoDebouncerFoundException('No Debouncer parent object present');
    }

    elToExecute?.execute();
  }

  static DebouncerState? _getDebouncerStateWidget(BuildContext context) {
    if (_isDebouncerWidget(context)) {
      // We have to type cast here
      final val = context as StatefulElement;
      return val.state as DebouncerState;
    }

    return null;
  }

  static _isDebouncerWidget(BuildContext context) =>
      context is StatefulElement &&
      context.widget is Debouncer &&
      context.state is DebouncerState;
}

class DebouncerState extends State<Debouncer> {
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.debouncerKey);
  }

  execute() {
    timer?.cancel();

    timer = Timer(widget.timeout, widget.action);
  }
}
