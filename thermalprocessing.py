import cv2
#137, 173 ; 266,236
#2/4th 1/2 to reach face
img = cv2.imread("thermal-image-human-face.jpg")
blur_image = cv2.GaussianBlur(img, (15,15), 0)
cv2.imshow('Original Image', img)
cv2.imshow('Blur Image', blur_image)
cv2.waitKey(0)