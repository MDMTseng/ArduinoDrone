
import numpy as np
import matplotlib.pyplot as plt
from keras.models import Sequential
from keras.layers import Dense, LSTM, GRU,SimpleRNN



# since we are using stateful rnn tsteps can be set to 1
tsteps = 1
batch_size = 10
epochs = 150
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


print('Build STATEFUL model...')
model = Sequential()
model.add(LSTM(10, batch_input_shape=(batch_size, 1, 1), return_sequences=False, stateful=True))
model.add(Dense(1, activation='sigmoid'))
model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])


print(">>>>>>len(X)>>>>>",len(X))





print('Train...')
for epoch in range(epochs):
    mean_tr_acc = []
    mean_tr_loss = []
    for i in range(len(X)//batch_size):
        tr_loss, tr_acc = model.train_on_batch(X[i*batch_size:(i+1)*batch_size,:,:],Y[i*batch_size:(i+1)*batch_size,:])
        mean_tr_acc.append(tr_acc)
        mean_tr_loss.append(tr_loss)
    model.reset_states()
    print('accuracy training = {}'.format(np.mean(mean_tr_acc)))
    print('loss training = {}'.format(np.mean(mean_tr_loss)))
    print('___________________________________')
    react=[]
    for i in range(len(X)//batch_size):
        y_pred = model.predict_on_batch(X[i*batch_size:(i+1)*batch_size,:,:])
        react= y_pred if(len(react)==0) else np.append(react, y_pred, axis=0)
    model.reset_states()
plt.plot(react)
plt.show()
