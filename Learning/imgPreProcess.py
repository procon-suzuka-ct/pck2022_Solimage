import cv2 as cv
import numpy as np
import os
from concurrent import futures

basePath = os.path.dirname(os.path.abspath(__file__))
imagesFolder = os.path.join(basePath, "image")


def process(cat: str):
  print(cat)
  catPath = os.path.join(imagesFolder, cat)
  fileNames = os.listdir(os.path.join(imagesFolder, cat))
  fileNames = [file for file in fileNames if os.path.isfile(
    os.path.join(imagesFolder, cat, file))]
  writeRoot = "Croped"
  #writeRoot = "Resized"
  writeDir = os.path.join(basePath, writeRoot, cat)
  os.makedirs(writeDir, exist_ok=True)
  WIDTH = 216
  HEIGHT = 384
  for file in fileNames:
    imagePath = os.path.join(catPath, file)
    writePath = os.path.join(writeDir, file)
    
    # Read image
    image = cv.imread(imagePath, cv.IMREAD_COLOR)
    
    # Resize image
    width = image.shape[1]
    height = image.shape[0]
    resizeRatio = max(WIDTH / width, HEIGHT / height)
    image = cv.resize(image,dsize=None, fx=resizeRatio, fy=resizeRatio)
    
    # Crop image
    width = image.shape[1]
    height = image.shape[0]
    center = [int(width / 2), int(height / 2)]
    left = center[0] - int(WIDTH / 2)
    right = center[0] + int(WIDTH / 2)
    top = center[1] - int(HEIGHT / 2)
    bottom = center[1] + int(HEIGHT / 2)
    
    croped = image[top:bottom, left:right]
    cv.imwrite(writePath, croped)

def main():
  categories = os.listdir(imagesFolder)
  categories = [cat for cat in categories if os.path.isdir(
    os.path.join(imagesFolder, cat))]

  with futures.ProcessPoolExecutor(max_workers=12) as executor:
    futureList = []
    for cat in categories:
      future = executor.submit(process, cat)
      futureList.append(future)
      
    _ = futures.as_completed(futureList)


if __name__ == "__main__":
  main()
