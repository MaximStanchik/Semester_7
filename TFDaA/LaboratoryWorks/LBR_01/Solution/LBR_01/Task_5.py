import cv2
import numpy as np
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt

image_path = r'D:\User\Documents\GitHub\Semester_7\TFDaA\LaboratoryWorks\LBR_01\Solution\LBR_01\static\subjectsOnList.jpg'
image = cv2.imread(image_path)

if image is None:
    print("Could not load image. Check the path.")
    exit()

gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

_, binary_image = cv2.threshold(gray_image, 127, 255, cv2.THRESH_BINARY)

kernel = np.ones((2, 2), np.uint8)
eroded_image = cv2.erode(binary_image, kernel, iterations=1)

dilated_image = cv2.dilate(binary_image, kernel, iterations=1)

plt.figure(figsize=(12, 6))

plt.subplot(1, 3, 1)
plt.imshow(binary_image, cmap='gray')
plt.title('Binary Image')
plt.axis('off')

plt.subplot(1, 3, 2)
plt.imshow(eroded_image, cmap='gray')
plt.title('Erosion')
plt.axis('off')

plt.subplot(1, 3, 3)
plt.imshow(dilated_image, cmap='gray')
plt.title('Dilation')
plt.axis('off')

plt.tight_layout()
plt.show()