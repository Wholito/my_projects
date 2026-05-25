    package com.autoparts.catalog;

    import androidx.annotation.NonNull;
    import androidx.lifecycle.ViewModel;
    import androidx.lifecycle.ViewModelProvider;

    public class ApiCatalogViewModelFactory implements ViewModelProvider.Factory {
        private final ApiCatalogRepository repository;

        public ApiCatalogViewModelFactory(ApiCatalogRepository repository) {
            this.repository = repository;
        }

        @NonNull
        @Override
        @SuppressWarnings("unchecked")
        public <T extends ViewModel> T create(@NonNull Class<T> modelClass) {
            if (modelClass.isAssignableFrom(ApiCatalogViewModel.class)) {
                return (T) new ApiCatalogViewModel(repository);
            }
            throw new IllegalArgumentException("Unknown ViewModel class");
        }
    }
