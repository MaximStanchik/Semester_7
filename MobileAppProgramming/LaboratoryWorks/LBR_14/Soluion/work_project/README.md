# LBR_14 — Анимации в существующем интерфейсе

Этот проект демонстрирует выполнение требований лабораторной работы по анимациям **без добавления отдельных “демо-страниц”**: всё встроено в уже существующие экраны (`HomeScreen`, `ProductListScreen`, `EmployeeListScreen`, `FavoritesScreen`, `ProductDetailScreen`).

## Быстрый запуск

- `flutter pub get`
- `flutter run`

Примечание: на эмуляторе возможны `Skipped frames` (лаг на старте). В проекте запуск staggered-анимаций сделан **после первого кадра**, чтобы их было видно даже при лаге.

---

# Как продемонстрировать (по пунктам задания)

## 1) Минимум 3 Implicit анимации

### Как показать

1. Открой приложение (экран `HomeScreen`).
2. Потапай по вкладкам нижнего меню: увидишь плавное изменение выделения.
3. На вкладке **Товары** введи текст в поиск: изменится фон/тень строки поиска.
4. Очисти/измени запрос: список товаров мягко переключится.

### Где в коде

- **`lib/screens/home_screen.dart`**
  - `AnimatedContainer` в `_buildBottomNavItem(...)` — анимация выделения таба.
  - `AnimatedScale` на кнопке переключения пользователя (иконка справа сверху).

- **`lib/screens/products/product_list_screen.dart`**
  - `AnimatedContainer` в `_buildSearchBar(...)` — фон/тень строки поиска в зависимости от наличия текста.
  - `AnimatedSwitcher` вокруг списка товаров — плавное обновление при смене query/данных.

---

## 2) Кастомная кривая (Curve) и её назначение

### Что требуется

Кривая: **f(t) = sin(t * π/2)**.

### Где реализовано

- **`lib/utils/animations.dart`**
  - `class SinInCurve extends Curve` — реализация `sin(t * π/2)`.

### Где используется

- Staggered-анимации (`EmployeeListScreen`, `ProductListScreen`)
- Implicit-анимации (`HomeScreen`, `ProductListScreen`)
- Переходы между страницами (кастомные `Route` builders)

---

## 3) Действие по окончанию анимации (`onEnd`)

### Как показать

1. На `HomeScreen` переключай вкладки нижнего меню.
2. После завершения анимации появляется `SnackBar` вида `Открыта вкладка: ...`.

### Где в коде

- **`lib/screens/home_screen.dart`**
  - `_buildBottomNavItem(...)` → `AnimatedContainer(onEnd: ...)`.

---

## 4) Несколько анимаций с использованием `TweenAnimationBuilder`

### Как показать

1. Открой вкладку **Товары** (`ProductListScreen`).
2. В карточке прогресса увидишь анимированное заполнение и числа процентов.
3. На `HomeScreen` при выборе таба иконка плавно увеличивается.

### Где в коде

- **`lib/screens/products/product_list_screen.dart`**
  - `_buildProgressCard()`:
    - `TweenAnimationBuilder<double>` для текста процентов
    - `TweenAnimationBuilder<double>` для `CircularProgressIndicator`

- **`lib/screens/home_screen.dart`**
  - `_buildBottomNavItem(...)`:
    - `TweenAnimationBuilder<double>` + `Transform.scale` для иконки таба

- **`lib/screens/employee_list_screen.dart`**
  - `_buildEmployeeCard(...)`:
    - `TweenAnimationBuilder<double>` для появления/сдвига карточек сотрудников

---

## 5) Минимум 2 явных (Explicit) анимации

### Как показать

1. Открой вкладку **Товары** — увидишь явную staggered-анимацию через `AnimationController`.
2. Открой вкладку **Сотрудники** — увидишь явную staggered-анимацию + пульсацию FAB.

### Где в коде

- **`lib/screens/products/product_list_screen.dart`**
  - `AnimationController _introController` + `FadeTransition/SlideTransition/ScaleTransition`

- **`lib/screens/employee_list_screen.dart`**
  - `AnimationController _headerController`
  - `AnimationController _folderController`
  - `AnimationController _fabController`

---

## 6) Минимум 2 ступенчатые (Staggered) анимации (разные), минимум 5 шагов, кривая `sin(t*π/2)`

### Как показать

#### Staggered #1 — `EmployeeListScreen`
1. Открой вкладку **Сотрудники**.
2. Появление элементов идёт ступенчато (по интервалам):
   - Discover
   - Employees
   - Folder
   - Search
   - Sort

#### Staggered #2 — `ProductListScreen`
1. Открой вкладку **Товары**.
2. Появление элементов идёт ступенчато (по интервалам):
   - Discover header
   - Progress card
   - Categories row
   - Exercise header
   - Search bar

### Где в коде

- **`lib/screens/employee_list_screen.dart`**
  - `CurvedAnimation(parent: _headerController, curve: Interval(..., curve: SinInCurve()))`

- **`lib/screens/products/product_list_screen.dart`**
  - `CurvedAnimation(parent: _introController, curve: Interval(..., curve: SinInCurve()))`

---

# Анимации при переходе между страницами (Navigation transitions)

## Как показать

1. На вкладке **Товары** открой товар — переход идёт **снизу вверх + fade**.
2. Нажми редактирование товара — переход **scale + fade**.
3. На вкладке **Сотрудники** открой сотрудника — переход **снизу вверх + fade**.
4. Открой `FileLocationsScreen` — переход **slide + fade**.

## Где в коде

- **`lib/utils/animations.dart`**
  - `buildSlideFadeRoute(...)`
  - `buildSlideUpFadeRoute(...)`
  - `buildScaleFadeRoute(...)`

Применение:

- **`lib/screens/products/product_list_screen.dart`**
  - `ProductDetailScreen` → `buildSlideUpFadeRoute`
  - `ProductEditScreen` → `buildScaleFadeRoute`
  - `Favorites/Security/Employees` → `buildSlideFadeRoute`

- **`lib/screens/products/favorites_screen.dart`**
  - `ProductDetailScreen` → `buildSlideUpFadeRoute`

- **`lib/screens/products/product_detail_screen.dart`**
  - `ProductEditScreen` → `buildScaleFadeRoute`

- **`lib/screens/employee_list_screen.dart`**
  - `EmployeeDetailScreen` → `buildSlideUpFadeRoute`
  - `EmployeeEditScreen` → `buildScaleFadeRoute`
  - `FileLocationsScreen` → `buildSlideFadeRoute`

---

# Примечания для демонстрации

- Если делаешь **Hot Restart** и «кажется, что анимации не проигрываются», в проекте добавлены `reassemble()` и запуск анимаций после первого кадра, чтобы их можно было повторно увидеть.
- На слабом эмуляторе часть анимаций может казаться менее плавной из-за `Skipped frames` — на реальном устройстве обычно заметно лучше.
