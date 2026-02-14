import cv2

image_path = r'D:\User\Documents\GitHub\Semester_7\TFDaA\LaboratoryWorks\LBR_01\Solution\LBR_01\static\test_1.jpg'
image = cv2.imread(image_path)

if image is None:
    print("Failed to load image")
    exit()

resized_image = cv2.resize(image, (35, 35))

cv2.imshow('Original image', image)

gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
cv2.imshow('Shades of gray', gray_image)

_, binary_image = cv2.threshold(gray_image, 127, 255, cv2.THRESH_BINARY)
cv2.imshow('Binary image (threshold)', binary_image)

adaptive_binary_image = cv2.adaptiveThreshold(gray_image, 255,
                                              cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
                                              cv2.THRESH_BINARY, 11, 2)
cv2.imshow('Binary image (adaptive)', adaptive_binary_image)

cv2.waitKey(0)
cv2.destroyAllWindows()