import numpy as np
import tensorflow as tf
from tensorflow.python.ops import seq2seq
from tensorflow.python.ops import rnn_cell

seed = 7
np.random.seed(7)


def generate_sequences(sequence_num, sequence_length, batch_size):
    x_data = np.random.uniform(0, 1, size=(sequence_num // batch_size, sequence_length, batch_size, 1))
    x_data = np.array(x_data, dtype=np.float32)

    y_data = []
    for x in x_data:
        sequence = [x[0]]
        for index in range(1, len(x)):
            sequence.append(x[0] * x[index])
        # sequence.append([np.max(sequence, axis=0)])
        # candidates_for_min = sequence[1:]
        # sequence.append([np.min(candidates_for_min, axis=0)])
        y_data.append(sequence)

    return x_data, y_data


def convert_seq_of_seq(inputs):
    tensor_array = []
    for sequence in inputs:
        tensor_array.append([tf.constant(x) for x in sequence])

    return tensor_array


def variable_summaries(var, name):
    """Attach a lot of summaries to a Tensor."""
    with tf.name_scope('summaries'):
        mean = tf.reduce_mean(var)
        tf.scalar_summary('mean/' + name, mean)
        with tf.name_scope('stddev'):
            stddev = tf.sqrt(tf.reduce_sum(tf.square(var - mean)))
        tf.scalar_summary('sttdev/' + name, stddev)
        tf.scalar_summary('max/' + name, tf.reduce_max(var))
        tf.scalar_summary('min/' + name, tf.reduce_min(var))
        tf.histogram_summary(name, var)


def main():
    datapoints_number = 1000
    sequence_size = 10
    batch_size = 10
    data_point_dim = 1

    if datapoints_number % float(batch_size) != 0:
        raise ValueError('Number of samples must be divisible with batch size')

    inputs, outputs = generate_sequences(sequence_num=datapoints_number, sequence_length=sequence_size,
                                         batch_size=batch_size)

    input_dim = len(inputs[0][0])
    output_dim = len(outputs[0][0])

    encoder_inputs = [tf.placeholder(tf.float32, shape=[batch_size, data_point_dim]) for _ in range(input_dim)]

    decoder_inputs = [tf.placeholder(tf.float32, shape=[batch_size, data_point_dim]) for _ in range(output_dim)]

    model_outputs, states = seq2seq.basic_rnn_seq2seq(encoder_inputs,
                                                      decoder_inputs,
                                                      rnn_cell.BasicLSTMCell(data_point_dim, state_is_tuple=True))

    reshaped_outputs = tf.reshape(model_outputs, [-1])
    reshaped_results = tf.reshape(decoder_inputs, [-1])

    cost = tf.reduce_sum(tf.squared_difference(reshaped_outputs, reshaped_results))
    variable_summaries(cost, 'cost')

    step = tf.train.AdamOptimizer(learning_rate=0.01).minimize(cost)

    init = tf.initialize_all_variables()

    merged = tf.merge_all_summaries()

    import matplotlib.pyplot as plt

    with tf.Session() as session:
        session.run(init)
        # writer = tf.train.SummaryWriter("/tmp/tensor/train", session.graph, )

        costs = []
        n_iterations = 100
        for i in range(n_iterations):
            batch_costs = []
            summary = None

            for batch_inputs, batch_outputs in zip(inputs, outputs):
                x_list = {key: value for (key, value) in zip(encoder_inputs, batch_inputs)}
                y_list = {key: value for (key, value) in zip(decoder_inputs, batch_outputs)}

                summary, err, _ = session.run([merged, cost, step])
                batch_costs.append(err)
            # if summary is not None:
            #     writer.add_summary(summary, i)
            costs.append(np.average(batch_costs, axis=0))

    plt.plot(costs)
    plt.show()

if __name__ == '__main__':
    main()
