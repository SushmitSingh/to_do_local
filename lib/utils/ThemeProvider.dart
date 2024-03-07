import 'package:flutter/material.dart';

import 'AppColors.dart';
import 'AppTheme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode selectedThemeMode = appThemes[0].mode;

  setSelectedThemeMode(ThemeMode _themeMode) {
    selectedThemeMode = _themeMode;
    notifyListeners();
  }

  Color selectedPrimaryColor = AppColors.primaryColors[0];

  setSelectedPrimaryColor(Color _color) {
    selectedPrimaryColor = _color;
    notifyListeners();
  }
}
