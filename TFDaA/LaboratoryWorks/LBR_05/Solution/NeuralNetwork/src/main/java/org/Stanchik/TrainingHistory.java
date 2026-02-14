package org.Stanchik;

import java.util.ArrayList;
import java.util.List;

public class TrainingHistory {
    private List<Double> trainLoss;
    private List<Double> trainAccuracy;
    private List<Double> testAccuracy;

    public TrainingHistory() {
        this.trainLoss = new ArrayList<>();
        this.trainAccuracy = new ArrayList<>();
        this.testAccuracy = new ArrayList<>();
    }

    public List<Double> getTrainLoss() { return trainLoss; }
    public List<Double> getTrainAccuracy() { return trainAccuracy; }
    public List<Double> getTestAccuracy() { return testAccuracy; }

    public void addTrainLoss(double loss) { trainLoss.add(loss); }
    public void addTrainAccuracy(double accuracy) { trainAccuracy.add(accuracy); }
    public void addTestAccuracy(double accuracy) { testAccuracy.add(accuracy); }
}