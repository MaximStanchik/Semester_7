# Лабораторная работа 7: Классификация текста на русском языке
import pandas as pd
import numpy as np
import re
import nltk
from nltk.corpus import stopwords
from sklearn.feature_extraction.text import CountVectorizer, TfidfVectorizer
from sklearn.model_selection import train_test_split
from sklearn.naive_bayes import MultinomialNB
from sklearn.svm import SVC
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, confusion_matrix
import matplotlib
matplotlib.use('Agg')  # Неинтерактивный бэкенд для PyCharm
import matplotlib.pyplot as plt
import seaborn as sns
from wordcloud import WordCloud
import warnings
warnings.filterwarnings('ignore')

print("="*70)
print("ЛАБОРАТОРНАЯ РАБОТА 7: КЛАССИФИКАЦИЯ ТЕКСТА НА РУССКОМ ЯЗЫКЕ")
print("="*70)

# 1. ЗАГРУЗКА ДАТАСЕТА
print("\n1. ЗАГРУЗКА ДАТАСЕТА")
print("-"*40)

try:
    # Пробуем загрузить датасет
    df = pd.read_csv('women-clothing-accessories.3-class.balanced.csv', sep=';')
    print("✓ Датасет успешно загружен!")

    # Проверяем наличие нужных столбцов
    if 'review' not in df.columns or 'sentiment' not in df.columns:
        print("Ошибка: В датасете должны быть столбцы 'review' и 'sentiment'")
        # Создаем тестовый датасет если нужные столбцы отсутствуют
        data = {
            'review': [
                "Отличное платье, сидит идеально! Качество ткани на высоте.",
                "Ужасный товар, размер не соответствует, ткань дешевая.",
                "Нормальное платье за свои деньги, но швы не очень ровные.",
                "Прекрасный выбор! Очень удобно и стильно выглядит.",
                "Разочарована покупкой, цвет на фото и в реальности отличается.",
                "Качественная вещь, но размер маловат, нужно брать больше.",
                "Очень плохое качество, после первой стирки полиняло.",
                "Идеально! То что нужно, буду заказывать еще.",
                "Средненько, ничего особенного, но носить можно.",
                "Лучшая покупка этого сезона! Рекомендую всем."
            ],
            'sentiment': [2, 0, 1, 2, 0, 1, 0, 2, 1, 2]  # 0-негативный, 1-нейтральный, 2-позитивный
        }
        df = pd.DataFrame(data)
        print("Используется тестовый датасет")

except FileNotFoundError:
    print("Файл 'women-clothing-accessories.3-class.balanced.csv' не найден.")
    print("Создаем тестовый датасет для демонстрации...")

    # Создаем тестовый датасет на русском языке
    data = {
        'review': [
            # Позитивные отзывы (sentiment = 2)
            "Отличное платье, сидит идеально! Качество ткани на высоте.",
            "Прекрасный выбор! Очень удобно и стильно выглядит.",
            "Идеально! То что нужно, буду заказывать еще.",
            "Лучшая покупка этого сезона! Рекомендую всем.",
            "Качественная вещь, хороший пошив, приятная ткань.",
            "Очень понравилось, размер соответствует, цвет как на фото.",
            "Отличное качество, быстро доставили, все супер!",
            "Прекрасная блузка, сидит как влитая, цвет шикарный.",
            "Супер товар! Соответствует описанию, упаковано отлично.",
            "Замечательное платье, всем нравится, спасибо магазину!",

            # Нейтральные отзывы (sentiment = 1)
            "Нормальное платье за свои деньги, но швы не очень ровные.",
            "Качественная вещь, но размер маловат, нужно брать больше.",
            "Средненько, ничего особенного, но носить можно.",
            "Неплохо, но ожидала большего за эти деньги.",
            "Обычное платье, ничего выдающегося, цена соответствует.",
            "Нормально, но фасон не совсем такой как на картинке.",
            "Приемлемое качество для такой цены, можно брать.",
            "Не плохо и не хорошо, средний товар за среднюю цену.",
            "В целом нормально, но есть небольшие недочеты.",
            "Удовлетворительно, соответствует ожиданиям.",

            # Негативные отзывы (sentiment = 0)
            "Ужасный товар, размер не соответствует, ткань дешевая.",
            "Разочарована покупкой, цвет на фото и в реальности отличается.",
            "Очень плохое качество, после первой стирки полиняло.",
            "Кошмарный товар, никому не советую, выбросила деньги.",
            "Ужасное качество пошива, нитки торчат, швы кривые.",
            "Не соответствует описанию, ткань очень тонкая и дешевая.",
            "Полный разочарование, вещь не стоит таких денег.",
            "Плохой товар, не рекомендую, лучше купить в другом месте.",
            "Ужасное обслуживание и качество товара на нуле.",
            "Не покупайте! Обман, вещь совсем не такая как на фото."
        ],
        'sentiment': [2, 2, 2, 2, 2, 2, 2, 2, 2, 2,  # позитивные
                      1, 1, 1, 1, 1, 1, 1, 1, 1, 1,  # нейтральные
                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0]  # негативные
    }
    df = pd.DataFrame(data)

