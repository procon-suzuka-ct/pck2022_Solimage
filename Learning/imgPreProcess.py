import cv2 as cv
import numpy as np
import os
from concurrent import futures

basePath = os.path.dirname(os.path.abspath(__file__))
imagesFolder = os.path.join(basePath, "image")


def process(cat: str):
    catPath = os.path.join(imagesFolder, cat)
    fileNames = os.listdir(os.path.join(imagesFolder, cat))
    fileNames = [file for file in fileNames if os.path.isfile(
        os.path.join(imagesFolder, cat, file))]
    WIDTH = 216
    HEIGHT = 384
    for file in fileNames:
        imagePath = os.path.join(catPath, file)
        writeRoot = "Croped"
        writeDir = os.path.join(basePath, writeRoot, cat)
        writePath = os.path.join(writeDir, file)

        image = cv.imread(imagePath)
        width = image.shape[1]
        height = image.shape[0]
        resizeRatio = min(WIDTH / width, HEIGHT / height)
        image = cv.resize(image, (int(width * resizeRatio),
                          int(height * resizeRatio)))
        center = [int(height / 2), int(width / 2)]
        left = center[1] - int(WIDTH / 2)
        right = center[1] + int(WIDTH / 2)
        top = center[0] - int(HEIGHT / 2)
        bottom = center[0] + int(HEIGHT / 2)
        cropedImage = image[top:bottom, left:right]
        cv.imwrite(writePath, cropedImage)


def main():
    categories = os.listdir(imagesFolder)
    categories = [cat for cat in categories if os.path.isdir(
        os.path.join(imagesFolder, cat))]

    with futures.ProcessPoolExecutor(max_workers=24) as executor:
        futureList = []
        for cat in categories:
            futureList.append(executor.submit(process, cat))

        _ = futures.as_completed(futureList)
    return


if __name__ == "__main__":
    main()
