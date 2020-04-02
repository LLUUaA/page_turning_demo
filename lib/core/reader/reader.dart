import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import './page_turning/simulation.dart' as simulation;
import './page_turning/cover.dart' as cover;

/// 支持翻页类型
enum PAGE_TURNING_TYPE { SIMULATION, SLIDE, COVER }

class MyReader extends StatefulWidget {
  @override
  _MyReader createState() => _MyReader();
}

class _MyReader extends State<MyReader> {
  _MyReader() {
    /// SystemChrome
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarDividerColor: Colors.black,
    ));

    this._init();
  }
  PAGE_TURNING_TYPE curType;
  Offset offset = Offset.zero; // move offset
  Size viewSize;
  Widget _widget;

  @override
  void initState() {
    super.initState();
  }

  void _init() {
    curType = PAGE_TURNING_TYPE.COVER;
    Size physicalSize = window.physicalSize;
    double pixdelRatio = window.devicePixelRatio;
    viewSize = Size(
        physicalSize.width / pixdelRatio, physicalSize.height / pixdelRatio);
  }

  @override
  Widget build(BuildContext context) {
    switch (curType) {
      case PAGE_TURNING_TYPE.SIMULATION:
        _widget = this._getSimutationWidget();
        break;
      case PAGE_TURNING_TYPE.SLIDE:
        _widget = this._getSlideWidget();
        break;
      case PAGE_TURNING_TYPE.COVER:
        _widget = this._getCoverWidget();
        break;
      default:
    }
    return _widget;
  }

  /// 仿真翻页widget
  Widget _getSimutationWidget() {
    return GestureDetector(
      onPanDown: (DragDownDetails _) {
        simulation.Simulation.handlePanDown(_);
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
        size: viewSize,
        painter: simulation.Simulation(offset: offset),
      ),
    );
  }

  /// 滚动翻页widget
  Widget _getSlideWidget() {
    return Container(
      child: Text('Slide Widget'),
    );
  }

  /// 覆盖翻页widget
  Widget _getCoverWidget() {
    return GestureDetector(
      onPanDown: (DragDownDetails _) {
        // simulation.Simulation.handlePanDown(_);
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
        size: viewSize,
        painter: cover.Cover(offset: offset),
      ),
    );
  }
}
