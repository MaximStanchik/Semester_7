import cv2
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
import numpy as np

def apply_corner_detectors(image_path):
    image = cv2.imread(image_path)
    if image is None:
        print(f"Ошибка: Не удалось загрузить изображение по пути {image_path}")
        return

    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    gray = np.float32(gray)

    img_harris = image.copy()
    img_shi_tomasi = image.copy()
    img_combined = image.copy()

    print("=== ДЕТЕКТОР УГЛОВ ХАРРИСА ===")

    block_size = 2
    ksize = 3
    k = 0.04

    harris_response = cv2.cornerHarris(gray, block_size, ksize, k)

    harris_response_norm = cv2.normalize(harris_response, None, 0, 255, cv2.NORM_MINMAX)
    harris_response_norm = np.uint8(harris_response_norm)

    harris_threshold = 0.01 * harris_response.max()

    img_harris[harris_response > harris_threshold] = [0, 0, 255]

    harris_corners = np.sum(harris_response > harris_threshold)
    print(f"Обнаружено углов Харриса: {harris_corners}")
    print(f"Порог: {harris_threshold:.2f}")

    print("\n=== ДЕТЕКТОР УГЛОВ ШИ-ТОМАСИ ===")

    max_corners = 1000
    quality_level = 0.02
    min_distance = 5

    shi_tomasi_corners = cv2.goodFeaturesToTrack(gray, max_corners, quality_level, min_distance)

    if shi_tomasi_corners is not None:
        shi_tomasi_corners = shi_tomasi_corners.astype(np.int32)
        for corner in shi_tomasi_corners:
            x, y = corner.ravel()
            cv2.circle(img_shi_tomasi, (x, y), 3, (0, 255, 0), -1)

        print(f"Обнаружено углов Ши-Томаси: {len(shi_tomasi_corners)}")
    else:
        print("Углы Ши-Томаси не обнаружены")

    img_combined[harris_response > harris_threshold] = [0, 0, 255]
    if shi_tomasi_corners is not None:
        for corner in shi_tomasi_corners:
            x, y = corner.ravel()
            cv2.circle(img_combined, (x, y), 3, (0, 255, 0), -1)

    plt.figure(figsize=(15, 10))

    plt.subplot(2, 3, 1)
    plt.imshow(cv2.cvtColor(image, cv2.COLOR_BGR2RGB))
    plt.title('Исходное изображение', fontsize=12, fontweight='bold')
    plt.axis('off')

    plt.subplot(2, 3, 2)
    plt.imshow(harris_response_norm, cmap='hot')
    plt.title('Карта ответа Харриса', fontsize=12, fontweight='bold')
    plt.colorbar()
    plt.axis('off')

    plt.subplot(2, 3, 3)
    plt.imshow(cv2.cvtColor(img_harris, cv2.COLOR_BGR2RGB))
    plt.title(f'Углы Харриса ({harris_corners} точек)', fontsize=12, fontweight='bold')
    plt.axis('off')

    plt.subplot(2, 3, 4)
    plt.imshow(cv2.cvtColor(img_shi_tomasi, cv2.COLOR_BGR2RGB))
    shi_count = len(shi_tomasi_corners) if shi_tomasi_corners is not None else 0
    plt.title(f'Углы Ши-Томаси ({shi_count} точек)', fontsize=12, fontweight='bold')
    plt.axis('off')

    plt.subplot(2, 3, 5)
    plt.imshow(cv2.cvtColor(img_combined, cv2.COLOR_BGR2RGB))
    plt.title('Комбинированный результат\n(Красный: Харрис, Зеленый: Ши-Томаси)',
              fontsize=12, fontweight='bold')
    plt.axis('off')

    plt.subplot(2, 3, 6)
    detectors = ['Харрис', 'Ши-Томаси']
    counts = [harris_corners, shi_count]
    colors = ['red', 'green']

    bars = plt.bar(detectors, counts, color=colors, alpha=0.7)
    plt.title('Сравнение количества углов', fontsize=12, fontweight='bold')
    plt.ylabel('Количество углов')

    for bar, count in zip(bars, counts):
        plt.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 5,
                 str(count), ha='center', va='bottom', fontweight='bold')

    plt.tight_layout()
    plt.show()

    print("\n=== СРАВНЕНИЕ ДЕТЕКТОРОВ ===")
    print(f"Харрис: {harris_corners} углов")
    print(f"Ши-Томаси: {shi_count} углов")

    if shi_tomasi_corners is not None:
        harris_points = np.argwhere(harris_response > harris_threshold)
        shi_points = shi_tomasi_corners.reshape(-1, 2)

        print(f"\nПлотность углов Харриса: {harris_corners / (gray.shape[0] * gray.shape[1]) * 10000:.2f} на 10000 пикселей")
        print(f"Плотность углов Ши-Томаси: {len(shi_points) / (gray.shape[0] * gray.shape[1]) * 10000:.2f} на 10000 пикселей")

    cv2.imwrite('harris_corners.png', img_harris)
    cv2.imwrite('shi_tomasi_corners.png', img_shi_tomasi)
    cv2.imwrite('combined_corners.png', img_combined)
    cv2.imwrite('harris_response.png', harris_response_norm)

    print("\nРезультаты сохранены в файлы:")
    print("- harris_corners.png")
    print("- shi_tomasi_corners.png")
    print("- combined_corners.png")
    print("- harris_response.png")

    return harris_response, shi_tomasi_corners

