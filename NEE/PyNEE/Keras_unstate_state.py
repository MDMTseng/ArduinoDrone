
import numpy as np

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
    y = 1 if(t>10 and t<20) else 0
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
model.add(GRU(50,
return_sequences=True,input_dim=1))
model.add(GRU(50))
#model.add(Dropout(0.3))
model.add(Dense(1,activation='tanh'))
model.compile(loss='mean_squared_error', optimizer='adam')

plt.figure(figsize=(12,5))
for epoch in range(2):
    print('model.fit:',epoch)
    model.fit(trainX, trainY, nb_epoch=200, batch_size=batch_size, verbose=2)

    look_ahead = 100
    trainPredict = [np.vstack([trainX[-1][1:], trainY[-1]])]
    predictions = np.zeros((look_ahead,1))









w = model.get_weights()
model = Sequential()
model.add(GRU(50,input_dim=1,stateful=True,
return_sequences=True,batch_input_shape=(1, 1, 1)))
model.add(GRU(50,stateful=True))
#model.add(Dropout(0.3))
model.add(Dense(1,activation='tanh'))
model.compile(loss='mean_squared_error', optimizer='adam')
model.set_weights(w)
model.reset_states()

trainPredictX = np.array([[[0]]])
trainPredictXs = trainPredictX
for i in range(look_ahead):
    prediction = model.predict(trainPredictX, batch_size=1)
    predictions[i] = prediction
    trainPredictX=np.array([[[i==15 or i==52]]])
    trainPredictXs=np.append(trainPredictXs,trainPredictX)
    
model.reset_states()
plt.plot(predictions,label='Line'+str(epoch))
plt.plot(trainPredictXs)
# plt.plot(np.arange(len(trainX)),np.squeeze(trainX))
# plt.plot(np.arange(200),scaler.inverse_transform(np.squeeze(trainPredict)[:,None][1:]))
# plt.plot(np.arange(200),scaler.inverse_transform(np.squeeze(testY)[:,None][:200]),'r')
plt.legend()
plt.show()
