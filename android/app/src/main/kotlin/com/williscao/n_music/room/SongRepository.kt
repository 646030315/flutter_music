package com.williscao.n_music.room

import android.content.Context
import android.provider.MediaStore
import android.text.TextUtils
import java.io.File
import java.util.*
import kotlin.collections.ArrayList
import kotlin.collections.set

/**
 * <pre>
 *     author: williscao
 *     time  : 2019-10-18
 * </pre>
 */
class SongRepository {

    private val mProjection = arrayOf(MediaStore.Audio.AudioColumns.TITLE,
            MediaStore.Audio.AudioColumns.DATA,
            MediaStore.Audio.AudioColumns.DISPLAY_NAME,
            MediaStore.Audio.AudioColumns.DURATION,
            MediaStore.Audio.AudioColumns._ID,
            MediaStore.Audio.AudioColumns.ALBUM_ID,
            MediaStore.Audio.AudioColumns.ARTIST,
            MediaStore.Audio.AudioColumns.ALBUM
    )

    /**
     * 获取歌曲，有两种方式
     * 1. room数据库获取：从媒体库扫描到的歌曲然后保存下来。如果room数据库没有就从媒体库进行扫描
     * 2. 媒体库扫描
     */
    fun getSongs(context: Context, forceLoad: Boolean = false): MutableList<Song> {
        synchronized(this) {
            var songs: MutableList<Song>? = null
            if (!forceLoad) {
                songs = SongDatabase.INSTANCE.songDao().selectAll()
            }
            val hasSongs = songs?.isNotEmpty() ?: false
            if (!hasSongs) {
                songs = doLoadSongsFromMedia(context)
            }

            songs?.sortWith(Comparator { o1, o2 ->
                o1.id - o2.id
            })

            return songs ?: arrayListOf()
        }
    }

    private fun doLoadSongsFromMedia(context: Context): MutableList<Song> {
        // 我们的本地数据库有没有保存扫描到的歌曲，我们进行本地磁盘扫描
        // 获取媒体库音乐，is_ringtone == 0过滤手机铃声，title COLLATE LOCALIZED ASC 搜索的排序是 先显示中文，然后显示英文，分别按照字母的升序显示，按照产品需求，先显示英文
        val sortOrder = MediaStore.Audio.Media.TITLE + " COLLATE LOCALIZED ASC"
        val cursor = context.contentResolver.query(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, mProjection, "", arrayOf(), sortOrder)

        // 如果没有扫描到歌曲
        if (cursor == null || cursor.count == 0) {
            cursor?.close()
            return arrayListOf()
        }

        // 用来记录歌曲名，当歌曲名重复之后，需要后面加序号处理： 稻香   稻香(1)   稻香(2)   稻香(3)
        val titleRecord = HashMap<String, Int>()
        // 开始遍历扫描到的歌曲
        cursor.moveToFirst()
        var song: Song?
        val songs = arrayListOf<Song>()
        val englishSong = ArrayList<Song>()
        val chineseSong = ArrayList<Song>()
        var id = 0
        while (cursor.moveToNext()) {
            val path = cursor.getString(cursor.getColumnIndex(MediaStore.Audio.AudioColumns.DATA))
            val file = File(path)
            if (file.exists() && file.isFile) {
                var title = cursor.getString(cursor.getColumnIndex(MediaStore.Audio.AudioColumns.TITLE)).trim()
                val record = if (titleRecord[title] == null) 1 else {
                    titleRecord[title]!!.plus(1)
                } // 当前歌曲的出现次数
                titleRecord[title] = record
                if (record > 1) {
                    title += " (" + (record - 1) + ")" // 后面的序号比出现次数少一  -> 稻香   稻香(1)   稻香(2)   稻香(3)
                }
                song = Song()
                song.songName = title
                song.id = ++id
                song.path = path

                song.fileName = cursor.getString(cursor.getColumnIndex(MediaStore.Audio.AudioColumns.DISPLAY_NAME)).trim()
                song.duration = cursor.getInt(cursor.getColumnIndex(MediaStore.Audio.AudioColumns.DURATION))
                song.songID = cursor.getInt(cursor.getColumnIndex(MediaStore.Audio.AudioColumns._ID))
                song.albumID = cursor.getInt(cursor.getColumnIndex(MediaStore.Audio.AudioColumns.ALBUM_ID))
                song.singerName = cursor.getString(cursor.getColumnIndex(MediaStore.Audio.AudioColumns.ARTIST)).trim()
                song.album = cursor.getString(cursor.getColumnIndex(MediaStore.Audio.AudioColumns.ALBUM)).trim()
                if (isChineseSong(title)) {
                    chineseSong.add(song)
                } else {
                    englishSong.add(song)
                }
            }
        }

        songs.addAll(englishSong)
        songs.addAll(chineseSong)

        SongDatabase.INSTANCE.songDao().insertSongs(songs)
        cursor.close()
        titleRecord.clear()
        return songs
    }

    fun deleteSong(song: Song) {
        val dao = SongDatabase.INSTANCE.songDao()
        dao.deleteSong(song)
    }

    fun getLastSongInfo(context: Context): Song {
        val preference = context.getSharedPreferences(PREFERENCE_NAME, Context.MODE_PRIVATE)

        val song = Song()
        song.album = preference.getString(KEY_ALBUM_NAME, "")
        song.albumID = preference.getInt(KEY_ALBUM_ID, 0)
        song.path = preference.getString(KEY_M4A, "")
        song.songID = preference.getInt(KEY_SONG_ID, 0)
        song.id = preference.getInt(KEY_ID, 0)
        song.singerName = preference.getString(KEY_SINGER_NAME, "")
        song.songName = preference.getString(KEY_SONG_NAME, "")

        return song
    }

    fun saveLastSongInfo(context: Context, song: Song) {
        val preference = context.getSharedPreferences(PREFERENCE_NAME, Context.MODE_PRIVATE)
        val editor = preference.edit()
        editor.putInt(KEY_ALBUM_ID, song.albumID)
        editor.putString(KEY_ALBUM_NAME, song.album)
        editor.putString(KEY_M4A, song.path)
        editor.putString(KEY_SINGER_NAME, song.singerName)
        editor.putInt(KEY_SONG_ID, song.songID)
        editor.putInt(KEY_ID, song.id)
        editor.putString(KEY_SONG_NAME, song.songName)
        editor.apply()
    }

    /**
     * 通过判断第一个字符是不是中文来判断是中文歌曲还是英文歌曲
     */
    private fun isChineseSong(title: String): Boolean {
        if (!TextUtils.isEmpty(title)) {
            return title.toCharArray()[0].toInt() in 0x4E00..0x9FA5
        }
        return false
    }

    companion object {

        private const val PREFERENCE_NAME = "last_song"
        private const val KEY_ALBUM_ID = "last_alubm_id"
        private const val KEY_ALBUM_NAME = "album_name"
        private const val KEY_M4A = "m4a"
        private const val KEY_SINGER_NAME = "singer_name"
        private const val KEY_SONG_ID = "song_id"
        private const val KEY_ID = "id"
        private const val KEY_SONG_NAME = "song_name"

        private var instance: SongRepository? = null

        fun getInstance(): SongRepository {
            if (instance == null) {
                synchronized(SongRepository::class) {
                    if (instance == null) {
                        instance = SongRepository()
                    }
                }
            }
            return instance!!
        }
    }
}