def apply_corner_detectors_with_params(image_path, harris_params=None, shi_tomasi_params=None):
    if harris_params is None:
        harris_params = {'block_size': 2, 'ksize': 3, 'k': 0.04, 'threshold': 0.01}

    if shi_tomasi_params is None:
        shi_tomasi_params = {'max_corners': 1000, 'quality_level': 0.01, 'min_distance': 10}

    image = cv2.imread(image_path)
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    gray = np.float32(gray)

    harris_response = cv2.cornerHarris(gray,
                                       harris_params['block_size'],
                                       harris_params['ksize'],
                                       harris_params['k'])

    harris_threshold = harris_params['threshold'] * harris_response.max()
    harris_corners = np.sum(harris_response > harris_threshold)

    shi_tomasi_corners = cv2.goodFeaturesToTrack(gray,
                                                 shi_tomasi_params['max_corners'],
                                                 shi_tomasi_params['quality_level'],
                                                 shi_tomasi_params['min_distance'])

    shi_count = len(shi_tomasi_corners) if shi_tomasi_corners is not None else 0

    print(f"Харрис (порог {harris_params['threshold']}): {harris_corners} углов")
    print(f"Ши-Томаси (качество {shi_tomasi_params['quality_level']}): {shi_count} углов")

    return harris_corners, shi_count

if __name__ == "__main__":
    image_path = r'D:\User\Documents\GitHub\Semester_7\TFDaA\LaboratoryWorks\LBR_03\Solution\LBR_01\static\CoolGirl.png'

    results = apply_corner_detectors(image_path)

    print("\n=== ЭКСПЕРИМЕНТЫ С РАЗНЫМИ ПАРАМЕТРАМИ ===")

    print("\n1. Строгие параметры (меньше углов):")
    apply_corner_detectors_with_params(image_path,
                                       {'block_size': 2, 'ksize': 3, 'k': 0.04, 'threshold': 0.05},
                                       {'max_corners': 100, 'quality_level': 0.1, 'min_distance': 20})

    print("\n2. Мягкие параметры (больше углов):")
    apply_corner_detectors_with_params(image_path,
                                       {'block_size': 2, 'ksize': 3, 'k': 0.04, 'threshold': 0.001},
                                       {'max_corners': 2000, 'quality_level': 0.001, 'min_distance': 5})