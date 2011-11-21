package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	
	public class Pickup extends Entity
	{
		public var sprite:Spritemap;
		
		public var stamp:Stamp;
		
		[Embed(source="images/pickups.png")]
		public static const Gfx: Class;
		
		private static var ignore:Object = {};
		
		public var id:String;
		
		public var message:String;
		
		public var action:Function;
		
		public function Pickup (_x:Number, _y:Number, tile:int)
		{
			x = _x;
			y = _y;
			
			id = "pickup-" + int(x) + ":" + int(y);
			
			if (ignore[id]) {
				x = -5000;
				y = -5000;
				return;
			}
			
			sprite = new Spritemap(Gfx, 16, 16);
			
			var frames:Array;
			
			if (tile == Room.SCROLL) {
				frames = [0,1];
				message = "An abandoned scroll, written in an ancient language you don't recognise.";
				action = function ():void {
					Player.scrollCount++;
				}
			} else if (tile == Room.BLINDFOLD) {
				frames = [2,3];
				message = "You found the blindfold!\n\nPress SPACE\nto wear it.";
				action = function ():void {
					Player.hasBlindfold = true;
				}
			}
			
			sprite.add("float", frames, 0.1);
			
			sprite.play("float");
			
			graphic = sprite;
			
			setHitbox(16, 16);
			
			type = "pickup";
		}
		
		public override function update (): void
		{
			var p:Player = collide("player", x, y) as Player;
			if (p && ! Player.eyesShut && ! Player.justOpenedEyes) {
				if (! stamp) {
					ignore[id] = true;
					
					if (action != null) {
						action();
					}
					
					var bgColor:int = 0x09141d;
					var borderColor:int = 0x55d4dc;
					
					var text:Text = new Text(message, 0, 0, {align: "center", width: FP.width * 0.45, wordWrap: true});
					
					text.scrollX = 0;
					text.scrollY = 0;
					text.relative = false;
					text.x = (FP.width - text.width) * 0.5;
					text.y = (FP.height - text.textHeight) * 0.5;
					
					var bitmap:BitmapData = new BitmapData(text.textWidth + 10, text.textHeight+ 10, false, borderColor);
					
					FP.rect.x = 1;
					FP.rect.y = 1;
					FP.rect.width = bitmap.width - 2;
					FP.rect.height = bitmap.height - 2;
					
					bitmap.fillRect(FP.rect, bgColor);
					
					stamp = new Stamp(bitmap);
					stamp.scrollX = 0;
					stamp.scrollY = 0;
					stamp.relative = false;
					stamp.x = (FP.width - stamp.width)*0.5;
					stamp.y = (FP.height - stamp.height)*0.5;
					
					addGraphic(stamp);
					addGraphic(text);
					
					layer = -20;
				}
				
				p.active = false;
				p.sprite.stop();
				
				if (Input.pressed(Key.SPACE)) {
					world.remove(this);
					p.active = true;
				}
			}
		}
		
		public override function render (): void
		{
			super.render();
			
			if (stamp) {
				FP.rect.x = stamp.x;
				FP.rect.y = stamp.y;
				FP.rect.width = stamp.width;
				FP.rect.height = stamp.height;
				
				Room.maskBuffer.fillRect(FP.rect, 0xffffffff);
			}	
		}
	}
}

