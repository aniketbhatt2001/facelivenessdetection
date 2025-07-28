import 'dart:developer' as dev;
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:facelivenessdetection/src/debouncer/debouncer.dart';
import 'package:facelivenessdetection/src/detector_view/detector_view.dart';
import 'package:facelivenessdetection/src/painter/dotted_painter.dart';
import 'package:facelivenessdetection/src/rule_set/rule_set.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectorView extends StatefulWidget {
  final int pauseDurationInSeconds;
  final Size cameraSize;
  final Function(
    bool validated,
    CameraController? controller,
  )? onSuccessValidation;
  final void Function(Rulesets ruleset, CameraController? controller)?
      onRulesetCompleted;
  final List<Rulesets> ruleset;
  final Color activeProgressColor;
  final Color progressColor;
  final Widget Function(
      {required Rulesets state,
      required int countdown,
      required bool hasFace,
      required bool multipleFacesFound}) child;
  final Widget Function(CameraController? controller, int? trackingId)
      onValidationDone;
  final int totalDots;
  final double dotRadius;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? contextPadding;

  const FaceDetectorView(
      {super.key,
      required this.onRulesetCompleted,
      required this.onValidationDone,
      this.ruleset = const [
        Rulesets.smiling,
        Rulesets.blink,
        Rulesets.toRight,
        Rulesets.toLeft,
        Rulesets.tiltUp,
        Rulesets.tiltDown
      ],
      required this.child,
      this.progressColor = Colors.green,
      this.activeProgressColor = Colors.red,
      this.totalDots = 60,
      this.dotRadius = 3,
      this.onSuccessValidation,
      this.backgroundColor = Colors.white,
      this.contextPadding,
      this.cameraSize = const Size(200, 200),
      this.pauseDurationInSeconds = 5})
      : assert(ruleset.length != 0, 'Ruleset cannot be empty');

  @override
  State<FaceDetectorView> createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
  int? trackingId;
  ValueNotifier<List<Rulesets>> ruleset = ValueNotifier<List<Rulesets>>([]);
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
        enableContours: false,
        enableLandmarks: true,
        enableTracking: false,
        performanceMode: FaceDetectorMode.accurate,
        enableClassification: true),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  String? _text;
  final _cameraLensDirection = CameraLensDirection.front;
  late ValueNotifier<Rulesets?> _currentTest;
  Debouncer? _debouncer;
  CameraController? controller;
  bool hasFace = false;
  bool multipleFacesFound = false;
  List<String> _eyeStates = [];
  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    _debouncer?.stop();
    super.dispose();
  }

  @override
  void initState() {
    ruleset.value = widget.ruleset.toList();
    _currentTest = ValueNotifier<Rulesets?>(ruleset.value.first);
    _debouncer = Debouncer(
        durationInSeconds: widget.pauseDurationInSeconds,
        onComplete: () =>
            dev.log('Timer is completed', name: 'Photo verification timer'));
    _debouncer?.start();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: widget.backgroundColor ?? Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        child: Container(
            padding: widget.contextPadding ??
                EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            width: double.infinity,
            child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ValueListenableBuilder(
                      valueListenable: _currentTest,
                      builder: (context, state, child) {
                        double targetProgress = state != null
                            ? (widget.ruleset.indexOf(state) /
                                    widget.ruleset.length)
                                .toDouble()
                            : 1.0;
                        return TweenAnimationBuilder(
                            duration:
                                Duration(milliseconds: 500), // Animation speed
                            tween: Tween<double>(begin: 0, end: targetProgress),
                            builder: (context, animation, _) => CustomPaint(
                                painter: DottedCirclePainter(
                                    activeProgressColor:
                                        widget.activeProgressColor,
                                    progressColor: widget.progressColor,
                                    progress: animation,
                                    totalDots: widget.totalDots,
                                    dotRadius: widget.dotRadius),
                                child: child));
                      },
                      child: Container(
                          height: widget.cameraSize.height,
                          width: widget.cameraSize.width,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: DetectorView(
                              cameraSize: widget.cameraSize,
                              onController: (controller_) =>
                                  controller = controller_,
                              title: 'Face Detector',
                              text: _text,
                              onImage: _processImage,
                              initialCameraLensDirection:
                                  _cameraLensDirection))),
                  Spacer(),
                  ValueListenableBuilder<Rulesets?>(
                      valueListenable: _currentTest,
                      builder: (context, state, child) {
                        if (state != null) {
                          return widget.child(
                              state: state,
                              countdown: _debouncer!.timeLeft,
                              hasFace: hasFace,
                              multipleFacesFound: multipleFacesFound);
                        }
                        return SizedBox.shrink();
                      }),
                  SizedBox(
                    height: 18,
                  ),
                  AnimatedBuilder(
                      animation: Listenable.merge([_currentTest, ruleset]),
                      builder: (context, child) {
                        if (_currentTest.value == null &&
                            ruleset.value.isEmpty &&
                            controller != null) {
                          return SizedBox(
                              width: double.infinity,
                              child: widget.onValidationDone(
                                  controller, trackingId));
                        } else {
                          return SizedBox.shrink();
                        }
                      })
                ])));
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;

    setState(() {
      _text = '';
    });

    final faces = await _faceDetector.processImage(inputImage);
    // if (faces.length > 1) return;
    if (faces.length > 1) {
      multipleFacesFound = true;
    } else {
      multipleFacesFound = false;
    }
    hasFace = faces.isNotEmpty;
    if (!(_debouncer?.isRunning ?? false)) handleRuleSet(faces);
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
    } else {
      String text = 'Faces found: ${faces.length}\n\n';
      for (final face in faces) {
        text += 'face: ${face.boundingBox}\n\n';
      }
      _text = text;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  void handleRuleSet(List<Face> faces) {
    if (faces.isEmpty || multipleFacesFound) return;

    for (Face face in faces) {
      startRandomizedTime(face);
    }
  }

  startRandomizedTime(Face face) {
    if (ruleset.value.isEmpty) {
      widget.onSuccessValidation?.call(
        true,
        controller,
      );
      return;
    } else {
      widget.onSuccessValidation?.call(
        false,
        controller,
      );
    }

    var currentRuleset = ruleset.value.removeAt(0);
    bool isDetected = false;
    switch (currentRuleset) {
      case Rulesets.smiling:
        isDetected = _onSmilingDetected(face);
        break;
      case Rulesets.blink:
        isDetected = _onBlinkDetected(face);
        break;
      case Rulesets.tiltUp:
        isDetected = _detectHeadTiltUp(face);
        break;
      case Rulesets.tiltDown:
        isDetected = _detectHeadTiltDown(face);
        break;
      case Rulesets.toLeft:
        isDetected = _detectLeftHeadMovement(face);
        break;
      case Rulesets.toRight:
        isDetected = _detectRightHeadMovement(face);
        break;
    }
    if (!isDetected) {
      ruleset.value.insert(0, currentRuleset);
    } else {
      if (ruleset.value.isNotEmpty) {
        _currentTest.value = ruleset.value.first;
        _debouncer?.start();
      } else {
        _currentTest.value = null;
        _debouncer?.stop();
      }
      HapticFeedback.vibrate();
    }
  }

  bool _detectHeadTiltUp(Face face) {
    return _detectHeadTilt(face, up: true);
  }

  bool _detectHeadTiltDown(Face face) {
    return _detectHeadTilt(face, up: false);
  }

  bool _detectHeadTilt(Face face, {bool up = true}) {
    final double? rotX = face.headEulerAngleX;
    if (rotX == null) return false;

    if (!up) {
      dev.log(rotX.toString(), name: 'Head Movement');
      if (rotX < -20) {
        // Adjust threshold if needed
        widget.onRulesetCompleted?.call(Rulesets.tiltUp, controller);
        return true;
      }
    } else {
      if (rotX > 20) {
        widget.onRulesetCompleted?.call(Rulesets.tiltUp, controller);
        return true;
      }
    }
    return false;
  }

  bool _detectRightHeadMovement(Face face) {
    return _detectHeadMovement(face, left: true);
  }

  bool _detectLeftHeadMovement(Face face) {
    return _detectHeadMovement(face, left: false);
  }

  bool _detectHeadMovement(Face face, {bool left = true}) {
    final double? rotY = face.headEulerAngleY;

    if (rotY == null) return false;
    final double adjustedRotY = Platform.isIOS ? -rotY : rotY;

    if (left) {
      if (adjustedRotY < -40) {
        widget.onRulesetCompleted?.call(Rulesets.toLeft, controller);
        return true;
      }
    } else {
      if (adjustedRotY > 40) {
        widget.onRulesetCompleted?.call(Rulesets.toRight, controller);
        return true;
      }
    }
    return false;
  }

  bool _onBlinkDetected(Face face) {
    final double? left = face.leftEyeOpenProbability;
    final double? right = face.rightEyeOpenProbability;

    if (left == null || right == null) return false;

    const double openThreshold = 0.6;
    const double closedThreshold = 0.4;

    final isOpen = left > openThreshold && right > openThreshold;
    final isClosed = left < closedThreshold && right < closedThreshold;

    String currentState = isClosed
        ? 'closed'
        : isOpen
            ? 'open'
            : 'unknown';

    if (currentState == 'unknown') return false;

    // Add to history
    _eyeStates.add(currentState);

    if (_eyeStates.length > 3) _eyeStates.removeAt(0);
    log('_eyeStates $_eyeStates');
    // Check for blink pattern: open → closed → open
    if (_eyeStates.length == 3 &&
        _eyeStates[0] == 'open' &&
        _eyeStates[1] == 'closed' &&
        _eyeStates[2] == 'open') {
      _eyeStates.clear(); // reset to avoid duplicate blink detection
      widget.onRulesetCompleted?.call(Rulesets.blink, controller);

      return true;
    }

    return false;
  }

  // bool _onBlinkDetectedd(Face face) {
  //   final double? leftEyeOpenProb = face.leftEyeOpenProbability;
  //   final double? rightEyeOpenProb = face.rightEyeOpenProbability;
  //   const double eyeOpenThreshold = 0.6;
  //   if (leftEyeOpenProb != null && rightEyeOpenProb != null) {
  //     if (leftEyeOpenProb < eyeOpenThreshold &&
  //         rightEyeOpenProb < eyeOpenThreshold) {
  //       widget.onRulesetCompleted?.call(Rulesets.blink, controller);
  //       return true;
  //     }
  //   }
  //   return false;
  // }

  // bool _onSmilingDetected(Face face) {
  //   if (face.smilingProbability != null) {
  //     final double? smileProb = face.smilingProbability;
  //     if ((smileProb ?? 0) > .5) {
  //       if (widget.onRulesetCompleted != null) {
  //         widget.onRulesetCompleted!(Rulesets.smiling);
  //         return true;
  //       }
  //     }
  //   }
  //   return false;
  // }

  bool _onSmilingDetected(Face face) {
    const double _smileThreshold = 0.5;
    final double prob = face.smilingProbability ?? 0;
    log('smile prob ${face.smilingProbability}');
    // Only consider smile valid if mouth is clearly visible
    final mouthVisible = face.landmarks[FaceLandmarkType.leftMouth] != null &&
        face.landmarks[FaceLandmarkType.rightMouth] != null &&
        face.landmarks[FaceLandmarkType.bottomMouth] != null;

    if (prob >= _smileThreshold && mouthVisible) {
      widget.onRulesetCompleted?.call(
        Rulesets.smiling,
        controller,
      );
      trackingId = face.trackingId;
      return true;
    }
    return false;
  }
}