print(f"\nИнформация о датасете:")
print(f"Размер датасета: {df.shape}")
print(f"Колонки: {list(df.columns)}")
print(f"\nПервые 5 строк:")
print(df.head())

print(f"\nРаспределение классов (sentiment):")
sentiment_counts = df['sentiment'].value_counts().sort_index()
sentiment_labels = {0: 'Негативный', 1: 'Нейтральный', 2: 'Позитивный'}
for sentiment, count in sentiment_counts.items():
    label = sentiment_labels.get(sentiment, f'Класс {sentiment}')
    print(f"  {label} ({sentiment}): {count} отзывов")

# 2. ПРЕДОБРАБОТКА ТЕКСТА НА РУССКОМ ЯЗЫКЕ
print("\n2. ПРЕДОБРАБОТКА ТЕКСТА НА РУССКОМ ЯЗЫКЕ")
print("-"*40)

# Загружаем стоп-слова для русского языка
try:
    nltk.download('stopwords', quiet=True)
    russian_stopwords = stopwords.words('russian')
except:
    print("Не удалось загрузить стоп-слова NLTK, используем базовый список...")
    russian_stopwords = [
        'и', 'в', 'во', 'не', 'что', 'он', 'на', 'я', 'с', 'со', 'как', 'а', 'то', 'все', 'она',
        'так', 'его', 'но', 'да', 'ты', 'к', 'у', 'же', 'вы', 'за', 'бы', 'по', 'только', 'ее',
        'мне', 'было', 'вот', 'от', 'меня', 'еще', 'нет', 'о', 'из', 'ему', 'теперь', 'когда',
        'даже', 'ну', 'вдруг', 'ли', 'если', 'уже', 'или', 'ни', 'быть', 'был', 'него', 'до',
        'вас', 'нибудь', 'опять', 'уж', 'вам', 'ведь', 'там', 'потом', 'себя', 'ничего', 'ей',
        'может', 'они', 'тут', 'где', 'есть', 'надо', 'ней', 'для', 'мы', 'тебя', 'их', 'чем',
        'была', 'сам', 'чтоб', 'без', 'будто', 'чего', 'раз', 'тоже', 'себе', 'под', 'будет',
        'ж', 'тогда', 'кто', 'этот', 'того', 'потому', 'этого', 'какой', 'совсем', 'ним',
        'здесь', 'этом', 'один', 'почти', 'мой', 'тем', 'чтобы', 'нее', 'сейчас', 'были', 'куда',
        'зачем', 'всех', 'никогда', 'можно', 'при', 'наконец', 'два', 'об', 'другой', 'хоть',
        'после', 'над', 'больше', 'тот', 'через', 'эти', 'нас', 'про', 'всего', 'них', 'какая',
        'много', 'разве', 'три', 'эту', 'моя', 'впрочем', 'хорошо', 'свою', 'этой', 'перед',
        'иногда', 'лучше', 'чуть', 'том', 'нельзя', 'такой', 'им', 'более', 'всегда', 'конечно',
        'всю', 'между'
    ]

def preprocess_russian_text(text):
    """
    Функция для предобработки русского текста:
    1. Приведение к нижнему регистру
    2. Удаление специальных символов и цифр
    3. Токенизация
    4. Удаление стоп-слов
    """
    if not isinstance(text, str):
        return ""

    # Приведение к нижнему регистру
    text = text.lower()

    # Удаление специальных символов, цифр и лишних пробелов
    text = re.sub(r'[^\w\s]', ' ', text)  # Удаляем пунктуацию
    text = re.sub(r'\d+', '', text)  # Удаляем цифры
    text = re.sub(r'\s+', ' ', text)  # Удаляем лишние пробелы
    text = text.strip()

    # Токенизация (разбиение на слова)
    words = text.split()

    # Удаление стоп-слов
    processed_words = []
    for word in words:
        if word not in russian_stopwords and len(word) > 2:  # Игнорируем короткие слова
            processed_words.append(word)

    return ' '.join(processed_words)

