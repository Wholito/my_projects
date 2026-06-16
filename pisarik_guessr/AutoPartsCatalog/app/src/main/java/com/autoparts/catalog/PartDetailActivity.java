package com.autoparts.catalog;

import android.Manifest;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.Toast;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.widget.Toolbar;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.content.FileProvider;

import com.google.android.material.button.MaterialButton;
import com.google.firebase.auth.FirebaseAuth;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class PartDetailActivity extends BaseActivity {

    public static final String EXTRA_PART_ID = "part_id";

    private static final int REQ_CAMERA = 801;

    private EditText editTitle;
    private EditText editDescription;
    private EditText editDate;
    private EditText editCategory;
    private EditText editImageUrl;
    private MaterialButton btnSave;
    private MaterialButton btnDelete;
    private MaterialButton btnCamera;
    private ImageView btnFavorite;
    private DatabaseHelper db;
    private long partId = -1;
    private boolean isNew;
    private boolean favorite;
    private Uri cameraUri;

    private final ActivityResultLauncher<Uri> takePictureLauncher =
            registerForActivityResult(new ActivityResultContracts.TakePicture(), success -> {
                if (success && cameraUri != null) {
                    editImageUrl.setText(cameraUri.toString());
                }
            });

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_part_detail);

        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        if (getSupportActionBar() != null) {
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        }
        toolbar.setNavigationOnClickListener(v -> finish());

        partId = getIntent().getLongExtra(EXTRA_PART_ID, -1);
        isNew = partId < 0;

        if (getSupportActionBar() != null) {
            getSupportActionBar().setTitle(isNew ? R.string.new_part : R.string.edit_part);
        }

        db = new DatabaseHelper(this);
        editTitle = findViewById(R.id.edit_title);
        editDescription = findViewById(R.id.edit_description);
        editDate = findViewById(R.id.edit_date);
        editCategory = findViewById(R.id.edit_category);
        editImageUrl = findViewById(R.id.edit_image_url);
        btnSave = findViewById(R.id.btn_save);
        btnDelete = findViewById(R.id.btn_delete);
        btnCamera = findViewById(R.id.btn_camera);
        btnFavorite = findViewById(R.id.btn_favorite);

        if (isNew) {
            btnFavorite.setVisibility(android.view.View.GONE);
            btnDelete.setVisibility(android.view.View.GONE);
            editDate.setText(new SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(new Date()));
        } else {
            loadPart();
        }

        btnSave.setOnClickListener(v -> savePart());
        btnDelete.setOnClickListener(v -> confirmDelete());
        btnCamera.setOnClickListener(v -> tryOpenCamera());
        btnFavorite.setOnClickListener(v -> {
            favorite = !favorite;
            updateFavoriteIcon();
        });
    }

    private void updateFavoriteIcon() {
        btnFavorite.setImageResource(
                favorite ? android.R.drawable.btn_star_big_on : android.R.drawable.btn_star_big_off);
    }

    private void tryOpenCamera() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.CAMERA}, REQ_CAMERA);
            return;
        }
        openCamera();
    }

    private void openCamera() {
        File dir = new File(getExternalFilesDir(Environment.DIRECTORY_PICTURES), "catalog");
        if (!dir.exists() && !dir.mkdirs()) {
            Toast.makeText(this, R.string.camera_error, Toast.LENGTH_SHORT).show();
            return;
        }
        File photo = new File(dir, "part_" + System.currentTimeMillis() + ".jpg");
        cameraUri = FileProvider.getUriForFile(
                this,
                getPackageName() + ".fileprovider",
                photo);
        takePictureLauncher.launch(cameraUri);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == REQ_CAMERA && grantResults.length > 0
                && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            openCamera();
        }
    }

    private void loadPart() {
        Part p = db.getPart(partId);
        if (p != null) {
            editTitle.setText(p.getTitle());
            editDescription.setText(p.getDescription());
            editDate.setText(p.getDate());
            editCategory.setText(p.getCategory());
            editImageUrl.setText(p.getImageUrl());
            favorite = p.isFavorite();
            updateFavoriteIcon();
        }
    }

    private void savePart() {
        String title = editTitle.getText().toString().trim();
        String desc = editDescription.getText().toString().trim();
        String date = editDate.getText().toString().trim();
        String category = editCategory.getText().toString().trim();
        String imageUrl = editImageUrl.getText().toString().trim();

        if (title.isEmpty()) {
            Toast.makeText(this, R.string.part_title, Toast.LENGTH_SHORT).show();
            return;
        }

        if (isNew) {
            Part part = new Part(title, desc, date);
            part.setCategory(category);
            part.setImageUrl(imageUrl);
            part.setFavorite(favorite);
            long newId = db.insertPart(part);
            Toast.makeText(this, R.string.save, Toast.LENGTH_SHORT).show();
            pushIfSignedIn(newId);
        } else {
            Part existing = db.getPart(partId);
            String remote = existing != null ? existing.getRemoteId() : "";
            Part part = new Part(partId, title, desc, date, category, imageUrl, remote, favorite);
            db.updatePart(part);
            Toast.makeText(this, R.string.save, Toast.LENGTH_SHORT).show();
            pushIfSignedIn(partId);
        }
        finish();
    }

    private void pushIfSignedIn(long localId) {
        if (FirebaseAuth.getInstance().getCurrentUser() == null) {
            return;
        }
        Part saved = db.getPart(localId);
        if (saved != null) {
            FirestoreSyncHelper.pushPart(this, db, saved, null);
        }
    }

    private void confirmDelete() {
        new AlertDialog.Builder(this)
                .setTitle(R.string.delete)
                .setMessage(R.string.delete_confirm)
                .setPositiveButton(R.string.confirm, (d, w) -> {
                    Part existing = db.getPart(partId);
                    String remote = existing != null ? existing.getRemoteId() : "";
                    db.deletePart(partId);
                    if (FirebaseAuth.getInstance().getCurrentUser() != null && remote != null && !remote.isEmpty()) {
                        FirestoreSyncHelper.deleteRemotePart(this, remote, null);
                    }
                    Toast.makeText(this, R.string.delete, Toast.LENGTH_SHORT).show();
                    finish();
                })
                .setNegativeButton(R.string.cancel, null)
                .show();
    }
}
