import 'dart:developer';

import 'package:example/face_registration_detector.dart';
import 'package:facelivenessdetection/facelivenessdetection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FaceRecognitionDetector extends StatefulWidget {
  const FaceRecognitionDetector({super.key});

  @override
  State<FaceRecognitionDetector> createState() =>
      _FaceRecognitionDetectorState();
}

class _FaceRecognitionDetectorState extends State<FaceRecognitionDetector> {
  final TextStyle _textStyle = const TextStyle();
  bool busy = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: FaceDetectorView(
        dotRadius: 2.5,
        totalDots: 70,
        activeProgressColor: Colors.green,
        progressColor: Colors.red,
        // ruleset: [Rulesets.smiling],
        backgroundColor: Theme.of(context).colorScheme.background,
        pauseDurationInSeconds: 2,
        cameraSize: Size(250, 250),
        onSuccessValidation: (
          validated,
          controller,
        ) {
          log('onSuccessValidation called');
        },
        ruleset: [Rulesets.blink],
        onRulesetCompleted: (ruleset, controller) {},
        onValidationDone: (controller, trackingId) {
          // if (busy) {
          //   return SizedBox();
          // } else {
          //   busy = true;
          //   log('onValidationDone......................................');
          //   Future.delayed(Duration(seconds: 1), () {
          //     if (mounted) {
          //       Navigator.of(context).pop();
          //     }
          //   });
          // }

          return ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Done'));
        },
        child: (
                {required countdown,
                required state,
                required hasFace,
                required multipleFacesFound}) =>
            Column(
          children: [
            SizedBox(
              height: 20,
            ),
            hasFace ? Text('Please center your face') : SizedBox(),
            const SizedBox(height: 20),
            Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                      child: AnimatedSize(
                          duration: const Duration(milliseconds: 150),
                          child: Text(
                            hasFace ? 'User face found' : 'User face not found',
                            style: _textStyle.copyWith(
                                //  color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 12),
                          )))
                ]),
            const SizedBox(height: 30),
            Text(getHintText(state),
                style: _textStyle.copyWith(
                    //   color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 20)),
            if (countdown > 0)
              Text.rich(
                textAlign: TextAlign.center,
                TextSpan(children: [
                  const TextSpan(text: 'IN'),
                  const TextSpan(text: '\n'),
                  TextSpan(
                      text: countdown.toString(),
                      style: _textStyle.copyWith(
                          //   color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 22))
                ]),
                style: _textStyle.copyWith(
                    //     color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              )
            else ...[
              const SizedBox(height: 50),
              const CupertinoActivityIndicator()
            ]
          ],
        ),
      )),
    );
  }
}
