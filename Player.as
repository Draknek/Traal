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
		public var targetAngle:Number = 0;
		
		public static const WALK_SPEED: Number = 1;
		public static const RUN_SPEED: Number = 2;
		public static const TURN_SPEED: Number = 2;
		public static const VIEW_ANGLE: Number = 20;
		
		public var eyesShut:Boolean = false;
		public var dead:Boolean = false;
		public var running:Boolean = false;
		
		public var sprite:Spritemap;
		
		[Embed(source="images/player.png")]
		public static const Gfx: Class;
		
		public function Player (_x:Number = 160, _y:Number = 120)
		{
			x = _x;
			y = _y;
			
			sprite = new Spritemap(Gfx, 16, 20);
			
			var animSpeed:Number = 0.05;
			
			sprite.add("right", [0, 1], animSpeed);
			sprite.add("left", [2, 3], animSpeed);
			sprite.add("down", [4, 5], animSpeed);
			sprite.add("up", [6, 7], animSpeed);
			
			sprite.add("right-running", [0, 9], animSpeed*2);
			sprite.add("left-running", [2, 11], animSpeed*2);
			sprite.add("down-running", [4, 13], animSpeed*2);
			sprite.add("up-running", [6, 15], animSpeed*2);
			
			sprite.x = -sprite.width*0.5;
			sprite.y = -sprite.height + 4;
			
			graphic = sprite;
			
			setHitbox(6, 6, 3, 3);
		}
		
		public override function update (): void
		{
			if (dead) {
				sprite.color = 0xFF0000;
				sprite.stop();
				return;
			}
			
			var vx:Number = 0;
			var vy:Number = 0;
			
			running = Input.check(Key.SHIFT);
			
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
			
			vx = int(Input.check(Key.RIGHT)) - int(Input.check(Key.LEFT));
			vy = int(Input.check(Key.DOWN)) - int(Input.check(Key.UP));
			
			if (running) {
				vx *= RUN_SPEED;
				vy *= RUN_SPEED;
			} else {
				vx *= WALK_SPEED;
				vy *= WALK_SPEED;
			}
			
			if (vx && vy) {
				vx /= Math.sqrt(2);
				vy /= Math.sqrt(2);
			}
			
			if (vx || vy) {
				moveBy(vx, vy, "solid");
				
				targetAngle = Math.atan2(vy, vx) * FP.DEG;
				
				var anim:String;
				
				if (vx < 0) {
					anim = "left";
				} else if (vx > 0) {
					anim = "right";
				} else if (vy < 0) {
					anim = "up";
				} else {
					anim = "down";
				}
				
				if (running) anim += "-running";
				
				sprite.play(anim);
			} else {
				sprite.stop();
				
				if (sprite.frame >= 8) sprite.frame -= 8;
			}
			
			angle += FP.angleDiff(angle, targetAngle) * 0.3;
			
			eyesShut = Input.check(Key.SPACE);
			
			if (collideTypes(["spikes", "enemy"], x, y)) {
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
			super.render();
			
			if (! dead) {
				var viewAngle:Number = VIEW_ANGLE;
				var dx1:Number = Math.cos((angle - viewAngle) * FP.RAD);
				var dy1:Number = Math.sin((angle - viewAngle) * FP.RAD);
				var dx2:Number = Math.cos((angle + viewAngle) * FP.RAD);
				var dy2:Number = Math.sin((angle + viewAngle) * FP.RAD);
			
				var coneLength: Number = 100;
				
				var headX:Number = x;
				var headY:Number = y - 13;
			
				Draw.linePlus(headX, headY, headX + dx1 * coneLength, headY + dy1 * coneLength, 0xdddddd);
				Draw.linePlus(headX, headY, headX + dx2 * coneLength, headY + dy2 * coneLength, 0xdddddd);
			}
		}
	}
}

