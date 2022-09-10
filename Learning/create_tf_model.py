import pickle, os, numpy as np, cv2

#data setの読み込み
x_train = np.load("./tmp/dataset/X_train.npy")
y_train = np.load("./tmp/dataset/y_train.npy")

label_dic : dict
with open("./tmp/dataset/label_dic.pickle", "rb") as f:
  label_dic = pickle.load(f)

label_dic = label_dic.items()

#機械学習
import tensorflow as tf
from keras.utils import to_categorical
from keras.models import Sequential
from keras.layers import Dense, Dropout, Flatten
import tensorflow_addons as tfa
from keras.applications.vgg16 import VGG16
from keras.preprocessing.image import ImageDataGenerator

classes = len(label_dic)
y_train = to_categorical(y_train, classes)

dataPath = "./image"

train = ImageDataGenerator(rescale = 1.0/255.0)
trainGenerator = train.flow_from_directory(dataPath, target_size = (216, 384), batch_size = 64, class_mode = "categorical")

#layer 構築
shape = x_train.shape[1:]

#VGG16の特徴検出の出力層を消してimport
vgg16 = VGG16(input_shape = shape, include_top = False, weights = "imagenet")
model = Sequential(vgg16.layers)

#15層目までは再学習しないよう固定する
for layer in model.layers[:15]:
  layer.trainable = False

#出力層を追加
model.add(Flatten())
model.add(Dense(1024, activation = tfa.activations.rrelu))
model.add(Dropout(0.5))
model.add(Dense(classes, activation = tfa.activations.sparsemax))

#最適化アルゴリズムのimportと設定
opt = tf.keras.optimizers.Adam(lr = 1e-4, decay = 1e-6, amsgrad = True)

#モデルのコンパイルと詳細出力
model.compile(loss = "categorical_crossentropy", optimizer = opt, metrics = ["accuracy"])
model.summary()

#学習
history = model.fit(trainGenerator, epochs = 400)

#学習結果表示
import matplotlib.pyplot as plt
fig = plt.figure()
ax = fig.add_subplot(1, 2, 1)
ax.plot(history.history['loss'], color='blue')
ax.set_title('Loss')
ax.set_xlabel('Epoch')
ax = fig.add_subplot(1, 2, 2)
ax.plot(history.history['accuracy'], color='red')
ax.set_title('Accuracy')
ax.set_xlabel('Epoch')
print("Learning Finished!")

plt.show()

#モデルの保存
os.makeirs("./tmp/model", exist_ok=True)
model.save("./tmp/model/model.h5")
