// Demonstrates focus management with Couchkeys

import 'package:couchkeys/couchkeys.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const FocusTestApp());
}

class FocusTestApp extends StatelessWidget {
  const FocusTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Couchkeys Focus Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const FocusTestPage(),
    );
  }
}

class FocusTestPage extends StatefulWidget {
  const FocusTestPage({super.key});

  @override
  State<FocusTestPage> createState() => _FocusTestPageState();
}

class _FocusTestPageState extends State<FocusTestPage> {
  final textController = TextEditingController();
  final otherFieldController = TextEditingController();
  final keyboardKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Focus Management Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Instructions
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Focus Test Instructions:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('1. Use Tab to navigate between text fields'),
                    Text(
                        '2. Click "Focus Keyboard" to return focus to keyboard'),
                    Text('3. Use "Focus Position" to jump to specific keys'),
                    Text(
                        '4. Test that focus position is preserved when switching'),
                    Text(
                        '5. Type directly with physical keyboard when focused!'),
                    Text('6. Press Enter on physical keyboard to submit'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Text fields for testing focus switching
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      labelText: "Main Text Field",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: otherFieldController,
                    decoration: const InputDecoration(
                      labelText: "Other Text Field",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    final keyboardState = Couchkeys.of(context);
                    keyboardState?.requestKeyboardFocus();
                  },
                  child: const Text('Focus Keyboard'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final keyboardState = Couchkeys.of(context);
                    keyboardState?.focusKey(
                        1, 2); // Focus third key in second row
                  },
                  child: const Text('Focus Position (1,2)'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final keyboardState = Couchkeys.of(context);
                    keyboardState?.focusKey(
                        3, 0); // Focus first key in fourth row
                  },
                  child: const Text('Focus Position (3,0)'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Virtual keyboard with custom styling
            Expanded(
              child: Couchkeys(
                key: keyboardKey,
                controller: textController,
                enableDpadNavigation: true,
                enablePhysicalKeyboard: true, // Enable physical keyboard input
                autofocus: true,
                keyboardHeight: 300,
                buttonStyle: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.grey[800]),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                  textStyle: WidgetStateProperty.all(
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                focusedButtonStyle: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.blue[700]),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                  textStyle: WidgetStateProperty.all(
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  side: WidgetStateProperty.all(
                    const BorderSide(color: Colors.blue, width: 3),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                onSubmit: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Submitted: "${textController.text}"'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                customLayout: [
                  // Numbers row
                  ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
                      .map(
                        (v) => KeyboardKey(
                          action: InsertAction(v),
                          child: Text(v),
                        ),
                      )
                      .toList(),

                  // QWERTY row
                  ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
                      .map(
                        (v) => KeyboardKey(
                          action: InsertAction(v),
                          child: Text(v),
                        ),
                      )
                      .toList(),

                  // ASDF row
                  ["A", "S", "D", "F", "G", "H", "J", "K", "L"]
                      .map(
                    (v) => KeyboardKey(
                      action: InsertAction(v),
                      child: Text(v),
                    ),
                  )
                      .followedBy([
                    KeyboardKey(
                      action: BackspaceAction(),
                      child: const Icon(Icons.backspace),
                    ),
                  ]).toList(),

                  // ZXCV row with special keys
                  ["Z", "X", "C", "V", "B", "N", "M"]
                      .map(
                    (v) => KeyboardKey(
                      action: InsertAction(v),
                      child: Text(v),
                    ),
                  )
                      .followedBy([
                    KeyboardKey(
                      action: SpaceAction(),
                      flex: 2,
                      child: const Text("SPACE"),
                    ),
                    KeyboardKey(
                      action: SubmitAction(),
                      focusedStyle: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(Colors.green[700]),
                        side: WidgetStateProperty.all(
                          const BorderSide(color: Colors.green, width: 3),
                        ),
                      ),
                      child: const Icon(Icons.keyboard_return),
                    ),
                  ]).toList(),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Text(
              'Current text: "${textController.text}"',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    textController.dispose();
    otherFieldController.dispose();
    super.dispose();
  }
}
