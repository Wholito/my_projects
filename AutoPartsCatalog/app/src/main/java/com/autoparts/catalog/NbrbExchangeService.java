package com.autoparts.catalog;

import java.util.List;

import retrofit2.Call;
import retrofit2.http.GET;
import retrofit2.http.Query;


public interface NbrbExchangeService {
    @GET("exrates/rates")
    Call<List<NbrbRateResponse>> getDailyRates(@Query("periodicity") int periodicity);
}
