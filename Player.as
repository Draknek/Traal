package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.geom.Matrix;
	
	public class Player extends Entity
	{
		public var vx: Number = 0;
		public var vy: Number = 0;
		
		public var angle:Number = 0;
		public var targetAngle:Number = 0;
		
		public static const WALK_SPEED: Number = 1;
		public static const RUN_SPEED: Number = 2;
		public static const TURN_SPEED: Number = 15;
		public static const VIEW_ANGLE: Number = 20;
		
		public static var eyesShut:Boolean = false;
		public static var hasBlindfold:Boolean = false;
		public static var justOpenedEyes:Boolean = false;
		public static var justReadScroll:Boolean = false;
		public static var clickedPlayer:Boolean = false;
		
		public static var scrollCountTotal:int = 0;
		public static var scrollCount:int = 0;
		
		public static var playTime:Number = 0;
		public static var numDeaths:int = 0;
		
		public var dead:Boolean = false;
		public var running:Boolean = false;
		
		public var sprite:Spritemap;
		public var death:Spritemap;
		
		[Embed(source="images/player.png")]
		public static const Gfx: Class;
		
		[Embed(source="images/exclamation.png")]
		public static const ExclamationGfx: Class;
		
		[Embed(source="images/player_circle.png")]
		public static const CircleGfx: Class;
		
		[Embed(source="images/death.png")]
		public static const DeathGfx: Class;		
		
		private var array:Array = [];
		
		public var pickups:Object = {};
		
		public static function clearPersistentData():void
		{
			Pickup.ignore = {};
			scrollCount = 0;
			eyesShut = false;
			hasBlindfold = false;
			justOpenedEyes = false;
			playTime = 0;
			numDeaths = 0;
		}
		
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
			
			sprite.frame = 6;
			
			sprite.x = -sprite.width*0.5;
			sprite.y = -sprite.height + 9;
			
			graphic = sprite;
			
			death = new Spritemap(DeathGfx,16,32);
			death.add("die", [0, 2], 0.04);
			death.x = -death.width*0.5;
			death.y = -death.height+13;
			
			setHitbox(6, 5, 3, -1);
			
			type = "player";
		}
		
		public override function added ():void
		{
			Main.playerDupe.bitmapData = sprite._buffer;
			Main.playerDupe.x = sprite.x * FP.screen.scale;
			Main.playerDupe.y = sprite.y * FP.screen.scale;
		}
		
		public override function update (): void
		{
			var e:Entity;
			var angleDiff:Number;
			
			playTime += FP.elapsed;
			
			if (dead) return;
			
			if (! running) {
				if (Main.joystick) {
					var joystickAngle:Number = FP.angle(0, 0, Main.joystickDir.x, Main.joystickDir.y);
					
					angleDiff = FP.angleDiff(angle, joystickAngle);
					
					vx = 0;
					vy = 0;
					
					if (! clickedPlayer && ! justReadScroll && (Main.joystickDir.x || Main.joystickDir.y)) {
						if (Input.mouseDown && angleDiff > -VIEW_ANGLE && angleDiff < VIEW_ANGLE) {
							vx = Main.joystickDir.x;
							vy = Main.joystickDir.y;
							
							var snap:Number = 0.15;
							
							if (vx > -snap && vx < snap) {
								vy = (vy > 0) ? 1 : -1;
								vx = 0;
							}
							else if (vy > -snap && vy < snap) {
								vx = (vx > 0) ? 1 : -1;
								vy = 0;
							}
						}
						
						targetAngle = joystickAngle;
						if (joystickAngle > 180) {
							targetAngle -= 360;
						}
					}
				} else if (Main.mouseControl) {
					var mouseAngle:Number = FP.angle(x, y, world.mouseX, world.mouseY);
					
					var mouseDistance:Number = FP.distance(x, y, world.mouseX, world.mouseY);
					
					angleDiff = FP.angleDiff(angle, mouseAngle);
					
					vx = 0;
					vy = 0;
					
					if (mouseDistance >= 8 && ! clickedPlayer && ! justReadScroll && (! Main.touchscreen || Input.mouseDown)) {
						if (Input.mouseDown && angleDiff > -VIEW_ANGLE && angleDiff < VIEW_ANGLE) {
							vx = Math.cos(mouseAngle * FP.RAD);
							vy = Math.sin(mouseAngle * FP.RAD);
						}
						
						targetAngle = mouseAngle;
						if (mouseAngle > 180) {
							targetAngle -= 360;
						}
					}
				} else {
					vx = int(Input.check(Key.RIGHT)) - int(Input.check(Key.LEFT));
					vy = int(Input.check(Key.DOWN)) - int(Input.check(Key.UP));
				
					if (vx && vy) {
						vx /= Math.sqrt(2);
						vy /= Math.sqrt(2);
					}
					
					if (vx || vy) {
						targetAngle = Math.atan2(vy, vx) * FP.DEG;
					}
				}
			
				vx *= WALK_SPEED;
				vy *= WALK_SPEED;
			}
			
			if (vx || vy) {
				var solidTypes:Array = ["solid", "fountain"];
				
				if (! running) solidTypes.push("breakable");
				
				moveBy(vx, vy, solidTypes);
			}
			
			layer = -y;
			
			if (vx || vy || Main.mouseControl || Main.joystick) {
				if (vx || vy) {
					targetAngle = FP.angle(0, 0, vx, vy);
					if (targetAngle > 180) {
						targetAngle -= 360;
					}
				}
				
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
			}
			
			if (! vx && ! vy) {
				sprite.index = 1;
				sprite.stop();
				
				if (sprite.frame >= 8) sprite.frame -= 8;
			}
			
			if (! running || vx || vy) {
				var turnAmount:Number = FP.angleDiff(angle, targetAngle) * 0.3;
				if(turnAmount > TURN_SPEED) turnAmount = TURN_SPEED;
				if(turnAmount < -TURN_SPEED) turnAmount = -TURN_SPEED;
				angle += turnAmount;
			}
			
			justOpenedEyes = false;
			
			if (hasBlindfold && ! running) {
				var toggleBlindfold:Boolean = false;
				
				if (Main.mouseControl) {
					distance = FP.distance(x, y, world.mouseX, world.mouseY);
					
					if (distance < 16) {
						if (Input.mousePressed) {
							clickedPlayer = true;
						}
					}
					
					if (clickedPlayer && ! Input.mouseDown) {
						toggleBlindfold = true;
						clickedPlayer = false;
					}
					
					if (distance >= 16) {
						clickedPlayer = false;
					}
				} else {
					toggleBlindfold = Input.pressed(Key.SPACE);
				}
				
				if (toggleBlindfold) {
					eyesShut = ! eyesShut;
					
					Audio.blindfold(eyesShut);
					
					if (! eyesShut) {
						justOpenedEyes = true;
					}
				}
			}
			
			e = collideTypes(["enemy", "spikes"], x, y);
			
			// Make more lenient with touch controls
			if (Main.mouseControl && e is Spike) {
				var change:int = 2;
				setHitbox(6-change*2, 5-change*2, 3-change, -1-change);
				e = collide("spikes", x, y);
				setHitbox(6, 5, 3, -1);
			}
			
			if (e) {
				numDeaths++;
				dead = true;
				eyesShut = false;
				graphic = death;
				death.play("die");
				Room(world).particles.addBurst(Particles.DEATH, x, y, vx/2, vy/2);
				FP.alarm(60, reloadAfterDeath);
				Audio.play("death");
			}
			
			if (running) {
				e = collide("breakable", x, y);
				
				if (e) {
					Room(world).particles.addBurst(Particles.BREAKABLE, x+8, y+8);
					world.remove(e);
				}
			}
			
			e = world.typeFirst("fountain");
			
			var i:int;
			
			if (e) {
				Audio.background(false);
			} else {
				Audio.background(true);
			}
			
			if (e && !eyesShut) {
				var distance:Number = FP.distance(x, y, e.x, e.y);
				
				if (distance < 32) {
					Endgame.summon(this);
				}
			}
			
			if (! running && ! eyesShut) {
				array.length = 0;
				world.getType("enemy", array);
			
				for each (e in array) {
					var angleThere:Number = FP.angle(x, y, e.x, e.y);
				
					angleDiff = FP.angleDiff(angle, angleThere);
				
					if (angleDiff < -VIEW_ANGLE || angleDiff > VIEW_ANGLE) {
						continue;
					}
					
					if (world.collideLine("solid", x, y, e.x, e.y)) {
						continue;
					}
					
					seenEnemy(e);
					
					break;
				}
			}
			
			if (! Input.mouseDown) {
				justReadScroll = false;
			}
		}
		
		private function reloadAfterDeath ():void
		{
			if (! world) return;
			Room(world).reloadState();
		}
		
		private function seenEnemy (e:Entity):void
		{
			running = true;
			
			vx = 0;
			vy = 0;
			
			if(e is Eye) {
				Eye(e).chase(this);
				Audio.play("eye");
			}
				
			var stamp1:Stamp = new Stamp(ExclamationGfx);
			stamp1.x = x - stamp1.width*0.5;
			stamp1.y = y - stamp1.height + sprite.y;
			var stampEntity1:Entity = world.addGraphic(stamp1, -5);
			
			var stamp2:Stamp = new Stamp(ExclamationGfx);
			stamp2.x = -stamp2.width*0.5;
			stamp2.y = -stamp2.height - 6;
			e.addGraphic(stamp2);
			e.layer = -5;
			
			if(! (e is Eye)) {
				Audio.play("spotted");
			}
			
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
		}
		
		public override function render (): void
		{
			sprite.updateBuffer();
			
			super.render();
			
			var headX:Number = x - world.camera.x;
			var headY:Number = y - world.camera.y;
			
			Main.sprite.x = FP.screen.x + headX*FP.screen.scale;
			Main.sprite.y = FP.screen.y + headY*FP.screen.scale;
			
			if (! eyesShut) {
				var viewAngle:Number = VIEW_ANGLE;
				var dx1:Number = Math.cos((angle - viewAngle) * FP.RAD);
				var dy1:Number = Math.sin((angle - viewAngle) * FP.RAD);
				var dx2:Number = Math.cos((angle + viewAngle) * FP.RAD);
				var dy2:Number = Math.sin((angle + viewAngle) * FP.RAD);
			
				var coneLength: Number = FP.stage.stageWidth + FP.stage.stageHeight;
				
				var circle:BitmapData = FP.getBitmap(CircleGfx);
				FP.point.x = headX-24;
				FP.point.y = headY-24;
				FP.rect.x = 0;
				FP.rect.y = 0;
				FP.rect.width = circle.width;
				FP.rect.height = circle.height;
				Room.maskBuffer.copyPixels(circle, FP.rect, FP.point, null, null, true);
			
				Main.playerCircleDupe.visible = true;
				Main.lightDupe.x = Main.lightDupe.y = 0;
				
				var shape:Sprite = Main.lightDupe;
				shape.graphics.clear();
				shape.graphics.beginFill(0x09141d, 1);
				shape.graphics.moveTo(0,0);
				shape.graphics.lineTo(dx1 * coneLength, dy1 * coneLength);
				shape.graphics.lineTo(dx2 * coneLength, dy2 * coneLength);
				shape.graphics.lineTo(0,0);
				shape.graphics.endFill();
				
				matrix.tx = headX;
				matrix.ty = headY;
				Room.maskBuffer.draw(shape, matrix);
			} else {
				Main.playerCircleDupe.visible = false;
				Main.lightDupe.x = -Main.sprite.x;
				Main.lightDupe.y = -Main.sprite.y;
				Main.lightDupe.graphics.clear();
				Main.lightDupe.graphics.beginFill(0x0, 1.0);
				Main.lightDupe.graphics.drawRect(0, 0, FP.stage.stageWidth, FP.stage.stageHeight);
				Main.lightDupe.graphics.endFill();
			}
		}
		
		private static var matrix:Matrix = new Matrix;
	}
}

