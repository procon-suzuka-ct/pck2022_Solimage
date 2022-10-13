import matplotlib.pyplot as plt, os, json, numpy as np

# 機械学習
from keras.models import Model
from keras.layers import Dense, Dropout, Flatten, Input
import tensorflow_addons as tfa
from keras.applications.vgg16 import VGG16
from keras.preprocessing.image import ImageDataGenerator
from keras.callbacks import EarlyStopping, ModelCheckpoint
from keras.optimizers import adam_v2

dataPath = "image"

basePath = os.path.dirname(os.path.abspath(__file__))
dataPath = os.path.join(basePath, dataPath)

train = ImageDataGenerator(rescale=1./255,  # 255で割ることで正規化
                           zoom_range=0.2,  # ランダムにズーム
                           horizontal_flip=True,  # 水平反転
                           rotation_range=40, # ランダムに回転
                           validation_split=0.1)  # 検証用データの割合
trainGenerator = train.flow_from_directory(dataPath, target_size=(
    384, 216), batch_size=16, class_mode="categorical", shuffle=True, subset="training")
valGenerator = train.flow_from_directory(dataPath, target_size=(
    384, 216), batch_size=16, class_mode="categorical", shuffle=True, subset="validation")

labels = trainGenerator.class_indices
os.makedirs("./tmp/model", exist_ok=True)
json_file = open("./tmp/multi_labels.json", "w")
json.dump(labels, json_file)
json_file.close()
json_file = open("./tmp/multi_labels_reverse.json", "w")
lebels_reverse = dict(zip(labels.values(), labels.keys()))
json.dump(lebels_reverse, json_file)
json_file.close()

# layer構築
# VGG16をベースにsigmoidを使って多ラベル分類
baseModel = VGG16(weights="imagenet",
                  include_top=False,
                  input_tensor=Input(shape=(216, 384, 3)),
                  classifier_activation='sigmoid',)

# 15層目まで重みを固定
for layer in baseModel.layers[:15]:
  layer.trainable = False

# 出力層
x = baseModel.output
x = Dropout(0.5)(x)
x = Flatten()(x)
x = Dense(512, activation=tfa.activations.rrelu)(x)
pridection = Dense(len(labels), activation="sigmoid")(x)

model = Model(inputs=baseModel.input, outputs=pridection)

# 多ラベル分類で設定
model.compile(optimizer=adam_v2.Adam(learning_rate=0.0001), loss="binary_crossentropy",
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
