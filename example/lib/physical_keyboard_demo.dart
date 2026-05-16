// Demonstrates physical keyboard support with Couchkeys

import 'package:couchkeys/couchkeys.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const PhysicalKeyboardApp());
}

class PhysicalKeyboardApp extends StatelessWidget {
  const PhysicalKeyboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Couchkeys Physical Keyboard Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const PhysicalKeyboardPage(),
    );
  }
}

class PhysicalKeyboardPage extends StatefulWidget {
  const PhysicalKeyboardPage({super.key});

  @override
  State<PhysicalKeyboardPage> createState() => _PhysicalKeyboardPageState();
}

class _PhysicalKeyboardPageState extends State<PhysicalKeyboardPage> {
  final controller = TextEditingController();
  bool enablePhysicalKeyboard = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Physical Keyboard Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Instructions
            Card(
              color: Colors.green[900],
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Physical Keyboard Features:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('✓ Type directly with your physical keyboard',
                        style: TextStyle(color: Colors.white)),
                    Text('✓ Global keyboard handling (more efficient!)',
                        style: TextStyle(color: Colors.white)),
                    Text('✓ Use arrow keys for navigation',
                        style: TextStyle(color: Colors.white)),
                    Text('✓ Press Enter to submit',
                        style: TextStyle(color: Colors.white)),
                    Text('✓ Backspace and Delete work as expected',
                        style: TextStyle(color: Colors.white)),
                    Text('✓ Works when any key is focused',
                        style: TextStyle(color: Colors.white)),
                    Text(
                        '✓ Perfect for Android TV with USB/Bluetooth keyboards',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Control toggle
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Text('Enable Physical Keyboard: '),
                    Switch(
                      value: enablePhysicalKeyboard,
                      onChanged: (value) {
                        setState(() {
                          enablePhysicalKeyboard = value;
                        });
                      },
                    ),
                    const Spacer(),
                    Text(
                      enablePhysicalKeyboard ? 'ON' : 'OFF',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            enablePhysicalKeyboard ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Text field
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Type here using virtual or physical keyboard...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.keyboard),
              ),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),

            // Virtual keyboard optimized for physical keyboard use
            Expanded(
              child: Couchkeys(
                controller: controller,
                enableDpadNavigation: true,
                enablePhysicalKeyboard: enablePhysicalKeyboard,
                autofocus: true,
                keyboardHeight: 280,
                buttonStyle: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.grey[800]),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                  textStyle: WidgetStateProperty.all(
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                focusedButtonStyle: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.green[600]),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                  textStyle: WidgetStateProperty.all(
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  side: WidgetStateProperty.all(
                    const BorderSide(color: Colors.green, width: 2),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  elevation: WidgetStateProperty.all(4),
                ),
                onSubmit: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          Text('Submitted: "${controller.text}"'),
                        ],
                      ),
                      backgroundColor: Colors.green[700],
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
                customLayout: [
                  // Top number row
                  ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
                      .map(
                        (v) => KeyboardKey(
                          action: InsertAction(v),
                          child: Text(v),
                        ),
                      )
                      .toList(),

                  // QWERTY layout
                  ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
                      .map(
                        (v) => KeyboardKey(
                          action: InsertAction(v),
                          child: Text(v),
                        ),
                      )
                      .toList(),

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
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.backspace, size: 16),
                          SizedBox(width: 4),
                          Text("DEL", style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ]).toList(),

                  ["Z", "X", "C", "V", "B", "N", "M"]
                      .map(
                    (v) => KeyboardKey(
                      action: InsertAction(v),
                      child: Text(v),
                    ),
                  )
                      .followedBy([
                    KeyboardKey(
                      action: InsertAction(","),
                      child: const Text(","),
                    ),
                    KeyboardKey(
                      action: InsertAction("."),
                      child: const Text("."),
                    ),
                    KeyboardKey(
                      action: InsertAction("?"),
                      child: const Text("?"),
                    ),
                  ]).toList(),

                  // Bottom row with special keys
                  [
                    KeyboardKey(
                      action: ClearAction(),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.clear, size: 16),
                          SizedBox(width: 4),
                          Text("CLEAR", style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                    KeyboardKey(
                      action: SpaceAction(),
                      flex: 4,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.space_bar, size: 16),
                          SizedBox(width: 4),
                          Text("SPACE", style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    KeyboardKey(
                      action: SubmitAction(),
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(Colors.blue[700]),
                      ),
                      focusedStyle: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(Colors.blue[500]),
                        side: WidgetStateProperty.all(
                          const BorderSide(color: Colors.blue, width: 3),
                        ),
                        elevation: WidgetStateProperty.all(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.keyboard_return, size: 16),
                          SizedBox(width: 4),
                          Text("ENTER", style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),
            // Status row
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Current text: "${controller.text}"',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                Icon(
                  enablePhysicalKeyboard ? Icons.keyboard : Icons.touch_app,
                  color: enablePhysicalKeyboard ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  enablePhysicalKeyboard ? 'Physical KB' : 'Touch Only',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        enablePhysicalKeyboard ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
