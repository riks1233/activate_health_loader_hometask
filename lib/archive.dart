
/// Archive, this stuff may be useful in future.

// class SpinningArc extends StatefulWidget {
//   const SpinningArc({
//     required this.color,
//     required this.arcSize,
//     required this.strokeWidth,
//     required this.tailAngle,
//     required this.headAngle,
//     this.spinClockwise = true,
//     this.loop = true,
//   });

//   final Color color;
//   final double arcSize;
//   final double strokeWidth;
//   final double tailAngle;
//   final double headAngle;
//   final bool spinClockwise;
//   final bool loop;

//   @override
//   State<SpinningArc> createState() {
//     return _SpinningArcState();
//   }
// }

// class _SpinningArcState extends State<SpinningArc> with SingleTickerProviderStateMixin {
//   late AnimationController controller;
//   late Animation<double> animation;
//   late SequenceAnimation sequenceAnimation;
//   late double headEndingFraction;
//   late double sweepAngleFraction;
//   late bool visible;
//   Tween<double> _rotationTween = Tween(begin: -math.pi, end: math.pi);

//   @override
//   void initState() {
//     super.initState();
//     visible = true;
//     controller = AnimationController(
//       vsync: this,
//     )
//     ..addStatusListener((status) {
//       // log('$status');
//       if (status == AnimationStatus.completed) {
//         if (widget.loop) {
//           controller.reset();
//           controller.forward();
//         } else {
//           visible = false;
//         }
//       }
//     });

//     sweepAngleFraction = ((360 - widget.tailAngle).abs() + widget.headAngle) % 360 / 360;
//     log('sweepanglefraction: ${sweepAngleFraction}');

//     double linearDurationDecimal = 1.6;
//     double curveDurationDecimal = 1;
//     double wholeDurationDecimal = linearDurationDecimal + curveDurationDecimal;
//     double deltaDurationDecimal = 0.6;
//     double headFirstLinearDurationDecimal = linearDurationDecimal - deltaDurationDecimal;
//     headEndingFraction = deltaDurationDecimal / wholeDurationDecimal;
//     log('headendingfraction: ${headEndingFraction}');

//     Duration tailLinearDuration = decimalDurationToDuration(linearDurationDecimal);
//     Duration headFirstLinearDuration = decimalDurationToDuration(headFirstLinearDurationDecimal);
//     Duration headCurveDuration = decimalDurationToDuration(headFirstLinearDurationDecimal + curveDurationDecimal);
//     Duration wholeDuration = decimalDurationToDuration(wholeDurationDecimal);

//     double headTweenBreakPoint = headFirstLinearDurationDecimal / linearDurationDecimal;

//     Cubic myCurve = createCircularLoaderCurve(curveDurationDecimal / linearDurationDecimal);


//     sequenceAnimation = SequenceAnimationBuilder()

//       .addAnimatable(animatable: Tween(begin: 0.0, end: 1.0), from: Duration(seconds: 0), to: tailLinearDuration, tag: 'tail')
//       .addAnimatable(animatable: CurveTween(curve: myCurve), from: tailLinearDuration, to: wholeDuration, tag: 'tail')


//       .addAnimatable(animatable: Tween(begin: 0.0, end: headTweenBreakPoint), from: Duration(seconds: 0), to: headFirstLinearDuration, tag: 'head')

//       .addAnimatable(animatable: CurveTween(curve: myCurve), from: headFirstLinearDuration, to: headCurveDuration, tag: 'head')
//       .addAnimatable(animatable: Tween(begin: 0.0, end: 0.0), from: Duration(seconds: 0), to: headFirstLinearDuration, tag: 'headCurveAlter')
//       .addAnimatable(animatable: Tween(begin: headTweenBreakPoint, end: headTweenBreakPoint), from: headFirstLinearDuration, to: headCurveDuration, tag: 'headCurveAlter')
//       .addAnimatable(animatable: Tween(begin: 0.0, end: 0.0), from: headCurveDuration, to: wholeDuration, tag: 'headCurveAlter')

//       .addAnimatable(animatable: Tween(begin: 0.0, end: 0.0), from: headCurveDuration, to: wholeDuration, tag: 'head')

//       .addAnimatable(animatable: Tween(begin: 0.0, end: 0.0), from: Duration(seconds: 0), to: headCurveDuration, tag: 'headContinuing')
//       .addAnimatable(animatable: Tween(begin: headTweenBreakPoint, end: 1.0), from: headCurveDuration, to: wholeDuration, tag: 'headContinuing')


//       .addAnimatable(animatable: Tween(begin: 0.0, end: 0.0), from: Duration(seconds: 0), to: headCurveDuration, tag: 'headFinishing')
//       .addAnimatable(animatable: CurveTween(curve: Curves.decelerate), from: headCurveDuration, to: wholeDuration, tag: 'headFinishing')
//       .addAnimatable(animatable: Tween(begin: 0.0, end: 0.0), from: Duration(seconds: 0), to: headCurveDuration, tag: 'headFinishingAlter')
//       .addAnimatable(animatable: Tween(begin: headTweenBreakPoint, end: headTweenBreakPoint), from: headCurveDuration, to: wholeDuration, tag: 'headFinishingAlter')

//       .animate(controller);




//     // animation = CurveTween(
//     //   curve: Interval(0.0, 0.5, curve: Curves.easeInOut)
//     // ).chain(CurveTween(
//     //   curve: Interval(0.5, 1.0, curve: Curves.fastLinearToSlowEaseIn)
//     // )).animate(controller);
//     // animation = CurveTween(
//     //   curve: Interval(0.0, 0.5, curve: Curves.easeInOut)
//     // ).animate(controller);

//     // animation = _rotationTween.animate(controller);
//     // animation.addListener(() => setState(() {}));

//     controller.forward();
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // const bool finishAnimation = false;
//     // final Animation<double> headAnimation = CurveTween(curve: Interval(0.8, 1, curve: Curves.fastOutSlowIn)).animate(_controller);
//     // final Animation<double> headAnimation = CurveTween(curve: Curves.easeInOut).animate(controller);
//     // final Animation<double> tailAnimation = CurveTween(curve: Curves.).animate(_controller);
//     return Transform(
//       transform: widget.spinClockwise ? Matrix4.identity() : Matrix4.rotationY(math.pi),
//       child: AnimatedBuilder(
//         animation: controller,
//         builder: (context, child) {
//           double headAlterValue =
//             sequenceAnimation['headCurveAlter'].value
//               + (widget.loop ?
//                   sequenceAnimation['headContinuing'].value
//                 :
//                   sequenceAnimation['headFinishing'].value * (headEndingFraction + sweepAngleFraction * 2)
//                   + sequenceAnimation['headFinishingAlter'].value
//                 );
//           double animatedTailAngle = (widget.tailAngle + (sequenceAnimation['tail'].value * 360)) % 360;
//           double animatedHeadAngle =
//             (widget.headAngle + ((
//               sequenceAnimation['head'].value
//               + headAlterValue
//             ) % 1 * 360)) % 360;
//           // log('Tail angle: ${animatedTailAngle} | Head angle: ${animatedHeadAngle}');
//           return Visibility(
//             visible: visible,
//             child: Arc(
//               color: widget.color,
//               arcSize: widget.arcSize,
//               strokeWidth: widget.strokeWidth,
//               tailAngle: animatedTailAngle,
//               headAngle: animatedHeadAngle,
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

