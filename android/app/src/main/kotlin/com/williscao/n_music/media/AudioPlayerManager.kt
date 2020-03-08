package com.williscao.n_music.media

import android.content.Context
import android.net.Uri
import android.text.TextUtils
import android.util.Log
import com.google.android.exoplayer2.ExoPlaybackException
import com.google.android.exoplayer2.Player
import com.google.android.exoplayer2.SimpleExoPlayer
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
class AudioPlayerManager : Player.EventListener {


    companion object {
        const val TAG = "SimpleExoPlayer"

        var manager: AudioPlayerManager? = null

        fun getInstance(): AudioPlayerManager {
            if (manager == null) {
                synchronized(this) {
                    if (manager == null) {
                        manager = AudioPlayerManager()
                    }
                }
            }

            return manager!!
        }
    }

    private var mPlayer: SimpleExoPlayer? = null
    private var mDataSourceFactory: DataSource.Factory? = null

    fun play(context: Context, audioPath: String): Boolean {
        Log.d(TAG, "play audioPath : $audioPath")

        if (TextUtils.isEmpty(audioPath)) {
            return false
        }

        val file = File(audioPath)
        if (!file.exists() || file.isDirectory) {
            return false
        }

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
        if (isPlaying) {

        } else {

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
        Log.d(TAG, "onPlayerStateChanged curState : $playbackState")

        if (playbackState == Player.STATE_ENDED) {
            mPlayer?.apply {
                removeListener(this@AudioPlayerManager)
                release()
            }
        }
    }

}