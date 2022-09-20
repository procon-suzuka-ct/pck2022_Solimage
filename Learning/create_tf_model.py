import os, json

#機械学習
from keras.models import Model
from keras.layers import Dense, Dropout, GlobalAveragePooling2D
import tensorflow_addons as tfa
from keras.applications.vgg16 import VGG16
from keras.applications.mobilenet_v2 import MobileNetV2
from keras.applications.nasnet import NASNetMobile
from keras.preprocessing.image import ImageDataGenerator
from keras.callbacks import EarlyStopping, ModelCheckpoint
from keras.applications.efficientnet import EfficientNetB0
from keras.optimizers import adam_v2

#classes = len(label_dic)
#y_train = to_categorical(y_train, classes)

dataPath = "image"

basePath = os.path.dirname(os.path.abspath(__file__))
dataPath = os.path.join(basePath, dataPath)

train = ImageDataGenerator(rescale=1./255, # 255で割ることで正規化
                           zoom_range=0.2, # ランダムにズーム
                           horizontal_flip=True, # 水平反転
                           rotation_range=40, # ランダムに回転
                           vertical_flip=True) # 垂直反転
trainGenerator = train.flow_from_directory(dataPath, target_size = (384, 216), batch_size = 32, class_mode = "categorical", shuffle=True)

labels = trainGenerator.class_indices
os.makedirs("./tmp/model", exist_ok=True)
json_file = open("./tmp/labels.json", "w")
json.dump(labels, json_file)
json_file.close()
json_file = open("./tmp/labels_reverse.json", "w")
lebels_reverse = zip(labels.values(), labels.keys())
json.dump(dict(lebels_reverse), json_file)
json_file.close()

#layer構築
base_model = VGG16(
    include_top=False,
    weights='imagenet',
)
x = base_model.output

x = Dropout(0.3)(x)
x = GlobalAveragePooling2D()(x)
x = Dense(512, activation = tfa.activations.rrelu)(x)
predictions = Dense(len(labels), activation="softmax")(x)

#15層目までは再学習しないよう固定する
for layer in base_model.layers[:15]:
  layer.trainable = False

#最適化アルゴリズムのimportと設定
clr = tfa.optimizers.CyclicalLearningRate(initial_learning_rate = 1e-4, maximal_learning_rate = 1e-2, step_size = 2000, scale_fn = lambda x: 1 / (2.0 ** (x - 1)), scale_mode = "cycle")
opt = adam_v2.Adam(clr)

#モデルのコンパイルと詳細出力
model = Model(inputs = base_model.input, outputs = predictions)
model.compile(loss = "categorical_crossentropy", optimizer = opt, metrics = ["accuracy"])
model.summary()

early_stopping = EarlyStopping(monitor = "loss", patience = 10, min_delta = 1e-4)
check_point = ModelCheckpoint("./tmp/model/model.h5", monitor = "loss", save_best_only = True)

#学習
history = model.fit(trainGenerator, epochs = 100, callbacks = [early_stopping, check_point])

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
