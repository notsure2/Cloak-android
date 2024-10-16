package com.github.shadowsocks.plugin.ck_client

import android.os.Bundle
import androidx.preference.EditTextPreference
import androidx.preference.ListPreference
import androidx.preference.Preference
import androidx.preference.PreferenceFragmentCompat
import com.github.shadowsocks.plugin.PluginContract
import com.github.shadowsocks.plugin.PluginOptions


class ConfigFragment : PreferenceFragmentCompat() {
    var options = PluginOptions()

    fun onInitializePluginOptions(options: PluginOptions) {
        this.options = options
        val ary = arrayOf(Pair("ProxyMethod","shadowsocks"), Pair("EncryptionMethod","plain"),
                Pair("Transport", "direct"), Pair("UID", ""), Pair("PublicKey",""), Pair("ServerName", "bing.com"),
                Pair("AlternativeNames", ""), Pair("CDNOriginHost", ""), Pair("CDNWsUrlPath", ""), Pair("NumConn","4"),
                Pair("BrowserSig", "chrome"), Pair("StreamTimeout","300"), Pair("KeepAlive", "0"),
                Pair("LoopbackTcpSendBuffer", "0"), Pair("LoopbackTcpReceiveBuffer", "0"),
                Pair("RemoteTcpSendBuffer", "0"), Pair("RemoteTcpReceiveBuffer", "0"))
        for (element in ary) {
            val key = element.first
            val defaultValue = element.second
            val pref: Preference? = findPreference(key)
            val value: String = if ((options[key] ?: "").isBlank()) defaultValue else (options[key]?.trim() ?: "")
            when (pref) {
                is ListPreference -> {
                    pref.value = value
                }
                is EditTextPreference -> {
                    pref.text = value
                }
            }
            // we want all preferences to be put into the options, not only the changed ones
            options[key] = value
            pref!!.setOnPreferenceChangeListener(
                    fun(_, value: Any): Boolean {
                        options[key] = value.toString()
                        return true
                    }
            )
        }
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        outState.putString(PluginContract.EXTRA_OPTIONS, options.toString())
    }

    override fun onCreatePreferences(savedInstanceState: Bundle?, rootKey: String?) {
        if (savedInstanceState != null) {
            options = PluginOptions(savedInstanceState.getString(PluginContract.EXTRA_OPTIONS))
            onInitializePluginOptions(options)
        }
        addPreferencesFromResource(R.xml.config)
    }
}
