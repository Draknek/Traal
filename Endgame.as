package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	import flash.geom.Rectangle;
	import flash.geom.Point;	
	
	public class Endgame extends Entity
	{
		public var scrolls:Array = [];
		
		public var stage:int = 0;
		public var timer:int = 0;
		
		public var scrollDistance:Number = 32;
		public var spacing:Number = 0;
		
		public var scrollCount:int;
		
		public var cx:int;
		public var cy:int;
		
		public static function summon (p:Player):void
		{
      trace('summon count:'+Player.scrollCount);
			if (Player.scrollCount >= 2) {
				p.active = false;
		
				p.sprite.stop();
		
				p.world.add(new Endgame(p.x, p.y));
			}
		}
		
		public function Endgame(_x:Number, _y:Number)
		{
			x = _x;
			y = _y;
		}

		public override function added (): void
		{
			var white:Image = Image.createRect(FP.width, FP.height, 0x05080b);
			
			white.scrollX = 0;
			white.scrollY = 0;
			
			world.addGraphic(white, 50);
			
			Audio.play("endgame");
			cx = world.camera.x;
			cy = world.camera.y;
			
			scrollCount = Player.scrollCount;
			
			function addScroll (i:int):void {
				var scroll:Image = new Spritemap(Pickup.Gfx, 16, 16);
				scroll.centerOO();
				scroll.alpha = 0;
				
				var angle:Number = getAngle(i);
				
				FP.tween(scroll, {alpha: 1}, 60, function (): void {
					FP.tween(scroll, {
						x: Math.cos(angle*FP.RAD)*scrollDistance,
						y: Math.sin(angle*FP.RAD)*scrollDistance
					}, 40, function ():void {
						stage = 2;
						timer = 0;
					});
				});
				
				world.addGraphic(scroll, -2030, x, y);
				
				scrolls.push(scroll);
			}
			
			for (var i:int = 0; i < scrollCount; i++) {
				addScroll(i);
			}
		}

		public override function update (): void
		{
			timer++;
			
			var i:int;
			
			if (stage == 2 && timer > 120) {
				stage = 3;
				
				FP.tween(this, {scrollDistance: 40}, 60);
				FP.tween(this, {spacing: 1}, 180);
			}
			
			if (stage == 3) {
				timer++;
				world.camera.x = cx + Math.random() * 2;
				world.camera.y = cy + Math.random() * 2;
				
				if (timer > 320) {
					stage = 4;
					FP.tween(this, {scrollDistance: 60}, 60);
				}
			}
			
			if (stage == 4) {
				timer++;
				world.camera.x = cx + Math.random() * 8;
				world.camera.y = cy + Math.random() * 8;
				
				if (timer > 600) {
					stage = 5;
					
					var secretEnd:Boolean = (scrollCount == Player.scrollCountTotal);
					
					secretEnd = false;
					
					FP.tween(this, {scrollDistance: 0}, 120, function ():void {
						stage = 6;
						
						var white:Image = Image.createRect(FP.width, FP.height, 0x09141d);
						
						white.scrollX = 0;
						white.scrollY = 0;
						
						white.alpha = 0;
						
						world.addGraphic(white, -2050);
						
						FP.tween(white, {alpha: 1}, 15, function ():void {
							stage = 7;
							
							if (secretEnd) {
								for each (scroll in scrolls) {
									scroll.visible = false;
								}
								
								secret(white);
							} else {
								FP.alarm(100, Audio.endgameOut);
								FP.alarm(300, function ():void {
									FP.world = new Credits;
								});
							}
						});
					});
				}
			}
			
			if (stage == 5) {
				timer++;
				world.camera.x = cx + Math.random() * 12;
				world.camera.y = cy + Math.random() * 12;
			}
			
			if (stage == 6) {
				timer++;
				world.camera.x = cx + Math.random() * 4;
				world.camera.y = cy + Math.random() * 4;
			}
			
			if (stage >= 2 && stage < 6) {
				for each (var scroll:Image in scrolls) {
					var angle:Number = getAngle(i) + (timer * 2);
					
					scroll.x = Math.cos(angle*FP.RAD)*scrollDistance;
					scroll.y = Math.sin(angle*FP.RAD)*scrollDistance;
					
					i++;
				}
			}
		}
		
		public function getAngle (i:int):Number
		{
			var missing:int = Player.scrollCountTotal - scrollCount;
			var numerator:Number = (i + missing * 0.5 + 0.5) * 360;
			var angle1:Number = numerator / Player.scrollCountTotal;
			var angle2:Number = numerator / (Player.scrollCountTotal - missing);
			return FP.lerp(angle1, angle2, spacing) - 90;
		}
		
		private function secret (screenCover:Image):void {
			
		}
	}
}
