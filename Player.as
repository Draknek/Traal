package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
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
		
		[Embed(source="images/exclamation.png")]
		public static const ExclamationGfx: Class;
		
		[Embed(source="images/player_circle.png")]
		public static const CircleGfx: Class;
		
		public var array:Array = [];
		
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
			sprite.y = -sprite.height + 9;
			
			graphic = sprite;
			
			setHitbox(6, 6, 3, -2);
			
			layer = -10;
			type = "player";
		}
		
		public override function added ():void
		{
			eyesShut = Input.check(Key.SPACE);
		}
		
		public override function update (): void
		{
			var e:Entity;
			
			if (dead) {
				sprite.color = 0xFF0000;
				sprite.stop();
				return;
			}
			
			if (! running) {
				vx = int(Input.check(Key.RIGHT)) - int(Input.check(Key.LEFT));
				vy = int(Input.check(Key.DOWN)) - int(Input.check(Key.UP));
				
				vx *= WALK_SPEED;
				vy *= WALK_SPEED;
				
				if (vx && vy) {
					vx /= Math.sqrt(2);
					vy /= Math.sqrt(2);
				}
			}
			
			if (vx || vy) {
				var solidTypes:Array = ["solid"];
				
				if (! running) solidTypes.push("breakable");
				
				moveBy(vx, vy, solidTypes);
				
				targetAngle = Math.atan2(vy, vx) * FP.DEG;
				
				var anim:String;
				
				if (targetAngle < -130) {
					anim = "left";
				} else if (targetAngle < -50) {
					anim = "down";
				} else if (targetAngle < 50) {
					anim = "right";
				} else if (targetAngle < 130) {
					anim = "up";
				} else {
					anim = "left";
				}
				
				if (running) anim += "-running";
				
				sprite.play(anim);
			} else {
				sprite.stop();
				
				if (sprite.frame >= 8) sprite.frame -= 8;
			}
			
			if (! running || vx || vy) {
				angle += FP.angleDiff(angle, targetAngle) * 0.3;
			}
			
			eyesShut = Input.check(Key.SPACE);
			
			if (collideTypes(["spikes", "enemy"], x, y)) {
				dead = true;
				FP.alarm(30, function ():void {
					if (! world) return;
					Room(world).reloadState();
				});
			}
			
			if (running) {
				e = collide("breakable", x, y);
				
				if (e) {
					Room(world).particles.addBurst(Particles.BREAKABLE, x+8, y+8);
					world.remove(e);
				}
			}
			
			if (! running && ! eyesShut) {
				array.length = 0;
				world.getType("enemy", array);
			
				for each (e in array) {
					var angleThere:Number = FP.angle(x, y, e.x, e.y);
				
					var angleDiff:Number = FP.angleDiff(angle, angleThere);
				
					if (angleDiff < -VIEW_ANGLE || angleDiff > VIEW_ANGLE) {
						continue;
					}
					
					if (world.collideLine("solid", x, y, e.x, e.y)) {
						continue;
					}
					
					running = true;
					
					vx = 0;
					vy = 0;
					
					if(e is Eye)
						Eye(e).chase(this);
						
					var stamp1:Stamp = new Stamp(ExclamationGfx);
					stamp1.x = x - stamp1.width*0.5;
					stamp1.y = y - stamp1.height + sprite.y;
					var stampEntity1:Entity = world.addGraphic(stamp1, -5);
					
					var stamp2:Stamp = new Stamp(ExclamationGfx);
					stamp2.x = -stamp2.width*0.5;
					stamp2.y = -stamp2.height - 6;
					e.addGraphic(stamp2);
					e.layer = -5;
					
					FP.alarm(20, function ():void {
						if (! world) return;
						
						world.remove(stampEntity1);
						
						vx = x - e.x;
						vy = y - e.y;
				
						var vz:Number = Math.sqrt(vx*vx + vy*vy);
				
						vx /= vz;
						vy /= vz;
					
						FP.alarm(60, function ():void {
							if (! world) return;
							running = false;
							stamp2.visible = false;
							e.layer = 0;
						});
					});
					
					break;
				}
			}
		}
		
		public override function render (): void
		{
			super.render();
			
			if (! dead && ! eyesShut) {
				var viewAngle:Number = VIEW_ANGLE;
				var dx1:Number = Math.cos((angle - viewAngle) * FP.RAD);
				var dy1:Number = Math.sin((angle - viewAngle) * FP.RAD);
				var dx2:Number = Math.cos((angle + viewAngle) * FP.RAD);
				var dy2:Number = Math.sin((angle + viewAngle) * FP.RAD);
			
				var coneLength: Number = 500;
				
				var headX:Number = x - world.camera.x;
				var headY:Number = y - world.camera.y;
				
				var circle:BitmapData = FP.getBitmap(CircleGfx);
				FP.point.x = headX-24;
				FP.point.y = headY-24;
				Room.maskBuffer.copyPixels(circle, circle.rect, FP.point);
			
				var shape:Sprite = FP.sprite;
				shape.graphics.clear();
				shape.graphics.beginFill(0xffffff, 1); // solid black
				shape.graphics.moveTo(headX, headY);
				shape.graphics.lineTo(headX + dx1 * coneLength, headY + dy1 * coneLength);
				shape.graphics.lineTo(headX + dx2 * coneLength, headY + dy2 * coneLength);
				shape.graphics.lineTo(headX, headY);
				shape.graphics.endFill();
				Room.maskBuffer.draw(shape);
			}
		}
	}
}

