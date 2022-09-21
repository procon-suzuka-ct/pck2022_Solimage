import tensorflow as tf
import os
import keras
import tensorflow_addons as tfa

dirPath = "tmp/model"
filename = "model.h5"
modelPath = "model.tflite"
quantize_mode =  'int8'
base = os.path.dirname(os.path.abspath(__file__))
os.makedirs(os.path.join(base, dirPath), exist_ok = True)
filePath = os.path.join(base, filename)
model = keras.models.load_model(filePath, custom_objects = {"rrelu": tfa.activations.rrelu})
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS, tf.lite.OpsSet.SELECT_TF_OPS]
converter.allow_custom_ops = True
tflite_model = converter.convert()
open(os.path.join(base, dirPath, modelPath), "wb").write(tflite_model)
