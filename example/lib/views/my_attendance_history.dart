import 'package:example/controllers/attendanceHistoryList/attendance_history_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceHistoryListCubit, AttendanceHistoryListState>(
      builder: (context, state) {
        return Scaffold();
        print(state);
        if (state is! AttendanceHistoryLoaded) return SizedBox();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: state.attenadanceHistory.entries
              .map((record) => Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Text(record.key),
                        ...record.value
                            .map((attendanceRecord) => ListTile(
                                  title: Text(attendanceRecord['checkInTime']
                                      .toString()),
                                ))
                            .toList()
// ...state.attenadanceHistory.values[key].
                        // ListView.builder(itemBuilder:(context, index) => record.value[index],)
                      ],
                    ),
                  ))
              .toList(),
          // children: [
          //   //  Padding(
          //   //   padding: EdgeInsets.symmetric(vertical: 8),
          //   //   child: Text(
          //   //     "October 2024",
          //   //     style: TextStyle(
          //   //         color: Colors.white,
          //   //         fontSize: 16,
          //   //         fontWeight: FontWeight.bold),
          //   //   ),
          //   // ),

          // ...state.attenadanceHistory.values
          //   .map((attendanceList) => Padding(
          //         padding: const EdgeInsets.symmetric(vertical: 6),
          //         child: Container(
          //           decoration: BoxDecoration(
          //             color: const Color(0xFF1C1C1E),
          //             borderRadius: BorderRadius.circular(10),
          //           ),
          //           child: ListTile(
          //             leading: Container(
          //               padding: const EdgeInsets.all(8),
          //               decoration: BoxDecoration(
          //                 color: const Color(0xFF2C2C2E),
          //                 borderRadius: BorderRadius.circular(8),
          //               ),
          //               child: const Icon(Icons.calendar_today,
          //                   color: Colors.white),
          //             ),
          //             title: Text(
          //         '',
          //               style: const TextStyle(color: Colors.white),
          //             ),
          //             subtitle: Text(
          //               "Check In: ${record}",
          //               style: const TextStyle(color: Colors.grey),
          //             ),
          //           ),
          //         ),
          //       ))

          // ],
        );
      },
    );
  }
}
