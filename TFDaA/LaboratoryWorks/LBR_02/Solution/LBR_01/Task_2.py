import cv2
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
import numpy as np

def analyze_contours(image_path):
    # Загрузка изображения
    image = cv2.imread(image_path)
    image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    original = image.copy()

    if image is None:
        print(f"Error: Cannot load image from {image_path}")
        return

    # Преобразование в оттенки серого и бинаризация
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    blurred = cv2.GaussianBlur(gray, (5, 5), 0)

    # Автоматическое определение порога
    _, thresh = cv2.threshold(blurred, 0, 255, cv2.THRESH_BINARY_INV + cv2.THRESH_OTSU)

    # Морфологические операции для улучшения контуров
    kernel = np.ones((3, 3), np.uint8)
    thresh = cv2.morphologyEx(thresh, cv2.MORPH_CLOSE, kernel)
    thresh = cv2.morphologyEx(thresh, cv2.MORPH_OPEN, kernel)

    # Поиск контуров (только внешние)
    contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    # Фильтрация контуров по площади
    filtered_contours = []
    for contour in contours:
        area = cv2.contourArea(contour)
        if area > 100:  # Минимальная площадь контура
            filtered_contours.append(contour)

    # Находим статистику по контурам
    areas = [cv2.contourArea(contour) for contour in filtered_contours]
    lengths = [cv2.arcLength(contour, True) for contour in filtered_contours]

    max_area = max(areas) if areas else 0
    min_area = min(areas) if areas else 0
    avg_area = np.mean(areas) if areas else 0

    max_length = max(lengths) if lengths else 0
    min_length = min(lengths) if lengths else 0
    avg_length = np.mean(lengths) if lengths else 0

    # Рисуем все прямоугольники разными цветами
    colors = [(0, 255, 0), (255, 0, 0), (0, 0, 255), (255, 255, 0),
              (255, 0, 255), (0, 255, 255), (128, 128, 128)]

    for i, contour in enumerate(filtered_contours):
        color = colors[i % len(colors)]
        x, y, w, h = cv2.boundingRect(contour)
        cv2.rectangle(original, (x, y), (x + w, y + h), color, 2)

        # Подписываем номер объекта
        cv2.putText(original, str(i+1), (x + 5, y + 20),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.6, color, 2)

    # Создаем изображение с подписями
    result_image = original.copy()

    # Добавляем текст с информацией на английском
    text_lines = [
        f"Objects: {len(filtered_contours)}",
        f"Area: max={max_area:.0f}, min={min_area:.0f}",
        f"Length: max={max_length:.0f}, min={min_length:.0f}"
    ]

    for i, text in enumerate(text_lines):
        y_pos = 30 + i * 30
        cv2.putText(result_image, text, (10, y_pos), cv2.FONT_HERSHEY_SIMPLEX,
                    0.7, (0, 0, 0), 3, cv2.LINE_AA)
        cv2.putText(result_image, text, (10, y_pos), cv2.FONT_HERSHEY_SIMPLEX,
                    0.7, (255, 255, 255), 2, cv2.LINE_AA)

    # Отображение результатов с английскими заголовками
    plt.figure(figsize=(15, 10))

    plt.subplot(2, 2, 1)
    plt.imshow(image_rgb)
    plt.title('Original Image', fontsize=14, fontweight='bold')
    plt.axis('off')

    plt.subplot(2, 2, 2)
    plt.imshow(thresh, cmap='gray')
    plt.title('Binary Image', fontsize=14, fontweight='bold')
    plt.axis('off')

    plt.subplot(2, 2, 3)
    # Показываем все контуры
    contour_image = np.zeros_like(image_rgb)
    for i, contour in enumerate(filtered_contours):
        color = colors[i % len(colors)]
        cv2.drawContours(contour_image, [contour], -1, color, 2)
    plt.imshow(contour_image)
    plt.title('All Contours', fontsize=14, fontweight='bold')
    plt.axis('off')

    plt.subplot(2, 2, 4)
    plt.imshow(cv2.cvtColor(result_image, cv2.COLOR_BGR2RGB))
    plt.title('Detected Objects with Bounding Boxes', fontsize=14, fontweight='bold')
    plt.axis('off')

    plt.tight_layout()
    plt.show()

    # Вывод подробной информации в консоль
    print(f"\n=== OBJECT ANALYSIS ===")
    print(f"Total objects: {len(filtered_contours)}")
    print(f"\nArea statistics:")
    print(f"  Max: {max_area:.0f} px²")
    print(f"  Min: {min_area:.0f} px²")
    print(f"  Avg: {avg_area:.0f} px²")
    print(f"  Std: {np.std(areas):.1f} px²")

    print(f"\nLength statistics:")
    print(f"  Max: {max_length:.0f} px")
    print(f"  Min: {min_length:.0f} px")
    print(f"  Avg: {avg_length:.0f} px")
    print(f"  Std: {np.std(lengths):.1f} px")

    return filtered_contours, areas, lengths

# Путь к вашему изображению
image_path = r'D:\User\Documents\GitHub\Semester_7\TFDaA\LaboratoryWorks\LBR_02\Solution\LBR_01\static\2.png'

# Анализ контуров
contours, areas, lengths = analyze_contours(image_path)