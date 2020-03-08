package com.williscao.n_music.main

import android.os.Bundle
import androidx.lifecycle.ViewModelProvider
import com.williscao.n_music.base.BaseActivity
import com.williscao.n_music.media.AudioPlayerManager
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

const val MUSIC_CHANNEL = "com.williscao.n_music.main/music"
const val CHANNEL_METHOD_GET_SONG_LIST = "com.williscao.n_music.main/getSongList"
const val CHANNEL_METHOD_PLAY_SONG = "com.williscao.n_music.main/playSong"
const val CHANNEL_METHOD_PAUSE_SONG = "com.williscao.n_music.main/pauseSong"
const val CHANNEL_METHOD_COMPLETE_SONG = "com.williscao.n_music.main/completeSong"

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
            GlobalScope.launch(Dispatchers.Main) {
                when (call.method) {
                    CHANNEL_METHOD_GET_SONG_LIST -> mSvm.loadSongs(context, result)
                    CHANNEL_METHOD_PLAY_SONG -> mSvm.playSong(context, call.arguments as String, result)
                    CHANNEL_METHOD_PAUSE_SONG -> mSvm.playSong(context, call.arguments as String, result)
                    else -> result.notImplemented()
                }
            }
        }

        AudioPlayerManager.getInstance().songCompleteData.observeForever {
            mMCMusic.invokeMethod(CHANNEL_METHOD_COMPLETE_SONG, it)
        }
    }
}
