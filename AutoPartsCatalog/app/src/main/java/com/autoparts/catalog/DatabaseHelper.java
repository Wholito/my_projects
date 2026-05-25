package com.autoparts.catalog;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

import java.util.ArrayList;
import java.util.List;

public class DatabaseHelper extends SQLiteOpenHelper {

    private static final String DB_NAME = "parts_db";
    private static final int DB_VERSION = 7;
    private static final String TABLE_PARTS = "parts";

    private static final String TABLE_API_PRODUCTS = "api_products";
    private static final String TABLE_NBRB_RATES = "nbrb_rates";

    private static final String COL_ID = "id";
    private static final String COL_TITLE = "title";
    private static final String COL_DESCRIPTION = "description";
    private static final String COL_DATE = "date";
    private static final String COL_CATEGORY = "category";
    private static final String COL_IMAGE_URL = "image_url";
    private static final String COL_REMOTE_ID = "remote_id";
    private static final String COL_FAVORITE = "favorite";

    private static final String N_COL_CUR_ID = "cur_id";
    private static final String N_COL_ABBR = "abbr";
    private static final String N_COL_SCALE = "scale";
    private static final String N_COL_NAME = "name";
    private static final String N_COL_OFFICIAL = "official_rate";
    private static final String N_COL_RATE_DATE = "rate_date";
    private static final String N_COL_CACHED_AT = "cached_at";

    public DatabaseHelper(Context context) {
        super(context, DB_NAME, null, DB_VERSION);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE " + TABLE_PARTS + " (" +
                COL_ID + " INTEGER PRIMARY KEY AUTOINCREMENT, " +
                COL_TITLE + " TEXT NOT NULL, " +
                COL_DESCRIPTION + " TEXT, " +
                COL_DATE + " TEXT, " +
                COL_CATEGORY + " TEXT, " +
                COL_IMAGE_URL + " TEXT, " +
                COL_REMOTE_ID + " TEXT, " +
                COL_FAVORITE + " INTEGER NOT NULL DEFAULT 0)");
        createNbrbRatesTable(db);
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        if (oldVersion < 2) {
            db.execSQL("CREATE TABLE IF NOT EXISTS " + TABLE_API_PRODUCTS + " (" +
                    COL_ID + " INTEGER PRIMARY KEY AUTOINCREMENT, " +
                    "api_id INTEGER, " +
                    COL_TITLE + " TEXT NOT NULL, " +
                    COL_DESCRIPTION + " TEXT, " +
                    "price REAL, " +
                    "updated_at TEXT)");
        }
        if (oldVersion < 3) {
            db.execSQL("DROP TABLE IF EXISTS " + TABLE_API_PRODUCTS);
            createNbrbRatesTable(db);
        }
        if (oldVersion < 4) {
            db.execSQL("ALTER TABLE " + TABLE_PARTS + " ADD COLUMN " + COL_CATEGORY + " TEXT");
            db.execSQL("ALTER TABLE " + TABLE_PARTS + " ADD COLUMN " + COL_IMAGE_URL + " TEXT");
            db.execSQL("ALTER TABLE " + TABLE_PARTS + " ADD COLUMN " + COL_REMOTE_ID + " TEXT");
        }
        if (oldVersion < 5) {
            db.execSQL("ALTER TABLE " + TABLE_PARTS + " ADD COLUMN latitude REAL");
            db.execSQL("ALTER TABLE " + TABLE_PARTS + " ADD COLUMN longitude REAL");
        }
        if (oldVersion < 7) {
            db.execSQL("ALTER TABLE " + TABLE_PARTS + " ADD COLUMN " + COL_FAVORITE + " INTEGER NOT NULL DEFAULT 0");
        }
    }

    public long insertPart(Part part) {
        SQLiteDatabase db = getWritableDatabase();
        ContentValues cv = new ContentValues();
        cv.put(COL_TITLE, part.getTitle());
        cv.put(COL_DESCRIPTION, part.getDescription());
        cv.put(COL_DATE, part.getDate());
        cv.put(COL_CATEGORY, part.getCategory());
        cv.put(COL_IMAGE_URL, part.getImageUrl());
        cv.put(COL_REMOTE_ID, emptyToNull(part.getRemoteId()));
        cv.put(COL_FAVORITE, part.isFavorite() ? 1 : 0);
        return db.insert(TABLE_PARTS, null, cv);
    }

