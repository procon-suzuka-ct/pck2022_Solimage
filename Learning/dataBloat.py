from concurrent import futures
import cv2
import os

filename = "datalist.csv"
base = os.path.dirname(os.path.abspath(__file__))
filename = os.path.join(base, filename)
imageBase = os.path.join(base, "image")

def flip(image):
  flipped = []
  flipped.append(cv2.flip(image, 1))
  flipped.append(cv2.flip(image, 0))
  flipped.append((image))
  return flipped

def change_Value(images : list):
  changed_images = []
  for i in range(0, 2):
    for image in images:
      img_hsv = cv2.cvtColor(image,cv2.COLOR_BGR2HSV)
      img_hsv[:,:,2] = img_hsv[:,:,2] * ((i + 2) / 3)
      img = cv2.cvtColor(img_hsv,cv2.COLOR_HSV2BGR)
      changed_images.append(img)
  return changed_images

def change_Saturatio(images : list):
  changed_images = []
  for i in range(0, 2):
    for image in images:
      img_hsv = cv2.cvtColor(image,cv2.COLOR_BGR2HSV)
      img_hsv[:,:,1] = img_hsv[:,:,1] * ((i + 2) / 3)
      img = cv2.cvtColor(img_hsv,cv2.COLOR_HSV2BGR)
      changed_images.append(img)
  return changed_images

def process(cat : str):
  fileNames = os.listdir(os.path.join(imageBase, cat))
  fileNames = [file for file in fileNames if os.path.isfile(os.path.join(imageBase, cat, file))]
  for file in fileNames:
    root = "image"
    loadfile = file + ".png"
    path = os.path.join(base, root, cat, loadfile)
    writeRootPath = "Bloated"
    writePath = os.path.join(base, writeRootPath, cat)
    os.makedirs(writePath, exist_ok=True)
    writePath = os.path.join(base, writeRootPath, cat, file)
    image = cv2.imread(path)
    WIDTH = 216
    HEIGHT = 384
    image = cv2.resize(image, (WIDTH, HEIGHT))
    images = flip(image)
    images = change_Value(images)
    images = change_Saturatio(images)
    for i in range(0, len(images)):
      cv2.imwrite(writePath + str(i) + ".png", images[i])


def main():
  categories = os.listdir(imageBase)
  categories = [dir for dir in categories if os.path.isdir(os.path.join(imageBase, dir))]
  with futures.ThreadPoolExecutor(max_workers = 24) as executor:
    futureList = []
    for cat in categories:
      future = executor.submit(process, cat)
      futureList.append(future)
    _ = futures.as_completed(futureList)
  return

if __name__ == '__main__':
  main()
