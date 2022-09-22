import tensorflow as tf
import os
from keras.models import load_model
import tensorflow_addons as tfa

dirPath = "tmp/model"
filename = "model.h5"
modelPath = "model.tflite"
quantize_mode =  'int8'
base = os.path.dirname(os.path.abspath(__file__))
os.makedirs(os.path.join(base, dirPath), exist_ok = True)
filePath = os.path.join(base, filename)
model = load_model(filePath, custom_objects = {"rrelu": tfa.activations.rrelu})
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()
open(os.path.join(base, dirPath, modelPath), "wb").write(tflite_model)
