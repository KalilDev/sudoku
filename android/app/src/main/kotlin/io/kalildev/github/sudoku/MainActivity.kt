package io.kalildev.github.sudoku

import android.os.Bundle
import android.util.TypedValue
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import io.kalildev.github.sudoku.R

const val COLOR_CHANNEL_NAME: String = "io.kalildev.github.sudoku/splash_colors";
const val COLOR_CHANNEL_GET_COLORS_NAME: String = "get_colors";

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        installSplashScreen();
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
        val background = resources.getColor(R.color.ic_launcher_background);
        val foreground = resources.getColor(R.color.ic_launcher_foreground);
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, COLOR_CHANNEL_NAME)
        .setMethodCallHandler(ColorChannelHandler(
            background, foreground,
        ));
    }
}

class ColorChannelHandler(private val background: Int, private val foreground: Int): MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == COLOR_CHANNEL_GET_COLORS_NAME) {
            result.success(
            mapOf(
                "ic_launcher_foreground" to foreground,
                "ic_launcher_background" to background,
            )
            );
        } else {
            result.notImplemented()
        }
    }
}