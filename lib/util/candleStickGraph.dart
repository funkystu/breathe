import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

//From https://github.com/trentpiercy/flutter-candlesticks
//MIT License
//Copyright (c) 2018 Trent Piercy
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class CandleGraph extends StatelessWidget {
  CandleGraph({
    Key key,
    @required this.data,
    this.lineWidth = 1.0,
    this.fallbackHeight = 100.0,
    this.fallbackWidth = 300.0,
    this.gridLineColor = Colors.black38,
    this.gridLineAmount = 5,
    this.gridLineWidth = 0.5,
    this.gridLineLabelColor = Colors.black54,
    this.labelPostfix = "",
    @required this.enableGridLines,
    @required this.volumeProp,
  })  : assert(data != null),
        assert(lineWidth != null),
        super(key: key);

  /// OHLCV data to graph  /// List of Maps containing open, high, low, close and volumeto
  /// Example: [["open" : 40.0, "high" : 75.0, "low" : 25.0, "close" : 50.0, "volumeto" : 5000.0}, {...}]
  final List data;

  /// All lines in chart are drawn with this width
  final double lineWidth;

  /// Enable or disable grid lines
  final bool enableGridLines;

  /// Color of grid lines and label text
  final Color gridLineColor;
  final Color gridLineLabelColor;

  /// Number of grid lines
  final int gridLineAmount;

  /// Width of grid lines
  final double gridLineWidth;

  /// Proportion of paint to be given to volume bar graph
  final double volumeProp;

  /// If graph is given unbounded space,
  /// it will default to given fallback height and width
  final double fallbackHeight;
  final double fallbackWidth;

  /// Symbol prefix for grid line labels
  final String labelPostfix;

  @override
  Widget build(BuildContext context) {
    return new LimitedBox(
      maxHeight: fallbackHeight,
      maxWidth: fallbackWidth,
      child: new CustomPaint(
        size: Size.infinite,
        painter: new _CandleGraphPainter(
          data,
          lineWidth: lineWidth,
          gridLineColor: gridLineColor,
          gridLineAmount: gridLineAmount,
          gridLineWidth: gridLineWidth,
          gridLineLabelColor: gridLineLabelColor,
          enableGridLines: enableGridLines,
          volumeProp: volumeProp,
          labelPostfix: labelPostfix,
        ),
      ),
    );
  }
}

class _CandleGraphPainter extends CustomPainter {
  _CandleGraphPainter(
    this.data, {
    @required this.lineWidth,
    @required this.enableGridLines,
    @required this.gridLineColor,
    @required this.gridLineAmount,
    @required this.gridLineWidth,
    @required this.gridLineLabelColor,
    @required this.volumeProp,
    @required this.labelPostfix,
  });

  final List data;
  final double lineWidth;

  final bool enableGridLines;
  final Color gridLineColor;
  final int gridLineAmount;
  final double gridLineWidth;
  final Color gridLineLabelColor;
  final String labelPostfix;

  final double volumeProp;

  double _min;
  double _max;
  double _maxVolume;

  List<TextPainter> gridLineTextPainters = [];
  TextPainter maxVolumePainter;

  numCommaParse(number) {
    return number.round().toString().replaceAllMapped(
        new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},");
  }

