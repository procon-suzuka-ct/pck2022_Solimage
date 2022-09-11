import pickle, os, numpy as np, cv2

#機械学習
import tensorflow as tf
from keras.models import Model
from keras.layers import Dense, Dropout, GlobalAveragePooling2D, Conv2D, Add
import tensorflow_addons as tfa
from keras.applications.vgg16 import VGG16
from keras.preprocessing.image import ImageDataGenerator
from keras.callbacks import EarlyStopping
from keras.optimizers import Adam

#classes = len(label_dic)
#y_train = to_categorical(y_train, classes)

dataPath = "image"

basePath = os.path.dirname(os.path.abspath(__file__))
dataPath = os.path.join(basePath, dataPath)

train = ImageDataGenerator(rescale = 1.0/255.0, rotation_range=90, horizontal_flip=True)
trainGenerator = train.flow_from_directory(dataPath, target_size = (216, 384), batch_size = 64, class_mode = "categorical", shuffle=True)

labels = trainGenerator.class_indices

#VGG16の出力層を消してimport
vgg16 = VGG16(include_top = False, weights = "imagenet")
x = vgg16.output

c_1 = Conv2D(filters=512, kernel_size = (3, 3), activation = tfa.activations.rrelu)(x)
c_2 = Conv2D(filters=512, kernel_size = (5, 5), activation = tfa.activations.rrelu)(x)
c_3 = Conv2D(filters=512, kernel_size = (7, 7), activation = tfa.activations.rrelu)(x)
x = Add()([c_1, c_2, c_3])
x = GlobalAveragePooling2D()(x)
x = Dense(512, activation = tfa.activations.rrelu)(x)
x = Dropout(0.5)(x)
x = Dense(256, activation = tfa.activations.rrelu)(x)
x = Dropout(0.3)(x)
predictions = Dense(len(labels), activation=tfa.activations.sparsemax)(x)

#15層目までは再学習しないよう固定する
for layer in vgg16.layers[:15]:
  layer.trainable = False

#最適化アルゴリズムのimportと設定
opt = Adam(lr = 1e-4, decay = 1e-6, amsgrad = True)

model = Model(inputs = vgg16.input, outputs = predictions)

#モデルのコンパイルと詳細出力
model.compile(loss = "categorical_crossentropy", optimizer = opt, metrics = ["accuracy"])
model.summary()

early_stopping = EarlyStopping(monitor = "val_loss", patience = 10, min_delta = 1e-3)
#学習
history = model.fit_generator(trainGenerator, epochs = 400, callbacks = [early_stopping])

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
