#include "data_collector.h"
#include <iostream>
#include <sstream>
#include <algorithm>

DataCollector::DataCollector() {
    gesture_counts_ = {
        {"palm", 0},
        {"fist", 0},
        {"ok", 0}
    };
}

bool DataCollector::addSample(const std::vector<float>& landmarks, const std::string& label) {
    if (!canAddSample(label)) {
        std::cout << "Max samples reached for gesture: " << label << std::endl;
        return false;
    }

    if (landmarks.size() != 63) {
        std::cerr << "Invalid landmarks size: " << landmarks.size() << std::endl;
        return false;
    }

    GestureSample sample;
    sample.label = label;
    sample.landmarks = landmarks;

    dataset_.push_back(sample);
    gesture_counts_[label]++;

    std::cout << "Added sample for " << label << " (total: " << gesture_counts_[label] << ")" << std::endl;
    return true;
}

bool DataCollector::canAddSample(const std::string& label) const {
    auto it = gesture_counts_.find(label);
    if (it != gesture_counts_.end()) {
        return it->second < max_samples_per_gesture_;
    }
    return true; // New gesture
}

bool DataCollector::saveToCSV() {
    std::ofstream file(csv_path_);
    if (!file.is_open()) {
        std::cerr << "Cannot open CSV file: " << csv_path_ << std::endl;
        return false;
    }

    // Header
    file << "label";
    for (int i = 0; i < 63; ++i) {
        file << ",f" << i / 3 << "_" << ((i % 3 == 0) ? "x" : (i % 3 == 1) ? "y" : "z");
    }
    file << "\n";

    // Data
    for (const auto& sample : dataset_) {
        file << sample.label;
        for (const auto& value : sample.landmarks) {
            file << "," << value;
        }
        file << "\n";
    }

    file.close();

    std::cout << "Dataset saved to " << csv_path_ << " (" << dataset_.size() << " samples)" << std::endl;
    return true;
}

bool DataCollector::loadFromCSV() {
    std::ifstream file(csv_path_);
    if (!file.is_open()) {
        std::cerr << "Cannot open CSV file: " << csv_path_ << std::endl;
        return false;
    }

    clear();

    std::string line;
    std::getline(file, line); // Skip header

    while (std::getline(file, line)) {
        std::stringstream ss(line);
        std::string token;
        GestureSample sample;

        // Read label
        if (!std::getline(ss, token, ',')) continue;
        sample.label = token;

        // Read landmarks
        sample.landmarks.clear();
        while (std::getline(ss, token, ',')) {
            sample.landmarks.push_back(std::stof(token));
        }

        if (sample.landmarks.size() == 63) {
            dataset_.push_back(sample);
            gesture_counts_[sample.label]++;
        }
    }

    file.close();

    std::cout << "Dataset loaded from " << csv_path_ << " (" << dataset_.size() << " samples)" << std::endl;
    return true;
}

int DataCollector::getCountForGesture(const std::string& gesture) const {
    auto it = gesture_counts_.find(gesture);
    return (it != gesture_counts_.end()) ? it->second : 0;
}

std::vector<std::string> DataCollector::getGestureLabels() const {
    std::vector<std::string> labels;
    for (const auto& pair : gesture_counts_) {
        labels.push_back(pair.first);
    }
    return labels;
}

void DataCollector::clear() {
    dataset_.clear();
    for (auto& pair : gesture_counts_) {
        pair.second = 0;
    }
}