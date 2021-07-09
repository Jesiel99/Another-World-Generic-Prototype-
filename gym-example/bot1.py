import gym
import gym_example
from gym_example.envs.example_env import Example_v0
import random

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

print('fala')
env = gym.make("example-v0")
print(type(env))
sum_reward = run_one_episode(env)
print(sum_reward)

history = []
for _ in range(10000):
    sum_reward = run_one_episode(env)
    history.append(sum_reward)
    print(sum_reward)
avg_sum_reward = sum(history) / len(history)
print("\nbaseline cumulative reward: {}".format(avg_sum_reward))