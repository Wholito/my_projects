package com.autoparts.catalog;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Toast;

import androidx.appcompat.widget.Toolbar;

import com.google.android.material.button.MaterialButton;
import com.google.android.material.textfield.TextInputEditText;
import com.google.firebase.auth.FirebaseAuth;

public class AuthActivity extends BaseActivity {

    private TextInputEditText editEmail;
    private TextInputEditText editPassword;
    private FirebaseAuth auth;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_auth);

        auth = FirebaseAuth.getInstance();
        if (auth.getCurrentUser() != null) {
            goMain();
            return;
        }

        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        editEmail = findViewById(R.id.edit_email);
        editPassword = findViewById(R.id.edit_password);
        MaterialButton btnLogin = findViewById(R.id.btn_login);
        MaterialButton btnRegister = findViewById(R.id.btn_register);

        btnLogin.setOnClickListener(v -> login());
        btnRegister.setOnClickListener(v -> register());
    }

    private String email() {
        return editEmail.getText() != null ? editEmail.getText().toString().trim() : "";
    }

    private String password() {
        return editPassword.getText() != null ? editPassword.getText().toString() : "";
    }

    private void login() {
        String e = email();
        String p = password();
        if (e.isEmpty() || p.isEmpty()) {
            Toast.makeText(this, R.string.auth_fill_fields, Toast.LENGTH_SHORT).show();
            return;
        }
        auth.signInWithEmailAndPassword(e, p)
                .addOnSuccessListener(r -> goMain())
                .addOnFailureListener(ex -> Toast.makeText(this,
                        getString(R.string.auth_error, ex.getMessage() != null ? ex.getMessage() : ex.toString()),
                        Toast.LENGTH_LONG).show());
    }

    private void register() {
        String e = email();
        String p = password();
        if (e.isEmpty() || p.length() < 6) {
            Toast.makeText(this, R.string.auth_password_hint, Toast.LENGTH_SHORT).show();
            return;
        }
        auth.createUserWithEmailAndPassword(e, p)
                .addOnSuccessListener(r -> goMain())
                .addOnFailureListener(ex -> Toast.makeText(this,
                        getString(R.string.auth_error, ex.getMessage() != null ? ex.getMessage() : ex.toString()),
                        Toast.LENGTH_LONG).show());
    }

    private void goMain() {
        startActivity(new Intent(this, MainActivity.class));
        finish();
    }
}
