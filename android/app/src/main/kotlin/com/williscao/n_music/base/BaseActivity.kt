package com.williscao.n_music.base

import android.annotation.SuppressLint
import androidx.annotation.NonNull
import androidx.lifecycle.ViewModelStore
import androidx.lifecycle.ViewModelStoreOwner
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

/**
 * <pre>
 *     author: williscao
 *     time: 2020/3/8 11:53
 * <pre>
 */
@SuppressLint("Registered")
open class BaseActivity : FlutterActivity(), ViewModelStoreOwner {

    private var mViewModelStore: ViewModelStore? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }

    override fun getViewModelStore(): ViewModelStore {
        if (mViewModelStore == null) {
            mViewModelStore = ViewModelStore()
        }
        return mViewModelStore!!
    }
}