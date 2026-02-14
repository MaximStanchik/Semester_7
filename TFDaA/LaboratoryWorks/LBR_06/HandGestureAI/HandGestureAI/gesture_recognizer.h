#pragma once
#ifndef GESTURE_RECOGNIZER_H
#define GESTURE_RECOGNIZER_H

#include <vector>
#include <string>
#include <memory>
#include <opencv2/opencv.hpp>

// Forward declarations для избежания зависимостей
namespace mediapipe {
    class CalculatorGraph;
    class Timestamp;
}

namespace tensorflow {
    class Session;
    class Tensor;
    class SavedModelBundle;
}

class GestureRecognizer {
private:
    std::unique_ptr<mediapipe::CalculatorGraph> graph_;
    std::unique_ptr<tensorflow::SavedModelBundle> model_;
    std::vector<std::string> gestures_ = { "palm", "fist", "ok" };
    bool is_initialized_ = false;

    // MediaPipe конфигурация
    const std::string graph_config_ = R"pb(
        input_stream: "input_video"
        output_stream: "hand_landmarks"
        node {
            calculator: "HandLandmarker"
            input_stream: "IMAGE:input_video"
            output_stream: "LANDMARKS:hand_landmarks"
            options {
                [mediapipe.HandLandmarkerOptions.ext] {
                    model_path: "hand_landmarker.task"
                    num_hands: 1
                }
            }
        }
    )pb";

public:
    GestureRecognizer();
    ~GestureRecognizer();

    bool initialize();
    bool initializeModel(const std::string& model_path);
    std::vector<float> extractLandmarks(const cv::Mat& frame);
    std::vector<float> normalizeLandmarks(const std::vector<float>& landmarks);
    std::pair<std::string, float> predictGesture(const std::vector<float>& landmarks);
    void drawLandmarks(cv::Mat& frame, const std::vector<float>& landmarks);
    void drawConnections(cv::Mat& frame, const std::vector<float>& landmarks);

    const std::vector<std::string>& getGestures() const { return gestures_; }
    bool isInitialized() const { return is_initialized_; }
    void setGestures(const std::vector<std::string>& gestures) { gestures_ = gestures; }

private:
    bool initializeMediaPipe();
    bool initializeTensorFlow(const std::string& model_path);
    cv::Point2f landmarkToPixel(const cv::Mat& frame, float x, float y);
};

#endif