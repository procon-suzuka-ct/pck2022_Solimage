from tkinter import filedialog
import keras
import PySimpleGUI as sg
import tensorflow_addons as tfa
from keras.preprocessing import image
import numpy as np
import os
import tensorflow as tf

model = keras.models.load_model("./model.h5", custom_objects={"rrelu": tfa.activations.rrelu})
layout = [[sg.Text("フォルダを選択してください", key="file"), sg.Button("ファイル選択")],
          [sg.Button("実行")]]

def load_image(img_path):
  
  img = tf.keras.utils.load_img(img_path, target_size=(384, 216, 3))
  img_tensor = tf.keras.utils.img_to_array(img)                    # (height, width, channels)
  img_tensor = np.expand_dims(img_tensor, axis=0)         # (1, height, width, channels), add a dimension because the model expects this shape: (batch_size, height, width, channels)
  img_tensor /= 255.                                      # imshow expects values in the range [0, 1]
  return img_tensor
  
def sel_file():
  fTyp = [("", "*")]
  iFile = os.path.abspath(os.path.dirname(__file__))
  iFilePath = filedialog.askopenfilename(filetype = fTyp, initialdir = iFile)
  return iFilePath

def main():
  window = sg.Window("モデルチェック", layout)
  f: str
  while True:
    event, _ = window.read()
    if event == sg.WIN_CLOSED:
      break
    if event == "ファイル選択":
      f = sel_file()
      window["file"].update(f)
      continue
    if event == "実行":
      if f is None:
        continue
      # predicting images
      img = load_image(f)
      pred = model.predict(img)
      print(pred)
      y_classes = pred.argmax()
      sg.popup(pred)

main()
