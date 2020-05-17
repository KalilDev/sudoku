import 'dart:developer';

import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:sudoku/presentation/sudoku_bloc/state.dart';
import 'preferences_repository.dart';

class CrossPreferencesRepository implements PreferencesRepository {
  Future<LocalStorageInterface> get prefs => LocalStorage.getInstance();

  @override
  Future<AnimationOptions> getAnimationOptions() async {
    final pref = await prefs;
    final optsStrings = pref.getStringList("animationOptions");
    if (optsStrings == null)
      return null;
    final options = AnimationOptions.parse(optsStrings);
    return options;
  }

  @override
  Future<String> getCurrentTheme() => prefs.then((pref) => pref.getString("currentTheme"));

  @override
  Future<int> getMainMenuX() => prefs.then((pref) => pref.getInt("mainMenuX"));

  @override
  Future<int> getMainMenuY() => prefs.then((pref) => pref.getInt("mainMenuY"));

  @override
  Future<void> updateAnimationOptions(AnimationOptions options) async {
    final pref = await prefs;
    final optsStrings = options.toStringList();
    pref.setStringList("animationOptions", optsStrings);
  }

  @override
  Future<void> updateMainMenuX(int x) => prefs.then((pref) => pref.setInt("mainMenuX", x));

  @override
  Future<void> updateMainMenuY(int y) => prefs.then((pref) => pref.setInt("mainMenuY", y));
  
  @override
  Future<void> updateTheme(String themeName) => prefs.then((pref) => pref.setString("currentTheme", themeName));

}