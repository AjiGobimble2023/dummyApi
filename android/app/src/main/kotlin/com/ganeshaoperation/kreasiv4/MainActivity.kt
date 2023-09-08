package com.ganeshaoperation.kreasiv4

import android.os.Bundle
import android.view.WindowManager.LayoutParams
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.ganeshaoperation.kreasi/secure_screen"
    private lateinit var channel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        window.addFlags(LayoutParams.FLAG_SECURE)
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method.equals("setSecureScreen")) {
                var isSecure: Boolean = call.arguments as? Boolean ?: false

                if (isSecure) {
                    window.setFlags(LayoutParams.FLAG_SECURE, LayoutParams.FLAG_SECURE)
                } else {
                    window.clearFlags(LayoutParams.FLAG_SECURE)
                }
                result.success(isSecure)
            } else {
                result.notImplemented()
            }
        }
    }
//    override fun onCreate(savedInstanceState: Bundle?) {
//        super.onCreate(savedInstanceState)
//        window.setFlags(LayoutParams.FLAG_SECURE, LayoutParams.FLAG_SECURE)
//    }
}