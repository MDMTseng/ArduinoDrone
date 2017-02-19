import tensorflow as tf

import matplotlib.pyplot as plt
from tensorflow.python.ops import rnn, rnn_cell
import numpy

def sqFunc(arr,start,stop):
    ret=[]
    for ele in arr:
        ret.append((0,1)[ele>=start and ele<stop])
    return ret

data_range = [-0.5, 0.5]


hm_epochs = 1300
hm_batch_size = 1

input_dim = 1
output_dim = 1
time_span = 50
rnn_size = 50

t=numpy.linspace(0,1,time_span);
train_X = numpy.asarray(t-0.5)*5
train_Y = 0.5*numpy.asarray( \
              sqFunc( t,0.5,1.1 )* numpy.sin(16*(t-0.5))  \
             -sqFunc(  t,0,0.5  )* 1 \
             +sqFunc(  t,0.2,0.8)* (0.5-t) \
             )
train_X=train_X.reshape([1,time_span,input_dim])
train_Y=train_Y.reshape([1,time_span,output_dim])

train_X_b = numpy.array([train_X,]* hm_batch_size).reshape([hm_batch_size,time_span,input_dim])
train_Y_b = numpy.array([train_Y,]* hm_batch_size).reshape([hm_batch_size,time_span,output_dim])




print("train_X_b.shape>>")
print(train_X_b.shape)
print("train_Y_b.shape>>")
print(train_Y_b.shape)
x = tf.placeholder('float', [None, time_span,input_dim])
y = tf.placeholder('float', [None, time_span,output_dim])


def recurrent_neural_network(x):
    layer = {'weights':tf.Variable(tf.random_normal([rnn_size,output_dim])),
             'biases':tf.Variable(tf.random_normal([output_dim]))}

    print("x.get_shape()>>")
    print(x.get_shape())#(input batch size),n_chunks,chunk_size
    x = tf.split(1, time_span, x)
    print(x[0].get_shape())#(input batch size),1,chunk_size:[n_chunks]
    x = [ tf.reshape(x_id, [-1, input_dim]) for x_id in x ]
    print(x[0].get_shape())#(input batch size),chunk_size:[n_chunks]

    lstm_cell = rnn_cell.GRUCell(rnn_size)
    outputs, states = rnn.rnn(lstm_cell, x, dtype=tf.float32)
    print("outputs[-1].get_shape()>>")
    print(outputs[-1].get_shape())#(input batch size),chunk_size:[last chunk]
    output_res = [ tf.nn.tanh(tf.matmul(output,layer['weights']) + layer['biases']) for output in outputs ]
    return output_res


def train_neural_network(x):
    prediction = recurrent_neural_network(x)
    print("prediction[-1].get_shape()>>")
    print(prediction[-1].get_shape())#(input batch size),chunk_size:[last chunk]

    packed_pred=tf.pack(prediction,axis=1)
    print("packed_pred.get_shape()>>")
    print(packed_pred.get_shape())#(input batch size),chunk_size:[last chunk]


    print("y.get_shape()>>")
    print(y.get_shape())#(input batch size),chunk_size:[last chunk]

    cost = tf.reduce_sum(tf.pow(packed_pred-y, 2))
    optimizer = tf.train.AdamOptimizer().minimize(cost)


    with tf.Session() as sess:
        sess.run(tf.initialize_all_variables())

        for epoch in range(hm_epochs):
            epoch_loss = 0

            c,_ = sess.run([ cost, optimizer], feed_dict={x: train_X_b, y: train_Y_b})

            epoch_loss += c

            print('Epoch', epoch, 'completed out of',hm_epochs,'loss:',epoch_loss)

        plt.plot(train_X.reshape([time_span]), train_Y.reshape([time_span]), 'b-', label='Original data')
        plt.plot(train_X.reshape([time_span]), sess.run(packed_pred, feed_dict={x: train_X}).reshape([time_span]), 'ro', label='Original data')

        plt.show()

train_neural_network(x)
