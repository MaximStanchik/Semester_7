package org.Stanchik;


import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import java.util.Random;

public class TextSteganography {

    private static final char ZW_SPACE = '\u200B';
    private static final char ZW_NON_JOINER = '\u200C';

    public static String textToBin(String text) {
        StringBuilder binary = new StringBuilder();
        for (char c : text.toCharArray()) {
            String binChar = String.format("%8s", Integer.toBinaryString(c)).replace(' ', '0');
            binary.append(binChar);
        }
        return binary.toString();
    }

    public static String binToText(String binary) {
        if (binary.length() % 8 != 0) {
            System.out.println("Предупреждение: Длина бинарной строки не кратна 8, может быть усечена.");
        }

        StringBuilder text = new StringBuilder();
        for (int i = 0; i < binary.length(); i += 8) {
            if (i + 8 <= binary.length()) {
                String byteStr = binary.substring(i, i + 8);
                int charCode = Integer.parseInt(byteStr, 2);
                text.append((char) charCode);
            }
        }
        return text.toString();
    }

    public static String embedSpace(String originalText, String message) {
        String binary = textToBin(message);
        String[] words = originalText.split(" ");
        int numIntervalsNeeded = binary.length();

        if (words.length - 1 < numIntervalsNeeded) {
            int repeats = (int) Math.ceil((double) (numIntervalsNeeded + 1) / words.length);
            List<String> repeatedWords = new ArrayList<String>();
            for (int i = 0; i < repeats; i++) {
                repeatedWords.addAll(Arrays.asList(words));
            }
            words = repeatedWords.toArray(new String[0]);
        }

        words = Arrays.copyOf(words, numIntervalsNeeded + 1);

        StringBuilder stego = new StringBuilder(words[0]);
        for (int i = 0; i < binary.length(); i++) {
            char bit = binary.charAt(i);
            if (bit == '0') {
                stego.append(" ").append(words[i + 1]);
            } else {
                stego.append("  ").append(words[i + 1]);
            }
        }
        return stego.toString();
    }

    public static String extractSpace(String stegoText) {
        StringBuilder binary = new StringBuilder();
        boolean inSpace = false;
        int spaceCount = 0;

        for (int i = 0; i < stegoText.length(); i++) {
            char c = stegoText.charAt(i);
            if (Character.isWhitespace(c)) {
                if (!inSpace) {
                    inSpace = true;
                    spaceCount = 1;
                } else {
                    spaceCount++;
                }
            } else {
                if (inSpace) {
                    if (spaceCount == 1) {
                        binary.append('0');
                    } else if (spaceCount >= 2) {
                        binary.append('1');
                    }
                    inSpace = false;
                    spaceCount = 0;
                }
            }
        }

        if (inSpace) {
            if (spaceCount == 1) {
                binary.append('0');
            } else if (spaceCount >= 2) {
                binary.append('1');
            }
        }

        return binToText(binary.toString());
    }

    public static String embedZero(String originalText, String message) {
        String binary = textToBin(message);
        StringBuilder hidden = new StringBuilder();

        for (char b : binary.toCharArray()) {
            hidden.append(b == '0' ? ZW_SPACE : ZW_NON_JOINER);
        }

        return originalText + hidden.toString();
    }

    public static String extractZero(String stegoText) {
        StringBuilder binary = new StringBuilder();

        for (char c : stegoText.toCharArray()) {
            if (c == ZW_SPACE) {
                binary.append('0');
            } else if (c == ZW_NON_JOINER) {
                binary.append('1');
            }
        }

        return binToText(binary.toString());
    }

    public static boolean detectSpace(String stegoText) {
        return stegoText.contains("  ");
    }

    public static boolean detectZero(String stegoText) {
        for (char c : stegoText.toCharArray()) {
            if (c == ZW_SPACE || c == ZW_NON_JOINER) {
                return true;
            }
        }
        return false;
    }

    public static int countChanges(String original, String stego) {
        int changes = 0;
        int minLength = Math.min(original.length(), stego.length());

        for (int i = 0; i < minLength; i++) {
            if (original.charAt(i) != stego.charAt(i)) {
                changes++;
            }
        }

        changes += Math.abs(original.length() - stego.length());
        return changes;
    }

    // Новые методы для анализа производительности
    public static long measureEmbedSpaceTime(String text, String message) {
        long startTime = System.nanoTime();
        embedSpace(text, message);
        return System.nanoTime() - startTime;
    }

    public static long measureExtractSpaceTime(String stegoText) {
        long startTime = System.nanoTime();
        extractSpace(stegoText);
        return System.nanoTime() - startTime;
    }

    public static long measureEmbedZeroTime(String text, String message) {
        long startTime = System.nanoTime();
        embedZero(text, message);
        return System.nanoTime() - startTime;
    }

    public static long measureExtractZeroTime(String stegoText) {
        long startTime = System.nanoTime();
        extractZero(stegoText);
        return System.nanoTime() - startTime;
    }

    public static String generateRandomText(int wordCount) {
        String[] words = {"the", "quick", "brown", "fox", "jumps", "over", "lazy", "dog",
                "hello", "world", "java", "programming", "text", "analysis",
                "стеганография", "метод", "анализ", "производительность",
                "универсальность", "сравнение", "эксперимент", "результат"};
        Random random = new Random();
        StringBuilder text = new StringBuilder();

        for (int i = 0; i < wordCount; i++) {
            text.append(words[random.nextInt(words.length)]).append(" ");
        }
        return text.toString().trim();
    }
}