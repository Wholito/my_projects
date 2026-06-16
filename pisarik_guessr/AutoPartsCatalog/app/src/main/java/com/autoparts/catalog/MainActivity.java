package com.autoparts.catalog;

import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Spinner;
import android.widget.TextView;

import androidx.appcompat.widget.Toolbar;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.checkbox.MaterialCheckBox;
import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.google.android.material.textfield.TextInputEditText;
import com.google.firebase.auth.FirebaseAuth;

import java.util.ArrayList;
import java.util.List;

public class MainActivity extends BaseActivity {

    private RecyclerView recycler;
    private TextView emptyView;
    private PartAdapter adapter;
    private DatabaseHelper db;
    private final List<Part> allParts = new ArrayList<>();
    private TextInputEditText editSearch;
    private TextInputEditText editDateFrom;
    private TextInputEditText editDateTo;
    private Spinner spinnerSort;
    private Spinner spinnerCategory;
    private MaterialCheckBox filterFavoritesOnly;
    private String selectedCategory = "";

    private final FirestorePartsRealtime firestoreRealtime = new FirestorePartsRealtime();

    private final TextWatcher filterWatcher = new TextWatcher() {
        @Override
        public void beforeTextChanged(CharSequence s, int start, int count, int after) {
        }

        @Override
        public void onTextChanged(CharSequence s, int start, int before, int count) {
            applyFilters();
        }

        @Override
        public void afterTextChanged(Editable s) {
        }
    };

    private final AdapterView.OnItemSelectedListener categoryListener = new AdapterView.OnItemSelectedListener() {
        @Override
        public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
            if (position == 0) {
                selectedCategory = "";
            } else {
                selectedCategory = String.valueOf(parent.getItemAtPosition(position));
            }
            applyFilters();
        }

