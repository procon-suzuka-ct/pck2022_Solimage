import tensorflow as tf
import numpy as np
import matplotlib.pyplot as plt
scale_fn = \
    lambda x: (tf.math.abs(tf.math.cos(x * np.pi / 6) - (tf.math.sin(x * np.pi / 24) * 0.5)) + 1) /\
    (tf.math.sqrt(tf.math.sqrt(tf.math.log(x + 1))) +
     tf.math.sqrt(tf.math.log(x + 1)) + tf.math.abs(tf.sin(x * np.pi / 6)))

x = np.arange(0, 5000, 1.)
y = scale_fn(x)

plt.plot(x, y)
plt.xlabel("steps")
plt.ylabel("learning rate")
plt.show()
