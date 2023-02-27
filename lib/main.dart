import 'dart:developer';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QLOCKTWO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Color selectedColor = Colors.white;

  final List<Color> colors = [
    Colors.white,
    Colors.blue,
    Colors.orange,
    Colors.pink,
    Colors.greenAccent.shade700,
    Colors.cyan,
    Colors.yellow,
  ];

  @override
  Widget build(BuildContext context) {
    Wrap;
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(builder: (context, constraints) {
        return Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: QlockTwo(
                  fontSize: 32,
                  color: selectedColor,
                  // simulatedTime: DateTime(2023, 1, 16, 9, 52, 0),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  if (constraints.maxWidth > 400)
                    Expanded(
                      child: Text(
                        'QLOCKTWO',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 20,
                          fontWeight: FontWeight.w200,
                          letterSpacing: 2,
                          height: 1,
                          fontFeatures: const [
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                    ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        height: 24,
                        child: ListView.separated(
                          itemCount: colors.length,
                          shrinkWrap: true,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 8),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final color = colors[index];
                            final isSelected = color == selectedColor;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => selectedColor = color),
                              child: CircleAvatar(
                                backgroundColor: color,
                                radius: 12,
                                child: Visibility(
                                  visible: isSelected,
                                  child: Icon(
                                    Icons.done,
                                    color: ThemeData.estimateBrightnessForColor(
                                                color) ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                    size: 12,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

const String letters = 'ITLISASAMPM'
    'ACQUARTERDC'
    'TWENTYFIVEX'
    'HALFBTENFTO'
    'PASTERUNINE'
    'ONESIXTHREE'
    'FOURFIVETWO'
    'EIGHTELEVEN'
    'SEVENTWELVE'
    'TENSEOCLOCK';

final List<List<String>> grid = letters.split('').slices(11).toList();

final List<String> rows = grid.map((row) => row.join()).toList();

const Set<String> words = {
  'IT',
  'IS',
  'ONE',
  'TWO',
  'THREE',
  'FOUR',
  'FIVE',
  'SIX',
  'SEVEN',
  'EIGHT',
  'NINE',
  'TEN',
  'ELEVEN',
  'TWELVE',
  'TWENTY',
  'TWENTYFIVE',
  'QUARTER',
  'HALF',
  'PAST',
  'TO',
  'OCLOCK',
};

const Map<int, String> numberToWord = {
  1: 'ONE',
  2: 'TWO',
  3: 'THREE',
  4: 'FOUR',
  5: 'FIVE',
  6: 'SIX',
  7: 'SEVEN',
  8: 'EIGHT',
  9: 'NINE',
  10: 'TEN',
  11: 'ELEVEN',
  12: 'TWELVE',
  20: 'TWENTY',
  25: 'TWENTYFIVE',
};

Map<String, int> wordToIndexFromString(Set<String> words, String letters) {
  letters = letters.toUpperCase();
  return {for (final word in words) word: letters.indexOf(word.toUpperCase())};
}

List<MapEntry<String, Position>> wordToIndexFromGrid(
    Set<String> words, List<String> rows) {
  final List<MapEntry<String, Position>> result = [];
  for (final word in words) {
    final List<MapEntry<int, String>> containingRows = rows
        .asMap()
        .entries
        .where(
            (entry) => entry.value.toUpperCase().contains(word.toUpperCase()))
        .toList();
    for (final entry in containingRows) {
      final int row = entry.key;
      final int column = entry.value.indexOf(word.toUpperCase());
      result.add(MapEntry(word, Position(row, column)));
    }
  }
  return result;
}

final List<MapEntry<String, Position>> positions =
    wordToIndexFromGrid(words, rows);

class QlockTwo extends StatefulWidget {
  final Color? inactiveColor;
  final Color? activeColor;
  final double fontSize;
  final DateTime? simulatedTime;
  final Color? color;

  const QlockTwo({
    Key? key,
    this.inactiveColor,
    this.activeColor,
    required this.fontSize,
    this.simulatedTime,
    this.color,
  })  : assert(color != null || activeColor != null),
        super(key: key);

  @override
  State<QlockTwo> createState() => _QlockTwoState();
}

class _QlockTwoState extends State<QlockTwo>
    with SingleTickerProviderStateMixin {
  late DateTime _initialTime;
  late DateTime _now;
  late List<Position> highlightingPositions;

  Ticker? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(onTick);
    if (widget.simulatedTime != null) {
      _initialTime = _now = widget.simulatedTime!;
    } else {
      _initialTime = _now = DateTime.now();
      _ticker?.start();
    }
    _parseTime(_now);
  }

  void _parseTime(DateTime time) {
    final String timeString = _getTime(time);
    highlightingPositions = getHighlightingPositions(timeString);
  }

  @override
  void didUpdateWidget(covariant QlockTwo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.simulatedTime == null && widget.simulatedTime != null) {
      _ticker?.stop();
      _now = widget.simulatedTime!;
      _parseTime(_now);
    } else if (oldWidget.simulatedTime != null &&
        widget.simulatedTime == null) {
      _initialTime = _now = DateTime.now();
      _parseTime(_now);
      _ticker?.start();
    } else if (oldWidget.simulatedTime != widget.simulatedTime) {
      _initialTime = _now = widget.simulatedTime!;
      _parseTime(_now);
    }
  }

  void onTick(Duration elapsed) {
    final newTime = _initialTime.add(elapsed);
    if (_now.minute != newTime.minute) {
      log('Time changed: $_now');
      _now = newTime;
      _parseTime(_now);
      setState(() {});
    }
  }

  List<Position> getHighlightingPositions(String time) {
    final List<String> words = time.split(' ');
    final List<Position> positionIndices = [];
    for (final word in words) {
      final matches =
          positions.where((element) => element.key == word).toList();
      if (matches.isEmpty) {
        throw Exception('Word $word not found in positions');
      }
      var item = matches.first.value;
      final bool isPosInUse = positionIndices
          .any((element) => element.row == item.row && element.col == item.col);
      final Position position = isPosInUse && matches.length > 1
          ? matches.last.value
          : matches.first.value;
      final List<Position> pos = List<Position>.generate(
          word.length, (index) => Position(position.row, position.col + index));
      positionIndices.addAll(pos);
    }
    return positionIndices;
  }

  String _getTime(DateTime time) {
    final int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final int minute = time.minute - (time.minute % 5);
    log('TIME: $hour:$minute');
    StringBuffer buffer = StringBuffer();
    buffer.write('IT IS ');
    if (minute == 0) {
      buffer.write(numberToWord[hour]);
      buffer.write(' OCLOCK');
      return buffer.toString();
    }
    if (minute == 15) {
      buffer.write('QUARTER PAST ');
      buffer.write(numberToWord[hour]);
      return buffer.toString();
    }
    if (minute == 30) {
      buffer.write('HALF PAST ');
      buffer.write(numberToWord[hour]);
      return buffer.toString();
    }
    if (minute == 45) {
      buffer.write('QUARTER TO ');
      buffer.write(numberToWord[(hour + 1) % 12]);
      return buffer.toString();
    }
    if (minute < 30) {
      buffer.write(numberToWord[minute]);
      buffer.write(' PAST ');
      buffer.write(numberToWord[hour]);
      return buffer.toString();
    }
    buffer.write(numberToWord[60 - minute]);
    buffer.write(' TO ');
    buffer.write(numberToWord[(hour + 1) % 12]);
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final Color activeColor = widget.activeColor ?? widget.color!;
    final Color inactiveColor =
        widget.inactiveColor ?? activeColor.withOpacity(0.2);
    return FittedBox(
      fit: BoxFit.fitWidth,
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(72),
        decoration: BoxDecoration(
          // color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: activeColor.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int row = 0; row < grid.length; row++)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    key: ValueKey(row),
                    children: [
                      for (int col = 0; col < grid[row].length; col++)
                        SizedBox.square(
                          dimension: widget.fontSize + 24,
                          child: Center(
                            child: Text(
                              grid[row][col],
                              style: TextStyle(
                                color:
                                    highlightingPositions.containsPos(row, col)
                                        ? activeColor
                                        : inactiveColor,
                                fontSize: widget.fontSize,
                                fontWeight: FontWeight.w200,
                                height: 1,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                                shadows: [
                                  if (highlightingPositions.containsPos(
                                      row, col))
                                    Shadow(
                                      color: activeColor.withOpacity(1),
                                      offset: const Offset(0, 0),
                                      blurRadius: 10,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (int minute = 1; minute < 5; minute += 1)
                    SizedBox.square(
                      dimension: widget.fontSize / 3,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: minute <= _now.minute % 5
                              ? activeColor
                              : inactiveColor,
                          boxShadow: [
                            if (minute <= _now.minute % 5)
                              BoxShadow(
                                color: activeColor.withOpacity(1),
                                offset: const Offset(0, 0),
                                blurRadius: 10,
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }
}

class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  @override
  String toString() => 'Position($row, $col)';
}

extension PosListExt on List<Position> {
  bool containsPos(int row, int col) =>
      any((pos) => pos.row == row && pos.col == col);
}