        @Override
        public void onNothingSelected(AdapterView<?> parent) {
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (FirebaseAuth.getInstance().getCurrentUser() == null) {
            startActivity(new Intent(this, AuthActivity.class));
            finish();
            return;
        }
        setContentView(R.layout.activity_main);

        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        db = new DatabaseHelper(this);
        recycler = findViewById(R.id.recycler);
        emptyView = findViewById(R.id.empty_view);
        editSearch = findViewById(R.id.edit_search);
        editDateFrom = findViewById(R.id.edit_date_from);
        editDateTo = findViewById(R.id.edit_date_to);
        spinnerSort = findViewById(R.id.spinner_sort);
        spinnerCategory = findViewById(R.id.spinner_category);
        filterFavoritesOnly = findViewById(R.id.filter_favorites_only);

        recycler.setLayoutManager(new LinearLayoutManager(this));
        adapter = new PartAdapter();
        adapter.setOnPartClickListener(p -> openPart(p.getId()));
        adapter.setOnPartLongClickListener(this::sharePart);
        adapter.setOnFavoriteToggleListener((part, favorite) -> {
            db.setPartFavorite(part.getId(), favorite);
            part.setFavorite(favorite);
            applyFilters();
        });
        recycler.setAdapter(adapter);

        setupSortSpinner();
        spinnerSort.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                applyFilters();
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
            }
        });

        editSearch.addTextChangedListener(filterWatcher);
        editDateFrom.addTextChangedListener(filterWatcher);
        editDateTo.addTextChangedListener(filterWatcher);
        filterFavoritesOnly.setOnCheckedChangeListener((buttonView, isChecked) -> applyFilters());

        FloatingActionButton fab = findViewById(R.id.fab_add);
        fab.setOnClickListener(v -> openPart(-1));

        loadParts();
    }

    @Override
    protected void onStart() {
        super.onStart();
        if (FirebaseAuth.getInstance().getCurrentUser() != null) {
            firestoreRealtime.start(this, db, this::loadParts);
        }
    }

    @Override
    protected void onStop() {
        firestoreRealtime.stop();
        super.onStop();
    }

    @Override
    protected void onResume() {
        super.onResume();
        loadParts();
    }

    private void setupSortSpinner() {
        String[] labels = new String[]{
                getString(R.string.sort_id_desc),
                getString(R.string.sort_date_desc),
                getString(R.string.sort_date_asc),
                getString(R.string.sort_title_asc)
        };
        ArrayAdapter<String> ad = new ArrayAdapter<>(
                this, android.R.layout.simple_spinner_dropdown_item, labels);
        spinnerSort.setAdapter(ad);
    }

    private void refreshCategorySpinner() {
        List<String> cats = db.getDistinctCategories();
        List<String> items = new ArrayList<>();
        items.add(getString(R.string.filter_category_all));
        items.addAll(cats);
        ArrayAdapter<String> ad = new ArrayAdapter<>(
                this, android.R.layout.simple_spinner_dropdown_item, items);
        spinnerCategory.setAdapter(ad);

        int sel = 0;
        if (!selectedCategory.isEmpty()) {
            for (int i = 1; i < items.size(); i++) {
                if (items.get(i).equalsIgnoreCase(selectedCategory)) {
                    sel = i;
                    break;
                }
            }
        }
        spinnerCategory.setOnItemSelectedListener(null);
        spinnerCategory.setSelection(sel, false);
        spinnerCategory.setOnItemSelectedListener(categoryListener);
    }

    private void loadParts() {
        allParts.clear();
        allParts.addAll(db.getAllParts());
        refreshCategorySpinner();
        applyFilters();
    }

    private void applyFilters() {
        String q = textOf(editSearch);
        String df = textOf(editDateFrom);
        String dt = textOf(editDateTo);
        PartQueryEngine.Sort sort = sortFromPosition(spinnerSort.getSelectedItemPosition());
        boolean favOnly = filterFavoritesOnly != null && filterFavoritesOnly.isChecked();
        List<Part> filtered = PartQueryEngine.apply(allParts, q, selectedCategory, df, dt, sort, favOnly);
        adapter.setItems(filtered);
        if (filtered.isEmpty()) {
            emptyView.setVisibility(View.VISIBLE);
            emptyView.setText(allParts.isEmpty()
                    ? getString(R.string.no_parts)
                    : getString(R.string.no_matches));
        } else {
            emptyView.setVisibility(View.GONE);
        }
    }

    private void sharePart(Part p) {
        String text = p.shareSummary();
        if (text == null || text.trim().isEmpty()) {
            text = p.getTitle() != null ? p.getTitle() : "";
        }
        Intent send = new Intent(Intent.ACTION_SEND);
        send.setType("text/plain");
        send.putExtra(Intent.EXTRA_SUBJECT, p.getTitle());
        send.putExtra(Intent.EXTRA_TEXT, text);
        startActivity(Intent.createChooser(send, getString(R.string.share_part)));
    }

    private static String textOf(TextInputEditText e) {
        if (e == null || e.getText() == null) {
            return "";
        }
        return e.getText().toString();
    }

    private static PartQueryEngine.Sort sortFromPosition(int pos) {
        switch (pos) {
            case 1:
                return PartQueryEngine.Sort.DATE_DESC;
            case 2:
                return PartQueryEngine.Sort.DATE_ASC;
            case 3:
                return PartQueryEngine.Sort.TITLE_ASC;
            case 0:
            default:
                return PartQueryEngine.Sort.ID_DESC;
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.main_menu, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == R.id.action_online_catalog) {
            startActivity(new Intent(this, ApiCatalogActivity.class));
            return true;
        }
        if (item.getItemId() == R.id.action_settings) {
            startActivity(new Intent(this, SettingsActivity.class));
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    private void openPart(long id) {
        Intent i = new Intent(this, PartDetailActivity.class);
        i.putExtra(PartDetailActivity.EXTRA_PART_ID, id);
        startActivity(i);
    }
}
