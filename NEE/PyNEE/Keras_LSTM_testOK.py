
import numpy as np

from sklearn.preprocessing import MinMaxScaler

import matplotlib.pyplot as plt



def create_dataset(X_t, Y_t ,look_back=1):

    xLlimit=len(X_t)-look_back
    dataX=np.array([X_t[0:xLlimit-1]])
    dataY=np.array([Y_t[xLlimit-1]])

    for i in range(look_back-1):
        secX=X_t[i:xLlimit-1+i]
        secY=Y_t[xLlimit-1+i]
        dataX= np.append(dataX,[secX],axis=0)
        dataY= np.append(dataY,[secY],axis=0)

    return dataX, dataY


X_t=[]
Y_t=[]
t=100000000;
for i in range(100):
    x=1 if i==50 else 0
    X_t.append([x])
    t = 0 if(x==1) else (t+1)
    y=np.exp(-0.2*t)
    Y_t.append([y])


plt.plot(X_t)
plt.plot(Y_t)
plt.show()

look_back = 55
train_size = int(len(X_t))
trainX = X_t[0:train_size]
trainY = Y_t[0:train_size]

trainX, trainY = create_dataset(trainX , trainY, look_back)

trainX = np.reshape(trainX, (trainX.shape[0], trainX.shape[1], 1))

testX=trainX
testY=trainY


import theano
from keras.models import Sequential
from keras.layers import Dense, LSTM, SimpleRNN,GRU, Dropout


theano.config.compute_test_value = "ignore"
# create and fit the LSTM network
batch_size = 100
model = Sequential()
model.add(GRU(32,input_dim=1))
#model.add(Dropout(0.3))
model.add(Dense(1))
model.compile(loss='mean_squared_error', optimizer='adam')

plt.figure(figsize=(12,5))
for epoch in range(5):
    print('model.fit:',epoch)
    model.fit(trainX, trainY, nb_epoch=100, batch_size=batch_size, verbose=2)

    look_ahead = 100
    trainPredict = [np.vstack([trainX[-1][1:], trainY[-1]])]
    predictions = np.zeros((look_ahead,1))
    trainPredictX = np.array([[[0]]])
    for i in range(look_ahead):
        prediction = model.predict(trainPredictX, batch_size=1)
        predictions[i] = prediction
        trainPredictX=np.append(trainPredictX,[[[i==5]]],axis=1)
    plt.plot(predictions,label='Line'+str(epoch))
# plt.plot(np.arange(len(trainX)),np.squeeze(trainX))
# plt.plot(np.arange(200),scaler.inverse_transform(np.squeeze(trainPredict)[:,None][1:]))
# plt.plot(np.arange(200),scaler.inverse_transform(np.squeeze(testY)[:,None][:200]),'r')
plt.legend()
plt.show()
