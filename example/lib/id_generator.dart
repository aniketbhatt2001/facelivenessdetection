import 'dart:math';

int generateTimeBasedRandomNumber({int min = 0, int max = 100}) {
  // Use current time in milliseconds as seed
  final milliseconds = DateTime.now().millisecondsSinceEpoch;

  // Seed the random generator
  final random = Random(milliseconds);

  // Generate random number between min and max
  return min + random.nextInt(max - min + 1);
}
