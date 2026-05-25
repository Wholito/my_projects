package com.autoparts.catalog;

import android.os.Bundle;
import android.view.View;
import android.widget.TextView;

import androidx.appcompat.widget.Toolbar;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.button.MaterialButton;

public class ApiCatalogActivity extends BaseActivity {
    private NbrbRatesAdapter adapter;
    private TextView statusText;
    private TextView emptyView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_api_catalog);

        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        if (getSupportActionBar() != null) {
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        }
        toolbar.setNavigationOnClickListener(v -> finish());

        RecyclerView recyclerView = findViewById(R.id.api_recycler);
        statusText = findViewById(R.id.api_status);
        emptyView = findViewById(R.id.api_empty);
        MaterialButton refreshButton = findViewById(R.id.api_refresh);

        recyclerView.setLayoutManager(new LinearLayoutManager(this));
        adapter = new NbrbRatesAdapter();
        recyclerView.setAdapter(adapter);

        ApiCatalogRepository repository = new ApiCatalogRepository(
                new DatabaseHelper(this),
                new NetworkMonitor(this)
        );
        ApiCatalogViewModel viewModel = new ViewModelProvider(
                this,
                new ApiCatalogViewModelFactory(repository)
        ).get(ApiCatalogViewModel.class);

        viewModel.getRates().observe(this, rates -> {
            adapter.setItems(rates);
            emptyView.setVisibility(rates.isEmpty() ? View.VISIBLE : View.GONE);
        });
        viewModel.getStatus().observe(this, this::updateStatusText);
        viewModel.getLoading().observe(this, loading -> refreshButton.setEnabled(!loading));

        refreshButton.setOnClickListener(v -> viewModel.refresh());
        viewModel.refresh();
    }

    private void updateStatusText(String status) {
        if ("offline".equals(status)) {
            statusText.setText(R.string.api_status_offline);
        } else if ("cache".equals(status)) {
            statusText.setText(R.string.api_status_cache);
        } else if ("online".equals(status)) {
            statusText.setText(R.string.api_status_online);
        } else {
            statusText.setText("");
        }
    }
}
