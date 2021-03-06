package com.williscao.n_music.media

import org.json.JSONObject

/**
 * <pre>
 *     author: williscao
 *     time: 2020/3/9 23:25
 * <pre>
 */
data class ProgressData(val progress: Int, val duration: Int, val buffed: Int) {

    fun toJson(): String {
        val json = JSONObject()
        json.put("progress", progress)
        json.put("duration", duration)
        json.put("buffed", buffed)
        return json.toString()
    }
}