package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	public class Player extends Entity
	{
		public var vx: Number = 0;
		public var vy: Number = 0;
		
		public var angle:Number = 0;
		
		public static const MOVE_SPEED: Number = 1;
		public static const TURN_SPEED: Number = 2;
		
		public var eyesShut:Boolean = false;
		public var dead:Boolean = false;
		
		public function Player (_x:Number = 160, _y:Number = 120)
		{
			x = _x;
			y = _y;
			
			setHitbox(16, 16, 8, 8);
		}
		
		public override function update (): void
		{
			var angleChange:Number = int(Input.check(Key.LEFT)) - int(Input.check(Key.RIGHT));
			
			angleChange *= TURN_SPEED;
			
			angle += angleChange;
			
			if (! angleChange) {
				var moveAmount: Number = int(Input.check(Key.UP)) - int(Input.check(Key.DOWN));
			
				moveAmount *= MOVE_SPEED;
			
				var vx:Number = dx * moveAmount;
				var vy:Number = dy * moveAmount;
			
				moveBy(vx, vy, "solid");
			}
			
			eyesShut = Input.check(Key.SPACE);
			
			if (collide("enemy", x, y)) {
				dead = true;
			}
		}
		
		public function get dx (): Number
		{
			return Math.cos(angle * FP.RAD);
		}
		
		public function get dy (): Number
		{
			return Math.sin(angle * FP.RAD);
		}
		
		public override function render (): void
		{
			if (! dead) {
				var dx1:Number = Math.cos((angle - 30) * FP.RAD);
				var dy1:Number = Math.sin((angle - 30) * FP.RAD);
				var dx2:Number = Math.cos((angle + 30) * FP.RAD);
				var dy2:Number = Math.sin((angle + 30) * FP.RAD);
			
				var coneLength: Number = 100;
			
				Draw.linePlus(x, y, x + dx1 * coneLength, y + dy1 * coneLength, 0xdddddd);
				Draw.linePlus(x, y, x + dx2 * coneLength, y + dy2 * coneLength, 0xdddddd);
			}
			
			Draw.circlePlus(x, y, 8, dead ? 0xFF0000 : 0x808080);
		}
	}
}

