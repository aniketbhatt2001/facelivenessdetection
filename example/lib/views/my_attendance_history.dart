import 'package:flutter/material.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final attendanceRecords = [
      {"date": "October 31, 2024", "time": "9:00 AM"},
      {"date": "October 30, 2024", "time": "9:05 AM"},
      {"date": "October 29, 2024", "time": "9:02 AM"},
      {"date": "October 28, 2024", "time": "9:01 AM"},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            "October 2024",
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        ...attendanceRecords.map((record) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        const Icon(Icons.calendar_today, color: Colors.white),
                  ),
                  title: Text(
                    record["date"]!,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "Check In: ${record["time"]}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ))
      ],
    );
  }
}
