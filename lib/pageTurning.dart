import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import './core/reader/reader.dart';

class PageTurningDemo1 extends StatefulWidget {
  @override
  _PageTurningDemo1 createState() => _PageTurningDemo1();
}

class _PageTurningDemo1 extends State<PageTurningDemo1> {
  _PageTurningDemo1() {
    /// SystemChrome
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarDividerColor: Colors.black,
    ));
  }

  Offset offset = Offset.zero; // move offset

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onPanDown: (DragDownDetails _) {
        MyReader.handlePanDown(_, size);
      },
      onPanUpdate: (DragUpdateDetails _) {
        setState(() {
          offset = _.globalPosition;
        });
      },
      onPanEnd: (DragEndDetails _) {
        setState(() {
          offset = Offset.zero;
        });
      },
      child: CustomPaint(
        size: size,
        painter: MyReader(offset: offset),
      ),
    );
  }
}
