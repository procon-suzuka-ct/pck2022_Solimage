import numpy as np
import cv2
import os, csv

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

  return

if __name__ == '__main__':
  main()
