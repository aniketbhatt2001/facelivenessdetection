import 'package:example/attendance_screen.dart';
import 'package:facelivenessdetection/facelivenessdetection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FaceRegistrationDetector extends StatefulWidget {
  const FaceRegistrationDetector({super.key});

  @override
  State<FaceRegistrationDetector> createState() =>
      _FaceRegistrationDetectorState();
}

class _FaceRegistrationDetectorState extends State<FaceRegistrationDetector> {
  final List<Rulesets> _completedRuleset = [];
  final TextStyle _textStyle = const TextStyle();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      body: SafeArea(
        child: FaceDetectorView(
            //   ruleset: [Rulesets.smiling],
            dotRadius: 2.5,
            totalDots: 70,
            activeProgressColor: Colors.green,
            progressColor: Colors.red,
            // ruleset: [Rulesets.smiling],
            backgroundColor: Theme.of(context).colorScheme.background,
            pauseDurationInSeconds: 3,
            cameraSize: Size(250, 250),
            onValidationDone: (controller, trackingId) {
              return ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => AttendanceScreen(),
                    ));
                  },
                  child: Text('Next'));
            },
            child: ({required countdown, required state, required hasFace}) =>
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
                                    hasFace
                                        ? 'User face found'
                                        : 'User face not found',
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
            onRulesetCompleted: (ruleset, controller) {
              if (!_completedRuleset.contains(ruleset)) {
                _completedRuleset.add(ruleset);
              }
            }),
      ),
    );
  }
}

String getHintText(Rulesets state) {
  String hint_ = '';
  switch (state) {
    case Rulesets.smiling:
      hint_ = 'Please Smile';
      break;
    case Rulesets.blink:
      hint_ = 'Please Blink';
      break;
    case Rulesets.tiltUp:
      hint_ = 'Please Look Up';
      break;
    case Rulesets.tiltDown:
      hint_ = 'Please Look Down';
      break;
    case Rulesets.toLeft:
      hint_ = 'Please Look Left';
      break;
    case Rulesets.toRight:
      hint_ = 'Please Look Right';
      break;
  }
  return hint_;
}
