#include <chrono>
#include <iostream>
#include <opencv2/opencv.hpp>
#include <opencv2/tracking.hpp>
#include <vector>

using namespace cv;
using namespace std;
using namespace std::chrono;

// Класс для детектирования движения методом вычитания фона
class MotionDetector {
  private:
    Ptr<BackgroundSubtractor> bgSubtractor;
    double learningRate;
    int motionThreshold;

  public:
    MotionDetector(double lr = 0.001, int threshold = 5000)
        : learningRate(lr), motionThreshold(threshold) {
        // Используем MOG2 для вычитания фона
        bgSubtractor = createBackgroundSubtractorMOG2(500, 16, true);
    }

    bool detectMotion(const Mat &frame, Mat &output) {
        Mat fgMask;
        Mat processedFrame = frame.clone();

        // Применяем вычитание фона
        bgSubtractor->apply(frame, fgMask, learningRate);

        // Морфологические операции для улучшения маски
        morphologyEx(fgMask, fgMask, MORPH_OPEN,
                     getStructuringElement(MORPH_ELLIPSE, Size(3, 3)));
        morphologyEx(fgMask, fgMask, MORPH_CLOSE,
                     getStructuringElement(MORPH_ELLIPSE, Size(15, 15)));

        // Находим контуры
        vector<vector<Point>> contours;
        findContours(fgMask, contours, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);

        bool motionDetected = false;
        for (const auto &contour : contours) {
            double area = contourArea(contour);
            if (area > motionThreshold) {
                motionDetected = true;
                // Рисуем bounding box вокруг движущегося объекта
                Rect bbox = boundingRect(contour);
                rectangle(processedFrame, bbox, Scalar(0, 0, 255), 2);
                putText(processedFrame, "MOTION DETECTED",
                        Point(bbox.x, bbox.y - 10), FONT_HERSHEY_SIMPLEX, 0.7,
                        Scalar(0, 0, 255), 2);
            }
        }

        output = processedFrame;
        return motionDetected;
    }
};

// Класс для работы с оптическим потоком Лукаса-Канаде
class LucasKanadeTracker {
  private:
    vector<Point2f> prevPoints;
    vector<Point2f> currentPoints;
    vector<Point2f> initialPoints;
    vector<uchar> status;
    vector<float> err;
    Mat prevGray;
    bool firstFrame;

  public:
    LucasKanadeTracker() : firstFrame(true) {}

    void processFrame(const Mat &frame, Mat &output) {
        Mat gray;
        cvtColor(frame, gray, COLOR_BGR2GRAY);
        output = frame.clone();

        if (firstFrame) {
            goodFeaturesToTrack(gray, prevPoints, 100, 0.3, 7);
            initialPoints = prevPoints;
            prevGray = gray.clone();
            firstFrame = false;
            return;
        }

        // 🔹 Проверяем, есть ли точки для отслеживания
        if (prevPoints.empty()) {
            goodFeaturesToTrack(gray, prevPoints, 100, 0.3, 7);
            initialPoints = prevPoints;
            prevGray = gray.clone();
            return;
        }

        // Вычисление оптического потока
        calcOpticalFlowPyrLK(prevGray, gray, prevPoints, currentPoints, status,
                             err);

        // 🔹 Если после вычисления точки потерялись — переинициализация
        int validCount = count_if(status.begin(), status.end(),
                                  [](uchar s) { return s != 0; });
        if (validCount < 10) {
            goodFeaturesToTrack(gray, prevPoints, 100, 0.3, 7);
            initialPoints = prevPoints;
            prevGray = gray.clone();
            return;
        }

        // Визуализация траекторий
        for (size_t i = 0; i < currentPoints.size(); i++) {
            if (status[i]) {
                line(output, prevPoints[i], currentPoints[i], Scalar(0, 255, 0),
                     2);
                circle(output, currentPoints[i], 3, Scalar(0, 255, 0), -1);
                line(output, initialPoints[i], currentPoints[i],
                     Scalar(255, 0, 0), 1);
            }
        }

        prevGray = gray.clone();
        prevPoints = currentPoints;
    }
};

// Класс для работы с трекером
class ObjectTracker {
  private:
    Ptr<Tracker> tracker;
    bool tracking;
    Rect bbox;

  public:
    ObjectTracker() : tracking(false) {
        // Используем трекер KCF
        tracker = TrackerKCF::create();
    }

    void startTracking(const Mat &frame, const Rect &roi) {
        bbox = roi;
        tracker->init(frame, bbox);
        tracking = true;
    }

    bool updateTracking(const Mat &frame, Mat &output) {
        if (!tracking)
            return false;

        output = frame.clone();
        bool success = tracker->update(frame, bbox);

        if (success) {
            // Рисуем bounding box
            rectangle(output, bbox, Scalar(255, 0, 0), 2);
            putText(output, "TRACKING", Point(bbox.x, bbox.y - 10),
                    FONT_HERSHEY_SIMPLEX, 0.7, Scalar(255, 0, 0), 2);
        } else {
            putText(output, "TRACKING LOST", Point(10, 50),
                    FONT_HERSHEY_SIMPLEX, 1, Scalar(0, 0, 255), 2);
        }

        return success;
    }

