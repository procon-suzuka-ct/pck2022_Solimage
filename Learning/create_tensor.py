from concurrent import futures
import numpy as np
import cv2, os, csv, pickle

base = os.path.dirname(os.path.abspath(__file__))
imageBase = os.path.join(base, "image")

#data setの基本的な配列
dataset = []

def createDataset(cat, label):
  fileNames = os.listdir(os.path.join(imageBase, cat))
  fileNames = [file for file in fileNames if os.path.isfile(os.path.join(imageBase, cat, file))]
  for file in fileNames:
    path = os.path.join(imageBase, cat, file)
    image = cv2.imread(path)
    dataset.append([image, label])
    del image

categories = os.listdir(imageBase)
categories = [cat for cat in categories if os.path.isdir(os.path.join(imageBase, cat))]
#カテゴリーの辞書を作成
catdic = {i : categories[i] for i in range(0, len(categories))}
#逆辞書を作成
dic = dict(zip(catdic.values(), catdic.keys()))
#マルチスレッド処理(24スレッド)
with futures.ThreadPoolExecutor(max_workers = 24) as executor:
  futureList = []
  for cat in categories:
    future = executor.submit(createDataset, cat = categories, label = dic[cat])
    futureList.append(future)
  
  _ = futures.as_completed(futureList)
  
#dataset
X_train = np.array([data[0] for data in dataset])
os.makedirs("./tmp/dataset", exist_ok=True)

np.save("./tmp/dataset/X_train.npy", X_train)
del X_train
y_train = np.array([data[1] for data in dataset])
np.save("./tmp/dataset/y_train.npy", y_train)
del y_train

#label dic data
with open("./tmp/dataset/label_dic.pickle", "wb") as f:
  pickle.dump(dic, f)

print("finished!")