# Применяем предобработку
df['processed_review'] = df['review'].apply(preprocess_russian_text)

print("Пример предобработки текста:")
print("Оригинальный текст:")
print(df.loc[0, 'review'])
print("\nОбработанный текст:")
print(df.loc[0, 'processed_review'])

# Проверяем, есть ли пустые тексты после обработки
empty_reviews = df[df['processed_review'].str.strip() == ''].shape[0]
if empty_reviews > 0:
    print(f"\nВнимание: {empty_reviews} отзывов стали пустыми после обработки")

# 3. РАЗДЕЛЕНИЕ ДАННЫХ
print("\n3. РАЗДЕЛЕНИЕ ДАННЫХ НА ОБУЧАЮЩУЮ И ТЕСТОВУЮ ВЫБОРКИ")
print("-"*40)

X = df['processed_review']
y = df['sentiment']

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.3, random_state=42, stratify=y
)

print(f"Размер обучающей выборки: {len(X_train)}")
print(f"Размер тестовой выборки: {len(X_test)}")

# 4. ПРЕОБРАЗОВАНИЕ ТЕКСТА В ЧИСЛОВУЮ ФОРМУ
print("\n4. ПРЕОБРАЗОВАНИЕ ТЕКСТА В ЧИСЛОВУЮ ФОРМУ")
print("-"*40)

# 4.1 Метод Bag of Words для русского текста
print("\n--- Метод Bag of Words ---")
bow_vectorizer = CountVectorizer(max_features=500, analyzer='word', ngram_range=(1, 2))
X_train_bow = bow_vectorizer.fit_transform(X_train)
X_test_bow = bow_vectorizer.transform(X_test)

print(f"Размер матрицы признаков (обучающая): {X_train_bow.shape}")
print(f"Размер матрицы признаков (тестовая): {X_test_bow.shape}")

feature_names = bow_vectorizer.get_feature_names_out()
print(f"\nПримеры признаков (слов/биграмм) в BoW:")
print(feature_names[:20])

# 4.2 Метод TF-IDF для русского текста
print("\n--- Метод TF-IDF ---")
tfidf_vectorizer = TfidfVectorizer(max_features=500, analyzer='word', ngram_range=(1, 2))
X_train_tfidf = tfidf_vectorizer.fit_transform(X_train)
X_test_tfidf = tfidf_vectorizer.transform(X_test)

print(f"Размер матрицы признаков (обучающая): {X_train_tfidf.shape}")
print(f"Размер матрицы признаков (тестовая): {X_test_tfidf.shape}")

# Пояснение TF-IDF
print("\nОбъяснение TF-IDF:")
print("TF (Term Frequency) - частота термина в документе")
print("IDF (Inverse Document Frequency) - обратная частота документа")
print("TF-IDF = TF * IDF")
print("TF = (количество вхождений термина в документе) / (общее количество терминов в документе)")
print("IDF = log((общее количество документов) / (количество документов, содержащих термин))")

# 5. ОБУЧЕНИЕ И ОЦЕНКА МОДЕЛЕЙ
print("\n5. ОБУЧЕНИЕ И ОЦЕНКА МОДЕЛЕЙ КЛАССИФИКАТОРОВ")
print("-"*40)

def evaluate_model(model, X_train, X_test, y_train, y_test, model_name, vectorizer_name):
    """Функция для обучения и оценки модели"""
    # Обучение модели
    model.fit(X_train, y_train)

    # Предсказания
    y_pred = model.predict(X_test)

    # Расчет метрик
    accuracy = accuracy_score(y_test, y_pred)
    precision = precision_score(y_test, y_pred, average='weighted')
    recall = recall_score(y_test, y_pred, average='weighted')
    f1 = f1_score(y_test, y_pred, average='weighted')

    print(f"\n{model_name} с {vectorizer_name}:")
    print(f"  Accuracy: {accuracy:.4f}")
    print(f"  Precision: {precision:.4f}")
    print(f"  Recall: {recall:.4f}")
    print(f"  F1-Score: {f1:.4f}")

    # Матрица ошибок (сохраняем в файл)
    cm = confusion_matrix(y_test, y_pred)

    plt.figure(figsize=(8, 6))
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues',
                xticklabels=['Негатив', 'Нейтрал', 'Позитив'],
                yticklabels=['Негатив', 'Нейтрал', 'Позитив'])
    plt.title(f'Матрица ошибок - {model_name} ({vectorizer_name})', fontsize=14)
    plt.ylabel('Истинный класс', fontsize=12)
    plt.xlabel('Предсказанный класс', fontsize=12)
    plt.tight_layout()

    # Сохраняем в файл
    filename = f"confusion_matrix_{model_name}_{vectorizer_name}.png"
    plt.savefig(filename, dpi=100)
    print(f"  Матрица ошибок сохранена в файл: {filename}")
    plt.close()

    return {
        'model': model_name,
        'vectorizer': vectorizer_name,
        'accuracy': accuracy,
        'precision': precision,
        'recall': recall,
        'f1': f1
    }

