import tensorflow as tf
import numpy as np
import matplotlib.pyplot as plt

rng = np.random


def stepFunc(arr):
    ret=[]
    for ele in arr:
        ret.append((1,0)[ele<0])
    return ret

def sqFunc(arr,start,stop):
    ret=[]
    for ele in arr:
        ret.append((0,1)[ele>=start and ele<stop])
    return ret


def randSets(arr,start,stop):
    ret=[]
    for ele in arr:
        ret.append((0,1)[ele>=start and ele<stop])
    return ret


n_samples = 180
train_X=np.zeros(shape=(n_samples,2))
train_Y=np.zeros(shape=(n_samples,2))
for i in range(n_samples):
    t = 3*i/n_samples*2*np.pi
    if i%2==0:
        train_X[i]=[t*np.sin(t), t*np.cos(t)]
        train_Y[i]=[1., 0.]
    else:
        train_X[i]=[t*np.sin(t+np.pi), t*np.cos(t+np.pi)]
        train_Y[i]=[0., 1.]

# Parameters
learning_rate = 0.001
training_epochs = 1000
errorStop = 0.01
display_step = 5

# tf Graph Input
X = tf.placeholder("float64",[None, train_X.shape[1]])
Y = tf.placeholder("float64",[None, train_Y.shape[1]])



def multi_perc_weight_init(dims):
    retWs=[]
    for i in range(len(dims)-1):
        retWs.append({'ws':rng.randn(dims[i],dims[i+1]), 'bs': rng.randn(1,dims[i+1])})
        print(retWs[i]['ws'].shape,"+bias:",retWs[i]['bs'].shape)
    return retWs

def multi_perc_network(weightObj,base_input):
    retTFWs=[]
    for layerW in weightObj:
        retTFWs.append({'ws':tf.Variable(layerW['ws']), 'bs':tf.Variable(layerW['bs'])})

    count = 0;
    p_output = base_input
    for tfLayer in retTFWs:
        temp_O = tf.add(tf.matmul(p_output, tfLayer['ws']), tfLayer['bs'])
        if count < len(retTFWs)-1:
            p_output = tf.nn.tanh(temp_O);
        else:
            p_output = tf.nn.softmax(temp_O);
        count=count+1

    return {'TFWs':retTFWs, 'Output': p_output}

weightObj = multi_perc_weight_init([train_X.shape[1], 35, 35, train_Y.shape[1]]);
NetObj = multi_perc_network(weightObj,X)
pred = NetObj['Output'];

cost = tf.reduce_mean(-tf.reduce_sum(Y*tf.log(pred), reduction_indices=[1]))

rate = tf.train.exponential_decay(learning_rate, cost, 1, 0.96)
# Gradient descent
optimizer = tf.train.AdamOptimizer(rate).minimize(cost)

plt.figure(0)
# Initializing the variables
init = tf.global_variables_initializer()
# Launch the graph
with tf.Session() as sess:
    sess.run(init)
    cost_hist = []
    batchNum=n_samples*5//6
    # Fit all training data
    for epoch in range(training_epochs):
        trainIdxArr = np.arange(n_samples-batchNum)
        rng.shuffle(trainIdxArr)
        for i in trainIdxArr:
            sess.run(optimizer, feed_dict={X: train_X[i:i+batchNum,:], Y: train_Y[i:i+batchNum,:]})

        # Display logs per epoch step
        if (epoch+1) % display_step == 0:
            c = sess.run(cost, feed_dict={X: train_X, Y:train_Y})
            cost_hist.append(c);
            print("Epoch:", '%04d' % (epoch+1), "cost=", "{:.9f}".format(c))
            if c < errorStop:
                print("Good enough, Break")
                break

    print("Optimization Finished!")
    training_cost = sess.run(cost, feed_dict={X: train_X, Y: train_Y})
    print("Training cost=", training_cost, '\n')

    plt.figure(0)
    pred_Y = sess.run(pred, feed_dict={X: train_X, Y: train_Y})
    for i in range(n_samples):
        if(pred_Y[i][0]>pred_Y[i][1]):
            plt.plot(train_X[i][0],train_X[i][1], 'ro', label='Original data')
        else:
            plt.plot(train_X[i][0],train_X[i][1], 'bo', label='Original data')
    #plt.show(block=False)
    plt.figure(1)
    plt.plot(cost_hist)
    plt.show()
