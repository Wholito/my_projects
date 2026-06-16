package com.autoparts.catalog;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class NbrbRatesAdapter extends RecyclerView.Adapter<NbrbRatesAdapter.ViewHolder> {
    private final List<NbrbRateResponse> items = new ArrayList<>();

    public void setItems(List<NbrbRateResponse> rates) {
        items.clear();
        items.addAll(rates);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_nbrb_rate, parent, false);
        return new ViewHolder(v);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        NbrbRateResponse r = items.get(position);
        holder.abbr.setText(r.getAbbreviation());
        holder.name.setText(r.getName());
        holder.rateLine.setText(String.format(Locale.getDefault(),
                "%d %s = %.4f BYN", r.getScale(), r.getAbbreviation(), r.getOfficialRate()));
        holder.rateDate.setText(r.getDate());
        String cached = r.getCachedAt();
        holder.cachedAt.setVisibility(cached.isEmpty() ? View.GONE : View.VISIBLE);
        holder.cachedAt.setText(holder.itemView.getContext().getString(R.string.nbrb_cached_at, cached));
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    static class ViewHolder extends RecyclerView.ViewHolder {
        final TextView abbr;
        final TextView name;
        final TextView rateLine;
        final TextView rateDate;
        final TextView cachedAt;

        ViewHolder(@NonNull View itemView) {
            super(itemView);
            abbr = itemView.findViewById(R.id.nbrb_abbr);
            name = itemView.findViewById(R.id.nbrb_name);
            rateLine = itemView.findViewById(R.id.nbrb_rate_line);
            rateDate = itemView.findViewById(R.id.nbrb_rate_date);
            cachedAt = itemView.findViewById(R.id.nbrb_cached_at);
        }
    }
}
