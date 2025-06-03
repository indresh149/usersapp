import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences sharedPreferences;

  ThemeBloc({required this.sharedPreferences}) : super(const ThemeState(ThemeMode.system)) {
    on<ThemeModeChanged>(_onThemeModeChanged);
    on<LoadTheme>(_onLoadTheme);
    add(LoadTheme()); // Load theme on initialization
  }

  Future<void> _onThemeModeChanged(ThemeModeChanged event, Emitter<ThemeState> emit) async {
    emit(ThemeState(event.themeMode));
    await sharedPreferences.setString(AppConstants.themeModeKey, event.themeMode.toString());
  }

  Future<void> _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) async {
    final themeString = sharedPreferences.getString(AppConstants.themeModeKey);
    ThemeMode themeMode = ThemeMode.system;
    if (themeString == ThemeMode.light.toString()) {
      themeMode = ThemeMode.light;
    } else if (themeString == ThemeMode.dark.toString()) {
      themeMode = ThemeMode.dark;
    }
    emit(ThemeState(themeMode));
  }
}