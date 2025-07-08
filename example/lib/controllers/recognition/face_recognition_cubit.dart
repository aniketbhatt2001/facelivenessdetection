import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:example/main.dart';
import 'package:example/services/attendance_service.dart';
import 'package:example/services/face_service.dart';
import 'package:meta/meta.dart';

part 'face_regcognition_state.dart';

class FaceRecognitionCubit extends Cubit<FaceRecognitionState> {
  FaceRecognitionCubit() : super(FaceRecognitionInitial());

  Future<void> recognize({required List<File> images}) async {
    try {
      emit(FaceRecognitionInProgress());

      final res = await FaceService.recognize(
        images: images,
      );

      await getIt.get<AttendanceService>().markAttendance(
            qdrantId: res['qdrant_id'].toString(),
          );

      emit(FaceRecognitionSuccess(recognitionData: res));
    } catch (e) {
      emit(FaceRecognitionFailed(e.toString()));
    }
  }
}