  update() {
    _min = double.infinity;
    _max = -double.infinity;
    _maxVolume = -double.infinity;
    for (var i in data) {
      if (i["high"] > _max) {
        _max = i["high"].toDouble();
      }
      if (i["low"] < _min) {
        _min = i["low"].toDouble();
      }
      if (i["volumeto"] > _maxVolume) {
        _maxVolume = i["volumeto"].toDouble();
      }
    }

    if (enableGridLines) {
      double gridLineValue;
      for (int i = 0; i < gridLineAmount; i++) {
        // Label grid lines
        gridLineValue = _max - (((_max - _min) / (gridLineAmount - 1)) * i);
        Duration gridLineDuration =
            Duration(milliseconds: gridLineValue.floor());
        String gridLineText = gridLineDuration.toString().substring(2, 7);

        gridLineTextPainters.add(new TextPainter(
            text: new TextSpan(
                text: gridLineText + " " + labelPostfix,
                style: new TextStyle(
                    color: gridLineLabelColor,
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold)),
            textDirection: TextDirection.ltr));
        gridLineTextPainters[i].layout();
      }

      // Label volume line
      Duration maxVolumeDuration = Duration(milliseconds: _maxVolume.floor());
      maxVolumePainter = new TextPainter(
          text: new TextSpan(
              text: "+" +
                  maxVolumeDuration.toString().substring(
                      0, maxVolumeDuration.toString().lastIndexOf(".")),
              style: new TextStyle(
                  color: gridLineLabelColor,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold)),
          textDirection: TextDirection.ltr);
      maxVolumePainter.layout();
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_min == null || _max == null || _maxVolume == null) {
      update();
    }

    final double volumeHeight = size.height * volumeProp;
    final double volumeNormalizer = volumeHeight / _maxVolume;

    double width = size.width;
    if (enableGridLines) width = size.width - 36.0;

    final double height = size.height * (1 - volumeProp);
    final double heightNormalizer = height / (_max - _min);
    final double rectWidth = width / data.length;

    double rectLeft;
    double rectTop;
    double rectRight;
    double rectBottom;

    Paint rectPaint;

    // Loop through all data
    for (int i = 0; i < data.length; i++) {
      //ignore empty days.
      if (data[i]["open"] == 0 &&
          data[i]["close"] == 0 &&
          data[i]["high"] == 0 &&
          data[i]["low"] == 0) continue;
      rectLeft = (i * rectWidth) + lineWidth / 2;
      rectRight = ((i + 1) * rectWidth) - lineWidth / 2;

      double volumeBarTop = (height + volumeHeight) -
          (data[i]["volumeto"] * volumeNormalizer - lineWidth) +
          10.0;
      double volumeBarBottom = height + volumeHeight + 10.0;

      if (data[i]["open"] == data[i]["close"]) {
        rectBottom = height - (data[i]["open"] - _min) * heightNormalizer;
        rectTop = rectBottom + 1;
        rectPaint = new Paint()
          ..color = Colors.green
          ..strokeWidth = lineWidth;
        Rect ocRect =
            new Rect.fromLTRB(rectLeft, rectTop, rectRight, rectBottom);
        canvas.drawRect(ocRect, rectPaint);

        // Draw volume bars
        Rect volumeRect = new Rect.fromLTRB(
            rectLeft, volumeBarTop, rectRight, volumeBarBottom);
        canvas.drawRect(volumeRect, rectPaint);
      } else if (data[i]["open"] > data[i]["close"]) {
        // Draw candlestick if decrease
        rectTop = height - (data[i]["open"] - _min) * heightNormalizer;
        rectBottom = height - (data[i]["close"] - _min) * heightNormalizer;
        rectPaint = new Paint()
          ..color = Colors.red
          ..strokeWidth = lineWidth;

        Rect ocRect =
            new Rect.fromLTRB(rectLeft, rectTop, rectRight, rectBottom);
        canvas.drawRect(ocRect, rectPaint);

        // Draw volume bars
        Rect volumeRect = new Rect.fromLTRB(
            rectLeft, volumeBarTop, rectRight, volumeBarBottom);
        canvas.drawRect(volumeRect, rectPaint);
      } else {
        // Draw candlestick if increase
        rectTop = (height - (data[i]["close"] - _min) * heightNormalizer) +
            lineWidth / 2;
        rectBottom = (height - (data[i]["open"] - _min) * heightNormalizer) -
            lineWidth / 2;
        rectPaint = new Paint()
          ..color = Colors.green
          ..strokeWidth = lineWidth;

        canvas.drawLine(new Offset(rectLeft, rectBottom - lineWidth / 2),
            new Offset(rectRight, rectBottom - lineWidth / 2), rectPaint);
        canvas.drawLine(new Offset(rectLeft, rectTop + lineWidth / 2),
            new Offset(rectRight, rectTop + lineWidth / 2), rectPaint);
        canvas.drawLine(new Offset(rectLeft + lineWidth / 2, rectBottom),
            new Offset(rectLeft + lineWidth / 2, rectTop), rectPaint);
        canvas.drawLine(new Offset(rectRight - lineWidth / 2, rectBottom),
            new Offset(rectRight - lineWidth / 2, rectTop), rectPaint);

        // Draw volume bars
        canvas.drawLine(new Offset(rectLeft, volumeBarBottom - lineWidth / 2),
            new Offset(rectRight, volumeBarBottom - lineWidth / 2), rectPaint);
        canvas.drawLine(new Offset(rectLeft, volumeBarTop + lineWidth / 2),
            new Offset(rectRight, volumeBarTop + lineWidth / 2), rectPaint);
        canvas.drawLine(new Offset(rectLeft + lineWidth / 2, volumeBarBottom),
            new Offset(rectLeft + lineWidth / 2, volumeBarTop), rectPaint);
        canvas.drawLine(new Offset(rectRight - lineWidth / 2, volumeBarBottom),
            new Offset(rectRight - lineWidth / 2, volumeBarTop), rectPaint);
      }

      // Draw low/high candlestick wicks
      if (data[i]["low"] == data[i]["high"]) continue;
      double low = height - (data[i]["low"] - _min) * heightNormalizer;
      double high = height - (data[i]["high"] - _min) * heightNormalizer;
      canvas.drawLine(
          new Offset(rectLeft + rectWidth / 2 - lineWidth / 2, rectBottom),
          new Offset(rectLeft + rectWidth / 2 - lineWidth / 2, low),
          rectPaint);
      canvas.drawLine(
          new Offset(rectLeft + rectWidth / 2 - lineWidth / 2, rectTop),
          new Offset(rectLeft + rectWidth / 2 - lineWidth / 2, high),
          rectPaint);
    }
    if (enableGridLines) {
      Paint gridPaint = new Paint()
        ..color = gridLineColor
        ..strokeWidth = 0.5;

      double gridLineDist = height / (gridLineAmount - 1);
      double gridLineY;

      // Draw grid lines
      for (int i = 0; i < gridLineAmount; i++) {
        gridLineY = (gridLineDist * i).round().toDouble();
        canvas.drawLine(new Offset(0.0, gridLineY),
            new Offset(width, gridLineY), gridPaint);

        // Label grid lines
        gridLineTextPainters[i]
            .paint(canvas, new Offset(width + 2.0, gridLineY - 6.0));
      }

      // Label volume line
      maxVolumePainter.paint(canvas, new Offset(5.0, gridLineY + 2.0));
    }
  }

  @override
  bool shouldRepaint(_CandleGraphPainter old) {
    return data != old.data ||
        lineWidth != old.lineWidth ||
        enableGridLines != old.enableGridLines ||
        gridLineColor != old.gridLineColor ||
        gridLineAmount != old.gridLineAmount ||
        gridLineWidth != old.gridLineWidth ||
        volumeProp != old.volumeProp ||
        gridLineLabelColor != old.gridLineLabelColor;
  }
}
