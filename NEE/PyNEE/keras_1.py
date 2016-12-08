'''Example script showing how to use stateful RNNs
to model long sequences efficiently.
'''
from __future__ import print_function
import numpy as np
import matplotlib.pyplot as plt
from keras.models import Sequential
from keras.layers import Dense, LSTM, GRU,SimpleRNN


# since we are using stateful rnn tsteps can be set to 1
tsteps = 1
batch_size = 10
epochs = 5
# number of elements ahead that are used to make the prediction
lahead = 1


def gen_XY(amp=1, period=10, x0=0, xn=500, step=1, k=0.0000001):
    """Generates an absolute cosine time series with the amplitude
    exponentially decreasing

    Arguments:
        amp: amplitude of the cosine function
        period: period of the cosine function
        x0: initial x of the time series
        xn: final x of the time series
        step: step of the time series discretization
        k: exponential rate
    """
    X = np.zeros(((xn - x0) * step, 1, 1))
    Y = np.zeros(((xn - x0) * step, 1))

    for i in range(len(X)):
        X[i, 0, 0] = i==90
        Y[i, 0] = i>=90 and i<100
    return X,Y


print('Generating Data')
X,Y = gen_XY()
print('Input shape:', X.shape)

print('Creating Model')
model = Sequential()
model.add(LSTM(50,
               batch_input_shape=(batch_size, tsteps, 1),
               return_sequences=True,
               stateful=True))
model.add(LSTM(50,
               return_sequences=False,
               stateful=True))
model.add(Dense(1))
model.compile(loss='mse', optimizer='adam')

print('Training')
for i in range(epochs):
    print('Epoch', i, '/', epochs)
    model.fit(X,
              Y,
              batch_size=batch_size,
              verbose=1,
              nb_epoch=100,
              shuffle=False)
    model.reset_states()

print('Predicting')
print('cos.shape:',X.shape)
print('cos[0:200,:].shape:',X[0:200,:].shape)

predicted_output=np.array([])
for i in range(X.shape[0]//batch_size):
    predicted_output =np.append(predicted_output, model.predict(X[i*batch_size:(i+1)*batch_size,:], batch_size=batch_size))

print('predicted_output.shape:',predicted_output.shape)

print('Plotting Results')
plt.subplot(2, 1, 1)
plt.plot(X[:,0])
plt.title('Expected')
plt.subplot(2, 1, 2)
plt.plot(Y)
plt.plot(predicted_output)
plt.title('Predicted')
plt.show()
