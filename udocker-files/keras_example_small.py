import numpy as np
import keras as K
import tensorflow as tf

np.random.seed(123)  # for reproducibility
from keras.models import Sequential
from keras.layers import Dense, Dropout, Activation, Flatten
from keras.layers import Convolution2D, MaxPooling2D
from keras.utils import np_utils
from keras.datasets import mnist
from keras import optimizers

(X_train, y_train), (X_test, y_test) = mnist.load_data()

X_train = X_train.reshape(X_train.shape[0], 28, 28,1)
X_test = X_test.reshape(X_test.shape[0], 28, 28,1)
X_train = X_train.astype('float32')
X_test = X_test.astype('float32')
X_train /= 255
X_test /= 255
Y_train = np_utils.to_categorical(y_train, 10)
Y_test = np_utils.to_categorical(y_test, 10)
model = Sequential()
model.add(Convolution2D(48, 8, 8, activation='elu', input_shape=(28,28,1)))
model.add(MaxPooling2D(pool_size=(3,3)))
model.add(Dropout(0.5))
model.add(Flatten())
model.add(Dense(96, activation='elu')) #32 original
model.add(Dropout(0.5)) #original 0.5
model.add(Dense(10,activation='softmax'))
model.compile(loss='categorical_crossentropy',optimizer='nadam',metrics=['accuracy'])
model.summary()
model.fit(X_train, Y_train,batch_size=100, epochs=5, verbose=1)
print(model.evaluate(X_test, Y_test, verbose=1))

