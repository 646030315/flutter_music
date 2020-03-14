package com.williscao.n_music.media

import android.content.Context
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.text.TextUtils
import android.util.Log
import androidx.lifecycle.MutableLiveData
import com.google.android.exoplayer2.ExoPlaybackException
import com.google.android.exoplayer2.Player
import com.google.android.exoplayer2.SimpleExoPlayer
import com.google.android.exoplayer2.source.MediaSource
import com.google.android.exoplayer2.source.ProgressiveMediaSource
import com.google.android.exoplayer2.upstream.DataSource
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory
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
        const val OPERATION_SEEK = 0 // 手动拖拽进度条
        const val OPERATION_PAUSE = 1 // 手动点击了暂停
        const val OPERATION_NONE = 2  // 当前无任何操作
        const val OPERATION_RESUME = 3 // 恢复播放

        val instance = AudioPlayerManagerHolder.instance
    }

    private object AudioPlayerManagerHolder {
        val instance = AudioPlayerManager()
    }

    private var mPlayer: SimpleExoPlayer? = null
    private var mDataSourceFactory: DataSource.Factory? = null

    private var mPlayingAudioPath = ""

    var songCompleteData = MutableLiveData<String>() // 歌曲播放完成观察者
    var songErrorData = MutableLiveData<String>()  // 歌曲播放出错观察者
    var progressData = MutableLiveData<ProgressData>() // 歌曲播放进度观察者
    var playingStateChangeData = MutableLiveData<Boolean>()  // 歌曲播放状态变化观察者

    private var mOperationType = OPERATION_NONE

    private val progressHandler = Handler(Looper.getMainLooper())
    private val progressRunnable: Runnable = object : Runnable {
        override fun run() {
            updateProgress()
            progressHandler.postDelayed(this, 1000)
        }
    }

    private fun updateProgress() {
        mPlayer?.let {
            progressData.postValue(ProgressData(mPlayer!!.currentPosition.toInt(), mPlayer!!.duration.toInt(), mPlayer!!.bufferedPosition.toInt()))
        }
    }

    /**
     * 根据音频文件路径进行播放
     */
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
     * 播放前初始化播放器
     */
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
        // 操作类型复位到none状态
        mOperationType = OPERATION_NONE
    }

    /**
     * 根据当前的状态来决定暂停还是播放
     */
    fun resumeOrPause() {
        mPlayer?.apply {
            if (playbackState == Player.STATE_READY) {
                if (isPlaying) {
                    pause()
                } else {
                    resume()
                }
            }
        }
    }

    /**
     * 播放音乐
     */
    fun resume() {
        mPlayer?.apply {
            mOperationType = OPERATION_RESUME
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
            mOperationType = OPERATION_PAUSE
            if (playbackState == Player.STATE_READY) {
                if (isPlaying) {
                    playWhenReady = false
                }
            }
        }
    }

    /**
     * 拉进度条，修改播放位置
     */
    fun seekTo(percent: Int) {
        mPlayer?.apply {
            mOperationType = OPERATION_SEEK
            val position = percent * duration / 100
            seekTo(position)
        }
    }

    /**
     * 正在播放状态变化
     */
    override fun onIsPlayingChanged(isPlaying: Boolean) {
        Log.d(TAG, "onIsPlayingChanged isPlaying : $isPlaying")
        playingStateChangeData.postValue(isPlaying)
        progressHandler.removeCallbacks(progressRunnable)
        if (isPlaying) {
            progressHandler.post(progressRunnable)
        } else {
            if (mOperationType > OPERATION_PAUSE) {
                // 在没有任何人为操作而暂停的情况视为音频文件有问题
                onMusicPlayingError()
            }
        }
    }

    /**
     * 音频播放出问题，音频文件可能损坏
     */
    private fun onMusicPlayingError() {
        Log.d(TAG, "onMusicPlayingError broken file")
        songErrorData.postValue(mPlayingAudioPath)
    }

    override fun onPlayerError(error: ExoPlaybackException) {
        Log.d(TAG, "onPlayerError error : $error")
//        if (error.type == ExoPlaybackException.TYPE_SOURCE) {
//            val cause = error.sourceException
//            if (cause is HttpDataSourceException) { // An HTTP error occurred.
//                // This is the request for which the error occurred.
//                val requestDataSpec = cause.dataSpec
//                // It's possible to find out more about the error both by casting and by
//                // querying the cause.
//                if (cause is InvalidResponseCodeException) {
//                    // Cast to InvalidResponseCodeException and retrieve the response code,
//                    // message and headers.
//                } else { // Try calling httpError.getCause() to retrieve the underlying cause,
//                    // although note that it may be null.
//                }
//            }
//        }
    }

    override fun onPositionDiscontinuity(reason: Int) {
        // 播放进度不连续回调
        Log.d(TAG, "onPositionDiscontinuity reason : $reason")
    }

    override fun onPlayerStateChanged(playWhenReady: Boolean, playbackState: Int) {
        Log.d(TAG, "onPlayerStateChanged curState : $playbackState, playWhenReady : $playWhenReady")

        when (playbackState) {
            Player.STATE_READY -> if (playWhenReady) onStart()
            Player.STATE_ENDED -> onComplete()
            Player.STATE_BUFFERING -> onBuffering()
            Player.STATE_IDLE -> onPlayerIDLE()
        }
    }

    /**
     * 音乐播放开始
     */
    private fun onStart() {
        Log.d(TAG, "onStart")
    }

    private fun onComplete() {
        Log.d(TAG, "onStart")
        progressHandler.removeCallbacks(progressRunnable)
        mPlayer?.apply {
            removeListener(this@AudioPlayerManager)
            release()
        }
        songCompleteData.postValue(mPlayingAudioPath)
    }

    /**
     * 音频缓冲中
     */
    private fun onBuffering() {

    }

    /**
     * 播放器空闲中
     */
    private fun onPlayerIDLE() {

    }
}