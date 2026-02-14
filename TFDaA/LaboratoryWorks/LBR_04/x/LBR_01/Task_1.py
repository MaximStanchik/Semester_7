import cv2
import numpy as np
import time
from collections import deque

class MotionDetectionAndTracking:
    def __init__(self):
        # Инициализация детектора фона
        self.background_subtractor = cv2.createBackgroundSubtractorMOG2(
            history=500, varThreshold=16, detectShadows=True
        )

        # Параметры для Лукаса-Канаде
        self.lk_params = dict(
            winSize=(15, 15),
            maxLevel=2,
            criteria=(cv2.TERM_CRITERIA_EPS | cv2.TERM_CRITERIA_COUNT, 10, 0.03)
        )

        self.feature_params = dict(
            maxCorners=100,
            qualityLevel=0.3,
            minDistance=7,
            blockSize=7
        )

        # Переменные для отслеживания
        self.prev_gray = None
        self.prev_points = None
        self.trajectories = deque(maxlen=20)

        # Статус движения
        self.motion_detected = False
        self.motion_start_time = 0

    def detect_motion_background_subtraction(self, frame):
        """
        1. Детектирование движения методом вычитания фона
        """
        # Применяем вычитание фона
        fg_mask = self.background_subtractor.apply(frame)

        # Морфологические операции для улучшения маски
        kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5))
        fg_mask = cv2.morphologyEx(fg_mask, cv2.MORPH_OPEN, kernel)
        fg_mask = cv2.morphologyEx(fg_mask, cv2.MORPH_CLOSE, kernel)

        # Находим контуры
        contours, _ = cv2.findContours(fg_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

        motion_detected = False
        motion_rects = []

        for contour in contours:
            area = cv2.contourArea(contour)
            if area > 500:  # Фильтр по площади
                x, y, w, h = cv2.boundingRect(contour)
                motion_rects.append((x, y, w, h))
                motion_detected = True

        return motion_detected, motion_rects, fg_mask

    def lucas_kanade_optical_flow(self, frame):
        """
        2. Метод Лукаса-Канаде для разреженного оптического потока
        """
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

        if self.prev_gray is None:
            # Инициализация: находим углы для отслеживания
            self.prev_points = cv2.goodFeaturesToTrack(gray, mask=None, **self.feature_params)
            self.prev_gray = gray.copy()
            return frame

        # Вычисляем оптический поток
        if self.prev_points is not None and len(self.prev_points) > 0:
            new_points, status, error = cv2.calcOpticalFlowPyrLK(
                self.prev_gray, gray, self.prev_points, None, **self.lk_params
            )

            # Отбираем хорошие точки
            if new_points is not None:
                good_new = new_points[status == 1]
                good_old = self.prev_points[status == 1]

                # Рисуем траектории
                for i, (new, old) in enumerate(zip(good_new, good_old)):
                    a, b = new.ravel()
                    c, d = old.ravel()
                    a, b, c, d = int(a), int(b), int(c), int(d)

                    # Рисуем линии траектории
                    cv2.line(frame, (a, b), (c, d), (0, 255, 0), 2)
                    cv2.circle(frame, (a, b), 3, (0, 0, 255), -1)

                    # Сохраняем траекторию
                    self.trajectories.append((a, b))

        # Обновляем предыдущие точки
        self.prev_points = cv2.goodFeaturesToTrack(gray, mask=None, **self.feature_params)
        self.prev_gray = gray.copy()

        # Рисуем траектории
        for i in range(1, len(self.trajectories)):
            if self.trajectories[i - 1] is None or self.trajectories[i] is None:
                continue
            cv2.line(frame, self.trajectories[i - 1], self.trajectories[i], (255, 255, 0), 2)

        return frame

    def process_frame(self, frame):
        """
        Основная функция обработки кадра
        """
        result_frame = frame.copy()

        # 1. Детектирование движения
        motion_detected, motion_rects, fg_mask = self.detect_motion_background_subtraction(frame)

        # Сигнализация при обнаружении движения
        if motion_detected:
            if not self.motion_detected:
                self.motion_detected = True
                self.motion_start_time = time.time()
                print("🚨 ДВИЖЕНИЕ ОБНАРУЖЕНО! Сигнал тревоги!")

            # Рисуем красные прямоугольники вокруг движущихся объектов
            for (x, y, w, h) in motion_rects:
                cv2.rectangle(result_frame, (x, y), (x + w, y + h), (0, 0, 255), 2)
                cv2.putText(result_frame, 'MOTION', (x, y-10),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 255), 2)
        else:
            if self.motion_detected and (time.time() - self.motion_start_time > 2):
                self.motion_detected = False
                print("✅ Движение прекратилось")

        # 2. Оптический поток Лукаса-Канаде
        result_frame = self.lucas_kanade_optical_flow(result_frame)

        # Добавляем информационную панель
        self.add_info_panel(result_frame, motion_detected, len(motion_rects))

        return result_frame, fg_mask

    def add_info_panel(self, frame, motion_detected, num_objects):
        """Добавление информационной панели"""
        status = "ОБНАРУЖЕНО ДВИЖЕНИЕ!" if motion_detected else "Статус: Норма"
        color = (0, 0, 255) if motion_detected else (0, 255, 0)

        cv2.putText(frame, f"Статус: {status}", (10, 30),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.7, color, 2)
        cv2.putText(frame, f"Объекты: {num_objects}", (10, 60),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)
        cv2.putText(frame, "Красный: Движение | Зеленый: Оптический поток",
                    (10, frame.shape[0] - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.4, (255, 255, 255), 1)

def main():
    # Инициализация детектора
    detector = MotionDetectionAndTracking()

    # Выбор источника видео
    print("Выберите источник видео:")
    print("1 - Веб-камера")
    print("2 - Видеофайл")
    choice = input("Введите номер (1 или 2): ")

    if choice == "1":
        cap = cv2.VideoCapture(0)  # Веб-камера
        print("Используется веб-камера")
    else:
        video_path = input("Введите путь к видеофайлу: ")
        cap = cv2.VideoCapture(video_path)
        print(f"Используется видеофайл: {video_path}")

    if not cap.isOpened():
        print("Ошибка: не удалось открыть видео источник")
        return

    print("Запуск системы детектирования движения...")
    print("Нажмите 'q' для выхода")
    print("Нажмите 'r' для сброса")

    while True:
        ret, frame = cap.read()
        if not ret:
            print("Конец видео или ошибка чтения")
            break

        # Обработка кадра
        processed_frame, motion_mask = detector.process_frame(frame)

        # Показ результатов
        cv2.imshow('Детектирование движения и отслеживание', processed_frame)
        cv2.imshow('Маска движения', motion_mask)

        # Управление
        key = cv2.waitKey(1) & 0xFF
        if key == ord('q'):
            break
        elif key == ord('r'):
            # Сброс детектора
            detector = MotionDetectionAndTracking()
            print("Система сброшена")

    cap.release()
    cv2.destroyAllWindows()
    print("Программа завершена")

if __name__ == "__main__":
    main()1