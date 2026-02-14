package org.Stanchik;

import javax.swing.*;
import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;
import java.awt.image.BufferedImage;

public class SmartMotionDetectorApplication
{
    public static void main(String[] args) {
        VideoCapture cap = new VideoCapture(0);
        if (!cap.isOpened()) {
            System.out.println("Ошибка: не удалось открыть видео поток!");
            return;
        }

        MotionDetector motionDetector = new MotionDetector(0.001, 5000);
        ObjectTracker objTracker = new ObjectTracker();

        JFrame frame = new JFrame("Video Analysis");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setSize(800, 600);
        JLabel label = new JLabel();
        frame.add(label);
        frame.setVisible(true);

        Mat videoFrame = new Mat();
        Mat outputFrame = new Mat();
        Rect2d selection = null;

        frame.addKeyListener(new KeyAdapter() {
            @Override
            public void keyPressed(KeyEvent e) {
                if (e.getKeyChar() == 's') {
                    // Выбор области для трекинга
                    selection = new Rect2d(100, 100, 200, 200); // Здесь можно использовать библиотеку для выбора ROI
                    objTracker.startTracking(videoFrame, selection);
                } else if (e.getKeyChar() == 'r') {
                    objTracker = new ObjectTracker();
                }
            }
        });

        while (true) {
            cap.read(videoFrame);
            if (videoFrame.empty()) break;

            boolean motionDetected = motionDetector.detectMotion(videoFrame, outputFrame);

            if (motionDetected) {
                System.out.println("ПРЕДУПРЕЖДЕНИЕ: Обнаружено движение!");
            }

            if (objTracker.isTracking()) {
                objTracker.updateTracking(videoFrame, outputFrame);
            }

            // Отображение результата
            ImageIcon imageIcon = new ImageIcon(Mat2BufferedImage(outputFrame));
            label.setIcon(imageIcon);
            frame.repaint();

            if (frame.isDisplayable()) {
                break;
            }
        }

        cap.release();
        frame.dispose();
    }

    // Вспомогательный метод для преобразования Mat в BufferedImage
    public static BufferedImage Mat2BufferedImage(Mat matrix) {
        int type = BufferedImage.TYPE_BYTE_GRAY;
        if (matrix.channels() > 1) {
            type = BufferedImage.TYPE_3BYTE_BGR;
        }
        int bufferSize = matrix.channels() * matrix.cols() * matrix.rows();
        byte[] b = new byte[bufferSize];
        matrix.get(0, 0, b); // Получаем массив байтов
        BufferedImage image = new BufferedImage(matrix.cols(), matrix.rows(), type);
        image.getRaster().setDataElements(0, 0, matrix.cols(), matrix.rows(), b);
        return image;
    }
}
