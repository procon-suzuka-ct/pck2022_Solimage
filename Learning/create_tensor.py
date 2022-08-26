from concurrent import futures
import numpy as np
import cv2, os, csv, pickle

filename = "datalist.csv"
base = os.path.dirname(os.path.abspath(__file__))
filename = os.path.join(base, filename)

#data setの基本的な配列
dataset = []

def createDataset(path, label):
  image = cv2.imread(path)
  dataset.append([image, label])

def main():
  with open(filename, 'r') as f:
    reader = csv.reader(f)
    fileList = [row for row in reader]
    fileNum = 64
    categories = fileList[1]
    fileNames = fileList[2]

    #カテゴリーの辞書を作成
    catdic = {i : categories[i] for i in range(0, len(categories))}
    #逆辞書を作成
    dic = dict(zip(catdic.values(), catdic.keys()))

    #パスのリストを作成
    paths = []

    for cat in categories:
      for file in fileNames:
        root = "Bloated"
        for i in range(0, fileNum):
          filepath = file + str(i)
          path = os.path.join(base, root, cat, filepath)
          paths.append(path)

    #マルチスレッド処理(24スレッド)
    with futures.ThreadPoolExecutor(max_workers = 24) as executor:
      futureList = []
      for path in paths:
        future = executor.submit(createDataset, path = path, label = dic[os.path.dirname(path)])
        futureList.append(future)
      
      _ = futures.as_completed(futureList)
    
  #dataset
  X_train = np.array([data[0] for data in dataset])
  y_train = np.array([data[1] for data in dataset])

  os.makedirs("./tmp/dataset", exist_ok=True)
  np.save("./tmp/dataset/X_train.npy", X_train)
  np.save("./tmp/dataset/y_train.npy", y_train)

  #label dic data
  with open("./tmp/dataset/label_dic.pickle", "wb") as f:
    pickle.dump(dic, f)
  return

if __name__ == "__main__":
  main()
  print("finish")
  exit()
