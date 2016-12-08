'''Trains a simple convnet on the MNIST dataset.
Gets to 99.25% test accuracy after 12 epochs
(there is still a lot of margin for parameter tuning).
16 seconds per epoch on a GRID K520 GPU.
'''

from __future__ import print_function
import numpy as np
np.random.seed(1337)  # for reproducibility

from keras.datasets import mnist
from keras.models import Sequential
from keras.layers import Dense, Dropout, Activation, Flatten
from keras.layers import Convolution2D, MaxPooling2D
from keras.utils import np_utils
from keras import backend as K
batch_size = 200
nb_classes = 10
nb_epoch = 1299

# input image dimensions
# number of convolutional filters to use
nb_filters = 100
# size of pooling area for max pooling
pool_size = (2, 2)
# convolution kernel size
kernel_size = (3, 3)

# the data, shuffled and split between train and test sets
(X_train, y_train) ,(X_test, y_test) = mnist.load_data()
img_dim =1# X_train.shape[1]
img_rows, img_cols = X_train.shape[1], X_train.shape[2]

if K.image_dim_ordering() == 'th':
    X_train = X_train.reshape(X_train.shape[0], img_dim, img_rows, img_cols)
    X_test = X_test.reshape(X_test.shape[0], img_dim, img_rows, img_cols)
    input_shape = (img_dim, img_rows, img_cols)
else:
    X_train = X_train.reshape(X_train.shape[0], img_rows, img_cols, img_dim)
    X_test = X_test.reshape(X_test.shape[0], img_rows, img_cols, img_dim)
    input_shape = (img_rows, img_cols, img_dim)

X_train = X_train.astype('float32')
X_test = X_test.astype('float32')
X_train /= 255
X_test /= 255
print('X_train shape:', X_train.shape)
print(X_train.shape[0], 'train samples')
print(X_test.shape[0], 'test samples')

# convert class vectors to binary class matrices
Y_train = np_utils.to_categorical(y_train, nb_classes)
Y_test = np_utils.to_categorical(y_test, nb_classes)

model = Sequential()

model.add(Convolution2D(nb_filters, 5, 1,
                        border_mode='same',
                        input_shape=input_shape))
model.add(Activation('relu'))
model.add(Convolution2D(nb_filters, 1, 5,
                        border_mode='same'))
model.add(Activation('relu'))
model.add(MaxPooling2D(pool_size=pool_size))
model.add(Convolution2D(nb_filters, 5, 1,
                        border_mode='same'))
model.add(Activation('relu'))
model.add(Convolution2D(nb_filters, 1, 5,
                        border_mode='same'))
model.add(Activation('relu'))
model.add(MaxPooling2D(pool_size=pool_size))
model.add(Flatten())
model.add(Dense(128))
model.add(Activation('relu'))
model.add(Dropout(0.5))
model.add(Dense(nb_classes))
model.add(Activation('softmax'))

model.compile(loss='categorical_crossentropy',
              optimizer='adadelta',
              metrics=['accuracy'])

model.summary()
model.fit(X_train, Y_train, batch_size=batch_size, nb_epoch=nb_epoch,
          verbose=2, validation_data=(X_test, Y_test))
score = model.evaluate(X_test, Y_test, verbose=0)
print('Test score:', score[0])
print('Test accuracy:', score[1])

"""
from pyprocessing import *
arc(50, 55, 50, 50, 0, PI/2);
noFill();
arc(50, 55, 60, 60, PI/2, PI);
arc(50, 55, 70, 70, PI, TWO_PI-PI/2);
arc(50, 55, 80, 80, TWO_PI-PI/2, TWO_PI);

run()"""
