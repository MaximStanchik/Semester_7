import warnings
warnings.filterwarnings('ignore')

import numpy as np
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.decomposition import PCA
from sklearn.manifold import TSNE
import os
from gensim.models import KeyedVectors

# Устанавливаем стиль графиков
plt.style.use('seaborn-v0_8-darkgrid')
sns.set_palette("husl")

class EmbeddingAnalyzer:
    def __init__(self, embeddings_dir='D:/embeddings'):
        """Инициализация анализатора эмбеддингов"""
        self.embeddings_dir = embeddings_dir
        self.models = {}
        self.model_names = []

    def load_wiki_news(self, limit=None):
        """
        Загрузка модели wiki-news-300d-1M.vec (Word2Vec)
        """
        model_path = os.path.join(self.embeddings_dir, 'wiki-news-300d-1M.vec')
        print(f"Загрузка Wiki News модели из {model_path}...")

        if not os.path.exists(model_path):
            print(f"Файл не найден: {model_path}")
            return None

        try:
            # Загружаем как текстовый формат Word2Vec
            model = KeyedVectors.load_word2vec_format(model_path, binary=False, limit=limit)
            self.models['WikiNews-W2V'] = model
            self.model_names.append('WikiNews-W2V')
            print(f"Wiki News модель загружена. Слов в словаре: {len(model.key_to_index):,}")
            return model
        except Exception as e:
            print(f"Ошибка при загрузке модели: {e}")
            return None

    def load_fasttext_model(self):
        """
        Загрузка модели FastText из .txt файла
        wiki_giga_2024_50_MFT20_vectors_seed_123_alpha_0.75_eta_0.075_combined.txt
        """
        model_path = os.path.join(self.embeddings_dir,
                                  'wiki_giga_2024_50_MFT20_vectors_seed_123_alpha_0.75_eta_0.075_combined.txt')
        print(f"Загрузка FastText модели из {model_path}...")

        if not os.path.exists(model_path):
            print(f"Файл не найден: {model_path}")
            return None

        # Сначала анализируем файл
        print("Анализ формата файла...")

        try:
            # Читаем первые 2 строки для анализа
            with open(model_path, 'r', encoding='utf-8', errors='ignore') as f:
                first_line = f.readline().strip()
                second_line = f.readline().strip()

            print(f"Первая строка файла (первые 100 символов): {first_line[:100]}")
            print(f"Вторая строка файла (первые 100 символов): {second_line[:100]}")

            # Анализируем формат
            parts_first = first_line.split()
            parts_second = second_line.split()

            # Вариант 1: Стандартный Word2Vec формат (количество_слов размерность)
            if len(parts_first) == 2:
                try:
                    vocab_size = int(parts_first[0])
                    vector_dim = int(parts_first[1])
                    print(f"Обнаружен стандартный формат: слова={vocab_size}, dim={vector_dim}")

                    model = KeyedVectors.load_word2vec_format(model_path, binary=False, limit=50000)
                    self.models['FastText-Standard'] = model
                    self.model_names.append('FastText-Standard')
                    print(f"FastText модель загружена. Слов в словаре: {len(model.key_to_index):,}")
                    return model

                except ValueError:
                    print("Первая строка не содержит числа, пробуем другие форматы...")

            # Вариант 2: Векторы без заголовка
            if len(parts_second) > 10:
                print("Пробуем загрузить как векторы без заголовка...")
                try:
                    # Пробуем пропустить заголовок
                    model = KeyedVectors.load_word2vec_format(
                        model_path,
                        binary=False,
                        no_header=True,
                        limit=50000
                    )
                    self.models['FastText-NoHeader'] = model
                    self.model_names.append('FastText-NoHeader')
                    print(f"FastText модель загружена (без заголовка). Слов: {len(model.key_to_index):,}")
                    return model
                except Exception as e:
                    print(f"Загрузка без заголовка не удалась: {e}")

            # Вариант 3: Ручная загрузка
            print("Пробуем ручную загрузку...")
            model = self._load_fasttext_manual(model_path, limit=50000)
            if model:
                self.models['FastText-Manual'] = model
                self.model_names.append('FastText-Manual')
                print(f"FastText модель загружена вручную. Слов: {len(model.key_to_index):,}")
                return model
            else:
                print("Ручная загрузка не удалась")
                return None

        except Exception as e:
            print(f"Ошибка при анализе файла: {e}")
            return None

    def _load_fasttext_manual(self, filepath, limit=50000):
        """
        Ручная загрузка FastText модели
        """
        from gensim.models import KeyedVectors
        import numpy as np

        words = []
        vectors = []
        vector_dim = None

        print(f"Ручная загрузка FastText (лимит: {limit} слов)...")

        try:
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                lines_processed = 0

                for i, line in enumerate(f):
                    if lines_processed >= limit:
                        break

                    line = line.strip()
                    if not line:
                        continue

                    parts = line.split(' ')

                    # Первая строка может быть заголовком
                    if i == 0 and len(parts) == 2:
                        try:
                            # Проверяем, может быть это заголовок (2 числа)
                            int(parts[0])
                            int(parts[1])
                            print(f"Пропускаем заголовок: {line}")
                            continue
                        except:
                            pass  # Не заголовок, обрабатываем как вектор

                    if len(parts) < 10:  # Слишком коротко для вектора
                        continue

                    word = parts[0]

                    try:
                        # Пробуем преобразовать остаток в вектор
                        vector = np.array([float(x) for x in parts[1:]])

                        if vector_dim is None:
                            vector_dim = len(vector)
                        elif len(vector) != vector_dim:
                            # Размерность не совпадает, пропускаем
                            continue

                        words.append(word)
                        vectors.append(vector)
                        lines_processed += 1

                        if lines_processed % 10000 == 0:
                            print(f"  Загружено {lines_processed} слов...")

                    except (ValueError, IndexError) as e:
                        # Не удалось преобразовать в вектор
                        continue

            if not words:
                print("Не удалось загрузить ни одного вектора")
                return None

            # Создаем KeyedVectors
            kv = KeyedVectors(vector_size=vector_dim)

            # Конвертируем векторы в numpy массив
            vectors_array = np.array(vectors)

            # Добавляем векторы
            kv.add_vectors(words, vectors_array)

            print(f"Успешно загружено {len(words)} слов, размерность {vector_dim}")
            return kv

        except Exception as e:
            print(f"Ошибка при ручной загрузке: {e}")
            return None

    def load_glove_model(self):
        """
        Загрузка модели GloVe в качестве альтернативы
        """
        try:
            import gensim.downloader as api

            print("Загрузка GloVe модели из gensim...")

            # Пробуем разные размерности
            glove_models = [
                'glove-wiki-gigaword-50',    # 50 измерений
                'glove-wiki-gigaword-100',   # 100 измерений
                'glove-wiki-gigaword-200',   # 200 измерений
                'glove-wiki-gigaword-300',   # 300 измерений
            ]

            for model_name in glove_models:
                try:
                    print(f"Пробуем загрузить {model_name}...")
                    model = api.load(model_name)
                    self.models['GloVe-' + model_name.split('-')[-1]] = model
                    self.model_names.append('GloVe-' + model_name.split('-')[-1])
                    print(f"GloVe модель загружена. Слов в словаре: {len(model.key_to_index):,}")
                    return model
                except:
                    continue

            print("Не удалось загрузить ни одну GloVe модель")
            return None

        except ImportError:
            print("Библиотека gensim.downloader не установлена")
            print("Установите: pip install gensim")
            return None
        except Exception as e:
            print(f"Ошибка при загрузке GloVe: {e}")
            return None

    def find_similar_words(self, word, topn=10):
        """
        Поиск семантически схожих слов для заданного слова
        """
        results = {}

        print(f"\n{'='*70}")
        print(f"ПОИСК СЛОВ, СХОЖИХ С '{word.upper()}'")
        print(f"{'='*70}")

        for model_name, model in self.models.items():
            print(f"\n{model_name}:")
            print("-" * 40)

            try:
                similar_words = model.most_similar(word, topn=topn)
                results[model_name] = similar_words

                for i, (similar_word, similarity) in enumerate(similar_words, 1):
                    print(f"{i:2d}. {similar_word:<25} similarity: {similarity:.4f}")

            except KeyError:
                print(f"✗ Слово '{word}' не найдено в словаре")
                results[model_name] = []
            except Exception as e:
                print(f"✗ Ошибка: {e}")
                results[model_name] = []

        return results

    def word_analogy(self, analogy, topn=10):
        """
        Выполнение семантической аналогии: A - B = C - ?

        analogy: кортеж из 3 слов (A, B, C)
        Пример: ('king', 'man', 'woman') → 'queen'
        """
        A, B, C = analogy

        print(f"\n{'='*70}")
        print(f"СЕМАНТИЧЕСКАЯ АНАЛОГИЯ: {A.upper()} - {B.upper()} = {C.upper()} - ?")
        print(f"{'='*70}")

        results = {}

        for model_name, model in self.models.items():
            print(f"\n{model_name}:")
            print("-" * 40)

            try:
                # Проверяем наличие всех слов в словаре
                for word in [A, B, C]:
                    if word not in model.key_to_index:
                        print(f"✗ Слово '{word}' не найдено в словаре")
                        results[model_name] = []
                        break
                else:
                    # Вычисляем аналогию: D = C + (B - A)
                    result = model.most_similar(positive=[C, B], negative=[A], topn=topn)
                    results[model_name] = result

                    print(f"Лучшие варианты для '{C} - ?' (аналогично '{A} - {B}'):")
                    for i, (word, similarity) in enumerate(result, 1):
                        print(f"{i:2d}. {word:<25} similarity: {similarity:.4f}")

            except Exception as e:
                print(f"✗ Ошибка: {e}")
                results[model_name] = []

        return results

    def visualize_embeddings(self, words_list, method='tsne', n_components=2):
        """
        Визуализация векторов слов с помощью PCA или t-SNE
        """
        if not words_list:
            print("Список слов пуст!")
            return

        # Получаем векторы для каждого слова из каждой модели
        vectors_dict = {}
        valid_words_dict = {}

        for model_name, model in self.models.items():
            vectors = []
            valid_words = []

            for word in words_list:
                try:
                    vector = model[word]
                    vectors.append(vector)
                    valid_words.append(word)
                except KeyError:
                    print(f"✗ Слово '{word}' не найдено в модели {model_name}")
                    continue

            if vectors:
                vectors_dict[model_name] = np.array(vectors)
                valid_words_dict[model_name] = valid_words
                print(f"✓ Модель {model_name}: найдено {len(vectors)} из {len(words_list)} слов")
            else:
                print(f"✗ Модель {model_name}: нет валидных слов")

        # Создаем графики
        n_models = len(vectors_dict)
        if n_models == 0:
            print("✗ Нет данных для визуализации")
            return

        fig, axes = plt.subplots(1, n_models, figsize=(6 * n_models, 6))
        if n_models == 1:
            axes = [axes]

        for idx, (model_name, vectors) in enumerate(vectors_dict.items()):
            valid_words = valid_words_dict[model_name]

            # Применяем PCA или t-SNE
            if method.lower() == 'pca':
                reducer = PCA(n_components=n_components, random_state=42)
                method_name = 'PCA'
            else:  # t-SNE
                reducer = TSNE(n_components=n_components, random_state=42,
                               perplexity=min(30, len(vectors)-1))
                method_name = 't-SNE'

            reduced_vectors = reducer.fit_transform(vectors)

            # Визуализируем
            ax = axes[idx]

            # Разделяем слова на семантические группы для разных цветов
            semantic_groups = {
                'royalty': ['king', 'queen', 'prince', 'princess'],
                'gender': ['man', 'woman', 'boy', 'girl'],
                'capitals': ['paris', 'london', 'berlin', 'rome', 'minsk'],
                'countries': ['france', 'england', 'germany', 'italy', 'belarus'],
                'food': ['pizza', 'pasta', 'baguette', 'beer', 'vodka'],
                'emotions': ['happy', 'sad', 'angry', 'excited']
            }

            # Назначаем цвета
            colors = []
            for word in valid_words:
                color_assigned = False
                for color_idx, (group, words) in enumerate(semantic_groups.items()):
                    if word in words:
                        colors.append(color_idx)
                        color_assigned = True
                        break
                if not color_assigned:
                    colors.append(len(semantic_groups))

            # Создаем scatter plot
            scatter = ax.scatter(reduced_vectors[:, 0], reduced_vectors[:, 1],
                                 c=colors, cmap='tab20', alpha=0.8, s=150, edgecolors='w', linewidth=0.5)

            # Добавляем подписи
            for i, word in enumerate(valid_words):
                ax.annotate(word, (reduced_vectors[i, 0], reduced_vectors[i, 1]),
                            fontsize=9, alpha=0.9,
                            bbox=dict(boxstyle="round,pad=0.3", facecolor='white', alpha=0.7, edgecolor='none'))

            ax.set_title(f'{model_name}\n({method_name} проекция)', fontsize=12, fontweight='bold')
            ax.set_xlabel('Component 1', fontsize=10)
            ax.set_ylabel('Component 2', fontsize=10)
            ax.grid(True, alpha=0.3)

            # Добавляем легенду для основных групп
            if idx == 0:
                legend_elements = []
                for i, group in enumerate(list(semantic_groups.keys())[:5]):
                    legend_elements.append(plt.Line2D([0], [0], marker='o', color='w',
                                                      markerfacecolor=plt.cm.tab20(i),
                                                      markersize=8, label=group))
                ax.legend(handles=legend_elements, loc='upper left', bbox_to_anchor=(1.05, 1))

        plt.suptitle(f'Визуализация семантических отношений между словами\n({method_name} проекция)',
                     fontsize=14, fontweight='bold')
        plt.tight_layout()

        # Исправление для PyCharm
        try:
            plt.show()
        except Exception as e:
            print(f"Ошибка отображения графика: {e}")
            plt.savefig('embeddings_visualization.png', dpi=300, bbox_inches='tight')
            print("График сохранен как 'embeddings_visualization.png'")

        return vectors_dict

    def evaluate_semantic_tasks(self, test_cases):
        """
        Оценка моделей на семантических задачах
        """
        print(f"\n{'='*70}")
        print("ОЦЕНКА КАЧЕСТВА НА СЕМАНТИЧЕСКИХ ЗАДАЧАХ")
        print(f"{'='*70}")

        scores = {model_name: {'total': 0, 'correct': 0, 'positions': []}
                  for model_name in self.models.keys()}

        for category, tasks in test_cases.items():
            print(f"\n{category.upper()}:")
            print("-" * 40)

            for i, task in enumerate(tasks):
                A, B, C, expected = task

                print(f"\nЗадача {i+1}: {A} - {B} = {C} - {expected}")

                for model_name, model in self.models.items():
                    try:
                        # Проверяем наличие всех слов
                        all_words_present = True
                        for word in [A, B, C, expected]:
                            if word not in model.key_to_index:
                                print(f"  {model_name}: ✗ Слово '{word}' не найдено")
                                all_words_present = False
                                break

                        if not all_words_present:
                            scores[model_name]['total'] += 1
                            continue

                        results = model.most_similar(positive=[C, B], negative=[A], topn=5)
                        found_words = [word for word, _ in results]

                        # Проверяем, находится ли ожидаемое слово в топ-5
                        if expected in found_words:
                            position = found_words.index(expected) + 1
                            scores[model_name]['positions'].append(position)
                            scores[model_name]['correct'] += 1
                            scores[model_name]['total'] += 1
                            print(f"  {model_name}: ✓ Найдено на позиции {position}")
                        else:
                            scores[model_name]['total'] += 1
                            print(f"  {model_name}: ✗ Не найдено в топ-5")

                    except Exception as e:
                        scores[model_name]['total'] += 1
                        print(f"  {model_name}: ✗ Ошибка: {str(e)[:50]}...")

        # Выводим результаты
        print(f"\n{'='*70}")
        print("РЕЗУЛЬТАТЫ ОЦЕНКИ")
        print(f"{'='*70}")

        for model_name, score in scores.items():
            if score['total'] > 0:
                accuracy = score['correct'] / score['total'] * 100
                if score['positions']:
                    avg_position = np.mean(score['positions'])
                    print(f"\n{model_name}:")
                    print(f"  Точность: {accuracy:.1f}% ({score['correct']}/{score['total']})")
                    print(f"  Средняя позиция правильного ответа: {avg_position:.2f}")
                else:
                    print(f"\n{model_name}:")
                    print(f"  Точность: {accuracy:.1f}% ({score['correct']}/{score['total']})")
                    print(f"  Правильных ответов не найдено")

    def analyze_vocabulary_coverage(self, test_words):
        """
        Анализ покрытия словаря
        """
        print(f"\n{'='*70}")
        print("АНАЛИЗ ПОКРЫТИЯ СЛОВАРЯ")
        print(f"{'='*70}")

        results = {}

        for model_name, model in self.models.items():
            found_words = []
            missing_words = []

            for word in test_words:
                if word in model.key_to_index:
                    found_words.append(word)
                else:
                    missing_words.append(word)

            coverage = len(found_words) / len(test_words) * 100
            results[model_name] = {
                'coverage': coverage,
                'found': found_words,
                'missing': missing_words
            }

            print(f"\n{model_name}:")
            print(f"  Покрытие: {coverage:.1f}% ({len(found_words)}/{len(test_words)})")
            print(f"  Найдено: {', '.join(found_words[:5])}{'...' if len(found_words) > 5 else ''}")
            if missing_words:
                print(f"  Не найдено: {', '.join(missing_words[:5])}{'...' if len(missing_words) > 5 else ''}")

        return results

    def compare_vector_properties(self):
        """
        Сравнение свойств векторных представлений
        """
        print(f"\n{'='*70}")
        print("СРАВНЕНИЕ СВОЙСТВ ВЕКТОРНЫХ ПРЕДСТАВЛЕНИЙ")
        print(f"{'='*70}")

        for model_name, model in self.models.items():
            # Берем случайные слова для анализа
            sample_words = list(model.key_to_index.keys())[:1000]
            vectors = np.array([model[word] for word in sample_words])

            # Вычисляем статистики
            mean_norm = np.mean(np.linalg.norm(vectors, axis=1))
            std_norm = np.std(np.linalg.norm(vectors, axis=1))
            mean_vector = np.mean(vectors, axis=0)
            vector_dim = vectors.shape[1]

            print(f"\n{model_name}:")
            print(f"  Размерность векторов: {vector_dim}")
            print(f"  Средняя норма векторов: {mean_norm:.4f} ± {std_norm:.4f}")
            print(f"  Норма среднего вектора: {np.linalg.norm(mean_vector):.4f}")
            print(f"  Примеры слов: {', '.join(sample_words[:5])}")

