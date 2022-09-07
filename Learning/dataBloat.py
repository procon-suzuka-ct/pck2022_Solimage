from concurrent import futures
import numpy as np
import cv2
import os, csv

filename = "datalist.csv"
base = os.path.dirname(os.path.abspath(__file__))
filename = os.path.join(base, filename)

def rotate(image):
  images = []
  images.append(image)
  images.append(np.rot90(image, 2))
  
  return images

def flip(images : list):
  flipped = []
  for image in images:
    flipped.append(cv2.flip(image, 1))
    flipped.append(cv2.flip(image, -1))
    flipped.append((image))
  return flipped

def change_Value(images : list):
  changed_images = []
  for i in range(0, 4):
    for image in images:
      img_hsv = cv2.cvtColor(image,cv2.COLOR_BGR2HSV)
      img_hsv[:,:,2] = img_hsv[:,:,2] * ((i + 1) / 4)
      img = cv2.cvtColor(img_hsv,cv2.COLOR_HSV2BGR)
      changed_images.append(img)
  return changed_images

def change_Saturatio(images : list):
  changed_images = []
  for i in range(0, 4):
    for image in images:
      img_hsv = cv2.cvtColor(image,cv2.COLOR_BGR2HSV)
      img_hsv[:,:,1] = img_hsv[:,:,1] * ((i + 1) / 4)
      img = cv2.cvtColor(img_hsv,cv2.COLOR_HSV2BGR)
      changed_images.append(img)
  return changed_images

def process(cat : str, fileNames : list):
  for file in fileNames:
    root = "image"
    loadfile = file + ".png"
    path = os.path.join(base, root, cat, loadfile)
    writeRootPath = "Bloated"
    writePath = os.path.join(base, writeRootPath, cat)
    os.makedirs(writePath, exist_ok=True)
    writePath = os.path.join(base, writeRootPath, cat, file)
    image = cv2.imread(path)
    images = rotate(image)
    images = flip(images)
    images = change_Value(images)
    images = change_Saturatio(images)
    for i in range(0, len(images)):
      cv2.imwrite(writePath + str(i) + ".png", images[i])


def main():
  with open(filename, 'r') as f:
    reader = csv.reader(f)
    fileList = [row for row in reader]
    fileNum = (int)(fileList[0][0])
    categories = fileList[1]
    fileNames = fileList[2]

    with futures.ThreadPoolExecutor(max_workers = 24) as executor:
      futureList = []
      for cat in categories:
        future = executor.submit(process, cat, fileNames)
        futureList.append(future)

      _ = futures.as_completed(futureList)
  return

if __name__ == '__main__':
  main()
