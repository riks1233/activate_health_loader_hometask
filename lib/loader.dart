import 'dart:developer';
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:activate_health_loader_hometask/functions.dart';
import 'package:activate_health_loader_hometask/colors.dart';
import 'package:activate_health_loader_hometask/arc.dart';
import 'package:flutter_sequence_animation/flutter_sequence_animation.dart';
import 'package:confetti/confetti.dart';


/// Custom fullscreen progress indicator (loader) widget with a default size of 200.
///
/// The widget has a property [value] (optional double value between 0.0 and 1.0).
/// [value] can also be higher than 1.0 or lesser than 0.0 but is then still treated as
/// one of the metioned boundaries.
///
/// - If the value is not set, the loader will spin arcs like an indeterminate progress indicator.
/// - If the value is > 0 but < 1.0, the loader will transform from indeterminate to determinate
///   state and show progress according to value.
/// - If the value is 1.0, the loader will play celebration animation.
class ActivateHealthProgressIndicator extends StatefulWidget {
  const ActivateHealthProgressIndicator({
    Key? key,
    this.value = 0.0,
  }) : super(key: key);

  final double value;

  @override
  State<ActivateHealthProgressIndicator> createState() => _ActivateHealthProgressIndicatorState();
}

class _ActivateHealthProgressIndicatorState extends State<ActivateHealthProgressIndicator> {
  final double size = 200;
  bool showLoadingArc = false;

  void finishedIndeterminateLoadingAnimation() {
    setState(() {
      showLoadingArc = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool shouldLoop;
    if (widget.value <= 0.0) {
      shouldLoop = true;
      showLoadingArc = false;
    } else {
      shouldLoop = false;
    }

    Widget currentShownWidget;
    if (showLoadingArc) {
      currentShownWidget = LoadingArc(
        loadedValue: widget.value,
        color: AppColors.primary,
        size: size,
        strokeWidth: size * 0.066,
      );
    } else {
      currentShownWidget = SpinningArcs(size: size, shouldLoop: shouldLoop, onFinishAnimationCallback: finishedIndeterminateLoadingAnimation);
    }

    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: currentShownWidget,
      )
    );
  }
}


class LoadingArc extends StatefulWidget {
  const LoadingArc({
    Key? key,
    required this.loadedValue,
    required this.color,
    required this.size,
    required this.strokeWidth,
  }) : super(key: key);

  final double loadedValue;
  final Color color;
  final double size;
  final double strokeWidth;

  @override
  State<LoadingArc> createState() => _LoadingArcState();
}

class _LoadingArcState extends State<LoadingArc> with SingleTickerProviderStateMixin{
  final ConfettiController confettiController = ConfettiController();
  final loadTweenDurationMilliseconds = 500;
  bool didPlayEndingAnimation = false;
  late SequenceAnimation textSequenceAnimation;
  late AnimationController textSequenceAnimationController;

  @override
  void initState() {
    super.initState();
    confettiController.duration = const Duration(milliseconds: 10);
    textSequenceAnimationController = AnimationController(
      vsync: this,
    );
    textSequenceAnimation = SequenceAnimationBuilder()
      .addAnimatable(animatable: CurveTween(curve: Curves.ease), from: const Duration(seconds: 0), to: const Duration(milliseconds: 400), tag: 'percentText')
      .addAnimatable(animatable: CurveTween(curve: Curves.ease), from: const Duration(milliseconds: 150), to: const Duration(milliseconds: 700), tag: 'doneText')
      .animate(textSequenceAnimationController);
  }

  void playEndingAnimation() {
    // Blast confetti 150 ms before fully loaded (100%).
    Future.delayed(Duration(milliseconds: math.max(loadTweenDurationMilliseconds - 150, 0)),
      () => confettiController.play()
    );
    // Start animating percent and "done text" crossfade.
    Future.delayed(const Duration(milliseconds: 700), textSequenceAnimationController.forward);
  }

