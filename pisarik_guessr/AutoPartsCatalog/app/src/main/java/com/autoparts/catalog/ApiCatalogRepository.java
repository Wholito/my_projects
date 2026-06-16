package com.autoparts.catalog;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class ApiCatalogRepository {
    public interface DataCallback {
        void onResult(List<NbrbRateResponse> rates, boolean fromCache, boolean online);
    }

    private final DatabaseHelper databaseHelper;
    private final NetworkMonitor networkMonitor;
    private final NbrbExchangeService nbrbService;
    private final ExecutorService ioExecutor = Executors.newSingleThreadExecutor();

    public ApiCatalogRepository(DatabaseHelper databaseHelper, NetworkMonitor networkMonitor) {
        this.databaseHelper = databaseHelper;
        this.networkMonitor = networkMonitor;
        Retrofit retrofit = new Retrofit.Builder()
                .baseUrl("https://api.nbrb.by/")
                .addConverterFactory(GsonConverterFactory.create())
                .build();
        this.nbrbService = retrofit.create(NbrbExchangeService.class);
    }

    public void loadRates(DataCallback callback) {
        if (!networkMonitor.isOnline()) {
            ioExecutor.execute(() ->
                    callback.onResult(databaseHelper.getCachedNbrbRates(), true, false));
            return;
        }

        nbrbService.getDailyRates(0).enqueue(new Callback<List<NbrbRateResponse>>() {
            @Override
            public void onResponse(Call<List<NbrbRateResponse>> call, Response<List<NbrbRateResponse>> response) {
                List<NbrbRateResponse> body = response.body();
                if (!response.isSuccessful() || body == null || body.isEmpty()) {
                    ioExecutor.execute(() ->
                            callback.onResult(databaseHelper.getCachedNbrbRates(), true, true));
                    return;
                }

                String cachedAt = new SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.getDefault())
                        .format(new Date());
                for (NbrbRateResponse rate : body) {
                    rate.setCachedAt(cachedAt);
                }
                ioExecutor.execute(() -> {
                    databaseHelper.replaceNbrbRates(body);
                    callback.onResult(databaseHelper.getCachedNbrbRates(), false, true);
                });
            }

            @Override
            public void onFailure(Call<List<NbrbRateResponse>> call, Throwable t) {
                ioExecutor.execute(() ->
                        callback.onResult(databaseHelper.getCachedNbrbRates(), true, true));
            }
        });
    }
}
