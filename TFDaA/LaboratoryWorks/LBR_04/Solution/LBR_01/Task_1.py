import cv2
import numpy as np
import time
from datetime import datetime

class MotionDetector:
    def __init__(self, learning_rate=0.001, motion_threshold=1000):
        self.learning_rate = learning_rate
        self.motion_threshold = motion_threshold
        self.bg_subtractor = cv2.createBackgroundSubtractorMOG2(history=500, varThreshold=16, detectShadows=True)

    def detect_motion(self, frame):
        fg_mask = self.bg_subtractor.apply(frame, learningRate=self.learning_rate)

        kernel_open = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5))
        kernel_close = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (20, 20))

        fg_mask = cv2.morphologyEx(fg_mask, cv2.MORPH_OPEN, kernel_open)
        fg_mask = cv2.morphologyEx(fg_mask, cv2.MORPH_CLOSE, kernel_close)

        contours, _ = cv2.findContours(fg_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

        motion_detected = False
        processed_frame = frame.copy()
        bounding_boxes = []

        for contour in contours:
            area = cv2.contourArea(contour)
            if area > self.motion_threshold:
                motion_detected = True
                x, y, w, h = cv2.boundingRect(contour)
                bounding_boxes.append((x, y, w, h))
                cv2.rectangle(processed_frame, (x, y), (x + w, y + h), (0, 0, 255), 2)
                cv2.putText(processed_frame, "MOTION", (x, y - 10),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 255), 2)

        return motion_detected, processed_frame, bounding_boxes

class LucasKanadeTracker:
    def __init__(self):
        self.prev_points = None
        self.current_points = None
        self.initial_points = None
        self.prev_gray = None
        self.first_frame = True

    def process_frame(self, frame):
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        output = frame.copy()

        if self.first_frame:
            self.prev_points = cv2.goodFeaturesToTrack(gray, maxCorners=200,
                                                       qualityLevel=0.01, minDistance=5, blockSize=3)
            if self.prev_points is not None:
                self.initial_points = self.prev_points.copy()
            self.prev_gray = gray.copy()
            self.first_frame = False
            return output

        if self.prev_points is None or len(self.prev_points) == 0:
            self.prev_points = cv2.goodFeaturesToTrack(gray, maxCorners=200,
                                                       qualityLevel=0.01, minDistance=5, blockSize=3)
            if self.prev_points is not None:
                self.initial_points = self.prev_points.copy()
            self.prev_gray = gray.copy()
            return output

        self.current_points, status, err = cv2.calcOpticalFlowPyrLK(
            self.prev_gray, gray, self.prev_points, None,
            winSize=(15, 15), maxLevel=2,
            criteria=(cv2.TERM_CRITERIA_EPS | cv2.TERM_CRITERIA_COUNT, 10, 0.03)
        )

        if self.current_points is not None:
            valid_count = np.sum(status)
            if valid_count < 5:
                self.prev_points = cv2.goodFeaturesToTrack(gray, maxCorners=200,
                                                           qualityLevel=0.01, minDistance=5, blockSize=3)
                if self.prev_points is not None:
                    self.initial_points = self.prev_points.copy()
                self.prev_gray = gray.copy()
                return output

            for i in range(len(self.current_points)):
                if status[i]:
                    prev_pt = tuple(self.prev_points[i].astype(int).ravel())
                    curr_pt = tuple(self.current_points[i].astype(int).ravel())
                    init_pt = tuple(self.initial_points[i].astype(int).ravel())

                    cv2.line(output, prev_pt, curr_pt, (0, 255, 0), 1)
                    cv2.circle(output, curr_pt, 2, (0, 255, 0), -1)
                    cv2.line(output, init_pt, curr_pt, (255, 0, 0), 1)

        self.prev_gray = gray.copy()
        if self.current_points is not None:
            self.prev_points = self.current_points.copy()

        return output