def create_test_cases():
    """
    Создание тестовых случаев для оценки
    """
    return {
        'Гендерные аналогии': [
            ('king', 'man', 'woman', 'queen'),
            ('prince', 'man', 'woman', 'princess'),
            ('actor', 'man', 'woman', 'actress'),
            ('uncle', 'man', 'woman', 'aunt'),
        ],
        'Столицы стран': [
            ('paris', 'france', 'berlin', 'germany'),
            ('london', 'england', 'tokyo', 'japan'),
            ('rome', 'italy', 'moscow', 'russia'),
            ('warsaw', 'poland', 'kyiv', 'ukraine'),
        ],
        'Страны и языки': [
            ('france', 'french', 'germany', 'german'),
            ('england', 'english', 'spain', 'spanish'),
            ('italy', 'italian', 'japan', 'japanese'),
        ],
        'Страны и кухня': [
            ('italy', 'pizza', 'france', 'baguette'),
            ('japan', 'sushi', 'mexico', 'taco'),
            ('germany', 'beer', 'russia', 'vodka'),
        ],
        'Города и достопримечательности': [
            ('paris', 'eiffel_tower', 'london', 'big_ben'),
            ('rome', 'colosseum', 'new_york', 'statue_of_liberty'),
            ('moscow', 'kremlin', 'beijing', 'forbidden_city'),
        ]
    }

