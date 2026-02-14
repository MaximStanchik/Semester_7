#include <iostream>
#include <opencv2/opencv.hpp>
#include "gesture_recognizer.h"
#include "data_collector.h"

// ������ ������ ����������
enum class AppMode {
    PREDICTION,     // ����� ������������
    DATA_COLLECTION // ����� ����� ������
};

class HandGestureApp {
private:
    GestureRecognizer recognizer_;
    DataCollector collector_;
    AppMode current_mode_ = AppMode::PREDICTION;
    bool is_running_ = true;
    cv::VideoCapture cap_;

    // ����������
    int total_frames_ = 0;
    int hand_detected_frames_ = 0;

public:
    bool initialize() {
        std::cout << "=== HandGestureAI Initialization ===" << std::endl;

        // ������������� ������
        if (!initializeCamera()) {
            return false;
        }

        // ������������� ��������������
        if (!recognizer_.initialize()) {
            std::cerr << "Failed to initialize GestureRecognizer" << std::endl;
            return false;
        }

        // �������� ������������ ������
        collector_.loadFromCSV();

        std::cout << "HandGestureAI initialized successfully!" << std::endl;
        printInstructions();
        return true;
    }

    void run() {
        while (is_running_) {
            cv::Mat frame;
            if (!cap_.read(frame)) {
                std::cerr << "Failed to read frame from camera" << std::endl;
                break;
            }

            total_frames_++;
            processFrame(frame);

            if (cv::waitKey(1) == 27) { // ESC
                stop();
            }
        }

        cleanup();
    }

private:
    bool initializeCamera() {
        cap_.open(0);
        if (!cap_.isOpened()) {
            std::cerr << "Cannot open camera" << std::endl;
            return false;
        }

        // ��������� ����������
        cap_.set(cv::CAP_PROP_FRAME_WIDTH, 640);
        cap_.set(cv::CAP_PROP_FRAME_HEIGHT, 480);
        cap_.set(cv::CAP_PROP_FPS, 30);

        std::cout << "Camera initialized: 640x480 @ 30FPS" << std::endl;
        return true;
    }

    void processFrame(cv::Mat& frame) {
        cv::flip(frame, frame, 1); // ���������� �����������

        // ���������� landmarks
        auto landmarks = recognizer_.extractLandmarks(frame);
        bool hand_detected = !landmarks.empty();

        if (hand_detected) {
            hand_detected_frames_++;
            recognizer_.drawLandmarks(frame, landmarks);

            if (current_mode_ == AppMode::PREDICTION) {
                processPrediction(frame, landmarks);
            }
        }

        drawUI(frame, hand_detected);
        cv::imshow("HandGestureAI - Complete Version", frame);
    }

    void processPrediction(cv::Mat& frame, const std::vector<float>& landmarks) {
        auto [gesture, confidence] = recognizer_.predictGesture(landmarks);

        std::string prediction_text = gesture + " (" + std::to_string(static_cast<float>(confidence)).substr(0, 4) + ")";
        cv::Scalar color = (confidence > 0.7) ? cv::Scalar(0, 255, 0) : cv::Scalar(0, 165, 255);

        cv::putText(frame, prediction_text, cv::Point(20, 60),
            cv::FONT_HERSHEY_SIMPLEX, 1.0, color, 3);
    }

    void drawUI(cv::Mat& frame, bool hand_detected) {
        // ���������� � ������
        std::string mode_text = (current_mode_ == AppMode::PREDICTION) ?
            "MODE: PREDICTION" : "MODE: DATA COLLECTION";

        cv::putText(frame, mode_text, cv::Point(20, 30),
            cv::FONT_HERSHEY_SIMPLEX, 0.7, cv::Scalar(255, 255, 0), 2);

        // ���������� ����������� ����
        std::string detection_text = "Hand: " + std::string(hand_detected ? "DETECTED" : "NOT FOUND");
        cv::Scalar detection_color = hand_detected ? cv::Scalar(0, 255, 0) : cv::Scalar(0, 0, 255);
        cv::putText(frame, detection_text, cv::Point(20, 90),
            cv::FONT_HERSHEY_SIMPLEX, 0.6, detection_color, 2);

        // ���������� ����� ������ (���� � ������ �����)
        if (current_mode_ == AppMode::DATA_COLLECTION) {
            drawDataCollectionInfo(frame);
        }

        // ����� ����������
        double detection_rate = (total_frames_ > 0) ?
            (static_cast<double>(hand_detected_frames_) / total_frames_) * 100.0 : 0.0;

        std::string stats_text = "Detection: " + std::to_string(detection_rate).substr(0, 4) + "%";
        cv::putText(frame, stats_text, cv::Point(20, frame.rows - 20),
            cv::FONT_HERSHEY_SIMPLEX, 0.5, cv::Scalar(200, 200, 200), 1);

        // ����������
        std::string instructions = "1-3: Data | P: Predict | S: Save | L: Load | Q: Quit";
        cv::putText(frame, instructions, cv::Point(20, frame.rows - 50),
            cv::FONT_HERSHEY_SIMPLEX, 0.5, cv::Scalar(200, 200, 200), 1);
    }

