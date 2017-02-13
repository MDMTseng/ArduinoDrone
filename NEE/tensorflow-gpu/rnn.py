import tensorflow as tf
from tensorflow.examples.tutorials.mnist import input_data
from tensorflow.python.ops import rnn, rnn_cell
mnist = input_data.read_data_sets("/MNIST_data", one_hot = True)

hm_epochs = 13
n_classes = 10
batch_size = 128
n_chunks = 14
chunk_size = 28*28//n_chunks
rnn_size = 50


x = tf.placeholder('float', [None, n_chunks,chunk_size])
y = tf.placeholder('float')


def recurrent_neural_network(x):
    layer = {'weights':tf.Variable(tf.random_normal([rnn_size,n_classes])),
             'biases':tf.Variable(tf.random_normal([n_classes]))}

    print("x.get_shape()>>")
    print(x.get_shape())#(input batch size),n_chunks,chunk_size
    x = tf.split(1, n_chunks, x)
    print(x[0].get_shape())#(input batch size),1,chunk_size:[n_chunks]
    x = [ tf.reshape(x_id, [-1, chunk_size]) for x_id in x ]
    print(x[0].get_shape())#(input batch size),chunk_size:[n_chunks]

    lstm_cell = rnn_cell.GRUCell(rnn_size)
    outputs, states = rnn.rnn(lstm_cell, x, dtype=tf.float32)
    print("outputs.get_shape()>>")
    print(outputs[-1].get_shape())#(input batch size),chunk_size:[last chunk]

    output = tf.matmul(outputs[-1],layer['weights']) + layer['biases']
    return output


def train_neural_network(x):
    prediction = recurrent_neural_network(x)
    cost = tf.reduce_mean( tf.nn.softmax_cross_entropy_with_logits(prediction,y) )
    optimizer = tf.train.AdamOptimizer().minimize(cost)


    with tf.Session() as sess:
        sess.run(tf.initialize_all_variables())

        for epoch in range(hm_epochs):
            epoch_loss = 0
            for _ in range(int(mnist.train.num_examples/batch_size)):
                epoch_x, epoch_y = mnist.train.next_batch(batch_size)

                #print("epoch_x.shape>>")
                #print(epoch_x.shape)#batch_size,n_chunks*chunk_size
                epoch_x = epoch_x.reshape((batch_size,n_chunks,chunk_size))

                c,_ = sess.run([ cost, optimizer], feed_dict={x: epoch_x, y: epoch_y})
                epoch_loss += c

            print('Epoch', epoch, 'completed out of',hm_epochs,'loss:',epoch_loss)

        correct = tf.equal(tf.argmax(prediction, 1), tf.argmax(y, 1))

        accuracy = tf.reduce_mean(tf.cast(correct, 'float'))
        print('Accuracy:',accuracy.eval({x:mnist.test.images.reshape((-1, n_chunks, chunk_size)), y:mnist.test.labels}))

train_neural_network(x)
