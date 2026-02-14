package org.Stanchik;

import java.awt.*;

private static class ObjectTracker {
    private TrackerKCF tracker;
    private Rect2d bbox;
    private boolean tracking;

    public ObjectTracker() {
        tracker = TrackerKCF.create();
        tracking = false;
    }

    public void startTracking(Mat frame, Rect2d roi) {
        bbox = roi;
        tracker.init(frame, bbox);
        tracking = true;
    }

    public boolean updateTracking(Mat frame, Mat output) {
        if (!tracking) return false;

        boolean success = tracker.update(frame, bbox);
        frame.copyTo(output);

        if (success) {
            Imgproc.rectangle(output, bbox.tl(), bbox.br(), new Scalar(255, 0, 0), 2);
            Imgproc.putText(output, "TRACKING", new Point(bbox.x, bbox.y - 10), Imgproc.FONT_HERSHEY_SIMPLEX, 0.7, new Scalar(255, 0, 0), 2);
        }
        else {
            Imgproc.putText(output, "TRACKING LOST", new Point(10, 50), Imgproc.FONT_HERSHEY_SIMPLEX, 1, new Scalar(0, 0, 255), 2);
        }

        return success;
    }

    public boolean isTracking() {
        return tracking;
    }
}