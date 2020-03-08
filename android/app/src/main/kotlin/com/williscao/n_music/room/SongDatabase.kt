package com.williscao.n_music.room

import android.util.Log
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.sqlite.db.SupportSQLiteDatabase
import com.williscao.n_music.MyApplication

@Database(entities = [Song::class], version = 1)
abstract class SongDatabase : RoomDatabase() {

    /**
     * 获取歌曲的dao对象
     */
    abstract fun songDao(): SongDao

    companion object {
        private const val TAG = "SongDatabase"

        val INSTANCE: SongDatabase by lazy(mode = LazyThreadSafetyMode.SYNCHRONIZED) {
            buildDatabase()
        }

        private fun buildDatabase(): SongDatabase {
            return Room.databaseBuilder(MyApplication.context, SongDatabase::class.java, "local_song")
                    .addCallback(object : Callback() {

                        override fun onCreate(db: SupportSQLiteDatabase) {
                            Log.d(TAG, "onCreate")//数据库文件每次打开的时候调用
                        }

                        override fun onOpen(db: SupportSQLiteDatabase) {
                            Log.d(TAG, "onOpen")//数据库文件每次打开的时候调用
                        }
                    })
                    .build()
        }
    }
}
