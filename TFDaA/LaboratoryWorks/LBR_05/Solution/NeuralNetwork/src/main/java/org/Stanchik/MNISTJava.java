package org.Stanchik;

import org.deeplearning4j.datasets.iterator.impl.MnistDataSetIterator;
import org.deeplearning4j.nn.conf.NeuralNetConfiguration;
import org.deeplearning4j.nn.conf.layers.*;
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork;
import org.deeplearning4j.nn.weights.WeightInit;
import org.nd4j.linalg.activations.Activation;
import org.nd4j.linalg.dataset.api.iterator.DataSetIterator;
import org.nd4j.linalg.learning.config.Adam;
import org.nd4j.linalg.lossfunctions.LossFunctions;
import org.nd4j.evaluation.classification.Evaluation;
import org.nd4j.linalg.dataset.DataSet;

import java.util.*;

public class MNISTJava {

    private static final int BATCH_SIZE = 128;
    private static final int EPOCHS = 15;
    private static final long SEED = 12345L;
    private static final int OUTPUT_NUM = 10;

    public static void main(String[] args) throws Exception {
        System.out.println("=== MNIST на Java с Maven ===");

        // Загрузка данных
        DataSetIterator trainIter = new MnistDataSetIterator(BATCH_SIZE, true, SEED);
        DataSetIterator testIter = new MnistDataSetIterator(BATCH_SIZE, false, SEED);

        System.out.println("Данные загружены успешно!");
        System.out.println("Обучающая выборка: 60000 изображений 28x28");
        System.out.println("Тестовая выборка: 10000 изображений 28x28");

        // Тестирование разных моделей
        Map<String, MultiLayerNetwork> models = new LinkedHashMap<>();
        models.put("CNN (без Dropout)", createCNNModel());
        models.put("CNN + Dropout", createCNNWithDropout());
        models.put("MLP (полносвязная)", createMLPModel());

        Map<String, Double> results = new HashMap<>();
        Map<String, TrainingHistory> histories = new HashMap<>();

        ModelTrainer trainer = new ModelTrainer();

        for (Map.Entry<String, MultiLayerNetwork> entry : models.entrySet()) {
            String name = entry.getKey();
            MultiLayerNetwork model = entry.getValue();

            System.out.println("\n--- Обучение модели: " + name + " ---");
            System.out.println(model.summary());

            TrainingHistory history = trainer.trainModel(model, trainIter, testIter, 5);

            Evaluation evaluation = new Evaluation(OUTPUT_NUM);
            testIter.reset();
            while (testIter.hasNext()) {
                DataSet dataset = testIter.next();
                evaluation.eval(dataset.getLabels(), model.output(dataset.getFeatures()));
            }

            results.put(name, evaluation.accuracy());
            histories.put(name, history);

            System.out.printf("Финальная точность: %.4f%n", evaluation.accuracy());

            // Показать примеры предсказаний для лучшей модели
            if (name.equals("CNN + Dropout")) {
                displaySamplePredictions(model, testIter);
            }
        }

        printModelComparison(results);

        // Финальная оценка
        String bestModelName = Collections.max(results.entrySet(), Map.Entry.comparingByValue()).getKey();
        MultiLayerNetwork bestModel = models.get(bestModelName);
        Evaluation finalEval = new Evaluation(OUTPUT_NUM);
        testIter.reset();
        while (testIter.hasNext()) {
            DataSet dataset = testIter.next();
            finalEval.eval(dataset.getLabels(), bestModel.output(dataset.getFeatures()));
        }

        System.out.println("\n=== Финальные результаты ===");
        System.out.println("Лучшая модель: " + bestModelName);
        System.out.printf("Тестовая точность: %.4f%n", finalEval.accuracy());
        System.out.printf("Потери: %.4f%n", bestModel.score());

        // Анализ переобучения
        TrainingHistory bestHistory = histories.get(bestModelName);
        double trainAcc = bestHistory.getTrainAccuracy().get(bestHistory.getTrainAccuracy().size() - 1);
        double testAcc = bestHistory.getTestAccuracy().get(bestHistory.getTestAccuracy().size() - 1);
        double difference = trainAcc - testAcc;

        System.out.println("\n=== Анализ переобучения ===");
        System.out.printf("Train accuracy: %.4f%n", trainAcc);
        System.out.printf("Test accuracy: %.4f%n", testAcc);
        System.out.printf("Разница: %.4f%n", difference);

        if (difference > 0.05) {
            System.out.println("❌ Сильное переобучение!");
        } else if (difference > 0.02) {
            System.out.println("⚠️  Умеренное переобучение");
        } else {
            System.out.println("✅ Переобучение минимальное");
        }
    }

