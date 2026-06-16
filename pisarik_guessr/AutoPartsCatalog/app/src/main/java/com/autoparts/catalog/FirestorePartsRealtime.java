package com.autoparts.catalog;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.firestore.DocumentChange;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.ListenerRegistration;

import java.util.concurrent.Executors;


public final class FirestorePartsRealtime {

    private ListenerRegistration registration;
    private final Handler mainHandler = new Handler(Looper.getMainLooper());

    public void start(Context context, DatabaseHelper db, Runnable onLocalDataChanged) {
        stop();
        FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();
        if (user == null) {
            return;
        }
        Context app = context.getApplicationContext();
        FirebaseFirestore fs = FirebaseFirestore.getInstance();
        registration = FirestoreSyncHelper.userPartsCollection(fs, user.getUid())
                .addSnapshotListener(Executors.newSingleThreadExecutor(), (snapshot, error) -> {
                    if (error != null || snapshot == null) {
                        return;
                    }
                    for (DocumentChange change : snapshot.getDocumentChanges()) {
                        DocumentSnapshot doc = change.getDocument();
                        switch (change.getType()) {
                            case ADDED:
                            case MODIFIED:
                                FirestoreSyncHelper.applyRemoteDocument(db, doc);
                                break;
                            case REMOVED:
                                db.deletePartByRemoteId(doc.getId());
                                break;
                            default:
                                break;
                        }
                    }
                    mainHandler.post(onLocalDataChanged);
                });
    }

    public void stop() {
        if (registration != null) {
            registration.remove();
            registration = null;
        }
    }
}