    void drawDataCollectionInfo(cv::Mat& frame) {
        int y_offset = 120;
        auto gestures = recognizer_.getGestures();

        for (size_t i = 0; i < gestures.size(); ++i) {
            int count = collector_.getCountForGesture(gestures[i]);
            std::string gesture_info = std::to_string(i + 1) + ": " + gestures[i] + " (" + std::to_string(count) + ")";

            cv::putText(frame, gesture_info, cv::Point(20, y_offset),
                cv::FONT_HERSHEY_SIMPLEX, 0.5, cv::Scalar(255, 255, 255), 1);
            y_offset += 25;
        }
    }

    void handleKeyPress(int key) {
        switch (key) {
        case 'q': case 'Q':
            stop();
            break;

        case 'p': case 'P':
            current_mode_ = AppMode::PREDICTION;
            std::cout << "Switched to PREDICTION mode" << std::endl;
            break;

        case 's': case 'S':
            collector_.saveToCSV();
            break;

        case 'l': case 'L':
            collector_.loadFromCSV();
            break;

        case '1': case '2': case '3':
            if (current_mode_ != AppMode::DATA_COLLECTION) {
                current_mode_ = AppMode::DATA_COLLECTION;
            }
            collectDataSample(key - '1');
            break;
        }
    }

    void collectDataSample(int gesture_index) {
        auto gestures = recognizer_.getGestures();
        if (gesture_index < gestures.size()) {
            std::string gesture_label = gestures[gesture_index];

            // �������� ������� ���� ��� landmarks
            cv::Mat temp_frame;
            cap_.read(temp_frame);
            cv::flip(temp_frame, temp_frame, 1);

            auto landmarks = recognizer_.extractLandmarks(temp_frame);
            if (!landmarks.empty()) {
                collector_.addSample(landmarks, gesture_label);
            }
            else {
                std::cout << "Hand not detected - sample not collected" << std::endl;
            }
        }
    }

    void printInstructions() {
        std::cout << "\n=== Controls ===" << std::endl;
        std::cout << "1, 2, 3: Collect data for gestures" << std::endl;
        std::cout << "P: Switch to prediction mode" << std::endl;
        std::cout << "S: Save dataset to CSV" << std::endl;
        std::cout << "L: Load dataset from CSV" << std::endl;
        std::cout << "Q: Quit application" << std::endl;
        std::cout << "ESC: Emergency quit" << std::endl;
        std::cout << "=================\n" << std::endl;
    }

    void stop() {
        is_running_ = false;
    }

    void cleanup() {
        collector_.saveToCSV(); // �������������� ��� ������
        cap_.release();
        cv::destroyAllWindows();

        std::cout << "\n=== Application Statistics ===" << std::endl;
        std::cout << "Total frames processed: " << total_frames_ << std::endl;
        std::cout << "Hand detected frames: " << hand_detected_frames_ << std::endl;
        std::cout << "Detection rate: " <<
            (static_cast<double>(hand_detected_frames_) / total_frames_ * 100.0) << "%" << std::endl;
        std::cout << "Total samples collected: " << collector_.getTotalSamples() << std::endl;
        std::cout << "=================================" << std::endl;
    }
};

int main() {
    std::cout << "Starting HandGestureAI - Complete Version" << std::endl;

    HandGestureApp app;
    if (!app.initialize()) {
        std::cerr << "Failed to initialize application" << std::endl;
        return -1;
    }

    app.run();

    std::cout << "HandGestureAI finished successfully" << std::endl;
    return 0;
}