# Инициализация моделей
models = {
    'Naive Bayes': MultinomialNB(),
    'SVM': SVC(kernel='linear', random_state=42),
    'Random Forest': RandomForestClassifier(n_estimators=100, random_state=42)
}

results = []

print("\nОЦЕНКА МОДЕЛЕЙ С BAG OF WORDS:")
print("-"*30)
for name, model in models.items():
    result = evaluate_model(model, X_train_bow, X_test_bow, y_train, y_test,
                            name, 'Bag of Words')
    results.append(result)

print("\nОЦЕНКА МОДЕЛЕЙ С TF-IDF:")
print("-"*30)
for name, model in models.items():
    result = evaluate_model(model, X_train_tfidf, X_test_tfidf, y_train, y_test,
                            name, 'TF-IDF')
    results.append(result)

# Создаем DataFrame с результатами
results_df = pd.DataFrame(results)
print("\n" + "="*70)
print("СРАВНЕНИЕ РЕЗУЛЬТАТОВ ВСЕХ МОДЕЛЕЙ")
print("="*70)
print(results_df.to_string(index=False))

# 6. ВЫБОР НАИЛУЧШЕЙ МОДЕЛИ
print("\n6. ВЫБОР НАИЛУЧШЕЙ МОДЕЛИ")
print("-"*40)

# Находим лучшую модель по F1-score
best_model_idx = results_df['f1'].idxmax()
best_model = results_df.loc[best_model_idx]

print(f"НАИЛУЧШАЯ МОДЕЛЬ:")
print(f"  Модель: {best_model['model']}")
print(f"  Векторизатор: {best_model['vectorizer']}")
print(f"  Accuracy: {best_model['accuracy']:.4f}")
print(f"  F1-Score: {best_model['f1']:.4f}")

# Обучаем лучшую модель на всех данных
print("\nОбучение финальной модели на всех данных...")
if best_model['vectorizer'] == 'Bag of Words':
    final_vectorizer = bow_vectorizer
    X_final = final_vectorizer.fit_transform(X)
else:
    final_vectorizer = tfidf_vectorizer
    X_final = final_vectorizer.fit_transform(X)

if best_model['model'] == 'Naive Bayes':
    final_model = MultinomialNB()
elif best_model['model'] == 'SVM':
    final_model = SVC(kernel='linear', random_state=42)
else:
    final_model = RandomForestClassifier(n_estimators=100, random_state=42)

final_model.fit(X_final, y)
print("✓ Финальная модель обучена!")

# 7. КЛАССИФИКАЦИЯ НОВЫХ ДАННЫХ
print("\n7. КЛАССИФИКАЦИЯ НОВЫХ ДАННЫХ")
print("-"*40)

# Новые отзывы для классификации
new_reviews = [
    "Отличная куртка, очень теплая и стильная, буду носить с удовольствием!",
    "Качество ужасное, ткань тонкая, не советую покупать этот товар.",
    "Нормальная сумка за свои деньги, но фурнитура могла бы быть лучше.",
    "Идеальное платье для вечеринки, все подруги спрашивают где купила!",
    "Размер не соответствует, пришлось вернуть, очень неудобно.",
    "Хорошая блузка, но цвет немного отличается от фото на сайте.",
    "Прекрасный шарф, мягкий и теплый, отлично дополнил мой образ.",
    "Ужасное качество пошива, швы расходятся после первой носки.",
    "В целом неплохо, но есть небольшие недочеты в отделке.",
    "Лучшая покупка этого месяца! Качество на высоте, доставка быстрая."
]

new_reviews_processed = [preprocess_russian_text(review) for review in new_reviews]

if best_model['vectorizer'] == 'Bag of Words':
    new_reviews_vectorized = bow_vectorizer.transform(new_reviews_processed)
