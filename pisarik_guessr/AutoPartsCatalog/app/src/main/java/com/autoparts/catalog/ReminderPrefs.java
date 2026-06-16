package com.autoparts.catalog;

import android.content.Context;
import android.content.SharedPreferences;

final class ReminderPrefs {
    private static final String PREFS = "catalog_reminder";
    private static final String KEY_ENABLED = "enabled";
    private static final String KEY_HOUR = "hour";
    private static final String KEY_MINUTE = "minute";

    private ReminderPrefs() {
    }

    static SharedPreferences prefs(Context ctx) {
        return ctx.getApplicationContext().getSharedPreferences(PREFS, Context.MODE_PRIVATE);
    }

    static boolean isEnabled(Context ctx) {
        return prefs(ctx).getBoolean(KEY_ENABLED, false);
    }

    static void setEnabled(Context ctx, boolean on) {
        prefs(ctx).edit().putBoolean(KEY_ENABLED, on).apply();
    }

    static int getHour(Context ctx) {
        return prefs(ctx).getInt(KEY_HOUR, 9);
    }

    static int getMinute(Context ctx) {
        return prefs(ctx).getInt(KEY_MINUTE, 0);
    }

    static void setTime(Context ctx, int hour, int minute) {
        prefs(ctx).edit().putInt(KEY_HOUR, hour).putInt(KEY_MINUTE, minute).apply();
    }
}
