#include "gesture_recognizer.h"
#include <iostream>
#include <fstream>
#include <algorithm>

// MediaPipe includes
#include "mediapipe/framework/calculator_graph.h"
#include "mediapipe/framework/formats/image_frame.h"
#include "mediapipe/framework/formats/landmark.pb.h"
#include "mediapipe/framework/port/parse_text_proto.h"
#include "mediapipe/framework/port/status.h"
#include "mediapipe/framework/port/packet.h"
#include "mediapipe/framework/port/adopt.h"

// TensorFlow includes - временно отключено из-за проблем с установкой
// #include "tensorflow/cc/saved_model/loader.h"
// #include "tensorflow/cc/saved_model/tag_constants.h"
// #include "tensorflow/core/public/session.h"
// #include "tensorflow/core/platform/env.h"
#define TENSORFLOW_DISABLED

using namespace mediapipe;

GestureRecognizer::GestureRecognizer() {
    graph_ = std::make_unique<CalculatorGraph>();
}

GestureRecognizer::~GestureRecognizer() {
    if (graph_) {
        graph_->CloseAllPacketSources();
        graph_->WaitUntilDone();
    }
}

bool GestureRecognizer::initialize() {
    std::cout << "Initializing GestureRecognizer..." << std::endl;

    if (!initializeMediaPipe()) {
        std::cerr << "Failed to initialize MediaPipe" << std::endl;
        return false;
    }

    std::cout << "MediaPipe initialized successfully" << std::endl;
    is_initialized_ = true;
    return true;
}

bool GestureRecognizer::initializeMediaPipe() {
    // ������� ������������ �����
    mediapipe::CalculatorGraphConfig config;
    if (!mediapipe::ParseTextProto<mediapipe::CalculatorGraphConfig>(graph_config_, &config).ok()) {
        std::cerr << "Error parsing MediaPipe graph config" << std::endl;
        return false;
    }

    // ������������� �����
    auto status = graph_->Initialize(config);
    if (!status.ok()) {
        std::cerr << "Error initializing MediaPipe graph: " << status.message() << std::endl;
        return false;
    }

    // ������ �����
    status = graph_->StartRun({});
    if (!status.ok()) {
        std::cerr << "Error starting MediaPipe graph: " << status.message() << std::endl;
        return false;
    }

    return true;
}

bool GestureRecognizer::initializeModel(const std::string& model_path) {
    return initializeTensorFlow(model_path);
}

bool GestureRecognizer::initializeTensorFlow(const std::string& model_path) {
#ifdef TENSORFLOW_DISABLED
    std::cerr << "TensorFlow is disabled. Prediction will not work." << std::endl;
    return false;
#else
    try {
        model_ = std::make_unique<tensorflow::SavedModelBundle>();
        tensorflow::SessionOptions session_options;
        tensorflow::RunOptions run_options;

        auto status = tensorflow::LoadSavedModel(
            session_options, run_options,
            model_path,
            { tensorflow::kSavedModelTagServe },
            model_.get()
        );

        if (!status.ok()) {
            std::cerr << "Error loading TensorFlow model: " << status.status().message() << std::endl;
            return false;
        }

        std::cout << "TensorFlow model loaded successfully: " << model_path << std::endl;
        return true;
    }
    catch (const std::exception& e) {
        std::cerr << "Exception loading TensorFlow model: " << e.what() << std::endl;
        return false;
    }
#endif
}

std::vector<float> GestureRecognizer::extractLandmarks(const cv::Mat& frame) {
    if (!is_initialized_) {
        return {};
    }

    try {
        // ����������� BGR to RGB
        cv::Mat rgb_frame;
        cv::cvtColor(frame, rgb_frame, cv::COLOR_BGR2RGB);

        // �������� ImageFrame ��� MediaPipe
        auto input_frame = std::make_unique<mediapipe::ImageFrame>(
            mediapipe::ImageFormat::SRGB,
            rgb_frame.cols, rgb_frame.rows,
            mediapipe::ImageFrame::kDefaultAlignmentBoundary
        );

        // ����������� ������
        uint8_t* input_frame_ptr = input_frame->MutablePixelData();
        const uint8_t* rgb_frame_ptr = rgb_frame.data;
        int data_size = rgb_frame.total() * rgb_frame.elemSize();
        std::memcpy(input_frame_ptr, rgb_frame_ptr, data_size);

        // �������� ����� � MediaPipe
        auto status = graph_->AddPacketToInputStream(
            "input_video",
            mediapipe::Adopt(input_frame.release()).At(mediapipe::Timestamp(0))
        );

        if (!status.ok()) {
            std::cerr << "Error sending frame to MediaPipe: " << status.message() << std::endl;
            return {};
        }

        // ��������� landmarks
        mediapipe::Packet landmark_packet;
        if (!graph_->GetOutputStream("hand_landmarks").NextPacket(&landmark_packet)) {
            return {};
        }

        const auto& landmark_list = landmark_packet.Get<mediapipe::NormalizedLandmarkList>();
        std::vector<float> landmarks;
        landmarks.reserve(21 * 3); // 21 ����� ? 3 ����������

        for (const auto& landmark : landmark_list.landmark()) {
            landmarks.push_back(landmark.x());
            landmarks.push_back(landmark.y());
            landmarks.push_back(landmark.z());
        }

        return landmarks;
    }
    catch (const std::exception& e) {
        std::cerr << "Exception in extractLandmarks: " << e.what() << std::endl;
        return {};
    }
}

