package org.Stanchik;

import static org.Stanchik.TextSteganography.*;

public class SteganographyApplication
{
    public static void main(String[] args) {
        String englishText = "Exploring the vast mysteries of the universe pushes the boundaries of human knowledge and technological capabilities forward.";
        String russianText = "Цифровизация экономики существенно влияет на рынок труда, создавая одни профессии и заменяя другие.";

        String shortMsg = "hi";
        String mediumMsg = "hello my gg";
        String longMsg = "the quick brown fox jumps over the lazy dog near the river bank yesterday hello i";

        Object[][] experiments = {
                {"Английский", "Короткое", englishText, shortMsg},
                {"Английский", "Среднее", englishText, mediumMsg},
                {"Английский", "Длинное", englishText, longMsg},
                {"Русский", "Короткое", russianText, shortMsg},
                {"Русский", "Среднее", russianText, mediumMsg},
                {"Русский", "Длинное", russianText, longMsg},
        };

        for (Object[] experiment : experiments) {
            String lang = (String) experiment[0];
            String length = (String) experiment[1];
            String text = (String) experiment[2];
            String msg = (String) experiment[3];

            System.out.println("\n--- " + lang + " - " + length + " Сообщение ---");
            System.out.println("Исходный текст: " + text);
            System.out.println("Сообщение: " + msg);

            String spaceStego = embedSpace(text, msg);
            String spaceExtracted = extractSpace(spaceStego);
            int spaceChanges = countChanges(text, spaceStego);
            boolean spaceDetected = detectSpace(spaceStego);

            System.out.println("\nСтеготекст с пробелами (визуально могут быть видны дополнительные пробелы): " + spaceStego);
            System.out.println("Извлечённое из пробелов: " + spaceExtracted);
            System.out.println("Изменения (пробелы): " + spaceChanges);
            System.out.println("Обнаружено (пробелы): " + spaceDetected);

            String zeroStego = embedZero(text, msg);
            String zeroExtracted = extractZero(zeroStego);
            int zeroChanges = countChanges(text, zeroStego);
            boolean zeroDetected = detectZero(zeroStego);

            System.out.println("\nСтеготекст с нулевой шириной (визуально идентичен): " + zeroStego);
            System.out.println("Извлечённое из нулевой ширины: " + zeroExtracted);
            System.out.println("Изменения (нулевая ширина): " + zeroChanges);
            System.out.println("Обнаружено (нулевая ширина): " + zeroDetected);

            System.out.println("\nПроверка корректности:");
            System.out.println("Пробелы: " + msg.equals(spaceExtracted));
            System.out.println("Нулевая ширина: " + msg.equals(zeroExtracted));
        }
    }
}
