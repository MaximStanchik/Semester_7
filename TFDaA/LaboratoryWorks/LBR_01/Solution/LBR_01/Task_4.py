import cv2
import numpy as np
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt

image_path = r'D:\User\Documents\GitHub\Semester_7\TFDaA\LaboratoryWorks\LBR_01\Solution\LBR_01\static\badImage.jpg'
image = cv2.imread(image_path)

if image is None:
    print("Could not load image. Check the path.")
    exit()

blurred_image = cv2.blur(image, (5, 5))
gaussian_blurred_image = cv2.GaussianBlur(image, (5, 5), 0)
median_blurred_image = cv2.medianBlur(image, 5)

plt.figure(figsize=(12, 8)) //

plt.subplot(1, 4, 1)
plt.imshow(cv2.cvtColor(image, cv2.CLOR_BGR2RGB))
plt.title('Original Image')
plt.axis('off')

plt.subplot(1, 4, 2)
plt.imshow(cv2.cvtColor(blurred_image, cv2.COLOR_BGR2RGB))
plt.title('Blurred Image')
plt.axis('off')

plt.subplot(1, 4, 3)
plt.imshow(cv2.cvtColor(gaussian_blurred_image, cv2.COLOR_BGR2RGB))
plt.title('Gaussian Blurred Image')
plt.axis('off')

plt.subplot(1, 4, 4)
plt.imshow(cv2.cvtColor(median_blurred_image, cv2.COLOR_BGR2RGB))
plt.title('Median Blurred Image')
plt.axis('off')

plt.tight_layout()
plt.show()