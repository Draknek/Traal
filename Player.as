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
		
		public var sprite:Spritemap;
		
		[Embed(source="images/player.png")]
		public static const Gfx: Class;
		
		public function Player (_x:Number = 160, _y:Number = 120)
		{
			x = _x;
			y = _y;
			
			sprite = new Spritemap(Gfx, 16, 20);
			
			sprite.x = -sprite.width*0.5;
			sprite.y = -sprite.height + 3;
			
			graphic = sprite;
			
			setHitbox(6, 6, 3, 3);
		}
		
		public override function update (): void
		{
			var vx:Number = 0;
			var vy:Number = 0;
			
			/*var angleChange:Number = int(Input.check(Key.LEFT)) - int(Input.check(Key.RIGHT));
			
			angleChange *= TURN_SPEED;
			
			angle += angleChange;
			
			if (! angleChange) {
				var moveAmount: Number = int(Input.check(Key.UP)) - int(Input.check(Key.DOWN));
			
				moveAmount *= MOVE_SPEED;
			
				vx = dx * moveAmount;
				vy = dy * moveAmount;
			
				moveBy(vx, vy, "solid");
			}*/
			
			vx = (int(Input.check(Key.RIGHT)) - int(Input.check(Key.LEFT))) * MOVE_SPEED;
			vy = (int(Input.check(Key.DOWN)) - int(Input.check(Key.UP))) * MOVE_SPEED;
			
			moveBy(vx, vy, "solid");
			
			//angle = 
			
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
				
				var headX:Number = x;
				var headY:Number = y - 12;
			
				Draw.linePlus(headX, headY, headX + dx1 * coneLength, headY + dy1 * coneLength, 0xdddddd);
				Draw.linePlus(headX, headY, headX + dx2 * coneLength, headY + dy2 * coneLength, 0xdddddd);
			}
			
			super.render();
		}
	}
}

