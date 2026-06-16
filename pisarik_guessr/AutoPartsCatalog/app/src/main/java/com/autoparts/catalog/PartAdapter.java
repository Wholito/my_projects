package com.autoparts.catalog;

import android.net.Uri;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

public class PartAdapter extends RecyclerView.Adapter<PartAdapter.ViewHolder> {

    private final List<Part> items = new ArrayList<>();
    private OnPartClickListener listener;
    private OnPartLongClickListener longClickListener;
    private OnFavoriteToggleListener favoriteListener;

    public interface OnPartClickListener {
        void onPartClick(Part part);
    }

    public interface OnPartLongClickListener {
        void onPartLongClick(Part part);
    }

    public interface OnFavoriteToggleListener {
        void onFavoriteToggle(Part part, boolean favorite);
    }

    public void setOnPartClickListener(OnPartClickListener listener) {
        this.listener = listener;
    }

    public void setOnPartLongClickListener(OnPartLongClickListener listener) {
        this.longClickListener = listener;
    }

    public void setOnFavoriteToggleListener(OnFavoriteToggleListener listener) {
        this.favoriteListener = listener;
    }

    public void setItems(List<Part> parts) {
        items.clear();
        items.addAll(parts);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_part, parent, false);
        return new ViewHolder(v);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        Part p = items.get(position);
        holder.title.setText(Objects.requireNonNullElse(p.getTitle(), ""));
        holder.description.setText(Objects.requireNonNullElse(p.getDescription(), ""));
        holder.date.setText(Objects.requireNonNullElse(p.getDate(), ""));

        String cat = p.getCategory();
        if (cat != null && !cat.trim().isEmpty()) {
            holder.category.setVisibility(View.VISIBLE);
            holder.category.setText(cat.trim());
        } else {
            holder.category.setVisibility(View.GONE);
        }

        String url = p.getImageUrl();
        if (url != null && !url.trim().isEmpty()) {
            holder.image.setVisibility(View.VISIBLE);
            String u = url.trim();
            Object load = u.startsWith("content:") || u.startsWith("file:") ? Uri.parse(u) : u;
            Glide.with(holder.image)
                    .load(load)
                    .centerCrop()
                    .placeholder(android.R.drawable.ic_menu_gallery)
                    .into(holder.image);
        } else {
            holder.image.setVisibility(View.GONE);
            holder.image.setImageDrawable(null);
        }

        holder.itemView.setOnClickListener(v -> {
            if (listener != null) {
                listener.onPartClick(p);
            }
        });
        holder.itemView.setOnLongClickListener(v -> {
            if (longClickListener != null) {
                longClickListener.onPartLongClick(p);
                return true;
            }
            return false;
        });

        holder.favorite.setImageResource(
                p.isFavorite() ? android.R.drawable.btn_star_big_on : android.R.drawable.btn_star_big_off);
        holder.favorite.setOnClickListener(v -> {
            if (favoriteListener != null) {
                favoriteListener.onFavoriteToggle(p, !p.isFavorite());
            }
        });
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    static class ViewHolder extends RecyclerView.ViewHolder {
        final TextView title;
        final TextView category;
        final TextView description;
        final TextView date;
        final ImageView image;
        final ImageView favorite;

        ViewHolder(View itemView) {
            super(itemView);
            title = itemView.findViewById(R.id.item_title);
            category = itemView.findViewById(R.id.item_category);
            description = itemView.findViewById(R.id.item_description);
            date = itemView.findViewById(R.id.item_date);
            image = itemView.findViewById(R.id.item_image);
            favorite = itemView.findViewById(R.id.item_favorite);
        }
    }
}
