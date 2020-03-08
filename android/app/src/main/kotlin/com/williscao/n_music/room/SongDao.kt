package com.williscao.n_music.room

import androidx.room.*

@Dao
interface SongDao {

    @Query("SELECT * FROM Song")
    fun selectAll(): MutableList<Song>

    @Query("SELECT rowid FROM Song WHERE id = :id")
    fun getSongPosition(id: Int): Int

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insertSong(song: Song)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insertSongs(songs: MutableList<Song>)

    @Delete
    fun deleteSong(song: Song)

    @Delete
    fun deleteSongs(songs: MutableList<Song>)
}
