from godot import exposed, export
from godot import *


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
	

