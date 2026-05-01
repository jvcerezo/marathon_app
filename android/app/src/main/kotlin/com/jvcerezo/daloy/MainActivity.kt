package com.jvcerezo.daloy

import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val channel = "daloy/share"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isInstagramInstalled" -> {
                        result.success(isPackageInstalled("com.instagram.android"))
                    }
                    "shareToInstagramStories" -> {
                        val path = call.argument<String>("path")
                        if (path == null) {
                            result.error("missing-path", "path argument required", null)
                            return@setMethodCallHandler
                        }
                        try {
                            shareToStories(path)
                            result.success(true)
                        } catch (e: ActivityNotFoundException) {
                            result.error("ig-not-installed",
                                "Instagram is not installed on this device.", null)
                        } catch (e: Exception) {
                            result.error("share-failed", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun isPackageInstalled(pkg: String): Boolean = try {
        packageManager.getPackageInfo(pkg, 0)
        true
    } catch (e: PackageManager.NameNotFoundException) {
        false
    }

    /**
     * Launches Instagram's Stories share intent with our PNG as the
     * `interactive_asset_uri`. This is what makes the image arrive as a
     * draggable, resizable sticker on top of whatever background the
     * user picks in Stories — same mechanism Strava uses.
     */
    private fun shareToStories(filePath: String) {
        val file = File(filePath)
        val uri: Uri = FileProvider.getUriForFile(
            this,
            "${applicationContext.packageName}.fileprovider",
            file,
        )

        val intent = Intent("com.instagram.share.ADD_TO_STORY").apply {
            setDataAndType(uri, "image/png")
            // Granting URI permission via flag + explicit grant for old
            // Android revisions where the flag alone isn't enough.
            flags = Intent.FLAG_GRANT_READ_URI_PERMISSION
            putExtra("interactive_asset_uri", uri.toString())
            // Optional but conventional: lets IG link back to our app.
            putExtra("source_application", applicationContext.packageName)
        }
        grantUriPermission(
            "com.instagram.android",
            uri,
            Intent.FLAG_GRANT_READ_URI_PERMISSION,
        )
        startActivity(intent)
    }
}
