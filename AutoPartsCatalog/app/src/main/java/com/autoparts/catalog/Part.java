package com.autoparts.catalog;

public class Part {
    private long id;
    private String title;
    private String description;
    private String date;
    private String category;
    private String imageUrl;
    private String remoteId;
    private boolean favorite;

    public Part(long id, String title, String description, String date,
                String category, String imageUrl, String remoteId, boolean favorite) {
        this.id = id;
        this.title = title;
        this.description = description;
        this.date = date;
        this.category = category != null ? category : "";
        this.imageUrl = imageUrl != null ? imageUrl : "";
        this.remoteId = remoteId != null ? remoteId : "";
        this.favorite = favorite;
    }

    public Part(long id, String title, String description, String date,
                String category, String imageUrl, String remoteId) {
        this(id, title, description, date, category, imageUrl, remoteId, false);
    }

    public Part(long id, String title, String description, String date) {
        this(id, title, description, date, "", "", "", false);
    }

    public Part(String title, String description, String date) {
        this(-1, title, description, date, "", "", "", false);
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category != null ? category : "";
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl != null ? imageUrl : "";
    }

    public String getRemoteId() {
        return remoteId;
    }

    public void setRemoteId(String remoteId) {
        this.remoteId = remoteId != null ? remoteId : "";
    }

    public boolean isFavorite() {
        return favorite;
    }

    public void setFavorite(boolean favorite) {
        this.favorite = favorite;
    }

    public String searchableText() {
        return (title + " " + description + " " + category).toLowerCase();
    }

    public String shareSummary() {
        StringBuilder sb = new StringBuilder();
        if (title != null && !title.isEmpty()) {
            sb.append(title);
        }
        if (category != null && !category.trim().isEmpty()) {
            if (sb.length() > 0) {
                sb.append(" — ");
            }
            sb.append(category.trim());
        }
        if (date != null && !date.isEmpty()) {
            if (sb.length() > 0) {
                sb.append("\n");
            }
            sb.append(date);
        }
        if (description != null && !description.trim().isEmpty()) {
            if (sb.length() > 0) {
                sb.append("\n");
            }
            sb.append(description.trim());
        }
        return sb.length() > 0 ? sb.toString() : "";
    }
}
