import 'package:bloc/bloc.dart';
import 'package:example/services/attendance_service.dart';
import 'package:meta/meta.dart';

part 'attendance_history_list_state.dart';

class AttendanceHistoryListCubit extends Cubit<AttendanceHistoryListState> {
  AttendanceHistoryListCubit() : super(AttendanceHistoryListInitial());

  Future<void> fetchAttendanceHistory(String qdrantId) async {
    try {
      emit(AttendanceHistoryListLoading());
      final attendanceList =
          await EmployeeService.getAttendanceHistory(qdrantId);
      final groupedData = EmployeeService.groupByMonth(attendanceList);
      emit(AttendanceHistoryLoaded(groupedData));
    } catch (e) {
      emit(AttendanceHistoryErrorLoading());
    }
  }
}
