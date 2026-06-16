package com.autoparts.catalog;

import android.content.Context;
import android.content.SharedPreferences;

public class ThemeHelper {

    private static final String PREFS_NAME = "app_prefs";
    private static final String KEY_THEME = "theme";
    public static final int THEME_LIGHT = 0;
    public static final int THEME_DARK = 1;
    public static final int THEME_SYSTEM = 2;

    private final SharedPreferences prefs;

    public ThemeHelper(Context context) {
        prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
    }

    public void setTheme(int theme) {
        prefs.edit().putInt(KEY_THEME, theme).apply();
    }

    public int getTheme() {
        return prefs.getInt(KEY_THEME, THEME_SYSTEM);
    }
}
