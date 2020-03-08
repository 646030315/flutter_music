package com.williscao.n_music.main

import android.content.Context
import android.util.Log
import androidx.lifecycle.ViewModel
import com.williscao.n_music.room.Song
import com.williscao.n_music.room.SongRepository
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.ArrayList

/**
 * <pre>
 *     author: williscao
 *     time: 2020/3/8 11:26
 * <pre>
 */

class SongViewModel : ViewModel() {

    fun loadSongs(context: Context, result: MethodChannel.Result) {
        GlobalScope.launch(Dispatchers.Main) {
            try {

                var songs: List<String>? = null
                withContext(Dispatchers.IO) {
                    songs = SongRepository.getInstance().getSongs(context).map {
                        return@map it.toJson()
                    }
                }

                val resultValid = songs?.isNotEmpty() ?: false
                if (resultValid) {
                    result.success(songs)
                } else {
                    result.error("1001", "没有加载到歌曲", null)
                }
            } catch (e: Throwable) {
                e.printStackTrace()
            }
        }
    }

}