std::vector<float> GestureRecognizer::normalizeLandmarks(const std::vector<float>& landmarks) {
    if (landmarks.size() != 63) {
        return landmarks;
    }

    std::vector<float> normalized = landmarks;

    // ������������ ������������ �������� (����� 0)
    float wrist_x = landmarks[0];
    float wrist_y = landmarks[1];

    for (int i = 0; i < 21; ++i) {
        normalized[i * 3] -= wrist_x;     // X
        normalized[i * 3 + 1] -= wrist_y; // Y
        // Z ��������� ��� ����
    }

    return normalized;
}

std::pair<std::string, float> GestureRecognizer::predictGesture(const std::vector<float>& landmarks) {
#ifdef TENSORFLOW_DISABLED
    // Временная заглушка без TensorFlow
    return { "unknown", 0.0f };
#else
    if (!model_ || landmarks.empty()) {
        return { "unknown", 0.0f };
    }

    try {
        auto normalized = normalizeLandmarks(landmarks);

        // �������� �������
        tensorflow::Tensor input_tensor(
            tensorflow::DT_FLOAT,
            tensorflow::TensorShape({ 1, 63 })
        );

        auto input_map = input_tensor.tensor<float, 2>();
        for (int i = 0; i < 63; ++i) {
            input_map(0, i) = normalized[i];
        }

        // ���������� ������������
        std::vector<tensorflow::Tensor> outputs;
        auto status = model_->session->Run(
            { {"input_1", input_tensor} }, // ��� �������� ����
            { "dense_2" }, // ��� ��������� ����
            {},
            &outputs
        );

        if (!status.ok() || outputs.empty()) {
            std::cerr << "Prediction error: " << status.message() << std::endl;
            return { "error", 0.0f };
        }

        // ��������� �����������
        auto output_matrix = outputs[0].matrix<float>();
        int max_index = 0;
        float max_confidence = output_matrix(0, 0);

        for (int i = 1; i < output_matrix.dimension(1); ++i) {
            if (output_matrix(0, i) > max_confidence) {
                max_confidence = output_matrix(0, i);
                max_index = i;
            }
        }

        if (max_index < gestures_.size()) {
            return { gestures_[max_index], max_confidence };
        }

        return { "unknown", max_confidence };
    }
    catch (const std::exception& e) {
        std::cerr << "Exception in predictGesture: " << e.what() << std::endl;
        return { "error", 0.0f };
    }
#endif
}

cv::Point2f GestureRecognizer::landmarkToPixel(const cv::Mat& frame, float x, float y) {
    return cv::Point2f(x * frame.cols, y * frame.rows);
}

void GestureRecognizer::drawLandmarks(cv::Mat& frame, const std::vector<float>& landmarks) {
    if (landmarks.size() != 63) return;

    // Connections between landmarks (MediaPipe hand connections)
    const std::vector<std::pair<int, int>> connections = {
        {0,1}, {1,2}, {2,3}, {3,4},         // Thumb
        {0,5}, {5,6}, {6,7}, {7,8},         // Index
        {0,9}, {9,10}, {10,11}, {11,12},    // Middle
        {0,13}, {13,14}, {14,15}, {15,16},  // Ring
        {0,17}, {17,18}, {18,19}, {19,20}   // Pinky
    };

    // Draw connections
    for (const auto& connection : connections) {
        int idx1 = connection.first;
        int idx2 = connection.second;

        cv::Point2f p1 = landmarkToPixel(frame, landmarks[idx1 * 3], landmarks[idx1 * 3 + 1]);
        cv::Point2f p2 = landmarkToPixel(frame, landmarks[idx2 * 3], landmarks[idx2 * 3 + 1]);

        cv::line(frame, p1, p2, cv::Scalar(0, 255, 0), 2);
    }

    // Draw landmarks
    for (int i = 0; i < 21; ++i) {
        cv::Point2f point = landmarkToPixel(frame, landmarks[i * 3], landmarks[i * 3 + 1]);

        // Different colors for different parts
        cv::Scalar color;
        if (i == 0) color = cv::Scalar(255, 255, 255); // Wrist - white
        else if (i <= 4) color = cv::Scalar(255, 0, 0);   // Thumb - blue
        else if (i <= 8) color = cv::Scalar(0, 255, 0);   // Index - green
        else if (i <= 12) color = cv::Scalar(0, 0, 255);  // Middle - red
        else if (i <= 16) color = cv::Scalar(255, 255, 0); // Ring - cyan
        else color = cv::Scalar(255, 0, 255);            // Pinky - magenta

        cv::circle(frame, point, 4, color, -1);
        cv::circle(frame, point, 4, cv::Scalar(0, 0, 0), 1);
    }
}

void GestureRecognizer::drawConnections(cv::Mat& frame, const std::vector<float>& landmarks) {
    if (landmarks.size() != 63) return;

    // Connections between landmarks (MediaPipe hand connections)
    const std::vector<std::pair<int, int>> connections = {
        {0,1}, {1,2}, {2,3}, {3,4},         // Thumb
        {0,5}, {5,6}, {6,7}, {7,8},         // Index
        {0,9}, {9,10}, {10,11}, {11,12},    // Middle
        {0,13}, {13,14}, {14,15}, {15,16},  // Ring
        {0,17}, {17,18}, {18,19}, {19,20}   // Pinky
    };

    // Draw connections
    for (const auto& connection : connections) {
        int idx1 = connection.first;
        int idx2 = connection.second;

        cv::Point2f p1 = landmarkToPixel(frame, landmarks[idx1 * 3], landmarks[idx1 * 3 + 1]);
        cv::Point2f p2 = landmarkToPixel(frame, landmarks[idx2 * 3], landmarks[idx2 * 3 + 1]);

        cv::line(frame, p1, p2, cv::Scalar(0, 255, 0), 2);
    }
}