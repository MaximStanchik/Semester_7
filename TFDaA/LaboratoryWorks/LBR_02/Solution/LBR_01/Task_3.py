import cv2
import numpy as np
import matplotlib
matplotlib.use('TkAgg')  # Изменяем бэкенд на TkAgg
import matplotlib.pyplot as plt

def process_lines_image(image_path):
    # Загрузка изображения
    img = cv2.imread(image_path)
    if img is None:
        print(f"Ошибка: Не удалось загрузить изображение {image_path}")
        return

    original = img.copy()

    # Конвертация в оттенки серого
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # Предобработка: сглаживание для уменьшения шума
    blurred = cv2.GaussianBlur(gray, (5, 5), 0)

    # Обнаружение краев с помощью Canny
    edges = cv2.Canny(blurred, 50, 150, apertureSize=3)

    # Обнаружение линий с помощью преобразования Хафа
    lines = cv2.HoughLines(edges, 1, np.pi/180, 150)

    # Отрисовка обнаруженных линий
    if lines is not None:
        print(f"Найдено линий: {len(lines)}")
        for line in lines:
            rho, theta = line[0]
            a = np.cos(theta)
            b = np.sin(theta)
            x0 = a * rho
            y0 = b * rho
            x1 = int(x0 + 1000 * (-b))
            y1 = int(y0 + 1000 * (a))
            x2 = int(x0 - 1000 * (-b))
            y2 = int(y0 - 1000 * (a))
            cv2.line(img, (x1, y1), (x2, y2), (0, 0, 255), 2)
    else:
        print("Линии не обнаружены")

    # Масштабирование для отображения
    scale_percent = 60  # процентов от оригинального размера
    width = int(img.shape[1] * scale_percent / 100)
    height = int(img.shape[0] * scale_percent / 100)
    dim = (width, height)

    # Отображение результатов
    cv2.imshow('Исходное изображение', cv2.resize(original, dim))
    cv2.imshow('Обнаруженные края (Canny)', cv2.resize(edges, dim))
    cv2.imshow('Обнаруженные линии', cv2.resize(img, dim))
    print("Нажмите любую клавишу для продолжения...")
    cv2.waitKey(0)
    cv2.destroyAllWindows()

def process_circles_image(image_path):
    # Загрузка изображения
    img = cv2.imread(image_path)
    if img is None:
        print(f"Ошибка: Не удалось загрузить изображение {image_path}")
        return 0

    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # Улучшение контраста для лучшего выделения границ
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    gray_enhanced = clahe.apply(gray)

    # Размытие для уменьшения шума
    blurred = cv2.GaussianBlur(gray_enhanced, (9, 9), 2)

    # Обнаружение окружностей с параметрами для крупных объектов
    circles = cv2.HoughCircles(blurred, cv2.HOUGH_GRADIENT, dp=1,
                               minDist=200, param1=100, param2=30,
                               minRadius=80, maxRadius=200)

    # Отображение результатов
    output = img.copy()
    detected_count = 0

    if circles is not None:
        circles = np.uint16(np.around(circles))
        sorted_circles = sorted(circles[0], key=lambda x: x[2], reverse=True)

        for i in sorted_circles[:3]:  # Берем только 3 самые крупные окружности
            center = (i[0], i[1])
            radius = i[2]

            if radius >= 80:
                cv2.circle(output, center, radius, (0, 255, 0), 4)  # Зеленый
                cv2.circle(output, center, 3, (0, 0, 255), 6)  # Красный
                detected_count += 1
                print(f"Обнаружена окружность: центр {center}, радиус {radius}")

    print(f"Обнаружено крупных окружностей: {detected_count}")

    # Отображение результата
    plt.figure(figsize=(12, 8))
    plt.imshow(cv2.cvtColor(output, cv2.COLOR_BGR2RGB))
    plt.title(f"Обнаружено крупных окружностей: {detected_count}")
    plt.axis('off')
    plt.pause(0.001)
    plt.show()

# Обработка изображения с прямыми линиями
print("=== ОБРАБОТКА ИЗОБРАЖЕНИЯ С ПРЯМЫМИ ЛИНИЯМИ ===")
process_lines_image(r'D:\User\Documents\GitHub\Semester_7\TFDaA\LaboratoryWorks\LBR_02\Solution\LBR_01\static\3_1.jpg')

# Обработка изображения с окружностями
print("\n=== ОБРАБОТКА ИЗОБРАЖЕНИЯ С ОКРУЖНОСТЯМИ ===")
circle_count = process_circles_image(r'D:\User\Documents\GitHub\Semester_7\TFDaA\LaboratoryWorks\LBR_02\Solution\LBR_01\static\3_2.jpg')
print(f"Итоговое количество окружностей: {circle_count}")