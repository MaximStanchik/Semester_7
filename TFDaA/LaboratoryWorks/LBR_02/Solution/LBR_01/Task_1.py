import cv2
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
import numpy as np

def apply_edge_detectors(image_path):
    image = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)

    if image is None:
        print(f"Ошибка: Не удалось загрузить изображение по пути {image_path}")
        return

    # 1. Оператор Собеля
    sobel_x = cv2.Sobel(image, cv2.CV_64F, 1, 0, ksize=3)
    sobel_y = cv2.Sobel(image, cv2.CV_64F, 0, 1, ksize=3)
    sobel_combined = cv2.magnitude(sobel_x, sobel_y)
    sobel_combined = np.uint8(sobel_combined)

    # 2. Оператор Лапласа
    laplacian = cv2.Laplacian(image, cv2.CV_64F, ksize=3)
    laplacian = np.uint8(np.absolute(laplacian))

    # 3. Детектор Кэнни (подобранные параметры)
    canny_edges = cv2.Canny(image, threshold1=50, threshold2=150, apertureSize=3)

    canny_tuned = cv2.Canny(image, threshold1=30, threshold2=100, apertureSize=5)
    canny_strong = cv2.Canny(image, threshold1=100, threshold2=200, apertureSize=3)

    plt.figure(figsize=(8.8, 5.9))

    plt.rcParams['font.size'] = 10
    plt.rcParams['axes.titlesize'] = 11
    plt.rcParams['axes.titleweight'] = 'bold'

    plt.subplot(2, 3, 1)
    plt.imshow(image, cmap='gray')
    plt.title('Исходное изображение', fontsize=11, fontweight='bold')
    plt.axis('off')

    plt.subplot(2, 3, 2)
    plt.imshow(sobel_combined, cmap='gray')
    plt.title('Оператор Собеля', fontsize=11, fontweight='bold')
    plt.axis('off')

    plt.subplot(2, 3, 3)
    plt.imshow(laplacian, cmap='gray')
    plt.title('Оператор Лапласа', fontsize=11, fontweight='bold')
    plt.axis('off')

    plt.subplot(2, 3, 4)
    plt.imshow(canny_edges, cmap='gray')
    plt.title('Кэнни (стандартные параметры)', fontsize=11, fontweight='bold')
    plt.axis('off')

    plt.subplot(2, 3, 5)
    plt.imshow(canny_tuned, cmap='gray')
    plt.title('Кэнни (подобранные: 30, 100)', fontsize=11, fontweight='bold')
    plt.axis('off')

    plt.subplot(2, 3, 6)
    plt.imshow(canny_strong, cmap='gray')
    plt.title('Кэнни (сильные: 100, 200)', fontsize=11, fontweight='bold')
    plt.axis('off')

    plt.tight_layout()
    plt.show()

    cv2.imwrite('sobel_result.png', sobel_combined)
    cv2.imwrite('laplacian_result.png', laplacian)
    cv2.imwrite('canny_result.png', canny_edges)
    cv2.imwrite('canny_tuned_result.png', canny_tuned)

    return sobel_combined, laplacian, canny_edges

image_path = r'D:\User\Documents\GitHub\Semester_7\TFDaA\LaboratoryWorks\LBR_02\Solution\LBR_01\static\1.png'

results = apply_edge_detectors(image_path)