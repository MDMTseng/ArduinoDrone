import numpy as np

from sklearn.preprocessing import MinMaxScaler

import matplotlib.pyplot as plt


trainPredictX = np.array([[[0]]])
trainPredictX=np.append(trainPredictX,[[[0]]],axis=1)
print(trainPredictX.shape)



# convert an array of values into a dataset matrix
def create_dataset(dataset, look_back=1):
    dataX, dataY = [], []

    for i in range(len(dataset)-look_back):
        dataX.append(dataset[i:(i+look_back)])
        dataY.append(dataset[i + look_back])
    return np.array(dataX), np.array(dataY)

t = np.linspace(0,1,100)
cos_t=np.cos(2*2*np.pi*t)
mask_t=(t<0.9)*1;
dataset = (cos_t*mask_t)
print(type(t))


npNdArr=np.append([[1, 2, 3], [4, 5, 6]],[[1, 2, 3], [4, 5, 6]], axis=1)
print(npNdArr)
print([[1, 2, 3], [4, 5, 6]])

tupleX=(8,5,6)
print(tupleX)
print(type(tupleX))

listX=[1]
listX.append(5)
listX*=2
print(listX)
print(type(listX))



look_back = 5

# split into train and test sets
train_size = int(len(dataset) * 0.67)
test_size = len(dataset) - train_size
train, test = dataset[0:train_size], dataset[train_size:len(dataset)]

print("train.shape:",train.shape)
print("test.shape:",test.shape)

trainX, trainY = create_dataset(train, look_back)
testX, testY = create_dataset(test, look_back)

print("trainX.shape:",trainX.shape)
print("trainY.shape:",trainY.shape)
plt.plot(trainX[:,0],label='LineX')
plt.plot(trainY,label='LineY')
plt.show()
print("testX.shape:",testX.shape)
print("testY.shape:",testY.shape)
"""
plt.figure(figsize=(12,5))
plt.plot(trainY,label='LineY')
plt.legend()

plt.show()"""
