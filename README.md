# couchkeys

[![Pub Package](https://img.shields.io/pub/v/couchkeys.svg)](https://pub.dartlang.org/packages/couchkeys)
[![Pub Points](https://img.shields.io/pub/points/couchkeys?color=2E8B57&label=pub%20points)](https://pub.dev/packages/couchkeys/score)

A customizable virtual keyboard package for Flutter applications, specifically designed for
use with D-pad navigation on devices like smart TVs and set-top boxes.

Inspired by the YouTube app for Android TV.

![image](https://github.com/user-attachments/assets/70ccf2c0-2dbc-4677-aad1-3aac8a4d0ad2)

## Features

- **D-pad Navigation Support**: Navigate between keys using arrow keys (↑↓←→)
- **Physical Keyboard Support**: Type directly with USB/Bluetooth keyboards connected to your TV
- **Customizable Keyboard Layout**: Define your own key arrangements
- **Focus Management**: Visual feedback with focused key highlighting
- **Key Activation**: Activate keys with Enter, Space, or Select buttons
- **Auto-focus**: Option to automatically focus the first key
- **Customizable Appearance**: Style keys and keyboard to match your app
- **Easy Integration**: Works seamlessly with Flutter `TextFields`

## Getting started

Add this to your `pubspec.yaml` file:
```yaml
dependencies:
  couchkeys: ^1.0.0
```
Then run:
```sh
flutter pub get
```

## Usage

### Basic Usage

```dart
import 'package:couchkeys/couchkeys.dart';

class _MyHomePageState extends State<MyHomePage> {
    final controller = TextEditingController();

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: Column(
                children: [
                    TextField(controller: controller),
                    Couchkeys(
                        controller: controller,
                        enableDpadNavigation: true, // Enable D-pad support
                        enablePhysicalKeyboard: true, // Enable physical keyboard
                        autofocus: true, // Auto-focus first key
                        keyboardHeight: 200,
                    ),
                ]
            )
        )
    }
}
```

### D-pad Navigation

When `enableDpadNavigation` is set to `true`, users can:

- **Navigate**: Use arrow keys (↑↓←→) to move between keys
- **Activate**: Press Enter, Space, or Select to activate the focused key
- **Visual Feedback**: The focused key will display a blue border
- **Auto-focus**: The first key can be automatically focused when the keyboard loads

### Physical Keyboard Support

When `enablePhysicalKeyboard` is set to `true`, users can:

- **Type Directly**: Type letters, numbers, and symbols using a physical keyboard
- **Global Handling**: Efficient keyboard handling at the widget level using HardwareKeyboard.instance
- **Special Keys**: Use Backspace, Delete, Enter, and Space keys
- **Submit**: Press Enter to trigger the submit action
- **Works with Focus**: Physical keyboard works when any virtual key is focused
- **Perfect for TV**: Ideal for Android TV apps with USB or Bluetooth keyboards connected

### Custom Layout with D-pad Support

```dart
Couchkeys(
  controller: controller,
  enableDpadNavigation: true,
  enablePhysicalKeyboard: true, // Enable physical keyboard input
  autofocus: true,
  customLayout: [
    // Numbers row
    ["1", "2", "3", "4", "5"]
        .map((v) => KeyboardKey(
              action: InsertAction(v),
              child: Text(v),
            ))
        .toList(),
    // Letters row
    ["A", "B", "C", "D", "E"]
        .map((v) => KeyboardKey(
              action: InsertAction(v),
              child: Text(v),
            ))
        .toList(),
    // Action row
    [
      KeyboardKey(
        action: SpaceAction(),
        flex: 2,
        child: const Text("SPACE"),
      ),
      KeyboardKey(
        action: BackspaceAction(),
        child: const Icon(Icons.backspace),
      ),
      KeyboardKey(
        action: ClearAction(),
        child: const Text("CLEAR"),
      ),
    ],
  ],
)
```

## API Reference

### Couchkeys Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `controller` | `TextEditingController?` | `null` | Controls the text being edited |
| `enableDpadNavigation` | `bool` | `true` | Enables D-pad navigation support |
| `enablePhysicalKeyboard` | `bool` | `true` | Enables physical keyboard input |
| `autofocus` | `bool` | `false` | Auto-focuses the first key when created |
| `focusNode` | `FocusNode?` | `null` | Focus node for the keyboard widget |
| `customLayout` | `List<List<KeyboardKey>>?` | `null` | Custom layout definition |
| `keyboardHeight` | `double?` | `200` | Height of the keyboard |
| `buttonStyle` | `ButtonStyle?` | `null` | Style applied to all keys |
| `onChanged` | `ValueChanged<String>?` | `null` | Callback when text changes |

### KeyboardKey Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `child` | `Widget` | required | Widget to display on the key |
| `action` | `KeyboardAction?` | `null` | Action to perform when pressed |
| `focusNode` | `FocusNode?` | `null` | Focus node for D-pad navigation |
| `canRequestFocus` | `bool` | `true` | Whether the key can be focused |
| `autofocus` | `bool` | `false` | Whether to auto-focus this key |
| `flex` | `int` | `1` | Space distribution in the row |
| `style` | `ButtonStyle?` | `null` | Custom styling for the key |

### Keyboard Actions

- `InsertAction(String)`: Inserts text
- `BackspaceAction()`: Deletes last character
- `SpaceAction()`: Inserts a space
- `ClearAction()`: Clears all text

## Examples

Check out the [example](example/) folder for complete examples:

- `main.dart`: Basic custom number pad
- `dpad_example.dart`: Full QWERTY keyboard with D-pad navigation
- `focus_test.dart`: Focus management and programmatic control
- `physical_keyboard_demo.dart`: Physical keyboard integration demo

## Documentation

Detailed API documentation can be found on [pub.dev](https://pub.dev/documentation/couchkeys).

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request or file an Issue on [GitHub](https://github.com/arafatamim/couchkeys).

## License

This project is MIT Licensed. See [LICENSE](https://github.com/arafatamim/couchkeys/blob/main/LICENSE) file for details.
