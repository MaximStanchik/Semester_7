import cv2
import numpy as np
import os
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt

DISPLAY_WIDTH = 600
DISPLAY_HEIGHT = 400

def display_image(img, title="Image"):
    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    plt.figure(figsize=(8, 6))
    plt.imshow(img_rgb, cmap='gray')
    plt.title(title)
    plt.axis('off')
    plt.show()

def task_4():
    img_path = "D:\\User\\Documents\\GitHub\\Semester_7\\TFDaA\\LaboratoryWorks\\LBR_03\\Solution\\LBR_01\\static\\akank.jpg"
    if not os.path.exists(img_path):
        print(f"Ошибка: файл изображения не найден по пути: {img_path}")
        return

    img = cv2.imread(img_path)
    if img is None:
        print(f"Ошибка: не удалось загрузить изображение {img_path}")
        return
    print(f"Изображение {img_path} успешно загружено, размер: {img.shape}")

    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    blurred = cv2.GaussianBlur(gray, (5, 5), 0)

    edges = cv2.Canny(blurred, 50, 150)

    contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    if len(contours) == 0:
        print("Ошибка: контуры документа не найдены")
        return
    contours = sorted(contours, key=cv2.contourArea, reverse=True)[:1]

    for contour in contours:
        epsilon = 0.02 * cv2.arcLength(contour, True)
        approx = cv2.approxPolyDP(contour, epsilon, True)

        if len(approx) == 4:
            pts = approx.reshape(4, 2)
            rect = np.zeros((4, 2), dtype="float32")
            s = pts.sum(axis=1)
            rect[0] = pts[np.argmin(s)]
            rect[2] = pts[np.argmax(s)]
            diff = np.diff(pts, axis=1)
            rect[1] = pts[np.argmin(diff)]
            rect[3] = pts[np.argmax(diff)]

            (tl, tr, br, bl) = rect
            widthA = np.sqrt(((br[0] - bl[0]) ** 2) + ((br[1] - bl[1]) ** 2))
            widthB = np.sqrt(((tr[0] - tl[0]) ** 2) + ((tr[1] - tl[1]) ** 2))
            maxWidth = max(int(widthA), int(widthB))

            heightA = np.sqrt(((tr[0] - br[0]) ** 2) + ((tr[1] - br[1]) ** 2))
            heightB = np.sqrt(((tl[0] - bl[0]) ** 2) + ((tl[1] - bl[1]) ** 2))
            maxHeight = max(int(heightA), int(heightB))

            dst = np.array([
                [0, 0],
                [maxWidth - 1, 0],
                [maxWidth - 1, maxHeight - 1],
                [0, maxHeight - 1]], dtype="float32")

            M = cv2.getPerspectiveTransform(rect, dst)
            warped = cv2.warpPerspective(img, M, (maxWidth, maxHeight))

            img_disp = cv2.resize(img, (DISPLAY_WIDTH, DISPLAY_HEIGHT))
            warped_disp = cv2.resize(warped, (DISPLAY_WIDTH, DISPLAY_HEIGHT))
            display_image(img_disp, "Original Document")
            display_image(warped_disp, "Aligned Document")
            print("Документ успешно выровнен и отображен")
            return

    print("Ошибка: не удалось аппроксимировать контур до четырёхугольника")

print("Задание 4: Выравнивание документа")
task_4()