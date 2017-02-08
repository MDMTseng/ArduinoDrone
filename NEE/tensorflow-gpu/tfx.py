import tensorflow as tf
import numpy
import matplotlib.pyplot as plt

rng = numpy.random


def stepFunc(arr):
    ret=[]
    for ele in arr:
        ret.append((1,0)[ele<0])
    return ret

data_range = [-0.5, 0.5]
sampleNum=30;

t=numpy.linspace(0,1,sampleNum);
train_X = numpy.asarray(t-0.5)*5
#train_Y = numpy.asarray(stepFunc(t-0.5)*numpy.sin(16*(t-0.5)))*0.5
train_Y = numpy.asarray(numpy.sin(16*(t*t)))*0.5

n_samples = train_X.shape[0]

train_X = numpy.reshape(train_X, [n_samples, 1])
train_Y = numpy.reshape(train_Y, [n_samples, 1])

# Parameters
learning_rate = 0.0001
training_epochs = 800
display_step = 10

# tf Graph Input
X = tf.placeholder("float64")
Y = tf.placeholder("float64")



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
        if (count == 0):
            temp_O = tf.add(tf.mul(p_output, tfLayer['ws']), tfLayer['bs'])
        else:
            temp_O = tf.add(tf.matmul(p_output, tfLayer['ws']), tfLayer['bs'])
        count=count+1
        p_output = tf.nn.tanh(temp_O);

    return {'TFWs':retTFWs, 'Output': p_output}

weightObj = multi_perc_weight_init([1, 35, 35, 35, 35,1]);
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

    print(NetObj['TFWs'][0]['ws'].eval())
    print(NetObj['TFWs'][0]['bs'].eval())
    # Fit all training data
    for epoch in range(training_epochs):
        trainIdxArr = numpy.arange(sampleNum)
        rng.shuffle(trainIdxArr)
        for i in trainIdxArr:
            sess.run(optimizer, feed_dict={X: train_X[i,0], Y: train_Y[i,0]})

        # Display logs per epoch step
        if (epoch+1) % display_step == 0:
            c = sess.run(cost, feed_dict={X: train_X, Y:train_Y})
            print("Epoch:", '%04d' % (epoch+1), "cost=", "{:.9f}".format(c))

    print("Optimization Finished!")
    training_cost = sess.run(cost, feed_dict={X: train_X, Y: train_Y})
    print("Training cost=", training_cost, '\n')

    # Graphic display
    plt.plot(train_X, train_Y, 'ro', label='Original data')
    plt.plot(train_X,sess.run(pred, feed_dict={X: train_X, Y: train_Y}), label='Fitted line')
    plt.legend()
    plt.show()
    print(NetObj['TFWs'][0]['ws'].eval())
    print(NetObj['TFWs'][0]['bs'].eval())
