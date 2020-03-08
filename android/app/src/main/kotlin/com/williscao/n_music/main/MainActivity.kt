package com.williscao.n_music.main

import android.os.Bundle
import androidx.lifecycle.ViewModelProvider
import com.williscao.n_music.base.BaseActivity
import io.flutter.plugin.common.MethodChannel

const val MUSIC_CHANNEL = "com.williscao.n_music.main/music"
const val CHANNEL_METHOD_GET_SONG_LIST = "com.williscao.n_music.main/getSongList"

class MainActivity : BaseActivity() {

    private lateinit var mSvm: SongViewModel
    private lateinit var mMCMusic: MethodChannel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        mSvm = ViewModelProvider(viewModelStore, ViewModelProvider.AndroidViewModelFactory.getInstance(application)).get(SongViewModel::class.java)
        initMethodChannel()
    }

    /**
     * 初始化 MethodChannel
     */
    private fun initMethodChannel() {
        mMCMusic = MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, MUSIC_CHANNEL)
        mMCMusic.setMethodCallHandler { call, result ->
            if (call.method == CHANNEL_METHOD_GET_SONG_LIST) {
                mSvm.loadSongs(context, result)
            } else {
                result.notImplemented()
            }
        }
    }
}