  @override
  void dispose() {
    confettiController.dispose();
    textSequenceAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loadedValue >= 1.0 && !didPlayEndingAnimation) {
      didPlayEndingAnimation = true;
      playEndingAnimation();
    }
    return TweenAnimationBuilder<double>(
      curve: Curves.ease,
      tween: Tween(begin: 0.0, end: widget.loadedValue),
      duration: Duration(milliseconds: loadTweenDurationMilliseconds),
      builder: (context, double value, child) {
        double tailAngle;
        double headAngle;
        int displayValue = math.max(math.min((value * 100).round(), 100), 1);
        if (value >= 1.0) {
          tailAngle = 0;
          headAngle = 360;
        } else {
          tailAngle = (widget.strokeWidth / 2) + value * (90 - (widget.strokeWidth / 2));
          headAngle = (widget.strokeWidth / 2) + 1 + value * (449 - (widget.strokeWidth / 2));
        }
        double minFontSize = widget.size / 24;
        double fontSize = widget.size / 8;
        // 200 is the standard widget size with which all hardcoded values were picked.
        double widgetSizeCoefficient = widget.size / 200;

        return Stack(
          children: [
            Center(
              child: Arc(
                color: AppColors.primary,
                arcSize: widget.size,
                strokeWidth: widget.strokeWidth,
                tailAngle: tailAngle,
                headAngle: headAngle,
              ),
            ),
            Center(
              child: ConfettiWidget(
                confettiController: confettiController,
                emissionFrequency: 1,
                blastDirectionality: BlastDirectionality.explosive,
                minBlastForce: 1,
                maxBlastForce: widget.size / 4,
                numberOfParticles: 30,
                minimumSize: Size(20 * widgetSizeCoefficient, 10 * widgetSizeCoefficient),
                maximumSize: Size(30 * widgetSizeCoefficient, 15 * widgetSizeCoefficient),
                colors: const [
                  AppColors.primary,
                  AppColors.secondary,
                  Colors.white,
                ],
              ),
            ),
            Stack(
              children: [
                Center(
                  child: AnimatedBuilder(
                    animation: textSequenceAnimationController,
                    builder: (context, child) {
                      double value = 1.0 - textSequenceAnimation['percentText'].value;
                      return Opacity(
                        opacity: value,
                        child: SizedBox(
                          height: minFontSize + (fontSize - minFontSize) * value,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: child!
                          ),
                        ),
                      );
                    },
                    child: ProgressIndicatorText('$displayValue%')
                  ),
                ),
                Center(
                  child: AnimatedBuilder(
                    animation: textSequenceAnimationController,
                    builder: (context, child) {
                      double value = textSequenceAnimation['doneText'].value;
                      return Opacity(
                        opacity: value,
                        child: SizedBox(
                          height: minFontSize + (fontSize - minFontSize) * value,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: child!
                          ),
                        ),
                      );
                    },
                    child: const ProgressIndicatorText('All done'),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}


class ProgressIndicatorText extends StatelessWidget {
  const ProgressIndicatorText(this.text, { Key? key }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontFamily: 'Montserrat',
      ),
      maxLines: 1,
      overflow: TextOverflow.visible,
      softWrap: false,
    );
  }
}


class SpinningArcs extends StatefulWidget {
  const SpinningArcs({
    Key? key,
    required this.onFinishAnimationCallback,
    required this.size,
    this.sweepAngle = 18,
    this.shouldLoop = true,
  }) : super(key: key);

  final Function onFinishAnimationCallback;
  final double size;
  final double sweepAngle;
  final bool shouldLoop;

  @override
  State<SpinningArcs> createState() => _SpinningArcsState();
}

class _SpinningArcsState extends State<SpinningArcs> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late SequenceAnimation sequenceAnimation;
  late Duration headCurveDuration;
  late double headEndingFraction;
  late double sweepAngleFraction;
  bool shouldPlayFinishingAnimation = false;

  void onHeadCurveFinish() {
    if (!widget.shouldLoop) {
      shouldPlayFinishingAnimation = true;
    }
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
    )
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (shouldPlayFinishingAnimation) {
          widget.onFinishAnimationCallback();
        } else {
          controller.reset();
          Timer(headCurveDuration, onHeadCurveFinish);
          controller.forward();
        }
      }
    });

    const double linearDurationDecimal = 1.6;
    const double curveDurationDecimal = 1;
    const double wholeDurationDecimal = linearDurationDecimal + curveDurationDecimal;
    const double deltaDurationDecimal = 0.6;
    const double headFirstLinearDurationDecimal = linearDurationDecimal - deltaDurationDecimal;

    const Duration zeroDuration = Duration(seconds: 0);
    Duration tailLinearDuration = decimalDurationToDuration(linearDurationDecimal);
    Duration headFirstLinearDuration = decimalDurationToDuration(headFirstLinearDurationDecimal);
    headCurveDuration = decimalDurationToDuration(headFirstLinearDurationDecimal + curveDurationDecimal);
    Duration wholeDuration = decimalDurationToDuration(wholeDurationDecimal);

    const double headTweenBreakPoint = headFirstLinearDurationDecimal / linearDurationDecimal;
    Cubic lineContinuationCurve = lineTangentContinuationCurve(curveDurationDecimal / linearDurationDecimal);

    headEndingFraction = deltaDurationDecimal / wholeDurationDecimal;
    sweepAngleFraction = widget.sweepAngle / 360;

    // This sequence animation animates the head and tail of an arc.
    //
    // Tail animation is simple, consists of 2 parts:
    //  - Linear tween from time 0.0 to tailLinearDuration.
    //  - And a curve tween from time tailLinearDuration to the end of whole animation (wholeDuration time).
    //
    // Head animation is complicated, consists of 3 parts:
    //  - Linear tween from time 0.0 to headFirstLinearDuration.
    //  - Curve tween from time headFirstLinearDuration to headCurveDuration (added the curve duration time).
    //  - And the third part animation depends on whether we are stopping the animation or continuing it.
    //    Goes from time headCurveDuration to the end of whole animation.
    //
    // Head animation uses altering values in order to rotate curve animation.
    // I.e. the the curvetween starts at 0.0 and ends at 1.0, but we want it to start at 0.25 and end at 0.75.
    sequenceAnimation = SequenceAnimationBuilder()
      // Tail linear.
      .addAnimatable(animatable: Tween(begin: 0.0, end: 1.0), from: zeroDuration, to: tailLinearDuration, tag: 'tail')
      // Tail curve.
      .addAnimatable(animatable: CurveTween(curve: lineContinuationCurve), from: tailLinearDuration, to: wholeDuration, tag: 'tail')

