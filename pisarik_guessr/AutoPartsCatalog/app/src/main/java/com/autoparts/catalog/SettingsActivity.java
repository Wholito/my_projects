package com.autoparts.catalog;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.widget.RadioGroup;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.Toolbar;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.google.android.material.button.MaterialButton;
import com.google.android.material.switchmaterial.SwitchMaterial;
import com.google.android.material.timepicker.MaterialTimePicker;
import com.google.android.material.timepicker.TimeFormat;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;

import java.util.Locale;

public class SettingsActivity extends BaseActivity {

    private static final int REQ_POST_NOTIFICATIONS = 0x702;

    private RadioGroup radioGroupTheme;
    private RadioGroup radioGroupLang;
    private ThemeHelper themeHelper;
    private LocaleHelper localeHelper;
    private SwitchMaterial switchReminder;
    private TextView textReminderTime;
    private MaterialButton btnPickTime;
    private MaterialButton btnSyncUp;
    private MaterialButton btnSyncDown;
    private TextView textAccount;
    private MaterialButton btnSignOut;
    private boolean muteReminderListener;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_settings);

        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        if (getSupportActionBar() != null) {
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        }
        toolbar.setNavigationOnClickListener(v -> finish());

        themeHelper = new ThemeHelper(this);
        localeHelper = new LocaleHelper(this);
        radioGroupTheme = findViewById(R.id.radio_group_theme);
        radioGroupLang = findViewById(R.id.radio_group_lang);
        switchReminder = findViewById(R.id.switch_reminder);
        textReminderTime = findViewById(R.id.text_reminder_time);
        btnPickTime = findViewById(R.id.btn_pick_time);
        btnSyncUp = findViewById(R.id.btn_sync_up);
        btnSyncDown = findViewById(R.id.btn_sync_down);
        textAccount = findViewById(R.id.text_account);
        btnSignOut = findViewById(R.id.btn_sign_out);

        radioGroupTheme.setOnCheckedChangeListener((group, checkedId) -> {
            int theme = themeFromId(checkedId);
            if (theme != themeHelper.getTheme()) {
                themeHelper.setTheme(theme);
                recreate();
            }
        });

        radioGroupLang.setOnCheckedChangeListener((group, checkedId) -> {
            String lang = langFromId(checkedId);
            if (!lang.equals(localeHelper.getLanguage())) {
                localeHelper.setLanguage(lang);
                recreate();
            }
        });

        radioGroupTheme.check(idFromTheme(themeHelper.getTheme()));
        radioGroupLang.check(idFromLang(localeHelper.getLanguage()));

        muteReminderListener = true;
        switchReminder.setChecked(ReminderPrefs.isEnabled(this));
        muteReminderListener = false;
        updateReminderSummary();

        switchReminder.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (muteReminderListener) {
                return;
            }
            if (isChecked) {
                if (Build.VERSION.SDK_INT >= 33) {
                    if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS)
                            != PackageManager.PERMISSION_GRANTED) {
                        muteReminderListener = true;
                        switchReminder.setChecked(false);
                        muteReminderListener = false;
                        ActivityCompat.requestPermissions(
                                this,
                                new String[]{Manifest.permission.POST_NOTIFICATIONS},
                                REQ_POST_NOTIFICATIONS);
                        return;
                    }
                }
                ReminderPrefs.setEnabled(this, true);
                ReminderScheduler.reschedule(this);
            } else {
                ReminderPrefs.setEnabled(this, false);
                ReminderScheduler.reschedule(this);
            }
            updateReminderSummary();
        });

        btnPickTime.setOnClickListener(v -> showTimePicker());
        btnSyncUp.setOnClickListener(v -> {
            if (FirebaseAuth.getInstance().getCurrentUser() == null) {
                Toast.makeText(this, R.string.auth_required_for_cloud, Toast.LENGTH_SHORT).show();
                return;
            }
            FirestoreSyncHelper.syncUp(
                    this,
                    new DatabaseHelper(this),
                    new FirestoreSyncHelper.Callback() {
                        @Override
                        public void onDone(String message) {
                            Toast.makeText(SettingsActivity.this, message, Toast.LENGTH_SHORT).show();
                        }

                        @Override
                        public void onError(String message) {
                            Toast.makeText(SettingsActivity.this, message, Toast.LENGTH_LONG).show();
                        }
                    });
        });
        btnSyncDown.setOnClickListener(v -> {
            if (FirebaseAuth.getInstance().getCurrentUser() == null) {
                Toast.makeText(this, R.string.auth_required_for_cloud, Toast.LENGTH_SHORT).show();
                return;
            }
            FirestoreSyncHelper.syncDown(
                    this,
                    new DatabaseHelper(this),
                    new FirestoreSyncHelper.Callback() {
                        @Override
                        public void onDone(String message) {
                            Toast.makeText(SettingsActivity.this, message, Toast.LENGTH_SHORT).show();
                        }

                        @Override
                        public void onError(String message) {
                            Toast.makeText(SettingsActivity.this, message, Toast.LENGTH_LONG).show();
                        }
                    });
        });

        btnSignOut.setOnClickListener(v -> {
            FirebaseAuth.getInstance().signOut();
            Intent i = new Intent(this, AuthActivity.class);
            i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
            startActivity(i);
            finish();
        });

        updateAccountSummary();
    }

    @Override
    protected void onResume() {
        super.onResume();
        updateAccountSummary();
    }

    private void updateAccountSummary() {
        FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();
        if (user != null && user.getEmail() != null && !user.getEmail().isEmpty()) {
            textAccount.setText(getString(R.string.auth_signed_as, user.getEmail()));
            btnSignOut.setEnabled(true);
        } else {
            textAccount.setText(R.string.auth_not_signed_in);
            btnSignOut.setEnabled(false);
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == REQ_POST_NOTIFICATIONS && grantResults.length > 0
                && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            muteReminderListener = true;
            switchReminder.setChecked(true);
            muteReminderListener = false;
            ReminderPrefs.setEnabled(this, true);
            ReminderScheduler.reschedule(this);
            updateReminderSummary();
        }
    }

    private void showTimePicker() {
        MaterialTimePicker picker = new MaterialTimePicker.Builder()
                .setTimeFormat(TimeFormat.CLOCK_24H)
                .setHour(ReminderPrefs.getHour(this))
                .setMinute(ReminderPrefs.getMinute(this))
                .setTitleText(R.string.reminder_pick_time)
                .build();
        picker.addOnPositiveButtonClickListener(v -> {
            ReminderPrefs.setTime(this, picker.getHour(), picker.getMinute());
            ReminderScheduler.reschedule(this);
            updateReminderSummary();
        });
        picker.show(getSupportFragmentManager(), "reminder_time");
    }

    private void updateReminderSummary() {
        int h = ReminderPrefs.getHour(this);
        int m = ReminderPrefs.getMinute(this);
        String time = String.format(Locale.getDefault(), "%02d:%02d", h, m);
        textReminderTime.setText(getString(R.string.reminder_time_summary, time));
    }

    private int themeFromId(int id) {
        if (id == R.id.radio_light) {
            return ThemeHelper.THEME_LIGHT;
        }
        if (id == R.id.radio_dark) {
            return ThemeHelper.THEME_DARK;
        }
        return ThemeHelper.THEME_SYSTEM;
    }

    private int idFromTheme(int theme) {
        if (theme == ThemeHelper.THEME_LIGHT) {
            return R.id.radio_light;
        }
        if (theme == ThemeHelper.THEME_DARK) {
            return R.id.radio_dark;
        }
        return R.id.radio_system;
    }

    private String langFromId(int id) {
        if (id == R.id.radio_lang_en) {
            return LocaleHelper.LANG_EN;
        }
        if (id == R.id.radio_lang_ru) {
            return LocaleHelper.LANG_RU;
        }
        return LocaleHelper.LANG_SYSTEM;
    }

    private int idFromLang(String lang) {
        if (LocaleHelper.LANG_EN.equals(lang)) {
            return R.id.radio_lang_en;
        }
        if (LocaleHelper.LANG_RU.equals(lang)) {
            return R.id.radio_lang_ru;
        }
        return R.id.radio_lang_system;
    }
}
