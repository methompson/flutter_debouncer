/// A Flutter widget that can debounce actions. Every time a debounced action
/// is called, the timer is reset. At the end of the timer, the action is
/// executed.
library debouncer_widget;

import 'dart:async';

import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

/// A custom exception to be thrown by this package. Makes it easy to determine
/// if an exception was thrown by this package.
class DebouncerException implements Exception {
  final String message;

  DebouncerException(this.message);

  @override
  String toString() {
    return message;
  }
}

/// An exception that is thrown when no Debouncer widget is found in the
/// widget tree.
class NoDebouncerFoundException extends DebouncerException {
  NoDebouncerFoundException(message) : super(message);
}

/// Provides a means to wait for an action to be activated a period of time
/// after the last input. [action] is the function that is run after the final
/// period of time has elapsed. [builder] is the input widget or widgets that are
/// acted upon and eventually executed the action. [timeout] is an optional
/// parameter that dictates how long the application ought to wait before
/// activating the action. [debouncerKey] is an optional parameter that can be
/// used to identify a specific Debouncer widget if multiple Debouncer widgets
/// are present in the widget tree.
class Debouncer extends StatefulWidget {
  /// The function that is run after the final period of time has elapsed.
  final Function() action;

  /// The builder function that returns a widget that will show the button or
  /// form that will eventually activate the action.
  final Widget Function(BuildContext context, String debouncerKey) builder;

  /// The time to wait before activating the action.
  final Duration timeout;

  /// A unique key to identify the Debouncer widget.
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

  /// Attempts to find the DebouncerState in a parent widget. [context] should
  /// be the BuildContext of a child widget to a Debouncer widget.
  /// [debouncerKey] is an optional key that can be used to find a specific
  /// Debouncer widget if multiple parent Debouncers exist.
  static DebouncerState? findDebouncerWidget(
    BuildContext context, {
    String? debouncerKey,
  }) {
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

    return elToExecute;
  }

  /// Attempts to find and activate the action located in a parent widget to an
  /// input. [context] should be the BuildContext of a child widget to a
  /// Debouncer widget. [debouncerKey] is an optional key that can be used to
  /// find a specific Debouncer widget if multiple parent Debouncers exist.
  ///
  /// If there is no Debouncer widget parent, an Exception is thrown. If there
  /// are multiple Debouncer widget parents, but no debouncerKey is provided,
  /// this function activates the first Debouncer it finds.
  static execute(BuildContext context, {String? debouncerKey}) {
    final elToExecute = Debouncer.findDebouncerWidget(
      context,
      debouncerKey: debouncerKey,
    );

    if (elToExecute == null) {
      throw NoDebouncerFoundException('No Debouncer parent object present');
    }

    elToExecute.execute();
  }

  /// Attempts to find and cancel the action located in a parent widget.
  /// [context] should be the BuildContext of a child widget to a Debouncer
  /// widget. [debouncerKey] is an optional key that can be used to find a
  /// specific Debouncer widget if multiple parent Debouncers exist.
  static cancel(BuildContext context, {String? debouncerKey}) {
    final elToExecute = Debouncer.findDebouncerWidget(
      context,
      debouncerKey: debouncerKey,
    );

    if (elToExecute == null) {
      throw NoDebouncerFoundException('No Debouncer parent object present');
    }

    elToExecute.cancel();
  }

  /// Type checks and type casts a BuildContext variable as a DebouncerState
  /// object. Returns null if the [context] is not a Debouncer widget.
  static DebouncerState? _getDebouncerStateWidget(BuildContext context) {
    if (_isDebouncerWidget(context)) {
      // We have to type cast here
      final val = context as StatefulElement;
      return val.state as DebouncerState;
    }

    return null;
  }

  // Type checks a BuildContext variable to see if it is a Debouncer widget.
  static _isDebouncerWidget(BuildContext context) =>
      context is StatefulElement &&
      context.widget is Debouncer &&
      context.state is DebouncerState;
}

/// The state of the Debouncer widget.
class DebouncerState extends State<Debouncer> {
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.debouncerKey);
  }

  /// Cancels the previous timer, and starts a new one to activate the action
  execute() {
    timer?.cancel();

    timer = Timer(widget.timeout, widget.action);
  }

  /// Cancels the current timer.
  cancel() {
    timer?.cancel();
  }
}