    public static MultiLayerNetwork createCNNModel() {
        NeuralNetConfiguration.List conf = new NeuralNetConfiguration.Builder()
                .seed(SEED)
                .weightInit(WeightInit.XAVIER)
                .updater(new Adam(0.001))
                .list()
                // Свёрточный блок 1
                .layer(new ConvolutionLayer.Builder(3, 3)
                        .nIn(1)
                        .nOut(32)
                        .activation(Activation.RELU)
                        .build())
                .layer(new SubsamplingLayer.Builder(SubsamplingLayer.PoolingType.MAX)
                        .kernelSize(2, 2)
                        .stride(2, 2)
                        .build())
                // Свёрточный блок 2
                .layer(new ConvolutionLayer.Builder(3, 3)
                        .nOut(64)
                        .activation(Activation.RELU)
                        .build())
                .layer(new SubsamplingLayer.Builder(SubsamplingLayer.PoolingType.MAX)
                        .kernelSize(2, 2)
                        .stride(2, 2)
                        .build())
                // Полносвязные слои
                .layer(new DenseLayer.Builder()
                        .nOut(128)
                        .activation(Activation.RELU)
                        .build())
                .layer(new OutputLayer.Builder(LossFunctions.LossFunction.NEGATIVELOGLIKELIHOOD)
                        .nOut(OUTPUT_NUM)
                        .activation(Activation.SOFTMAX)
                        .build())
                .build();

        MultiLayerNetwork model = new MultiLayerNetwork(conf);
        model.init();
        return model;
    }

    public static MultiLayerNetwork createCNNWithDropout() {
        NeuralNetConfiguration.List conf = new NeuralNetConfiguration.Builder()
                .seed(SEED)
                .weightInit(WeightInit.XAVIER)
                .updater(new Adam(0.001))
                .list()
                .layer(new ConvolutionLayer.Builder(3, 3)
                        .nIn(1)
                        .nOut(32)
                        .activation(Activation.RELU)
                        .build())
                .layer(new SubsamplingLayer.Builder(SubsamplingLayer.PoolingType.MAX)
                        .kernelSize(2, 2)
                        .stride(2, 2)
                        .build())
                .layer(new ConvolutionLayer.Builder(3, 3)
                        .nOut(64)
                        .activation(Activation.RELU)
                        .build())
                .layer(new SubsamplingLayer.Builder(SubsamplingLayer.PoolingType.MAX)
                        .kernelSize(2, 2)
                        .stride(2, 2)
                        .build())
                .layer(new DenseLayer.Builder()
                        .nOut(128)
                        .activation(Activation.RELU)
                        .build())
                .layer(new DropoutLayer.Builder(0.5).build()) // 50% dropout
                .layer(new OutputLayer.Builder(LossFunctions.LossFunction.NEGATIVELOGLIKELIHOOD)
                        .nOut(OUTPUT_NUM)
                        .activation(Activation.SOFTMAX)
                        .build())
                .build();

        MultiLayerNetwork model = new MultiLayerNetwork(conf);
        model.init();
        return model;
    }

    public static MultiLayerNetwork createMLPModel() {
        NeuralNetConfiguration.List conf = new NeuralNetConfiguration.Builder()
                .seed(SEED)
                .weightInit(WeightInit.XAVIER)
                .updater(new Adam(0.001))
                .list()
                .layer(new DenseLayer.Builder()
                        .nIn(784) // 28x28 flattened
                        .nOut(512)
                        .activation(Activation.RELU)
                        .dropOut(0.3)
                        .build())
                .layer(new DenseLayer.Builder()
                        .nOut(256)
                        .activation(Activation.RELU)
                        .dropOut(0.3)
                        .build())
                .layer(new OutputLayer.Builder(LossFunctions.LossFunction.NEGATIVELOGLIKELIHOOD)
                        .nOut(OUTPUT_NUM)
                        .activation(Activation.SOFTMAX)
                        .build())
                .build();

        MultiLayerNetwork model = new MultiLayerNetwork(conf);
        model.init();
        return model;
    }

    public static void displaySamplePredictions(MultiLayerNetwork model, DataSetIterator testIter) {
        System.out.println("\n--- Примеры предсказаний ---");
        testIter.reset();
        DataSet testBatch = testIter.next();

        var predictions = model.output(testBatch.getFeatures());

        for (int i = 0; i < Math.min(6, testBatch.numExamples()); i++) {
            int actual = testBatch.getLabels().argMax(1).getInt(i);
            int predicted = predictions.argMax(1).getInt(i);
            boolean isCorrect = actual == predicted;

            System.out.println("Пример " + (i + 1) + ": Истинная = " + actual +
                    ", Предсказанная = " + predicted + " " +
                    (isCorrect ? "✅" : "❌"));
        }
    }

    public static void printModelComparison(Map<String, Double> results) {
        System.out.println("\n=== Сравнение моделей ===");
        results.entrySet().stream()
                .sorted(Map.Entry.<String, Double>comparingByValue().reversed())
                .forEach(entry -> {
                    String name = entry.getKey();
                    double accuracy = entry.getValue();
                    System.out.printf("%-20s: %.4f%n", name, accuracy);
                });
    }
}
