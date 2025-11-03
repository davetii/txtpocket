import 'dart:io';
import 'package:flutter/services.dart';

class KeyboardHelper {
  /// Returns true if the primary modifier key is pressed
  /// On macOS: Cmd (Meta)
  /// On Windows/Linux: Ctrl
  static bool isPrimaryModifierPressed() {
    if (Platform.isMacOS) {
      return HardwareKeyboard.instance.isMetaPressed;
    }
    return HardwareKeyboard.instance.isControlPressed;
  }

  /// Returns true if Control key is pressed (for macOS-specific Ctrl shortcuts)
  static bool isControlPressed() {
    return HardwareKeyboard.instance.isControlPressed;
  }

  /// Returns true if Meta/Command key is pressed (macOS)
  static bool isMetaPressed() {
    return HardwareKeyboard.instance.isMetaPressed;
  }

  /// Returns true if Shift is pressed
  static bool isShiftPressed() {
    return HardwareKeyboard.instance.isShiftPressed;
  }

  /// Gets the display name for keyboard shortcuts based on platform
  static String getShortcutPrefix() {
    return Platform.isMacOS ? 'Cmd' : 'Ctrl';
  }
}
