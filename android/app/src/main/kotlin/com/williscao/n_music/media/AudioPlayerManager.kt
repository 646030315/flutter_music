package com.williscao.n_music.media

import android.content.Context
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.os.Message
import android.text.TextUtils
import android.util.Log
import androidx.lifecycle.MutableLiveData
import com.google.android.exoplayer2.ExoPlaybackException
import com.google.android.exoplayer2.Player
import com.google.android.exoplayer2.SimpleExoPlayer
import com.google.android.exoplayer2.Timeline
import com.google.android.exoplayer2.source.MediaSource
import com.google.android.exoplayer2.source.ProgressiveMediaSource
import com.google.android.exoplayer2.upstream.DataSource
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory
import com.google.android.exoplayer2.upstream.HttpDataSource.HttpDataSourceException
import com.google.android.exoplayer2.upstream.HttpDataSource.InvalidResponseCodeException
import com.google.android.exoplayer2.util.Util
import java.io.File


/**
 * <pre>
 *     author: williscao
 *     time: 2020/3/8 19:26
 * <pre>
 */
class AudioPlayerManager private constructor() : Player.EventListener {

    companion object {
        const val TAG = "AudioPlayerManager"

        val instance = AudioPlayerManagerHolder.instance
    }

    private object AudioPlayerManagerHolder {
        val instance = AudioPlayerManager()
    }

    private var mPlayer: SimpleExoPlayer? = null
    private var mDataSourceFactory: DataSource.Factory? = null

    private var mPlayingAudioPath = ""

    var songCompleteData = MutableLiveData<String>()
    var progressData = MutableLiveData<Int>()
    var playingData = MutableLiveData<Boolean>()

    private val progressHandler = Handler(Looper.getMainLooper())
    private val progressRunnable: Runnable = object : Runnable {
        override fun run() {
            updateProgress()
            progressHandler.postDelayed(this, 1000)
        }
    }

    private fun updateProgress() {
        mPlayer?.let {
            progressData.postValue(mPlayer!!.currentPosition.toInt())
        }
    }

    fun play(context: Context, audioPath: String): Boolean {
        Log.d(TAG, "play audioPath : $audioPath")

        if (TextUtils.isEmpty(audioPath)) {
            return false
        }

        val file = File(audioPath)
        if (!file.exists() || file.isDirectory) {
            return false
        }

        mPlayingAudioPath = audioPath
        initPlayer(context)

        mPlayer?.apply {
            // This is the MediaSource representing the media to be played.
            val audioSource: MediaSource = ProgressiveMediaSource.Factory(mDataSourceFactory)
                    .createMediaSource(Uri.fromFile(file))
            // Prepare the player with the source.
            prepare(audioSource)
            playWhenReady = true
        }
        return true
    }

    /**
     * 根据当前的状态来决定暂停还是播放
     */
    fun resumeOrPause() {
        mPlayer?.apply {
            if (playbackState == Player.STATE_READY) {
                if (isPlaying) {
                    playWhenReady = false
                    updateProgress()
                } else {
                    playWhenReady = true
                }

            }
        }
    }

    /**
     * 播放音乐
     */
    fun resume() {
        mPlayer?.apply {
            if (playbackState == Player.STATE_READY) {
                if (!isPlaying) {
                    playWhenReady = true
                }
            }
        }
    }

    /**
     * 暂停音乐
     */
    fun pause() {
        mPlayer?.apply {
            if (playbackState == Player.STATE_READY) {
                if (isPlaying) {
                    playWhenReady = false
                }
            }
        }
    }

    private fun initPlayer(context: Context) {
        mPlayer?.apply {
            removeListener(this@AudioPlayerManager)
            release()
        }
        mPlayer = SimpleExoPlayer.Builder(context).build()
        // Produces DataSource instances through which media data is loaded.
        if (mDataSourceFactory == null) {
            mDataSourceFactory = DefaultDataSourceFactory(context,
                    Util.getUserAgent(context, "n_music"))
        }

        mPlayer!!.addListener(this)
    }

    override fun onIsPlayingChanged(isPlaying: Boolean) {
        Log.d(TAG, "onIsPlayingChanged isPlaying : $isPlaying")
        playingData.postValue(isPlaying)
        progressHandler.removeCallbacks(progressRunnable)
        if (isPlaying) {
            progressHandler.post(progressRunnable)
        }
    }

    override fun onPlayerError(error: ExoPlaybackException) {
        Log.d(TAG, "onPlayerError error : $error")
        if (error.type == ExoPlaybackException.TYPE_SOURCE) {
            val cause = error.sourceException
            if (cause is HttpDataSourceException) { // An HTTP error occurred.
                // This is the request for which the error occurred.
                val requestDataSpec = cause.dataSpec
                // It's possible to find out more about the error both by casting and by
                // querying the cause.
                if (cause is InvalidResponseCodeException) {
                    // Cast to InvalidResponseCodeException and retrieve the response code,
                    // message and headers.
                } else { // Try calling httpError.getCause() to retrieve the underlying cause,
                    // although note that it may be null.
                }
            }
        }
    }

    override fun onPositionDiscontinuity(reason: Int) {
        // 播放进度不连续回调
        Log.d(TAG, "onPositionDiscontinuity reason : $reason")
    }

    override fun onPlayerStateChanged(playWhenReady: Boolean, playbackState: Int) {
        Log.d(TAG, "onPlayerStateChanged curState : $playbackState, playWhenReady : $playWhenReady")

        when (playbackState) {
            Player.STATE_ENDED -> {
                progressHandler.removeCallbacks(progressRunnable)
                mPlayer?.apply {
                    removeListener(this@AudioPlayerManager)
                    release()
                }
                songCompleteData.postValue(mPlayingAudioPath)
            }
        }
    }

}