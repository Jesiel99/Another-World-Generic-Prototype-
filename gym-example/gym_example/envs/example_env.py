import gym
from gym.utils import seeding
import random

def move_enemy(position):
  if position > 450:
    position -= 1
  elif position < 30:
    position += 1
  else:
    position += random.choice([-1, 1])

  return position

class Example_v0 (gym.Env):
    # possible actions
    MOVE_LF = 0
    MOVE_RT = 1
    #WALK = 2
    #JUMP = 3
    SHOOT = 2
    #PUNCH = 5
    #DEFEND = 6
    #RUN = 7

    # possible positions
    LF_MIN = 1
    RT_MAX = 480
    #BOTTOM_LF = 0
    #BOTTOM_RT = 0
    #UPPER_LF = 100
    #UPPER_RT = 100

    # land on the GOAL position within MAX_STEPS steps
    MAX_STEPS = 100

    # possible rewards
    #RWD_TAKE_DAMAGE = -2
    RWD_MISS_SHOT = -10
    RWD_LOSS_MOVIMENT = -2
    RWD_WRONG_DIRECTION = -2
    RWD_RIGHT_DIRECTION = -1
    RWD_HIT_SHOT = 10
    #RWD_GIVE_DAMAGE = 10
    #RWD_DEFEND_DAMAGE = 1
    RWD_GOAL = 100

    metadata = {
        "render.modes": ["human"]
        }


    def __init__ (self):
        # the action space ranges [0, 1] where:
        #  `0` move left
        #  `1` move right
        self.action_space = gym.spaces.Discrete(3)

        # NB: Ray throws exceptions for any `0` value Discrete
        # observations so we'll make position a 1's based value
        self.observation_space = gym.spaces.Discrete(self.RT_MAX + 1)

        # possible positions to chose on `reset()`
        self.enemy_position = 30
        #self.goal = 30
        #int((self.LF_MIN + self.RT_MAX - 1) / 2)

        self.init_positions = 450
        #list(range(self.LF_MIN, self.RT_MAX))
        #self.init_positions.remove(self.goal)

        # NB: change to guarantee the sequence of pseudorandom numbers
        # (e.g., for debugging)
        self.seed()

        self.reset()


    def reset (self):
        """
        Reset the state of the environment and returns an initial observation.
        Returns
        -------
        observation (object): the initial observation of the space.
        """
        self.enemy_position = 30
        self.position = 450
        self.total_damage = 0
        self.direction = self.MOVE_LF
        #self.np_random.choice(self.init_positions)
        self.count = 0

        # for this environment, state is simply the position
        self.state = self.position
        self.reward = 0
        self.done = False
        self.info = {}

        return self.state


    def step (self, action, enemy_position = None):
        """
        The agent takes a step in the environment.
        Parameters
        ----------
        action : Discrete
        Returns
        -------
        observation, reward, done, info : tuple
            observation (object) :
                an environment-specific object representing your observation of
                the environment.
            reward (float) :
                amount of reward achieved by the previous action. The scale
                varies between environments, but the goal is always to increase
                your total reward.
            done (bool) :
                whether it's time to reset the environment again. Most (but not
                all) tasks are divided up into well-defined episodes, and done
                being True indicates the episode has terminated. (For example,
                perhaps the pole tipped too far, or you lost your last life.)
            info (dict) :
                 diagnostic information useful for debugging. It can sometimes
                 be useful for learning (for example, it might contain the raw
                 probabilities behind the environment's last state change).
                 However, official evaluations of your agent are not allowed to
                 use this for learning.
        """
        if self.done:
            # code should never reach this point
            print("EPISODE DONE!!!")

        elif self.count == self.MAX_STEPS:
            self.done = True

        else:
            assert self.action_space.contains(action)
            self.count += 1
            self.enemy_position = move_enemy(self.enemy_position) if enemy_position is None else enemy_position
            aux_reward = 0

            if self.total_damage >= 100:
                aux_reward = self.RWD_GOAL
                self.done = 1

            else:
                if action == self.MOVE_LF:
                    if self.position == self.LF_MIN:
                        # invalid
                        self.reward = self.RWD_LOSS_MOVIMENT
                    else:
                        self.position -= 1
                        self.direction = self.MOVE_LF
                        #if self.total_damage >= 100:
                            # on goal now
                        #    aux_reward = self.REWARD_GOAL
                        #    self.done = 1
                        if self.position < self.enemy_position:
                            # moving away from goal
                            aux_reward = self.RWD_WRONG_DIRECTION
                        else:
                            # moving toward goal
                            aux_reward = self.RWD_RIGHT_DIRECTION

                elif action == self.MOVE_RT:
                    if self.position == self.RT_MAX:
                        # invalid
                        self.reward = self.RWD_LOSS_MOVIMENT
                    else:
                        self.position += 1
                        self.direction = self.MOVE_RT

                        #if self.total_damage >= 100:
                            # on goal now
                        #    aux_reward = self.REWARD_GOAL
                        #    self.done = 1
                        if self.position > self.enemy_position:
                            # moving away from goal
                            aux_reward = self.RWD_WRONG_DIRECTION
                        else:
                            # moving toward goal
                            aux_reward = self.RWD_RIGHT_DIRECTION

                elif action == self.SHOOT:
                    #if self.total_damage >= 100:
                            # on goal now
                    #        aux_reward = self.REWARD_GOAL
                    #        self.done = 1
                    if self.position > self.enemy_position:
                        if self.direction == self.MOVE_LF:
                            # moving away from goal
                            aux_reward = self.RWD_HIT_SHOT
                            self.total_damage += self.RWD_HIT_SHOT
                        else:
                            aux_reward = self.RWD_MISS_SHOT
                          
                    elif self.position < self.enemy_position:
                        if self.direction == self.MOVE_RT:
                            # moving away from goal
                            aux_reward = self.RWD_HIT_SHOT
                            self.total_damage += self.RWD_HIT_SHOT
                        else:
                            aux_reward = self.RWD_MISS_SHOT

            self.reward = aux_reward
            #self.total_damage += aux_reward
            self.state = self.position
            self.info["dist"] = self.total_damage

        try:
            assert self.observation_space.contains(self.state)
        except AssertionError:
            print("INVALID STATE", self.state)

        return [self.state, self.reward, self.done, self.info]


    def render (self, mode="human"):
        """Renders the environment.
        The set of supported modes varies per environment. (And some
        environments do not support rendering at all.) By convention,
        if mode is:
        - human: render to the current display or terminal and
          return nothing. Usually for human consumption.
        - rgb_array: Return an numpy.ndarray with shape (x, y, 3),
          representing RGB values for an x-by-y pixel image, suitable
          for turning into a video.
        - ansi: Return a string (str) or StringIO.StringIO containing a
          terminal-style text representation. The text can include newlines
          and ANSI escape sequences (e.g. for colors).
        Note:
            Make sure that your class's metadata 'render.modes' key includes
              the list of supported modes. It's recommended to call super()
              in implementations to use the functionality of this method.
        Args:
            mode (str): the mode to render with
        """
        s = "position: {:2d}   enemy position: {:2d}    total damage: {:2d}    reward: {:2d}    info: {}"
        print(s.format(self.state, self.enemy_position, self.total_damage,  self.reward, self.info))


    def seed (self, seed=None):
        """Sets the seed for this env's random number generator(s).
        Note:
            Some environments use multiple pseudorandom number generators.
            We want to capture all such seeds used in order to ensure that
            there aren't accidental correlations between multiple generators.
        Returns:
            list<bigint>: Returns the list of seeds used in this env's random
              number generators. The first value in the list should be the
              "main" seed, or the value which a reproducer should pass to
              'seed'. Often, the main seed equals the provided 'seed', but
              this won't be true if seed=None, for example.
        """
        self.np_random, seed = seeding.np_random(seed)
        return [seed]


    def close (self):
        """Override close in your subclass to perform any necessary cleanup.
        Environments will automatically close() themselves when
        garbage collected or when the program exits.
        """
        pass