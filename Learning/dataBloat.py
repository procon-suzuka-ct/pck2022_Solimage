import numpy as np
import cv2
import os, csv

filename = "datalist.csv"
base = os.path.dirname(os.path.abspath(__file__))
filename = os.path.join(base, filename)

def rotate(image):
  images = []
  for i in range(0, 4):
    images.append(np.rot90(image, i))
  
  return images

def flip(images : list):
  flipped = []
  for image in images:
    flipped.append(cv2.flip(image, 1))
    flipped.append(cv2.flip(image, -1))
    flipped.append((image))
  return flipped

def main():
  with open(filename, 'r') as f:
    reader = csv.reader(f)
    fileList = [row for row in reader]
    fileNum = (int)(fileList[0][0])
    categories = fileList[1]
    fileNames = fileList[2]

    for cat in categories:
      for file in fileNames:
        root = "image"
        path = os.path.join(base, root, cat, file)
        writeRootPath = "Bloated"
        writePath = os.path.join(base, writeRootPath, cat, file)
        image = cv2.imread(path)
        images = rotate(image)
        images = flip(images)
        for i in range(0, len(images)):
          cv2.imwrite(writePath + str(i) + ".png", images[i])
  return

if __name__ == '__main__':
  main()
