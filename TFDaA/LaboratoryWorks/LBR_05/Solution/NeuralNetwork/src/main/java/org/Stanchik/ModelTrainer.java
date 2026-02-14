package org.Stanchik;

import org.deeplearning4j.datasets.iterator.impl.MnistDataSetIterator;
import org.deeplearning4j.nn.multilayer.MultiLayerNetwork;
import org.deeplearning4j.optimize.listeners.ScoreIterationListener;
import org.nd4j.evaluation.classification.Evaluation;
import org.nd4j.linalg.dataset.DataSet;

public class ModelTrainer {

    public TrainingHistory trainModel(
            MultiLayerNetwork model,
            MnistDataSetIterator trainIter,
            MnistDataSetIterator testIter,
            int numEpochs
    ) {
        TrainingHistory history = new TrainingHistory();

        model.setListeners(new ScoreIterationListener(100));
        System.out.println("Модель успешно скомпилирована!");

        for (int epoch = 1; epoch <= numEpochs; epoch++) {
            System.out.println("Эпоха " + epoch + "/" + numEpochs);

            // Обучение
            trainIter.reset();
            while (trainIter.hasNext()) {
                DataSet dataset = trainIter.next();
                model.fit(dataset);
            }

            // Оценка на тренировочных данных
            trainIter.reset();
            Evaluation trainEval = model.evaluate(trainIter);
            history.addTrainAccuracy(trainEval.accuracy());

            // Оценка на тестовых данных
            testIter.reset();
            Evaluation testEval = model.evaluate(testIter);
            history.addTestAccuracy(testEval.accuracy());

            // Потери
            history.addTrainLoss(model.score());

            System.out.printf("Train Accuracy: %.4f, Test Accuracy: %.4f%n",
                    trainEval.accuracy(), testEval.accuracy());
        }

        return history;
    }
}