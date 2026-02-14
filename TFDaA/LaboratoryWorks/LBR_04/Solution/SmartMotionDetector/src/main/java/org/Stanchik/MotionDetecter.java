package org.Stanchik;

import jdk.internal.org.jline.terminal.Size;
import org.w3c.dom.css.Rect;

import java.awt.*;
import java.util.ArrayList;

private static class MotionDetecter {
    private BackgroundSubtractorMOG2 bgSubtractor;
    private double learningRate;
    private int motionThreshold;

    public MotionDetector(double lr, int threshold) {
        learningRate = lr;
        motionThreshold = threshold;
        bgSubtractor = Video.createBackgroundSubtractorMOG2(500, 16, true);
    }

    public boolean detectMotion(Mat frame, Mat output) {
        Mat fgMask = new Mat();
        frame.copyTo(output);

        bgSubtractor.apply(frame, fgMask, learningRate);
x
        // Морфологические операции
        Imgproc.morphologyEx(fgMask, fgMask, Imgproc.MORPH_OPEN, Imgproc.getStructuringElement(Imgproc.MORPH_ELLIPSE, new Size(3, 3)));
        Imgproc.morphologyEx(fgMask, fgMask, Imgproc.MORPH_CLOSE, Imgproc.getStructuringElement(Imgproc.MORPH_ELLIPSE, new Size(15, 15)));

        List<MatOfPoint> contours = new ArrayList<>();
        Imgproc.findContours(fgMask, contours, new Mat(), Imgproc.RETR_EXTERNAL, Imgproc.CHAIN_APPROX_SIMPLE);

        boolean motionDetected = false;
        for (MatOfPoint contour : contours) {
            double area = Imgproc.contourArea(contour);
            if (area > motionThreshold) {
                motionDetected = true;
                Rect bbox = Imgproc.boundingRect(contour);
                Imgproc.rectangle(output, bbox.tl(), bbox.br(), new Scalar(0, 0, 255), 2);
                Imgproc.putText(output, "MOTION DETECTED", new Point(bbox.x, bbox.y - 10), Imgproc.FONT_HERSHEY_SIMPLEX, 0.7, new Scalar(0, 0, 255), 2);
            }
        }

        return motionDetected;
    }
}