import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemedAppBar extends AppBar {
  ThemedAppBar({
    super.key,
    required String title,
  }) : super(
          title: Text(title),
          centerTitle: true,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Provider.of<ThemeProvider>(
              navigatorKey.currentContext!,
              listen: false,
            ).isDarkMode
                ? Colors.white
                : Colors.black,
          ),
          backgroundColor:
              Provider.of<ThemeProvider>(
                navigatorKey.currentContext!,
                listen: false,
              ).isDarkMode
                  ? Colors.grey[900]
                  : Colors.white,
        );

  static final navigatorKey = GlobalKey<NavigatorState>();
}