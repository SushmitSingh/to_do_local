import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'AppColors.dart';
import 'AppTheme.dart';
import 'ThemeProvider.dart';

const double _containerWidth = 450.0;

class ThemeSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (c, themeProvider, _) => SizedBox(
        height: (_containerWidth - (17 * 2) - (10 * 2)) / 3,
        child: GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          crossAxisCount: appThemes.length,
          children: List.generate(
            appThemes.length,
            (i) {
              bool _isSelectedTheme =
                  appThemes[i].mode == themeProvider.selectedThemeMode;
              return GestureDetector(
                onTap: _isSelectedTheme
                    ? null
                    : () =>
                        themeProvider.setSelectedThemeMode(appThemes[i].mode),
                child: AnimatedContainer(
                  height: 100,
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: _isSelectedTheme
                        ? Theme.of(context).primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        width: 2, color: Theme.of(context).primaryColor),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 7),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).cardColor.withOpacity(0.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(appThemes[i].icon),
                          Text(
                            appThemes[i].title,
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class PrimaryColorSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (c, themeProvider, _) => SizedBox(
        height: (_containerWidth - (17 * 2) - (10 * 2)) / 3,
        child: GridView.count(
          crossAxisCount: AppColors.primaryColors.length,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          children: List.generate(
            AppColors.primaryColors.length,
            (i) {
              bool _isSelectedColor = AppColors.primaryColors[i] ==
                  themeProvider.selectedPrimaryColor;
              return GestureDetector(
                onTap: _isSelectedColor
                    ? null
                    : () => themeProvider
                        .setSelectedPrimaryColor(AppColors.primaryColors[i]),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColors[i],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isSelectedColor ? 1 : 0,
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: Theme.of(context).cardColor.withOpacity(0.5),
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
