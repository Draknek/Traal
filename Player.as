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
		
		public function Player (_x:Number = 160, _y:Number = 120)
		{
			x = _x;
			y = _y;
		}
		
		public override function update (): void
		{
			var angleChange:Number = int(Input.check(Key.LEFT)) - int(Input.check(Key.RIGHT));
			
			angleChange *= TURN_SPEED;
			
			angle += angleChange;
			
			var moveAmount: Number = int(Input.check(Key.UP)) - int(Input.check(Key.DOWN));
			
			moveAmount *= MOVE_SPEED;
			
			var vx:Number = dx * moveAmount;
			var vy:Number = dy * moveAmount;
			
			moveBy(vx, vy);
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
			Draw.circlePlus(x, y, 8, 0x808080);
			
			var dx1:Number = Math.cos((angle - 30) * FP.RAD);
			var dy1:Number = Math.sin((angle - 30) * FP.RAD);
			var dx2:Number = Math.cos((angle + 30) * FP.RAD);
			var dy2:Number = Math.sin((angle + 30) * FP.RAD);
			
			Draw.linePlus(x, y, x + dx1 * 40, y + dy1 * 40, 0xdddddd);
			Draw.linePlus(x, y, x + dx2 * 40, y + dy2 * 40, 0xdddddd);
		}
	}
}

