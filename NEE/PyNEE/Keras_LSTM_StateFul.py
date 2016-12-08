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
    y = 1 if(t>5 and t<10) else 0
    Y_t.append([y])



look_back = 1
train_size = int(len(X_t))
trainX = X_t[0:train_size]
trainY = Y_t[0:train_size]

trainX, trainY = create_dataset(trainX , trainY, look_back)

trainX = np.reshape(trainX, (trainX.shape[1],1,1))



print(trainX.shape)

batchSize = trainX.shape[0]
numOfPrevSteps = trainX.shape[1]
featurelen = trainX.shape[2]

plt.plot(X_t)
plt.plot(Y_t)
plt.show()


from keras.models import Sequential
from keras.layers.core import Dense, Activation, Dropout
from keras.layers import Dense, LSTM, SimpleRNN,GRU, Dropout


print('Building model...')

model = Sequential()
model.add(LSTM(50 , batch_input_shape=trainX.shape, stateful=True))
model.add(Dense( featurelen ))
model.add(Activation('softmax'))
model.compile(loss='mean_squared_error', optimizer='adam')
model.reset_states()

print('starting training')
num_epochs = 100
for e in range(num_epochs):
    print('epoch - ',e+1)
    for i in range(trainX.shape[0]-1):
        model.train_on_batch(trainX[i:i+1,:,  :], trainY[i:i+1, :]) # Train on guessing a single element based on the previous element
    model.reset_states()
    for i in range(100):
        pred = model.predict(np.array([[[1]]]))
        print(pred)
print('training complete')
