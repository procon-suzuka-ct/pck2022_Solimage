import tensorflow as tf

converter = tf.lite.TFLiteConverter.from_saved_model("./tmp/model/model.h5")
tflite_model = converter.convert()
open("./tmp/model/model.tflite", "wb").write(tflite_model)
