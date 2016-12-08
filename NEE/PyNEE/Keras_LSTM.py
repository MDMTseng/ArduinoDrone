
import numpy as np

from sklearn.preprocessing import MinMaxScaler

import matplotlib.pyplot as plt


t = np.linspace(0,1,1000)

cos_t=np.cos(50*np.pi*t)*np.cos(50*np.pi*t)*np.cos(50*np.pi*t)

mask_t=(t<0.9)*1;

dataset = (cos_t*mask_t)
# convert an array of values into a dataset matrix
def create_dataset(dataset, look_back=1):
    dataX, dataY = [], []

    for i in range(len(dataset)-look_back):
        dataX.append(dataset[i:(i+look_back)])
        dataY.append(dataset[i + look_back])
    return np.array(dataX), np.array(dataY)



look_back = 12
dataset.reshape(-1, 1)
# split into train and test sets
train_size = int(len(dataset) * 0.67)
test_size = len(dataset) - train_size
train, test = dataset[0:train_size], dataset[train_size:len(dataset)]


trainX, trainY = create_dataset(train, look_back)
testX, testY = create_dataset(test, look_back)

trainX = np.reshape(trainX, (trainX.shape[0], trainX.shape[1], 1))
testX = np.reshape(testX, (testX.shape[0], testX.shape[1], 1))


print(testX.shape)
print(testY.shape)

import theano
from keras.models import Sequential
from keras.layers import Dense, LSTM, SimpleRNN,GRU, Dropout


theano.config.compute_test_value = "ignore"
# create and fit the LSTM network
batch_size = 320
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
    for i in range(look_ahead):
        prediction = model.predict(np.array([trainPredict[-1]]), batch_size=1)
        predictions[i] = prediction
        trainPredict.append(np.vstack([trainPredict[-1][1:],prediction]))
    plt.plot(predictions,label='Line'+str(epoch))
# plt.plot(np.arange(len(trainX)),np.squeeze(trainX))
# plt.plot(np.arange(200),scaler.inverse_transform(np.squeeze(trainPredict)[:,None][1:]))
# plt.plot(np.arange(200),scaler.inverse_transform(np.squeeze(testY)[:,None][:200]),'r')
plt.legend()
plt.show()
