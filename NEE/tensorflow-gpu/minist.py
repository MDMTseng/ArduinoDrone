#Just some random code for MNIST data play

from tensorflow.examples.tutorials.mnist import input_data
import matplotlib.image as mpimg
import matplotlib.pyplot as plt
mnist = input_data.read_data_sets("MNIST_data/", one_hot=True)
print(mnist.train.images[0:5,:])
print(mnist.train.images[1,:].reshape([28,28]))
print(mnist.train.images.shape)

print(mnist.train.labels[0:5,:])
print(mnist.train.labels.shape)


batch_xs, batch_ys = mnist.train.next_batch(100)

print(batch_xs)
print(batch_ys)

#plt.gray()
imgplot = plt.imshow(batch_xs[8].reshape([28,28]), cmap='gray')

plt.show()