else:
    new_reviews_vectorized = tfidf_vectorizer.transform(new_reviews_processed)

predictions = final_model.predict(new_reviews_vectorized)
sentiment_mapping = {0: 'Негативный', 1: 'Нейтральный', 2: 'Позитивный'}
prediction_labels = [sentiment_mapping[pred] for pred in predictions]

print("Результаты классификации новых отзывов:")
print("-" * 60)
for i, (review, label) in enumerate(zip(new_reviews, prediction_labels), 1):
    short_review = review[:70] + "..." if len(review) > 70 else review
    print(f"\nОтзыв {i}: {label}")
    print(f"  {short_review}")

# 8. ОБЛАКО СЛОВ
print("\n8. ОБЛАКО СЛОВ ДЛЯ РАЗНЫХ КАТЕГОРИЙ")
print("-"*40)

# Создаем тексты для разных категорий тональности
for sentiment, label in sentiment_mapping.items():
    text = ' '.join(df[df['sentiment'] == sentiment]['processed_review'])
    if text.strip():  # Проверяем, что текст не пустой
        wordcloud = WordCloud(
            width=800,
            height=400,
            background_color='white',
            max_words=100,
            contour_width=3,
            contour_color='steelblue',
            font_path=None,  # Для русского текста может потребоваться шрифт
            colormap='viridis'
        ).generate(text)

        plt.figure(figsize=(10, 5))
        plt.imshow(wordcloud, interpolation='bilinear')
        plt.title(f"Облако слов для {label.lower()} отзывов", fontsize=16)
        plt.axis('off')
        plt.tight_layout()

        filename = f"wordcloud_{label}.png"
        plt.savefig(filename, dpi=100)
        print(f"  Облако слов '{label}' сохранено в файл: {filename}")
        plt.close()
    else:
        print(f"  Нет данных для создания облака слов '{label}'")

# 9. ОТВЕТЫ НА ВОПРОСЫ
print("\n9. ОТВЕТЫ НА ВОПРОСЫ")
print("-"*40)

answers = """
1. Что означает термин лемматизация?
Лемматизация - это процесс приведения слова к его нормальной (словарной) форме (лемме). 
В отличие от стемминга, который просто отрезает окончания, лемматизация учитывает 
морфологический анализ слова и его контекст. Например:
- "бежал", "бежит", "бегу" → "бежать"
- "лучший", "лучше" → "хороший"
- "столы", "столам", "столами" → "стол"

2. Метод Bag of Words.
Bag of Words (BoW) - это метод представления текста в виде числового вектора, 
где каждый элемент вектора соответствует частоте встречаемости определенного 
слова в документе. Особенности:
- Не учитывает порядок слов
- Каждое слово становится отдельным признаком
- Значение признака - частота слова в документе
- Создает разреженную матрицу (много нулей)

3. Метод TF-IDF. Метрики TF и IDF.
TF-IDF (Term Frequency-Inverse Document Frequency) - статистическая мера, 
используемая для оценки важности слова в документе относительно коллекции документов.

TF (Term Frequency) - частота термина в документе:
TF(t, d) = (количество вхождений термина t в документе d) / 
           (общее количество терминов в документе d)

IDF (Inverse Document Frequency) - обратная частота документа:
IDF(t, D) = log((общее количество документов в коллекции D) / 
               (количество документов, содержащих термин t))

TF-IDF вычисляется как произведение этих двух величин:
TF-IDF(t, d, D) = TF(t, d) × IDF(t, D)

Преимущества TF-IDF:
- Уменьшает вес часто встречающихся слов (стоп-слов)
- Увеличивает вес редких, но значимых слов
- Лучше отражает важность слов в контексте всей коллекции документов
"""

print(answers)

print("\n" + "="*70)
print("ЛАБОРАТОРНАЯ РАБОТА УСПЕШНО ЗАВЕРШЕНА!")
print("="*70)

# Дополнительная статистика
print("\nДОПОЛНИТЕЛЬНАЯ СТАТИСТИКА:")
print(f"Всего отзывов: {len(df)}")
print(f"Средняя длина отзыва (символов): {df['review'].apply(len).mean():.1f}")
print(f"Средняя длина отзыва (слов): {df['review'].apply(lambda x: len(str(x).split())).mean():.1f}")

# Сохраняем обработанные данные в файл
df.to_csv('processed_reviews.csv', index=False, encoding='utf-8')
print(f"\nОбработанные данные сохранены в файл: processed_reviews.csv")