    public int updatePart(Part part) {
        if (part.getId() < 0) return 0;
        SQLiteDatabase db = getWritableDatabase();
        ContentValues cv = new ContentValues();
        cv.put(COL_TITLE, part.getTitle());
        cv.put(COL_DESCRIPTION, part.getDescription());
        cv.put(COL_DATE, part.getDate());
        cv.put(COL_CATEGORY, part.getCategory());
        cv.put(COL_IMAGE_URL, part.getImageUrl());
        cv.put(COL_REMOTE_ID, emptyToNull(part.getRemoteId()));
        cv.put(COL_FAVORITE, part.isFavorite() ? 1 : 0);
        return db.update(TABLE_PARTS, cv, COL_ID + " = ?",
                new String[]{String.valueOf(part.getId())});
    }

    public void setPartFavorite(long id, boolean favorite) {
        SQLiteDatabase db = getWritableDatabase();
        ContentValues cv = new ContentValues();
        cv.put(COL_FAVORITE, favorite ? 1 : 0);
        db.update(TABLE_PARTS, cv, COL_ID + " = ?", new String[]{String.valueOf(id)});
    }

    public int deletePart(long id) {
        SQLiteDatabase db = getWritableDatabase();
        return db.delete(TABLE_PARTS, COL_ID + " = ?", new String[]{String.valueOf(id)});
    }

    public int deletePartByRemoteId(String remoteId) {
        if (remoteId == null || remoteId.isEmpty()) {
            return 0;
        }
        SQLiteDatabase db = getWritableDatabase();
        return db.delete(TABLE_PARTS, COL_REMOTE_ID + " = ?", new String[]{remoteId});
    }

    public Part getPart(long id) {
        SQLiteDatabase db = getReadableDatabase();
        Cursor c = db.query(TABLE_PARTS, null, COL_ID + " = ?",
                new String[]{String.valueOf(id)}, null, null, null);
        if (c.moveToFirst()) {
            Part p = cursorToPart(c);
            c.close();
            return p;
        }
        c.close();
        return null;
    }

    public Part getPartByRemoteId(String remoteId) {
        if (remoteId == null || remoteId.isEmpty()) {
            return null;
        }
        SQLiteDatabase db = getReadableDatabase();
        Cursor c = db.query(TABLE_PARTS, null, COL_REMOTE_ID + " = ?",
                new String[]{remoteId}, null, null, null);
        if (c.moveToFirst()) {
            Part p = cursorToPart(c);
            c.close();
            return p;
        }
        c.close();
        return null;
    }

    public List<Part> getAllParts() {
        List<Part> list = new ArrayList<>();
        SQLiteDatabase db = getReadableDatabase();
        Cursor c = db.query(TABLE_PARTS, null, null, null, null, null, COL_ID + " DESC");
        while (c.moveToNext()) {
            list.add(cursorToPart(c));
        }
        c.close();
        return list;
    }

    public List<String> getDistinctCategories() {
        List<String> out = new ArrayList<>();
        SQLiteDatabase db = getReadableDatabase();
        Cursor c = db.query(true, TABLE_PARTS, new String[]{COL_CATEGORY},
                COL_CATEGORY + " IS NOT NULL AND " + COL_CATEGORY + " != ''",
                null, null, null, COL_CATEGORY + " ASC", null);
        while (c.moveToNext()) {
            String cat = c.getString(0);
            if (cat != null) {
                String t = cat.trim();
                if (!t.isEmpty() && !out.contains(t)) {
                    out.add(t);
                }
            }
        }
        c.close();
        return out;
    }

