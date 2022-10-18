import matplotlib.pyplot as plt
import os
import json
from statistics import mode

# 機械学習
from keras.models import Model
from keras.layers import Dense, Dropout, Flatten, Input
import numpy as np
import tensorflow_addons as tfa
from keras.applications.vgg16 import VGG16
from keras.applications.mobilenet_v2 import MobileNetV2
from keras.applications.nasnet import NASNetMobile
from keras.preprocessing.image import ImageDataGenerator
from keras.callbacks import EarlyStopping, ModelCheckpoint
from keras.applications.efficientnet import EfficientNetB7
from keras.applications.mobilenet import MobileNet
from keras.optimizers import adam_v2
from keras.models import load_model
import tensorflow as tf
from keras.regularizers import l2

#classes = len(label_dic)
#y_train = to_categorical(y_train, classes)

dataPath = "image"

basePath = os.path.dirname(os.path.abspath(__file__))
dataPath = os.path.join(basePath, dataPath)

train = ImageDataGenerator(rescale=1./255,  # 255で割ることで正規化
                           zoom_range=0.2,  # ランダムにズーム
                           horizontal_flip=True,  # 水平反転
                           rotation_range=40, # ランダムに回転
                           validation_split=0.1,  # 検証用データの割合
                           brightness_range=[0.3, 1.5],)  # ランダムに明るさを変更

trainGenerator = train.flow_from_directory(dataPath, target_size=(
    384, 216), batch_size=32, class_mode="categorical", shuffle=True, subset="training")
valGenerator = train.flow_from_directory(dataPath, target_size=(
    384, 216), batch_size=32, class_mode="categorical", shuffle=True, subset="validation")

labels = trainGenerator.class_indices
os.makedirs("./tmp/model", exist_ok=True)
json_file = open("./tmp/labels.json", "w")
json.dump(labels, json_file)
json_file.close()
json_file = open("./tmp/labels_reverse.json", "w")
lebels_reverse = dict(zip(labels.values(), labels.keys()))
json.dump(lebels_reverse, json_file)
json_file.close()

# layer構築
# base_model = tf.keras.applications.EfficientNetV2L(
#    include_top=True,
#    weights="imagenet",
#    input_tensor=None,
#    input_shape=None,
#    pooling=None,
#    classes=1000,
#    classifier_activation="softmax",
#    include_preprocessing=True,
# )
base_model = VGG16(input_tensor=Input(shape=(384, 216, 3)),include_top=False, weights='imagenet',)
x = base_model.output

x = Dropout(0.5)(x)
x = Flatten()(x)
x = Dense(512, activation=tfa.activations.rrelu, kernel_regularizer=l2(0.01))(x)
# 空間的なグローバルプーリング層を追加する
#x = GlobalAveragePooling2D()(x)
# 全結合層を追加する
#x = Dense(512, activation='relu')(x)
predictions = Dense(len(labels), activation="softmax")(x)

# 15層目までは再学習しないよう固定する
for layer in base_model.layers[:15]:
    layer.trainable = False

# 最適化アルゴリズムのimportと設定


def scale_fn(x): return tf.math.abs(tf.math.cos(x * np.pi / 6) - (tf.math.sin(x * np.pi / 24) * 0.5) + 1) /\
    (tf.math.sqrt(tf.math.sqrt(tf.math.log(x + 1))) +
     tf.math.sqrt(tf.math.log(x + 1)) + tf.math.abs(tf.sin(x * np.pi / 6)))


clr = tfa.optimizers.CyclicalLearningRate(
    initial_learning_rate=1e-4, maximal_learning_rate=1e-2, step_size=1024, scale_fn=scale_fn, scale_mode='cycle')
opt = adam_v2.Adam(lr=1e-4)

# モデルのコンパイルと詳細出力
model = Model(inputs=base_model.input, outputs=predictions)
model.compile(optimizer=opt, loss='categorical_crossentropy',
              metrics=["accuracy"])
model.summary()

early_stopping = EarlyStopping(monitor="val_loss", patience=2, min_delta=0)
check_point = ModelCheckpoint(
    "./tmp/model/model.h5", save_best_only=True, mode="min", monitor='val_loss')

# 学習
history = model.fit(trainGenerator, validation_data=valGenerator,epochs=50, callbacks=[
                    early_stopping, check_point])

del model

print("Learning Finished!")

# 学習結果表示
fig = plt.figure()
ax = fig.add_subplot(1, 2, 1)
ax.plot(history.history['loss'], color='blue')
ax.set_title('Loss')
ax.set_xlabel('Epoch')
ax = fig.add_subplot(1, 2, 2)
ax.plot(history.history['accuracy'], color='red')
ax.set_title('Accuracy')
ax.set_xlabel('Epoch')

plt.show()
plt.savefig("./tmp/model/learning_result.png")