def create_simplified_test_cases():
    """
    Упрощенные тестовые случаи (только слова которые точно есть)
    """
    return {
        'Простые аналогии': [
            ('king', 'man', 'woman', 'queen'),
            ('paris', 'france', 'berlin', 'germany'),
            ('france', 'french', 'germany', 'german'),
            ('london', 'england', 'tokyo', 'japan'),
        ],
        'Категории': [
            ('car', 'vehicle', 'plane', 'aircraft'),
            ('dog', 'animal', 'cat', 'feline'),
            ('apple', 'fruit', 'carrot', 'vegetable'),
        ]
    }

def main():
    """
    Основная функция для сравнения эмбеддингов
    """
    print(f"{'='*70}")
    print("ЛАБОРАТОРНАЯ РАБОТА 8: СРАВНЕНИЕ ЭМБЕДДИНГОВ")
    print("="*70)

    # Создаем анализатор
    analyzer = EmbeddingAnalyzer('D:/embeddings')

    # 1. Загружаем модели
    print("\n1. ЗАГРУЗКА МОДЕЛЕЙ")
    print("-" * 40)

    # Загружаем Word2Vec (быстро, только 50к слов для теста)
    print("\nЗагрузка Word2Vec модели...")
    wiki_model = analyzer.load_wiki_news(limit=50000)

    # Пробуем загрузить FastText
    print("\nПопытка загрузки FastText модели...")
    fasttext_model = analyzer.load_fasttext_model()

    # Если FastText не загрузился, пробуем GloVe
    if len(analyzer.models) < 2:
        print("\nFastText не загрузился, пробуем GloVe...")
        glove_model = analyzer.load_glove_model()

    # Проверяем, что загружено хотя бы 2 модели
    if len(analyzer.models) < 2:
        print("\n⚠ ВНИМАНИЕ: Загружена только одна модель!")
        print("Для сравнения нужны минимум 2 модели.")
        print("Продолжаем с одной моделью...")

    print(f"\n✓ Загружено моделей: {len(analyzer.models)}")
    for name in analyzer.model_names:
        model = analyzer.models[name]
        print(f"   - {name}: {len(model.key_to_index):,} слов")

    # 2. Тестовые слова для анализа
    test_words = [
        'king', 'queen', 'man', 'woman', 'boy', 'girl',
        'paris', 'london', 'berlin', 'rome', 'minsk', 'warsaw',
        'france', 'germany', 'italy', 'belarus', 'russia', 'ukraine',
        'pizza', 'baguette', 'sushi', 'vodka', 'beer', 'coffee',
        'happy', 'sad', 'angry', 'excited', 'calm', 'nervous',
        'computer', 'phone', 'car', 'house', 'book', 'music'
    ]

    # 3. Поиск семантически схожих слов
    print(f"\n{'='*70}")
    print("2. ПОИСК СЕМАНТИЧЕСКИ СХОЖИХ СЛОВ")
    print("="*70)

    search_words = ['king', 'paris', 'computer', 'happy']
    for word in search_words:
        analyzer.find_similar_words(word, topn=5)
        print()

    # 4. Семантические аналогии
    print(f"\n{'='*70}")
    print("3. СЕМАНТИЧЕСКИЕ АНАЛОГИИ")
    print("="*70)

    analogies = [
        ('king', 'man', 'woman'),
        ('paris', 'france', 'berlin'),
        ('france', 'french', 'germany'),
        ('london', 'england', 'tokyo'),
    ]

    for analogy in analogies:
        analyzer.word_analogy(analogy, topn=5)
        print()

    # 5. Оценка на тестовых задачах
    print(f"\n{'='*70}")
    print("4. КОМПЛЕКСНАЯ ОЦЕНКА КАЧЕСТВА")
    print("="*70)

    test_cases = create_simplified_test_cases()
    analyzer.evaluate_semantic_tasks(test_cases)

    print(f"\n{'='*70}")
    print("5. ВИЗУАЛИЗАЦИЯ СЕМАНТИЧЕСКИХ ОТНОШЕНИЙ")
    print("="*70)

    words_for_visualization = [
        'king', 'queen', 'man', 'woman',
        'paris', 'london', 'berlin', 'rome',
        'france', 'germany', 'italy', 'russia',
        'pizza', 'baguette', 'beer', 'vodka',
        'happy', 'sad', 'angry', 'excited'
    ]

    analyzer.visualize_embeddings(words_for_visualization, method='tsne')

    print(f"\n{'='*70}")
    print("6. АНАЛИЗ ПОКРЫТИЯ СЛОВАРЯ")
    print("="*70)

    analyzer.analyze_vocabulary_coverage(test_words)

    analyzer.compare_vector_properties()

    # 9. Выводы
    print(f"\n{'='*70}")
    print("7. ВЫВОДЫ И РЕЗУЛЬТАТЫ")
    print("="*70)

    model_stats = {}
    for model_name in analyzer.models:
        model = analyzer.models[model_name]
        model_stats[model_name] = {
            'vocab_size': len(model.key_to_index),
            'vector_dim': model.vector_size
        }

    print("\nСТАТИСТИКА МОДЕЛЕЙ:")
    print("-" * 40)
    for model_name, stats in model_stats.items():
        print(f"{model_name}:")
        print(f"  Словарь: {stats['vocab_size']:,} слов")
        print(f"  Размерность: {stats['vector_dim']} измерений")

    print("\n" + "="*70)
    print("ОТВЕТЫ НА ВОПРОСЫ ЛАБОРАТОРНОЙ РАБОТЫ")
    print("="*70)

    print("""
    1. ПРИНЦИП ВЫДЕЛЕНИЯ ЭМБЕДДИНГОВ:
    
    Word2Vec:
    - Использует нейронные сети для обучения
    - Две архитектуры: CBOW (предсказывает слово по контексту) 
      и Skip-gram (предсказывает контекст по слову)
    - Работает с целыми словами как неделимыми единицами
    
    FastText:
    - Расширение Word2Vec с использованием n-грамм символов
    - Учитывает морфологию слова (префиксы, суффиксы, основы)
    - Может работать с неизвестными словами (OOV)
    
    GloVe:
    - Использует матрицу совстречаемости слов
    - Объединяет преимущества матричной факторизации и вероятностных моделей
    - Оптимизирует функцию потерь на основе глобальной статистики
    
    2. ПАРАМЕТР СЕМАНТИЧЕСКОЙ БЛИЗОСТИ:
    
    - Косинусное сходство (cosine similarity): от -1 до 1
      • 1: идеальная семантическая близость
      • 0: нейтральное отношение
      • -1: противоположное значение
    
    Формула: cos(θ) = (A·B) / (||A||·||B||)
    Где A и B - векторные представления слов
    
    3. ОБУЧЕНИЕ СОБСТВЕННЫХ ЭМБЕДДИНГОВ:
    
    Библиотеки для обучения:
    - Gensim: Word2Vec, FastText, Doc2Vec
    - TensorFlow/PyTorch: кастомные архитектуры
    - FastText (Facebook): оригинальная реализация
    
    Процесс обучения:
    1. Подготовка текстового корпуса
    2. Токенизация и препроцессинг
    3. Настройка гиперпараметров:
       - размерность векторов
       - размер контекстного окна
       - алгоритм обучения (CBOW/Skip-gram)
    4. Обучение модели
    5. Оценка качества
    
    Пример кода (Gensim):
    ```
    from gensim.models import Word2Vec
    model = Word2Vec(sentences, vector_size=100, 
                     window=5, min_count=5, workers=4)
    ```
    """)

    print("\n" + "="*70)
    print("РЕКОМЕНДАЦИИ ПО ВЫБОРУ МОДЕЛИ")
    print("="*70)

    print("""
    НА ОСНОВЕ РЕЗУЛЬТАТОВ ТЕСТИРОВАНИЯ:
    
    1. Для общего использования:
       • Word2Vec: хороший баланс качества и скорости
       • GloVe: хорошие результаты на семантических задачах
    
    2. Для работы с редкими словами/опечатками:
       • FastText: лучший выбор из-за n-грамм
    
    3. Для русскоязычных текстов:
       • FastText: лучше учитывает морфологию
       • Необходимо использовать предобученные на русском корпусах
    
    4. Для научных исследований:
       • Тестировать все модели на конкретной задаче
       • Учитывать размер и качество тренировочного корпуса
    """)

