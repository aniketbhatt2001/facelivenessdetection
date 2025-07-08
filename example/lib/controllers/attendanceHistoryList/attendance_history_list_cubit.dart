import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:example/services/attendance_service.dart';
import 'package:meta/meta.dart';

part 'attendance_history_list_state.dart';

class AttendanceHistoryListCubit extends Cubit<AttendanceHistoryListState> {
  late final StreamSubscription<int> _qdrantSub;
  AttendanceHistoryListCubit() : super(AttendanceHistoryListInitial()) {
    _qdrantSub = EmployeeService.qdrantIdStream.listen(
      (id) => fetchAttendanceHistory(id.toString()),
      onError: (err, stk) {
        emit(AttendanceHistoryErrorLoading("Stream error: ${err.toString()}"));
      },
    );
  }

  Future<void> fetchAttendanceHistory(String qdrantId) async {
    try {
      print('id............. $qdrantId');
      emit(AttendanceHistoryListLoading());
      final attendanceList =
          await EmployeeService.getAttendanceHistory(qdrantId);
      final groupedData = EmployeeService.groupByMonth(attendanceList);
      emit(AttendanceHistoryLoaded(groupedData));
    } catch (e) {
      emit(AttendanceHistoryErrorLoading(e.toString()));
    }
  }

  @override
  Future<void> close() {
    // TODO: implement close
    _qdrantSub.cancel();
    return super.close();
  }
}
