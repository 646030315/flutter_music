package com.williscao.n_music

import android.content.Context
import io.flutter.app.FlutterApplication

/**
 * <pre>
 *     author: williscao
 *     time: 2020/3/8 10:27
 * <pre>
 */

class MyApplication : FlutterApplication() {

    companion object {
        lateinit var context: Context
    }

    override fun onCreate() {
        super.onCreate()

        context = applicationContext
    }

}