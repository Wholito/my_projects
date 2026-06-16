package com.autoparts.catalog;

import android.content.Context;
import android.content.SharedPreferences;

public class LocaleHelper {

    private static final String PREFS_NAME = "app_prefs";
    private static final String KEY_LANG = "language";
    public static final String LANG_EN = "en";
    public static final String LANG_RU = "ru";
    public static final String LANG_SYSTEM = "system";

    private final SharedPreferences prefs;

    public LocaleHelper(Context context) {
        prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
    }

    public void setLanguage(String lang) {
        prefs.edit().putString(KEY_LANG, lang).apply();
    }

    public String getLanguage() {
        return prefs.getString(KEY_LANG, LANG_SYSTEM);
    }
}