      // Head first linear.
      .addAnimatable(animatable: Tween(begin: 0.0, end: headTweenBreakPoint), from: zeroDuration, to: headFirstLinearDuration, tag: 'head')
      // Head curve.
      .addAnimatable(animatable: CurveTween(curve: lineContinuationCurve), from: headFirstLinearDuration, to: headCurveDuration, tag: 'head')
      // Head curve alter value.
      .addAnimatable(animatable: Tween(begin: 0.0, end: 0.0), from: zeroDuration, to: headFirstLinearDuration, tag: 'headCurveAlter')
      .addAnimatable(animatable: Tween(begin: headTweenBreakPoint, end: headTweenBreakPoint), from: headFirstLinearDuration, to: headCurveDuration, tag: 'headCurveAlter')
      .addAnimatable(animatable: Tween(begin: 0.0, end: 0.0), from: headCurveDuration, to: wholeDuration, tag: 'headCurveAlter')

      // Head animation ending to continue the animation.
      .addAnimatable(animatable: Tween(begin: 0.0, end: 0.0), from: zeroDuration, to: headCurveDuration, tag: 'headContinuing')
      .addAnimatable(animatable: Tween(begin: headTweenBreakPoint, end: 1.0), from: headCurveDuration, to: wholeDuration, tag: 'headContinuing')
      // Head animation ending to finish the animation.
      .addAnimatable(animatable: Tween(begin: 0.0, end: 0.0), from: zeroDuration, to: headCurveDuration, tag: 'headFinishing')
      .addAnimatable(animatable: CurveTween(curve: Curves.decelerate), from: headCurveDuration, to: wholeDuration, tag: 'headFinishing')
      .addAnimatable(animatable: Tween(begin: 0.0, end: 0.0), from: zeroDuration, to: headCurveDuration, tag: 'headFinishingAlter')
      .addAnimatable(animatable: Tween(begin: headTweenBreakPoint, end: headTweenBreakPoint), from: headCurveDuration, to: wholeDuration, tag: 'headFinishingAlter')

      .animate(controller);
    controller.forward();

    Timer(headCurveDuration, onHeadCurveFinish);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  double calculateAnimatedAngle(double initialAngle, String tag, double alterValue) {
    return
    (initialAngle + ((
      sequenceAnimation[tag].value
      + alterValue
    ) % 1 * 360)) % 360;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double headAlterValue =
          sequenceAnimation['headCurveAlter'].value
            + (shouldPlayFinishingAnimation ?
                sequenceAnimation['headFinishing'].value * (headEndingFraction + sweepAngleFraction * 2)
                + sequenceAnimation['headFinishingAlter'].value
              :
                sequenceAnimation['headContinuing'].value
              );
        double animatedTailAngleClockwise = calculateAnimatedAngle(0, 'tail', 0.0);
        double animatedTailAngleCounterClockwise = calculateAnimatedAngle(360 - widget.sweepAngle, 'tail', 0.0);

        double animatedHeadAngleClockwise = calculateAnimatedAngle(widget.sweepAngle, 'head', headAlterValue);
        double animatedHeadAngleCounterClockwise = calculateAnimatedAngle(0.0, 'head', headAlterValue);

        return Stack(
          children: [
            Arc(
              color: AppColors.primary,
              arcSize: widget.size,
              strokeWidth: widget.size * 0.066,
              tailAngle: animatedTailAngleClockwise,
              headAngle: animatedHeadAngleClockwise,
            ),
            Arc(
              color: AppColors.darkGray,
              arcSize: widget.size * 0.82,
              strokeWidth: widget.size * 0.033,
              tailAngle: animatedTailAngleClockwise,
              headAngle: animatedHeadAngleClockwise,
            ),
            Transform(
              transform: Matrix4.rotationY(math.pi),
              child: Arc(
                color: AppColors.secondary,
                arcSize: widget.size * 0.64,
                strokeWidth: widget.size * 0.033,
                tailAngle: animatedTailAngleCounterClockwise,
                headAngle: animatedHeadAngleCounterClockwise,
              ),
            ),
            Transform(
              transform: Matrix4.rotationY(math.pi),
              child: Arc(
                color: AppColors.darkGray,
                arcSize: widget.size * 0.89,
                strokeWidth: widget.size * 0.0083,
                tailAngle: animatedTailAngleCounterClockwise,
                headAngle: animatedHeadAngleCounterClockwise,
              ),
            ),
          ],
        );
      },
    );
  }
}