def quick_demo():
    """
    Быстрая демонстрация для лабораторной работы
    """
    print("ЛАБОРАТОРНАЯ РАБОТА 8 - БЫСТРАЯ ДЕМОНСТРАЦИЯ")
    print("="*60)

    # Создаем анализатор
    analyzer = EmbeddingAnalyzer('D:/embeddings')

    # Загружаем только Word2Vec для быстрой демонстрации
    print("\n1. Загрузка Word2Vec модели (первые 30к слов)...")
    wiki_model = analyzer.load_wiki_news(limit=30000)

    if not analyzer.models:
        print("Модель не загрузилась, пробуем GloVe...")
        analyzer.load_glove_model()

    if not analyzer.models:
        print("Ошибка: не удалось загрузить модель")
        return

    print(f"\n✓ Загружена модель: {list(analyzer.models.keys())[0]}")

    # Демонстрация возможностей
    print("\n" + "="*60)
    print("2. ДЕМОНСТРАЦИЯ ВОЗМОЖНОСТЕЙ")
    print("="*60)

    # Поиск схожих слов
    print("\nА) Поиск семантически схожих слов:")
    print("-" * 40)
    analyzer.find_similar_words('king', topn=5)
    analyzer.find_similar_words('paris', topn=5)

    # Семантические аналогии
    print("\nБ) Семантические аналогии:")
    print("-" * 40)
    analyzer.word_analogy(('king', 'man', 'woman'), topn=3)
    analyzer.word_analogy(('paris', 'france', 'berlin'), topn=3)

    # Ответы на вопросы
    print("\n" + "="*60)
    print("3. ОТВЕТЫ НА ВОПРОСЫ")
    print("="*60)

    print("""
    1. Принцип эмбеддингов: преобразование слов в векторы 
       с сохранением семантических отношений.
    
    2. Косинусное сходство (0-1) характеризует семантическую близость.
    
    3. Для обучения использовать Gensim (Word2Vec, FastText) 
       или TensorFlow/PyTorch.
    """)

    print("\n" + "="*60)
    print("ЛАБОРАТОРНАЯ РАБОТА ВЫПОЛНЕНА")
    print("="*60)

if __name__ == "__main__":
    # Выберите режим запуска
    print("Выберите режим запуска:")
    print("1. Полный анализ (рекомендуется)")
    print("2. Быстрая демонстрация")

    try:
        choice = input("Введите номер (1 или 2): ").strip()

        if choice == '2':
            quick_demo()
        else:
            main()
    except:
        print("Автоматический запуск полного анализа...")
        main()