import tensorflow as tf
import numpy
import matplotlib.pyplot as plt

rng = numpy.random


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

data_range = [-0.5, 0.5]

t=numpy.linspace(0,1,80);
train_X = numpy.asarray(t-0.5)*5
train_Y = 0.5*numpy.asarray( \
              sqFunc( t,0.5,1.1 )* numpy.sin(16*(t-0.5))  \
             -sqFunc(  t,0,0.5  )* 1 \
             +sqFunc(  t,0.2,0.8)* (0.5-t) \
             )
#train_Y = numpy.asarray(numpy.sin(40*(t*t)))*0.5

n_samples = train_X.shape[0]

train_X = numpy.reshape(train_X, [n_samples, 1])
train_Y = numpy.reshape(train_Y, [n_samples, 1])

# Parameters
learning_rate = 0.001
training_epochs = 500
errorStop = 0.00005
display_step = 5

# tf Graph Input
X = tf.placeholder("float64",[None, 1])
Y = tf.placeholder("float64",[None, 1])



def multi_perc_weight_init(dims):
    retWs=[]
    for i in range(len(dims)-1):
        retWs.append({'ws':rng.randn(dims[i],dims[i+1]), 'bs': rng.randn(1,dims[i+1])})
        print(retWs[i]['ws'].shape,">>",retWs[i]['bs'].shape)
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
            if(count == len(retTFWs)-2 ):
                p_output = tf.nn.tanh(temp_O);
            else:
                p_output = tf.nn.tanh(temp_O);
        else:
            p_output = tf.nn.tanh(temp_O);
        count=count+1

    return {'TFWs':retTFWs, 'Output': p_output}

weightObj = multi_perc_weight_init([1, 35, 35, 1]);
NetObj = multi_perc_network(weightObj,X)
pred = NetObj['Output'];

# Mean squared error
cost = tf.reduce_sum(tf.pow(pred-Y, 2))/(2*n_samples)

rate = tf.train.exponential_decay(learning_rate, cost, 1, 0.96)
# Gradient descent
optimizer = tf.train.AdamOptimizer(rate).minimize(cost)

# Initializing the variables
init = tf.global_variables_initializer()
# Launch the graph
with tf.Session() as sess:
    sess.run(init)
    cost_hist = []
    batchNum=n_samples*5//6
    # Fit all training data
    for epoch in range(training_epochs):
        trainIdxArr = numpy.arange(n_samples-batchNum)
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

    # Graphic display
    plt.plot(train_X, train_Y, 'ro', label='Original data')
    plt.plot(train_X,sess.run(pred, feed_dict={X: train_X, Y: train_Y}), label='Fitted line')
    plt.legend()
    plt.show()


    plt.plot(cost_hist)
    plt.show()
