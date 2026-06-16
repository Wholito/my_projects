package com.autoparts.catalog;

import com.google.gson.annotations.SerializedName;

public class NbrbRateResponse {
    @SerializedName("Cur_ID")
    private int curId;
    @SerializedName("Date")
    private String date;
    @SerializedName("Cur_Abbreviation")
    private String abbreviation;
    @SerializedName("Cur_Scale")
    private int scale;
    @SerializedName("Cur_Name")
    private String name;
    @SerializedName("Cur_OfficialRate")
    private double officialRate;

    private String cachedAt;

    public int getCurId() {
        return curId;
    }

    public void setCurId(int curId) {
        this.curId = curId;
    }

    public String getDate() {
        return date == null ? "" : date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public String getAbbreviation() {
        return abbreviation == null ? "" : abbreviation;
    }

    public void setAbbreviation(String abbreviation) {
        this.abbreviation = abbreviation;
    }

    public int getScale() {
        return scale;
    }

    public void setScale(int scale) {
        this.scale = scale;
    }

    public String getName() {
        return name == null ? "" : name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public double getOfficialRate() {
        return officialRate;
    }

    public void setOfficialRate(double officialRate) {
        this.officialRate = officialRate;
    }

    public String getCachedAt() {
        return cachedAt == null ? "" : cachedAt;
    }

    public void setCachedAt(String cachedAt) {
        this.cachedAt = cachedAt;
    }
}
