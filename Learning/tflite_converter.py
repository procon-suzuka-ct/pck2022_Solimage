import tensorflow as tf
import os
from keras.models import load_model
from keras.preprocessing.image import ImageDataGenerator
import tensorflow_addons as tfa

dirPath = "tmp/model"
filename = "model.h5"
modelPath = "model.tflite"
quantize_mode = 'int8'
base = os.path.dirname(os.path.abspath(__file__))
os.makedirs(os.path.join(base, dirPath), exist_ok=True)
filePath = os.path.join(base, filename)
model = load_model(filePath, custom_objects={"rrelu": tfa.activations.rrelu})

dataPath = "image"

basePath = os.path.dirname(os.path.abspath(__file__))
dataPath = os.path.join(basePath, dataPath)

generator = ImageDataGenerator(rescale=1./255,  # 255で割ることで正規化
                               zoom_range=0.2,  # ランダムにズーム
                               horizontal_flip=True,  # 水平反転
                               rotation_range=40,)  # ランダムに回転

valGen = generator.flow_from_directory(dataPath, target_size=(
    384, 216), batch_size=16, class_mode="categorical", shuffle=True)


def representative_dataset_gen():
    for i in range(300):
        yield [valGen.next()[0]]


converter = tf.lite.TFLiteConverter.from_keras_model(model)
# quantize
#converter.optimizations = [tf.lite.Optimize.DEFAULT]
#converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
#converter.inference_input_type = tf.int8
#converter.inference_output_type = tf.int8
#converter.optimizations = [tf.lite.Optimize.DEFAULT]
#converter.target_spec.supported_types = [tf.float16]

converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.representative_dataset = representative_dataset_gen
# Ensure that if any ops can't be quantized, the converter throws an error
converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
# Set the input and output tensors to uint8 (APIs added in r2.3)
converter.inference_input_type = tf.uint8
converter.inference_output_type = tf.uint8

tflite_model = converter.convert()
open(os.path.join(base, dirPath, modelPath), "wb").write(tflite_model)