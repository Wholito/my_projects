# Auto Parts Catalog

Android-каталог автозапчастей: локальная SQLite-база, фильтры, фото, облачная синхронизация Firebase, курсы НБ РБ.

## Стек

- Java, Material Design
- SQLite, RecyclerView
- Firebase Auth + Firestore
- Retrofit (API НБ РБ)
- Glide

## Запуск

1. Откройте проект в Android Studio.
2. Подставьте свой `app/google-services.json` для Firebase (опционально).
3. Соберите и запустите на эмуляторе или устройстве (minSdk 24).

## Возможности

- CRUD запчастей с категорией и фото
- Поиск, сортировка, фильтр по дате и категории
- Избранное
- Синхронизация с Firestore
- Курсы валют НБ РБ (онлайн и кэш)
- Напоминания, RU/EN, тёмная тема
