#pragma once
#ifndef DATA_COLLECTOR_H
#define DATA_COLLECTOR_H

#include <vector>
#include <string>
#include <fstream>
#include <map>
#include <opencv2/opencv.hpp>

struct GestureSample {
    std::string label;
    std::vector<float> landmarks;
    cv::Mat image; // Optional: store image for visualization
};

class DataCollector {
private:
    std::vector<GestureSample> dataset_;
    std::map<std::string, int> gesture_counts_;
    std::string csv_path_ = "gesture_dataset.csv";
    int max_samples_per_gesture_ = 200;

public:
    DataCollector();

    bool addSample(const std::vector<float>& landmarks, const std::string& label);
    bool saveToCSV();
    bool loadFromCSV();
    void clear();

    size_t getTotalSamples() const { return dataset_.size(); }
    int getCountForGesture(const std::string& gesture) const;
    std::vector<std::string> getGestureLabels() const;
    const std::vector<GestureSample>& getSamples() const { return dataset_; }

    void setMaxSamples(int max) { max_samples_per_gesture_ = max; }
    void setCSVPath(const std::string& path) { csv_path_ = path; }

private:
    bool canAddSample(const std::string& label) const;
};

#endif