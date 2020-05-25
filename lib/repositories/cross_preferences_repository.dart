import 'package:cross_local_storage/cross_local_storage.dart';
import 'package:sudoku_presentation/common.dart';
import 'package:sudoku_presentation/repositories.dart';

class CrossPreferencesRepository implements PreferencesRepository {
  Future<LocalStorageInterface> get prefs async => await LocalStorage.getInstance();

  @override
  Future<AnimationOptions> getAnimationOptions() async {
    final pref = await prefs;
    final optsStrings = pref.getStringList("animationOptions");
    if (optsStrings == null || optsStrings.isEmpty) {
      return null;
    }
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
    await pref.setStringList("animationOptions", optsStrings);
  }

  @override
  Future<void> updateMainMenuX(int x) => prefs.then((pref) => pref.setInt("mainMenuX", x));

  @override
  Future<void> updateMainMenuY(int y) => prefs.then((pref) => pref.setInt("mainMenuY", y));
  
  @override
  Future<void> updateTheme(String themeName) => prefs.then((pref) => pref.setString("currentTheme", themeName));

  @override
  Future<bool> getAknowledgement() => prefs.then((pref)=>pref.getBool("storageAknowledgement"));

  @override
  Future<void> updateAknowledgement(bool a) => prefs.then((pref)=>pref.setBool("storageAknowledgement", a));

}