    public void updatePartRemoteId(long localId, String remoteId) {
        SQLiteDatabase db = getWritableDatabase();
        ContentValues cv = new ContentValues();
        cv.put(COL_REMOTE_ID, emptyToNull(remoteId));
        db.update(TABLE_PARTS, cv, COL_ID + " = ?", new String[]{String.valueOf(localId)});
    }

    private static String emptyToNull(String s) {
        return (s == null || s.isEmpty()) ? null : s;
    }

    private Part cursorToPart(Cursor c) {
        String remote = c.getString(c.getColumnIndexOrThrow(COL_REMOTE_ID));
        int fav = 0;
        int favIdx = c.getColumnIndex(COL_FAVORITE);
        if (favIdx >= 0) {
            fav = c.getInt(favIdx);
        }
        return new Part(
                c.getLong(c.getColumnIndexOrThrow(COL_ID)),
                c.getString(c.getColumnIndexOrThrow(COL_TITLE)),
                c.getString(c.getColumnIndexOrThrow(COL_DESCRIPTION)),
                c.getString(c.getColumnIndexOrThrow(COL_DATE)),
                nullToEmpty(c.getString(c.getColumnIndexOrThrow(COL_CATEGORY))),
                nullToEmpty(c.getString(c.getColumnIndexOrThrow(COL_IMAGE_URL))),
                remote != null ? remote : "",
                fav == 1
        );
    }

    private static String nullToEmpty(String s) {
        return s != null ? s : "";
    }

    private void createNbrbRatesTable(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE IF NOT EXISTS " + TABLE_NBRB_RATES + " (" +
                N_COL_CUR_ID + " INTEGER PRIMARY KEY, " +
                N_COL_ABBR + " TEXT NOT NULL, " +
                N_COL_SCALE + " INTEGER NOT NULL, " +
                N_COL_NAME + " TEXT, " +
                N_COL_OFFICIAL + " REAL NOT NULL, " +
                N_COL_RATE_DATE + " TEXT, " +
                N_COL_CACHED_AT + " TEXT)");
    }

    public void replaceNbrbRates(List<NbrbRateResponse> rates) {
        SQLiteDatabase db = getWritableDatabase();
        db.beginTransaction();
        try {
            db.delete(TABLE_NBRB_RATES, null, null);
            for (NbrbRateResponse r : rates) {
                ContentValues cv = new ContentValues();
                cv.put(N_COL_CUR_ID, r.getCurId());
                cv.put(N_COL_ABBR, r.getAbbreviation());
                cv.put(N_COL_SCALE, r.getScale());
                cv.put(N_COL_NAME, r.getName());
                cv.put(N_COL_OFFICIAL, r.getOfficialRate());
                cv.put(N_COL_RATE_DATE, r.getDate());
                cv.put(N_COL_CACHED_AT, r.getCachedAt());
                db.insert(TABLE_NBRB_RATES, null, cv);
            }
            db.setTransactionSuccessful();
        } finally {
            db.endTransaction();
        }
    }

    public List<NbrbRateResponse> getCachedNbrbRates() {
        List<NbrbRateResponse> list = new ArrayList<>();
        SQLiteDatabase db = getReadableDatabase();
        Cursor c = db.query(TABLE_NBRB_RATES, null, null, null, null, null, N_COL_ABBR + " ASC");
        while (c.moveToNext()) {
            NbrbRateResponse r = new NbrbRateResponse();
            r.setCurId(c.getInt(c.getColumnIndexOrThrow(N_COL_CUR_ID)));
            r.setAbbreviation(c.getString(c.getColumnIndexOrThrow(N_COL_ABBR)));
            r.setScale(c.getInt(c.getColumnIndexOrThrow(N_COL_SCALE)));
            r.setName(c.getString(c.getColumnIndexOrThrow(N_COL_NAME)));
            r.setOfficialRate(c.getDouble(c.getColumnIndexOrThrow(N_COL_OFFICIAL)));
            r.setDate(c.getString(c.getColumnIndexOrThrow(N_COL_RATE_DATE)));
            r.setCachedAt(c.getString(c.getColumnIndexOrThrow(N_COL_CACHED_AT)));
            list.add(r);
        }
        c.close();
        return list;
    }
}
