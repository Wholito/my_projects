package com.autoparts.catalog;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public final class PartQueryEngine {

    public enum Sort {
        ID_DESC,
        DATE_DESC,
        DATE_ASC,
        TITLE_ASC
    }

    private PartQueryEngine() {
    }

    public static List<Part> apply(List<Part> source,
                                   String rawQuery,
                                   String categoryFilterOrEmpty,
                                   String dateFromOrEmpty,
                                   String dateToOrEmpty,
                                   Sort sort,
                                   boolean favoritesOnly) {
        List<Part> out = new ArrayList<>();
        String cat = categoryFilterOrEmpty != null ? categoryFilterOrEmpty.trim() : "";
        Date from = parseDate(dateFromOrEmpty);
        Date to = parseDate(dateToOrEmpty);

        for (Part p : source) {
            if (favoritesOnly && !p.isFavorite()) {
                continue;
            }
            if (!cat.isEmpty()) {
                String pc = p.getCategory() != null ? p.getCategory().trim() : "";
                if (!pc.equalsIgnoreCase(cat)) {
                    continue;
                }
            }
            if (!inDateRange(p, from, to)) {
                continue;
            }
            if (!matchesFuzzyQuery(rawQuery, p)) {
                continue;
            }
            out.add(p);
        }

        Comparator<Part> cmp = comparatorFor(sort);
        Collections.sort(out, cmp);
        return out;
    }

    private static Comparator<Part> comparatorFor(Sort sort) {
        switch (sort) {
            case DATE_ASC:
                return (a, b) -> compareDates(a.getDate(), b.getDate(), true);
            case DATE_DESC:
                return (a, b) -> compareDates(a.getDate(), b.getDate(), false);
            case TITLE_ASC:
                return Comparator.comparing(
                        p -> p.getTitle() != null ? p.getTitle().toLowerCase(Locale.getDefault()) : "",
                        String::compareTo);
            case ID_DESC:
            default:
                return (a, b) -> Long.compare(b.getId(), a.getId());
        }
    }

    private static int compareDates(String da, String db, boolean ascending) {
        Date a = parseDate(da);
        Date b = parseDate(db);
        long ta = a != null ? a.getTime() : Long.MIN_VALUE;
        long tb = b != null ? b.getTime() : Long.MIN_VALUE;
        int c = Long.compare(ta, tb);
        return ascending ? c : -c;
    }

    private static Date parseDate(String s) {
        if (s == null) {
            return null;
        }
        String t = s.trim();
        if (t.isEmpty()) {
            return null;
        }
        try {
            return new SimpleDateFormat("yyyy-MM-dd", Locale.US).parse(t);
        } catch (ParseException e) {
            return null;
        }
    }

    private static boolean inDateRange(Part p, Date from, Date to) {
        if (from == null && to == null) {
            return true;
        }
        Date d = parseDate(p.getDate());
        if (d == null) {
            return from == null && to == null;
        }
        if (from != null && d.before(truncateDay(from))) {
            return false;
        }
        if (to != null && d.after(endOfDay(to))) {
            return false;
        }
        return true;
    }

    private static Date truncateDay(Date d) {
        try {
            String day = new SimpleDateFormat("yyyy-MM-dd", Locale.US).format(d);
            return new SimpleDateFormat("yyyy-MM-dd", Locale.US).parse(day);
        } catch (ParseException e) {
            return d;
        }
    }

    private static Date endOfDay(Date d) {
        Date start = truncateDay(d);
        if (start == null) {
            return d;
        }
        return new Date(start.getTime() + 24L * 60 * 60 * 1000 - 1);
    }


    static boolean matchesFuzzyQuery(String rawQuery, Part p) {
        if (rawQuery == null || rawQuery.trim().isEmpty()) {
            return true;
        }
        String hay = p.searchableText();
        for (String token : tokenize(rawQuery)) {
            if (token.isEmpty()) {
                continue;
            }
            if (!tokenMatchesHaystack(token, hay)) {
                return false;
            }
        }
        return true;
    }

    private static List<String> tokenize(String q) {
        String[] parts = q.toLowerCase(Locale.getDefault()).trim().split("\\s+");
        List<String> list = new ArrayList<>();
        for (String s : parts) {
            if (!s.isEmpty()) {
                list.add(s);
            }
        }
        return list;
    }

    private static boolean tokenMatchesHaystack(String token, String hayLower) {
        if (hayLower.contains(token)) {
            return true;
        }
        int maxDist = token.length() <= 3 ? 0 : 1;
        if (maxDist == 0) {
            return false;
        }
        for (String word : hayLower.split("\\s+")) {
            if (word.isEmpty()) {
                continue;
            }
            if (levenshtein(token, word) <= maxDist) {
                return true;
            }
        }
        return false;
    }

    static int levenshtein(String a, String b) {
        int n = a.length();
        int m = b.length();
        if (n == 0) {
            return m;
        }
        if (m == 0) {
            return n;
        }
        int[] prev = new int[m + 1];
        int[] cur = new int[m + 1];
        for (int j = 0; j <= m; j++) {
            prev[j] = j;
        }
        for (int i = 1; i <= n; i++) {
            cur[0] = i;
            char ca = a.charAt(i - 1);
            for (int j = 1; j <= m; j++) {
                int cost = ca == b.charAt(j - 1) ? 0 : 1;
                cur[j] = Math.min(Math.min(cur[j - 1] + 1, prev[j] + 1), prev[j - 1] + cost);
            }
            int[] t = prev;
            prev = cur;
            cur = t;
        }
        return prev[m];
    }
}
