import cv2
import numpy as np
from ultralytics import YOLO

# Загрузка предобученной модели YOLOv8 (nano)
model = YOLO('yolov8n.pt')

# Пути к видео
input_video_path = "input_video.mp4"
output_video_path = "output_video.mp4"

# Открываем видео
cap = cv2.VideoCapture(input_video_path)
if not cap.isOpened():
    print("Ошибка: не удалось открыть видеофайл.")
    exit()

# Получаем параметры видео
fps = int(cap.get(cv2.CAP_PROP_FPS))
width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

# Инициализация записи выходного видео
fourcc = cv2.VideoWriter_fourcc(*'mp4v')
out = cv2.VideoWriter(output_video_path, fourcc, fps, (width, height))

# Классы COCO
CAR_CLASS_ID = 2
BUS_CLASS_ID = 5

car_counts = []
bus_counts = []

frame_count = 0
while True:
    ret, frame = cap.read()
    if not ret:
        break

    # Детекция объектов
    results = model(frame)

    car_count = 0
    bus_count = 0

    # Обработка всех обнаруженных объектов
    for result in results:
        boxes = result.boxes
        for box in boxes:
            cls = int(box.cls.item())
            x1, y1, x2, y2 = map(int, box.xyxy[0])

            if cls == CAR_CLASS_ID:
                car_count += 1
                cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)  # зелёный
                cv2.putText(frame, 'car', (x1, y1 - 10),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 2)

            elif cls == BUS_CLASS_ID:
                bus_count += 1
                cv2.rectangle(frame, (x1, y1), (x2, y2), (255, 165, 0), 2)  # оранжевый
                cv2.putText(frame, 'bus', (x1, y1 - 10),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 165, 0), 2)

    # Отображаем общее количество в углу кадра
    cv2.putText(frame, f'Cars: {car_count}, Buses: {bus_count}', (10, 30),
                cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 255), 2)

    # Сохраняем счётчики для статистики
    car_counts.append(car_count)
    bus_counts.append(bus_count)

    # Записываем кадр в выходное видео
    out.write(frame)
    frame_count += 1

    # показ в реальном времени
    cv2.imshow("Car & Bus Counter", frame)
    if cv2.waitKey(1) == ord('q'):
        break

# Освобождаем ресурсы
cap.release()
out.release()
cv2.destroyAllWindows()

# Вывод статистики
if car_counts:
    total_frames = len(car_counts)
    print(f"Обработано кадров: {total_frames}")

    print(f"\nАвтомобили (cars):")
    print(f"  - Максимум в кадре: {max(car_counts)}")
    print(f"  - Среднее: {np.mean(car_counts):.2f}")
    print(f"  - Всего детекций (по кадрам): {sum(car_counts)}")

    print(f"\nАвтобусы (buses):")
    print(f"  - Максимум в кадре: {max(bus_counts)}")
    print(f"  - Среднее: {np.mean(bus_counts):.2f}")
    print(f"  - Всего детекций (по кадрам): {sum(bus_counts)}")

    total_vehicles = sum(car_counts) + sum(bus_counts)
    print(f"\nОбщее количество транспортных средств (всех детекций): {total_vehicles}")
else:
    print("Ни одного кадра не обработано.")