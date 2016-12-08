
import numpy as np # Matrix and vector computation package


"""
   Wx
Xk-----+-> Sk---o--> Y
       |__Wrec__|

"""

 # Define the forward step functions
def update_state(xk, sk, wx, wRec):
    """
    Compute state k from the previous state (sk) and current input (xk),
    by use of the input weights (wx) and recursive weights (wRec).
    """
    return xk * wx + sk * wRec

def forward_states(X, wx, wRec):
    """
    Unfold the network and compute all state activations given the input X,
    and input weights (wx) and recursive weights (wRec).
    Return the state activations in a matrix, the last column S[:,-1] contains the
    final activations.
    """
    # Initialise the matrix that holds all states for all input sequences.
    # The initial state s0 is set to 0.
    S = np.zeros((X.shape[0], X.shape[1]+1))
    # Use the recurrence relation defined by update_state to update the
    #  states trough time.
    for k in range(0, X.shape[1]):

        # S[k] = S[k-1] * wRec + X[k] * wx
        S[:,k+1] = update_state(X[:,k], S[:,k], wx, wRec)
    return S

def cost(y, t):
    """
    Return the MSE between the targets t and the outputs y.
    """
    return ((t - y)**2).sum() / nb_of_samples

def output_gradient(y, t):
    """
    Compute the gradient of the MSE cost function with respect to the output y.
    """
    return 2.0 * (y - t) / nb_of_samples

def backward_gradient(X, S, grad_out, wRec):
    """
    Backpropagate the gradient computed at the output (grad_out) through the network.
    Accumulate the parameter gradients for wX and wRec by for each layer by addition.
    Return the parameter gradients as a tuple, and the gradients at the output of each layer.
    """
    # Initialise the array that stores the gradients of the cost with respect to the states.
    grad_over_time = np.zeros((X.shape[0], X.shape[1]+1))
    grad_over_time[:,-1] = grad_out
    # Set the gradient accumulations to 0
    wx_grad = 0
    wRec_grad = 0
    for k in range(X.shape[1], 0, -1):
        # Compute the parameter gradients and accumulate the results.
        wx_grad += np.sum(grad_over_time[:,k] * X[:,k-1])
        wRec_grad += np.sum(grad_over_time[:,k] * S[:,k-1])
        # Compute the gradient at the output of the previous layer
        grad_over_time[:,k-1] = grad_over_time[:,k] * wRec
    return (wx_grad, wRec_grad), grad_over_time
