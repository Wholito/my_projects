package com.autoparts.catalog;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import java.util.ArrayList;
import java.util.List;

public class ApiCatalogViewModel extends ViewModel {
    private final ApiCatalogRepository repository;
    private final MutableLiveData<List<NbrbRateResponse>> rates = new MutableLiveData<>(new ArrayList<>());
    private final MutableLiveData<Boolean> loading = new MutableLiveData<>(false);
    private final MutableLiveData<String> status = new MutableLiveData<>("");

    public ApiCatalogViewModel(ApiCatalogRepository repository) {
        this.repository = repository;
    }

    public LiveData<List<NbrbRateResponse>> getRates() {
        return rates;
    }

    public LiveData<Boolean> getLoading() {
        return loading;
    }

    public LiveData<String> getStatus() {
        return status;
    }

    public void refresh() {
        loading.setValue(true);
        repository.loadRates((data, fromCache, online) -> {
            rates.postValue(data);
            if (!online) {
                status.postValue("offline");
            } else if (fromCache) {
                status.postValue("cache");
            } else {
                status.postValue("online");
            }
            loading.postValue(false);
        });
    }
}
