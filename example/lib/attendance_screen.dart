// ignore_for_file: deprecated_member_use

import 'package:example/face_recognition_detector.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mq = MediaQuery.of(context);
    final hPad = mq.size.width * 0.05;
    final vPad = mq.size.height * 0.02;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.background,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        centerTitle: true,
        title: const Text('Attendance'),
      ),
      bottomNavigationBar: _buildBottomNav(cs),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today',
                style: TextStyle(
                  color: cs.onBackground,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TableCalendar(
                rowHeight: 42,
                firstDay: DateTime.utc(2020),
                lastDay: DateTime.utc(2030),
                focusedDay: _selectedDay ?? _focusedDay,
                selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
                onDaySelected: (sel, foc) {
                  setState(() {
                    _selectedDay = sel;
                    _focusedDay = foc;
                  });
                },
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    color: cs.onBackground,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  leftChevronIcon:
                      Icon(Icons.chevron_left, color: cs.onBackground),
                  rightChevronIcon:
                      Icon(Icons.chevron_right, color: cs.onBackground),
                  headerPadding: const EdgeInsets.only(bottom: 8),
                ),
                calendarStyle: CalendarStyle(
                  cellMargin: const EdgeInsets.all(4),
                  defaultTextStyle:
                      TextStyle(color: cs.onSurface.withOpacity(0.7)),
                  weekendTextStyle:
                      TextStyle(color: cs.onSurface.withOpacity(0.7)),
                  todayDecoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(
                    color: cs.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: TextStyle(
                    color: cs.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Attendance',
                style: TextStyle(
                  color: cs.onBackground,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildRecordRow(cs, '09:00 AM', 'Entry'),
              const SizedBox(height: 12),
              _buildRecordRow(cs, '06:00 PM', 'Exit'),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const FaceRecognitionDetector(),
                    ));
                  },
                  child: const Text(
                    'Start Face Recognition',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: vPad),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordRow(ColorScheme cs, String time, String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.access_time,
            color: cs.onSurface,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              time,
              style: TextStyle(
                color: cs.onBackground,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style:
                  TextStyle(color: cs.onSurface.withOpacity(0.7), fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  BottomNavigationBar _buildBottomNav(ColorScheme cs) {
    return BottomNavigationBar(
      backgroundColor: cs.surface,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: cs.primary,
      unselectedItemColor: cs.onSurface.withOpacity(0.7),
      currentIndex: _currentIndex,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined, color: cs.onSurface.withOpacity(0.7)),
          activeIcon: Icon(Icons.home, color: cs.primary),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          activeIcon: Icon(Icons.calendar_month_sharp, color: cs.primary),
          icon: Icon(
            Icons.calendar_month_outlined,
          ),
          label: 'Attendance',
        ),
        BottomNavigationBarItem(
          activeIcon: Icon(Icons.people_sharp, color: cs.primary),
          icon:
              Icon(Icons.people_outline, color: cs.onSurface.withOpacity(0.7)),
          label: 'Employees',
        ),
        BottomNavigationBarItem(
          activeIcon: Icon(Icons.settings_sharp, color: cs.primary),
          icon: Icon(Icons.settings_outlined,
              color: cs.onSurface.withOpacity(0.7)),
          label: 'Settings',
        ),
      ],
      onTap: (i) {
        // TODO: navigation logic
        setState(() {
          _currentIndex = i;
        });
      },
    );
  }
}
