package org.Stanchik;

import static org.Stanchik.TextSteganography.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class SteganographyApplication {

    public static void main(String[] args) {
        List<TestData> testData = prepareTestData();

        System.out.println("=== СРАВНИТЕЛЬНЫЙ АНАЛИЗ СТЕГАНОГРАФИЧЕСКИХ МЕТОДОВ ===");
        System.out.println("Количество экспериментов: " + testData.size());
        System.out.println("=====================================================\n");

        List<ExperimentResult> results = new ArrayList<>();

        for (int i = 0; i < testData.size(); i++) {
            TestData data = testData.get(i);
            System.out.println("\n--- Эксперимент " + (i + 1) + " ---");
            System.out.println("Тип: " + data.description);
            System.out.println("Длина текста: " + data.text.length() + " символов");
            System.out.println("Длина сообщения: " + data.message.length() + " символов (" +
                    data.message.length() * 8 + " бит)");

            ExperimentResult result = performExperiment(data.text, data.message, data.description);
            results.add(result);
        }

        analyzeResults(results);
    }

    private static List<TestData> prepareTestData() {
        List<TestData> data = new ArrayList<>();
        Random random = new Random();

        String englishText = "Exploring the vast mysteries of the universe pushes the boundaries of human knowledge and technological capabilities forward.";
        String russianText = "Цифровизация экономики существенно влияет на рынок труда, создавая одни профессии и заменяя другие.";
        String mixedText = "Digital transformation 2024: Цифровая трансформация и AI технологии revolutionize бизнес-процессы.";

        String[] shortMessages = {"hi", "ok", "test", "pass", "code"};
        String[] mediumMessages = {
                "hello world", "secret message", "confidential",
                "steganography test", "hidden data here"
        };
        String[] longMessages = {
                "The quick brown fox jumps over the lazy dog in the park near the river bank yesterday evening",
                "Современные методы стеганографии позволяют скрывать информацию в различных типах данных",
                "This is a much longer secret message that contains multiple sentences and various types of characters for comprehensive testing purposes"
        };

        for (String msg : shortMessages) {
            data.add(new TestData(englishText, msg, "Английский текст, короткое сообщение"));
        }

        for (String msg : mediumMessages) {
            data.add(new TestData(russianText, msg, "Русский текст, среднее сообщение"));
        }

        for (String msg : longMessages) {
            data.add(new TestData(mixedText, msg, "Смешанный текст, длинное сообщение"));
        }

        data.add(new TestData("Text with\ttabs\nand newlines", "secret", "Текст с табуляцией и переносами"));
        data.add(new TestData("Text with  multiple   spaces", "data", "Текст с множественными пробелами"));
        data.add(new TestData("Punctuation! Test? With, various; symbols.", "msg", "Текст с пунктуацией"));
        data.add(new TestData("123 numbers 456 and 7890", "hide", "Текст с числами"));

        data.add(new TestData(generateRandomText(10), "test", "Короткий случайный текст (10 слов)"));
        data.add(new TestData(generateRandomText(50), "message", "Средний случайный текст (50 слов)"));
        data.add(new TestData(generateRandomText(200), "long secret", "Длинный случайный текст (200 слов)"));

        data.add(new TestData("Short", "a", "Очень короткий текст"));
        data.add(new TestData(generateRandomText(500),
                "This is a very long secret message that needs to be hidden in a large text container for testing maximum capacity and performance under stress conditions with various character types and lengths",
                "Максимальная нагрузка"));

        return data;
    }

    private static ExperimentResult performExperiment(String text, String message, String description) {
        ExperimentResult result = new ExperimentResult(description);

        long spaceEmbedTime = measureEmbedSpaceTime(text, message);
        String spaceStego = embedSpace(text, message);
        long spaceExtractTime = measureExtractSpaceTime(spaceStego);
        String spaceExtracted = extractSpace(spaceStego);

        long zeroEmbedTime = measureEmbedZeroTime(text, message);
        String zeroStego = embedZero(text, message);
        long zeroExtractTime = measureExtractZeroTime(zeroStego);
        String zeroExtracted = extractZero(zeroStego);

        result.spaceEmbedTime = spaceEmbedTime;
        result.spaceExtractTime = spaceExtractTime;
        result.zeroEmbedTime = zeroEmbedTime;
        result.zeroExtractTime = zeroExtractTime;
        result.spaceCorrect = message.equals(spaceExtracted);
        result.zeroCorrect = message.equals(zeroExtracted);
        result.spaceChanges = countChanges(text, spaceStego);
        result.zeroChanges = countChanges(text, zeroStego);
        result.spaceDetectable = detectSpace(spaceStego);
        result.zeroDetectable = detectZero(zeroStego);
        result.spaceSize = spaceStego.length();
        result.zeroSize = zeroStego.length();
        result.originalSize = text.length();

        System.out.println("Space метод - Встраивание: " + spaceEmbedTime/1000 + " мкс, " +
                "Извлечение: " + spaceExtractTime/1000 + " мкс, " +
                "Корректность: " + result.spaceCorrect);
        System.out.println("Zero-width метод - Встраивание: " + zeroEmbedTime/1000 + " мкс, " +
                "Извлечение: " + zeroExtractTime/1000 + " мкс, " +
                "Корректность: " + result.zeroCorrect);
        System.out.println("Изменения: Space=" + result.spaceChanges + ", Zero=" + result.zeroChanges);
        System.out.println("Обнаружимость: Space=" + result.spaceDetectable + ", Zero=" + result.zeroDetectable);

        return result;
    }

    private static void analyzeResults(List<ExperimentResult> results) {
        System.out.println("\n\n=== СВОДНЫЙ АНАЛИЗ РЕЗУЛЬТАТОВ ===");

        long totalSpaceEmbedTime = 0;
        long totalSpaceExtractTime = 0;
        long totalZeroEmbedTime = 0;
        long totalZeroExtractTime = 0;
        int spaceCorrectCount = 0;
        int zeroCorrectCount = 0;
        int spaceDetectableCount = 0;
        int zeroDetectableCount = 0;
        int spaceChangesTotal = 0;
        int zeroChangesTotal = 0;

        for (ExperimentResult result : results) {
            totalSpaceEmbedTime += result.spaceEmbedTime;
            totalSpaceExtractTime += result.spaceExtractTime;
            totalZeroEmbedTime += result.zeroEmbedTime;
            totalZeroExtractTime += result.zeroExtractTime;
            if (result.spaceCorrect) spaceCorrectCount++;
            if (result.zeroCorrect) zeroCorrectCount++;
            if (result.spaceDetectable) spaceDetectableCount++;
            if (result.zeroDetectable) zeroDetectableCount++;
            spaceChangesTotal += result.spaceChanges;
            zeroChangesTotal += result.zeroChanges;
        }

        int count = results.size();

        System.out.println("\n--- ПРОИЗВОДИТЕЛЬНОСТЬ ---");
        System.out.printf("Space метод - Среднее время встраивания: %.2f мкс\n", totalSpaceEmbedTime / (count * 1000.0));
        System.out.printf("Space метод - Среднее время извлечения: %.2f мкс\n", totalSpaceExtractTime / (count * 1000.0));
        System.out.printf("Zero-width метод - Среднее время встраивания: %.2f мкс\n", totalZeroEmbedTime / (count * 1000.0));
        System.out.printf("Zero-width метод - Среднее время извлечения: %.2f мкс\n", totalZeroExtractTime / (count * 1000.0));

        System.out.println("\n--- НАДЕЖНОСТЬ ---");
        System.out.printf("Space метод - Корректность: %d/%d (%.1f%%)\n",
                spaceCorrectCount, count, (spaceCorrectCount * 100.0 / count));
        System.out.printf("Zero-width метод - Корректность: %d/%d (%.1f%%)\n",
                zeroCorrectCount, count, (zeroCorrectCount * 100.0 / count));

        System.out.println("\n--- СКРЫТНОСТЬ ---");
        System.out.printf("Space метод - Обнаружимость: %d/%d (%.1f%%)\n",
                spaceDetectableCount, count, (spaceDetectableCount * 100.0 / count));
        System.out.printf("Zero-width метод - Обнаружимость: %d/%d (%.1f%%)\n",
                zeroDetectableCount, count, (zeroDetectableCount * 100.0 / count));

        System.out.println("\n--- ИЗМЕНЕНИЯ ---");
        System.out.printf("Space метод - Среднее количество изменений: %.1f\n", spaceChangesTotal / (double)count);
        System.out.printf("Zero-width метод - Среднее количество изменений: %.1f\n", zeroChangesTotal / (double)count);

        System.out.println("\n--- ВЫВОДЫ ---");
        if (totalSpaceEmbedTime < totalZeroEmbedTime) {
            System.out.println("✓ Space метод быстрее при встраивании");
        } else {
            System.out.println("✓ Zero-width метод быстрее при встраивании");
        }

        if (spaceCorrectCount >= zeroCorrectCount) {
            System.out.println("✓ Space метод более надежен");
        } else {
            System.out.println("✓ Zero-width метод более надежен");
        }

        if (spaceDetectableCount <= zeroDetectableCount) {
            System.out.println("✓ Space метод менее обнаружим");
        } else {
            System.out.println("✓ Zero-width метод менее обнаружим");
        }

        System.out.println("\n--- УНИВЕРСАЛЬНОСТЬ ---");
        System.out.println("Space метод: Лучше для текстов с естественным форматированием");
        System.out.println("Zero-width метод: Лучше для сохранения визуального вида текста");
        System.out.println("Оба метода: Поддерживают различные языки и форматы текста");
    }

    static class TestData {
        String text;
        String message;
        String description;

        TestData(String text, String message, String description) {
            this.text = text;
            this.message = message;
            this.description = description;
        }
    }

    static class ExperimentResult {
        String description;
        long spaceEmbedTime;
        long spaceExtractTime;
        long zeroEmbedTime;
        long zeroExtractTime;
        boolean spaceCorrect;
        boolean zeroCorrect;
        int spaceChanges;
        int zeroChanges;
        boolean spaceDetectable;
        boolean zeroDetectable;
        int spaceSize;
        int zeroSize;
        int originalSize;

        ExperimentResult(String description) {
            this.description = description;
        }
    }
}