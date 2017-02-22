import tensorflow as tf

import matplotlib.pyplot as plt
from tensorflow.python.ops import rnn, rnn_cell
import numpy
import numpy.random as rng


hm_epochs = 1300
hm_batch_size = 800

input_dim = 1
output_dim = 1
time_span = 150
rnn_size = 50

def sqFunc(arr,start,stop):
    ret=[]
    for ele in arr:
        ret.append((0,1)[ele>=start and ele<stop])
    return ret

def GenXYSignal(start_t,stop_t,N):
    t=numpy.linspace(start_t,stop_t,N);
    X = numpy.asarray(sqFunc(  t,0.0,0.1 ))
    Y = numpy.asarray(sqFunc(  t,0.2,0.4 ))*0.8
    return X,Y


def GenXYSignalSets(randArr,N):
    counter=0
    #The randArr is to give random offset of time to offset X,Y
    for rand in randArr:
        x,y=GenXYSignal(rand,rand+1,N)
        if counter == 0:
            set_x,set_y=x,y
        else:
            set_x=numpy.vstack((set_x,x))
            set_y=numpy.vstack((set_y,y))
        counter=counter+1


    return set_x,set_y

[train_X_b,train_Y_b]=GenXYSignalSets(-rng.rand(hm_batch_size)/2,time_span)
train_X_b = train_X_b.reshape([hm_batch_size,time_span,input_dim])
train_Y_b = train_Y_b.reshape([hm_batch_size,time_span,output_dim])








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
    gru_cell = rnn_cell.GRUCell(rnn_size)

    state = tf.Variable(gru_cell.zero_state(batch_size=hm_batch_size,dtype=tf.float32), trainable=False)
    outputs, new_state = rnn.dynamic_rnn(gru_cell, x, dtype=tf.float32, initial_state=state)
    print("new_state.get_shape()>>")
    print(new_state.get_shape())
    print("outputs.get_shape()>>")
    print(outputs.get_shape())
    print("outputs[:,1,:].get_shape()>>")
    print(outputs[:,1,:].get_shape())

    #set state feed back to keep RNN state
    with tf.control_dependencies([state.assign(new_state)]):
        outputs = tf.identity(outputs)

    output_res = [ tf.nn.tanh(tf.matmul(outputs[:,i,:],layer['weights']) + layer['biases']) for i in range(time_span) ]
    print("output_res[-1].get_shape()>>")
    print(output_res[-1].get_shape())

    return output_res


def train_neural_network(x):
    prediction = recurrent_neural_network(x)
    print("prediction[-1].get_shape()>>")
    print(prediction[-1].get_shape())

    packed_pred=tf.pack(prediction,axis=1)
    print("packed_pred.get_shape()>>")
    print(packed_pred.get_shape())


    print("y.get_shape()>>")
    print(y.get_shape())

    cost = tf.reduce_mean(tf.pow(packed_pred-y, 2))
    optimizer = tf.train.AdamOptimizer().minimize(cost)


    with tf.Session() as sess:
        sess.run(tf.global_variables_initializer())

        for epoch in range(hm_epochs):
            epoch_loss = 0

            c,_ = sess.run([ cost, optimizer], feed_dict={x: train_X_b, y: train_Y_b})

            epoch_loss += c
            print('Epoch', epoch, 'completed out of',hm_epochs,'loss:',epoch_loss)
            if(epoch_loss<0.001):break

        for tryIdx in range(50):
            pred_test=sess.run(packed_pred, feed_dict={x: train_X_b})
            plt.plot(train_X_b[tryIdx,:,0], 'g-', label='X data')
            plt.plot(train_Y_b[tryIdx,:,0], 'b-', label='Ground truth Y data')
            plt.plot(pred_test[tryIdx:tryIdx+1,:,:].reshape([time_span]), 'ro', label='Fitted Y data')
            plt.legend()
            plt.show()

train_neural_network(x)