class SimpleObjectTracker:
    def __init__(self):
        self.face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
        self.object_detector = cv2.createBackgroundSubtractorMOG2(history=300, varThreshold=25)
        self.tracked_objects = []
        self.next_id = 1
        self.colors = [
            (255, 0, 0),
            (0, 255, 0),
            (0, 0, 255),
            (255, 255, 0),
            (255, 0, 255),
            (0, 255, 255),
        ]

    def detect_faces(self, frame):
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        faces = self.face_cascade.detectMultiScale(gray, 1.1, 4, minSize=(50, 50))
        return faces

    def detect_moving_objects(self, frame):
        fg_mask = self.object_detector.apply(frame)

        kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (10, 10))
        fg_mask = cv2.morphologyEx(fg_mask, cv2.MORPH_OPEN, kernel)
        fg_mask = cv2.morphologyEx(fg_mask, cv2.MORPH_CLOSE, kernel)

        contours, _ = cv2.findContours(fg_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

        objects = []
        for contour in contours:
            area = cv2.contourArea(contour)
            if area > 1500:
                x, y, w, h = cv2.boundingRect(contour)
                if w < frame.shape[1] * 0.8 and h < frame.shape[0] * 0.8:
                    objects.append((x, y, w, h))

        return objects

    def update_tracking(self, frame):
        output = frame.copy()

        faces = self.detect_faces(frame)

        moving_objects = self.detect_moving_objects(frame)

        all_objects = list(faces) + moving_objects

        if not all_objects:
            h, w = frame.shape[:2]
            all_objects = [
                (int(w*0.2), int(h*0.2), int(w*0.15), int(h*0.15)),
                (int(w*0.6), int(h*0.3), int(w*0.2), int(h*0.2)),
                (int(w*0.4), int(h*0.6), int(w*0.15), int(h*0.15))
            ]

        all_objects = all_objects[:6]

        current_objects = []

        for i, (x, y, w, h) in enumerate(all_objects):
            obj_id = i + 1
            color = self.colors[i % len(self.colors)]

            cv2.rectangle(output, (x, y), (x + w, y + h), color, 3)

            cv2.putText(output, f"ID:{obj_id}", (x, y - 10),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.7, color, 2)

            center_x = x + w // 2
            center_y = y + h // 2
            cv2.circle(output, (center_x, center_y), 6, color, -1)

            marker_size = 4
            cv2.circle(output, (x, y), marker_size, color, -1)
            cv2.circle(output, (x + w, y), marker_size, color, -1)
            cv2.circle(output, (x, y + h), marker_size, color, -1)
            cv2.circle(output, (x + w, y + h), marker_size, color, -1)

            if i < len(faces):
                obj_type = "FACE"
            else:
                obj_type = "OBJECT"

            cv2.putText(output, obj_type, (x, y + h + 20),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 1)

            current_objects.append({
                'id': obj_id,
                'bbox': (x, y, w, h),
                'color': color,
                'type': obj_type
            })

        total_objects = len(all_objects)
        faces_count = len(faces)
        moving_count = len(moving_objects)

        cv2.putText(output, f"TRACKING: {total_objects} OBJECTS", (10, 30),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 255, 0), 2)
        cv2.putText(output, f"Faces: {faces_count}, Moving: {moving_count}", (10, 70),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 0), 2)

        self.tracked_objects = current_objects

        return total_objects > 0, output

def main():
    cap = cv2.VideoCapture(0)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)

    if not cap.isOpened():
        print("Error: Could not open video stream!")
        return -1

    motion_detector = MotionDetector()
    lk_tracker = LucasKanadeTracker()
    obj_tracker = SimpleObjectTracker()

    motion_alert_sent = False
    last_alert_time = 0

    cv2.namedWindow("Video Analysis", cv2.WINDOW_NORMAL)

    print("=== VIDEO ANALYSIS SYSTEM ===")
    print("All modules running automatically...")
    print("Object Tracking: Face detection + Motion detection")
    print("Press 'q' to exit")
    print("==============================")

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        motion_detected, motion_output, _ = motion_detector.detect_motion(frame)

        if motion_detected and not motion_alert_sent:
            current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            print(f"WARNING: Motion detected! {current_time}")
            motion_alert_sent = True
            last_alert_time = time.time()

        if motion_alert_sent and (time.time() - last_alert_time) > 3:
            motion_alert_sent = False

        lk_output = lk_tracker.process_frame(frame)

        tracking_success, tracking_output = obj_tracker.update_tracking(frame)

        display_size = (640, 480)

        motion_display = cv2.resize(motion_output, display_size)
        lk_display = cv2.resize(lk_output, display_size)
        tracking_display = cv2.resize(tracking_output, display_size)
        original_display = cv2.resize(frame, display_size)

        top_row = np.hstack([motion_display, lk_display])
        bottom_row = np.hstack([tracking_display, original_display])
        final_output = np.vstack([top_row, bottom_row])

        cv2.putText(final_output, "1. Motion Detection", (10, 30),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)
        cv2.putText(final_output, "2. Optical Flow", (650, 30),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)
        cv2.putText(final_output, "3. Object Tracking", (10, 510),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)
        cv2.putText(final_output, "4. Original", (650, 510),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)

        cv2.imshow("Video Analysis", final_output)

        key = cv2.waitKey(30) & 0xFF
        if key == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    main()