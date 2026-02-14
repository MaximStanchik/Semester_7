import cv2
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt

image_path = r'D:\User\Documents\GitHub\Semester_7\TFDaA\LaboratoryWorks\LBR_01\Solution\LBR_01\static\prikol.jpg'
image = cv2.imread(image_path)

if image is None:
    print("Failed to load image")
    exit()

gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

plt.figure(figsize=(12, 6))

plt.subplot(1, 2, 1)
plt.hist(gray_image.ravel(), bins=256, range=[0, 256], color='gray')
plt.title('Histogram of original image')
plt.xlim([0, 256])

equalized_image = cv2.equalizeHist(gray_image)

plt.subplot(1, 2, 2)
plt.hist(equalized_image.ravel(), bins=256, range=[0, 256], color='gray')
plt.title('Histogram of the equalized image')
plt.xlim([0, 256])

plt.tight_layout()
plt.show()

cv2.imshow('Original image', gray_image)
cv2.imshow('Aligned image', equalized_image)

cv2.waitKey(0)
cv2.destroyAllWindows()