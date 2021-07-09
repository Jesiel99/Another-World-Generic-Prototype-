from godot import exposed, export
from godot import *

import gym
import gym_example
from gym_example1.gym_example.envs.example_env import Example_v0

@exposed
class AI(Node):

	# member variables here, example:
	a = export(int)
	b = export(str, default='foo')
	
	controller_action = signal()
	
	def _on_Enemy_enemy_info(self, x_pos, health_bar, player_health_bar):
		print(x_pos)
		print(health_bar)
		print(player_health_bar)
		
	def _on_VisibilityNotifier2D_screen_exited(body):
		print('b')
		
	def _ready(self):
		self.call("emit_signal","controller_action", 'action')	
		env = gym.make("example-v0")
		print(type(env))
		sum_reward = run_one_episode(env)

		history = []
		for _ in range(10000):
			sum_reward = run_one_episode(env)
			history.append(sum_reward)
		   # print(sum_reward)
		avg_sum_reward = sum(history) / len(history)
		print("\nbaseline cumulative reward: {}".format(avg_sum_reward))
	
	def run_one_episode (env):
		env.reset()
		sum_reward = 0
		for i in range(env.MAX_STEPS):
			action = env.action_space.sample()
			state, reward, done, info = env.step(action)
			sum_reward += reward
			if done:
				break
		return sum_reward

	def action_bot (env, enemy_position = None):
		env.reset()
		sum_reward = 0
		for i in range(env.MAX_STEPS):
			action = env.action_space.sample()
			state, reward, done, info = env.step(action, enemy_position)
			sum_reward += reward
			if done:
				break
		return state, action, env.direction