    bool isTracking() const { return tracking; }
};

int main() {
    // Инициализация видео потока (0 - веб-камера, или путь к видео файлу)
    VideoCapture cap("test.mp4"); // Замените на 0 для веб-камеры
    // VideoCapture cap(2); // Для использования веб-камеры

    if (!cap.isOpened()) {
        cerr << "Ошибка: не удалось открыть видео поток!" << endl;
        return -1;
    }

    // Инициализация компонентов
    MotionDetector motionDetector;
    LucasKanadeTracker lkTracker;
    ObjectTracker objTracker;

    // Переменные для управления режимами
    bool motionAlertSent = false;
    steady_clock::time_point lastAlertTime;
    bool roiSelected = false;
    Rect selection;

    namedWindow("Video Analysis", WINDOW_NORMAL);

    cout << "Управление:" << endl;
    cout << "1. Нажмите 's' для выбора области отслеживания" << endl;
    cout << "2. Нажмите 'r' для сброса трекера" << endl;
    cout << "3. Нажмите 'q' для выхода" << endl;

    Mat frame;
    while (true) {
        cap >> frame;
        if (frame.empty())
            break;

        Mat output;
        vector<Mat> displays;

        // 1. Детектирование движения
        Mat motionOutput;
        bool motionDetected = motionDetector.detectMotion(frame, motionOutput);

        if (motionDetected && !motionAlertSent) {
            cout << "ПРЕДУПРЕЖДЕНИЕ: Обнаружено движение! "
                 << system_clock::to_time_t(system_clock::now()) << endl;
            motionAlertSent = true;
            lastAlertTime = steady_clock::now();
        }

        // Сбрасываем alert через 3 секунды
        if (motionAlertSent &&
            duration_cast<seconds>(steady_clock::now() - lastAlertTime)
                    .count() > 3) {
            motionAlertSent = false;
        }

        // 2. Оптический поток Лукаса-Канаде
        Mat lkOutput = frame.clone();
        lkTracker.processFrame(frame, lkOutput);

        // 3. Трекинг объектов
        Mat trackingOutput = frame.clone();
        if (objTracker.isTracking()) {
            objTracker.updateTracking(frame, trackingOutput);
        }

        // Собираем все результаты в один вывод
        resize(motionOutput, motionOutput, Size(640, 480));
        resize(lkOutput, lkOutput, Size(640, 480));
        resize(trackingOutput, trackingOutput, Size(640, 480));
        resize(frame, frame, Size(640, 480));

        if (motionOutput.channels() == 1)
            cvtColor(motionOutput, motionOutput, COLOR_GRAY2BGR);
        if (lkOutput.channels() == 1)
            cvtColor(lkOutput, lkOutput, COLOR_GRAY2BGR);
        if (trackingOutput.channels() == 1)
            cvtColor(trackingOutput, trackingOutput, COLOR_GRAY2BGR);
        if (frame.channels() == 1)
            cvtColor(frame, frame, COLOR_GRAY2BGR);

        Mat topRow, bottomRow, finalOutput;
        hconcat(motionOutput, lkOutput, topRow);
        hconcat(trackingOutput, frame, bottomRow);
        vconcat(topRow, bottomRow, finalOutput);

        // Добавляем подписи
        putText(finalOutput, "1. Motion Detection", Point(10, 30),
                FONT_HERSHEY_SIMPLEX, 1, Scalar(255, 255, 255), 2);
        putText(finalOutput, "2. Lucas-Kanade Optical Flow", Point(650, 30),
                FONT_HERSHEY_SIMPLEX, 1, Scalar(255, 255, 255), 2);
        putText(finalOutput, "3. Object Tracking", Point(10, 510),
                FONT_HERSHEY_SIMPLEX, 1, Scalar(255, 255, 255), 2);
        putText(finalOutput, "4. Original", Point(650, 510),
                FONT_HERSHEY_SIMPLEX, 1, Scalar(255, 255, 255), 2);

        imshow("Video Analysis", finalOutput);

        // Обработка пользовательского ввода
        char key = waitKey(30);
        if (key == 'q')
            break;
        else if (key == 's') {
            // Выбор области для трекинга
            selection = selectROI("Video Analysis", frame, false);
            if (selection.width > 0 && selection.height > 0) {
                objTracker.startTracking(frame, selection);
                roiSelected = true;
            }
        } else if (key == 'r') {
            // Сброс трекера
            objTracker = ObjectTracker();
            roiSelected = false;
        }
    }

    cap.release();
    destroyAllWindows();

    return 0;
}
