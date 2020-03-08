package com.williscao.n_music.media

import android.app.PendingIntent
import android.os.Build
import android.os.Bundle
import android.support.v4.media.MediaBrowserCompat
import android.support.v4.media.session.MediaSessionCompat
import android.support.v4.media.session.PlaybackStateCompat
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import androidx.media.MediaBrowserServiceCompat
import androidx.media.session.MediaButtonReceiver
import com.williscao.n_music.R


/**
 * <pre>
 *     author: williscao
 *     time: 2020/3/8 17:08
 * <pre>
 */
@RequiresApi(Build.VERSION_CODES.LOLLIPOP)
class AudioPlayBackService : MediaBrowserServiceCompat() {


    companion object {
        const val MY_MEDIA_ROOT_ID = "root"
        const val MY_EMPTY_MEDIA_ROOT_ID = "empty"
        const val NOTIFICATION_ID = 1000
    }

    private lateinit var mediaSession: MediaSessionCompat
    private lateinit var stateBuilder: PlaybackStateCompat.Builder

    override fun onCreate() {
        super.onCreate()

        mediaSession = MediaSessionCompat(baseContext, "AudioPlayBackService").apply {
            stateBuilder = PlaybackStateCompat.Builder()
                    .setActions(PlaybackStateCompat.ACTION_PLAY or PlaybackStateCompat.ACTION_PLAY_PAUSE)
            setPlaybackState(stateBuilder.build())
            setCallback(object : MediaSessionCompat.Callback() {})
            setSessionToken(sessionToken)
        }
    }

    override fun onGetRoot(clientPackageName: String, clientUid: Int, rootHints: Bundle?): BrowserRoot? {
        return if (allowBrowsing(clientPackageName, clientUid)) {
            // Returns a root ID that clients can use with onLoadChildren() to retrieve
            // the content hierarchy.
            BrowserRoot(MY_MEDIA_ROOT_ID, null)
        } else {
            // Clients can connect, but this BrowserRoot is an empty hierachy
            // so onLoadChildren returns nothing. This disables the ability to browse for content.
            BrowserRoot(MY_EMPTY_MEDIA_ROOT_ID, null)
        }
    }

    private fun allowBrowsing(clientPackageName: String, clientUid: Int) = true

    override fun onLoadChildren(parentId: String, result: Result<MutableList<MediaBrowserCompat.MediaItem>>) {
        if (MY_EMPTY_MEDIA_ROOT_ID == parentId) {
            result.sendResult(null)
            return
        }

        val mediaItems = mutableListOf<MediaBrowserCompat.MediaItem>()

        if (MY_MEDIA_ROOT_ID == parentId) {

        } else {

        }

        result.sendResult(mediaItems)
    }

    /**
     * 使服务置于前台，在音乐播放之后调用
     */
    private fun makeServiceForeground() {
        // Get the session's metadata
        val controller = mediaSession.controller
        val mediaMetadata = controller.metadata
        val description = mediaMetadata?.description

        val builder = NotificationCompat.Builder(baseContext, "").apply {
            description?.let {
                // Add the metadata for the currently playing track
                setContentTitle(description.title)
                setContentText(description.subtitle)
                setSubText(description.description)
                setLargeIcon(description.iconBitmap)
            }

            // Enable launching the player by clicking the notification
            setContentIntent(controller.sessionActivity)

            // Stop the service when the notification is swiped away
            setDeleteIntent(MediaButtonReceiver.buildMediaButtonPendingIntent(
                    baseContext,
                    PlaybackStateCompat.ACTION_STOP
            ))

            // Make the transport controls visible on the lock screen
            setVisibility(NotificationCompat.VISIBILITY_PUBLIC)

            // Add an app icon and set its accent color
            // Be careful about the color
            setSmallIcon(R.mipmap.stat_notify_red)
            color = ContextCompat.getColor(baseContext, R.color.themeColor)

            // Add a pause button
            addAction(
                    NotificationCompat.Action(
                            R.mipmap.note_btn_pause,
                            getString(R.string.pause),
                            MediaButtonReceiver.buildMediaButtonPendingIntent(
                                    baseContext,
                                    PlaybackStateCompat.ACTION_PAUSE
                            )
                    )
            )

            // Take advantage of MediaStyle features
            setStyle(androidx.media.app.NotificationCompat.MediaStyle()
                    .setMediaSession(mediaSession.sessionToken)
                    .setShowActionsInCompactView(0)

                    // Add a cancel button
                    .setShowCancelButton(true)
                    .setCancelButtonIntent(
                            MediaButtonReceiver.buildMediaButtonPendingIntent(
                                    baseContext,
                                    PlaybackStateCompat.ACTION_STOP
                            )
                    )
            )
        }

        // Display the notification and place the service in the foreground
        startForeground(NOTIFICATION_ID, builder.build())
    }

}