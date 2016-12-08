from keras.models import Sequential
from keras.layers import *
from keras.optimizers import *
from qlearning4k import Agent


import numpy as np
import qlearning4k

class Catch:

	def __init__(self, grid_size=10):
		self.grid_size = grid_size
		self.won = False
		self.reset()

	def reset(self):
		n = np.random.randint(0, self.grid_size-1, size=1)
		m = np.random.randint(1, self.grid_size-2, size=1)
		self.state = np.asarray([0, n, m])[np.newaxis]

	@property
	def name(self):
		return "Catch"

	@property
	def nb_actions(self):
		return 3

	def get_frame(self):
		return self.get_state()

	def play(self, action):
		state = self.state
		if action == 0:
			action = -1
		elif action == 1:
			action = 0
		else:
			action = 1
		f0, f1, basket = state[0]
		new_basket = min(max(1, basket + action), self.grid_size-1)
		f0 += 1
		out = np.asarray([f0, f1, new_basket])
		out = out[np.newaxis]
		assert len(out.shape) == 2
		self.state = out

	def get_state(self):
		im_size = (self.grid_size,) * 2
		state = self.state[0]
		canvas = np.zeros(im_size)
		canvas[state[0], state[1]] = 1
		canvas[-1, state[2]-1:state[2] + 2] = 1
		return canvas

	def get_score(self):
		fruit_row, fruit_col, basket = self.state[0]
		if fruit_row == self.grid_size-1:
			if abs(fruit_col - basket) <= 1:
				self.won = True
				return 1
			else:
				return -1
		else:
			return 0

	def is_over(self):
		if self.state[0, 0] == self.grid_size-1:
			return True
		else:
			return False

	def is_won(self):
		fruit_row, fruit_col, basket = self.state[0]
		return fruit_row == self.grid_size-1 and abs(fruit_col - basket) <= 1




grid_size = 10
hidden_size = 100
nb_frames = 1

model = Sequential()
model.add(Flatten(input_shape=(nb_frames, grid_size, grid_size)))
model.add(Dense(hidden_size, activation='relu'))
model.add(Dense(hidden_size, activation='relu'))
model.add(Dense(hidden_size, activation='relu'))
model.add(Dense(hidden_size, activation='relu'))
model.add(Dense(3))
model.compile(sgd(lr=.2), "mse")
print("asdkldsfjlkas")
catch = Catch(grid_size)
agent = Agent(model=model)
agent.train(catch, batch_size=10, nb_epoch=1000, epsilon=.1)
agent.play(catch)
