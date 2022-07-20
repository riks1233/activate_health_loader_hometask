import 'dart:math' as math;
import 'package:flutter/material.dart';


/// Create a curve, that continues the line tangent (or slope, or velocity)
/// and ends with the same tangent.
Cubic lineTangentContinuationCurve(double tangent) {
  double atan = math.atan(tangent);
  double x = math.cos(atan);
  double y = math.sin(atan);
  double x1Pos = x / 1.1; // Divide by 1.X to have a smoother slope.
  double x2Pos = 1 - x1Pos;
  double y1Pos = y / 1.1;
  double y2Pos = 1 - y1Pos;
  Cubic curve = Cubic(x1Pos, y1Pos, x2Pos, y2Pos);
  return curve;
}


/// Convert duration described in decimal seconds (i.e. 2.5 seconds)
/// to a Duration value (i.e. Duration(seconds: 2, milliseconds: 500)).
Duration decimalDurationToDuration(double decimalDurationSeconds) {
  int durationSeconds = decimalDurationSeconds.floor();
  Duration duration = Duration(
    seconds: durationSeconds,
    milliseconds: ((decimalDurationSeconds - durationSeconds) * 1000).round(),
  );
  return duration;
}
