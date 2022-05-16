library debouncer;

import 'dart:async';

import 'package:flutter/material.dart';

class Debouncer extends StatefulWidget {
  final Function() action;
  final Widget Function(BuildContext context) child;
  final Duration timeout;

  Debouncer({
    Key? key,
    required this.action,
    required this.child,
    Duration? timeout,
  })  : timeout = timeout ?? Duration(milliseconds: 500),
        super(key: key);

  @override
  DebouncerState createState() => DebouncerState();

  static execute(BuildContext context) {
    DebouncerState? el;

    if (context is StatefulElement &&
        context.widget is Debouncer &&
        context.state is DebouncerState) {
      // print('is debouncer and executing');
      el = context.state as DebouncerState;
    } else {
      context.visitAncestorElements((parent) {
        if (parent is StatefulElement &&
            parent.widget is Debouncer &&
            parent.state is DebouncerState) {
          el = parent.state as DebouncerState;
          return false;
        }

        return true;
      });
    }

    if (el == null) {
      throw Exception('No Debouncer parent object present');
    }

    el?.execute();
  }
}

class DebouncerState extends State<Debouncer> {
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    return widget.child(context);
  }

  execute() {
    timer?.cancel();

    timer = Timer(widget.timeout, widget.action);
  }
}
