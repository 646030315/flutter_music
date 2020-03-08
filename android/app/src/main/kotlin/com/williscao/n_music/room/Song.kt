package com.williscao.n_music.room

import android.os.Parcel
import android.os.Parcelable
import android.text.TextUtils
import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey
import org.json.JSONObject
import java.io.File
import java.io.Serializable

@Entity
class Song() : Parcelable, Serializable {

    @PrimaryKey(autoGenerate = true)
    @ColumnInfo(name = "id")
    var id: Int = 0

    @ColumnInfo(name = "song_id")
    var songID = 0

    @ColumnInfo(name = "duration")
    var duration = 0

    @ColumnInfo(name = "album_id")
    var albumID = 0

    @ColumnInfo(name = "singer_name")
    var singerName: String? = ""

    @ColumnInfo(name = "song_name")
    var songName: String? = ""

    @ColumnInfo(name = "file_name")
    var fileName: String? = ""

    @ColumnInfo(name = "path")
    var path: String? = ""

    @ColumnInfo(name = "album")
    var album: String? = ""

    constructor(parcel: Parcel) : this() {
        id = parcel.readInt()
        songID = parcel.readInt()
        duration = parcel.readInt()
        albumID = parcel.readInt()
        singerName = parcel.readString()
        songName = parcel.readString()
        fileName = parcel.readString()
        path = parcel.readString()
        album = parcel.readString()
    }


    override fun writeToParcel(dest: Parcel?, flags: Int) {
        dest?.apply {
            writeInt(id)
            writeInt(songID)
            writeInt(duration)
            writeInt(albumID)
            writeString(singerName)
            writeString(songName)
            writeString(fileName)
            writeString(path)
            writeString(album)
        }
    }

    override fun describeContents(): Int = 0

    companion object CREATOR : Parcelable.Creator<Song> {
        override fun createFromParcel(parcel: Parcel): Song {
            return Song(parcel)
        }

        override fun newArray(size: Int): Array<Song?> {
            return arrayOfNulls(size)
        }
    }

    fun isSameSong(song: Song?): Boolean {
        return song?.id == id && song.path == path
    }

    fun isValidSong(): Boolean {
        return !TextUtils.isEmpty(path) && File(path).exists()
    }

    override fun toString(): String {
        return "Song(id=$id, songID=$songID, duration=$duration, albumID=$albumID, singerName=$singerName, songName=$songName, fileName=$fileName, path=$path, album=$album)"
    }

    fun toJson(): String {

        val json = JSONObject()
        json.put("id", id)
        json.put("songID", songID)
        json.put("duration", duration)
        json.put("albumID", albumID)
        json.put("singerName", singerName)
        json.put("songName", songName)
        json.put("fileName", fileName)
        json.put("path", path)
        json.put("album", album)

        return json.toString()
    }
}
