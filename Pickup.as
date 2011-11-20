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
		
		public function Pickup (_x:Number, _y:Number, tile:int)
		{
			x = _x;
			y = _y;
			
			sprite = new Spritemap(Gfx, 16, 16);
			
			var frames:Array;
			
			if (tile == Room.SCROLL) {
				frames = [0,1];
			} else if (tile == Room.BLINDFOLD) {
				frames = [2,3];
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
			if (p && ! Player.eyesShut) {
				if (! stamp) {
					var bgColor:int = 0x09141d;
					var borderColor:int = 0x55d4dc;
					
					var bitmap:BitmapData = new BitmapData(FP.width*0.5, FP.height*0.5, false, borderColor);
					
					FP.rect.x = 1;
					FP.rect.y = 1;
					FP.rect.width = bitmap.width - 2;
					FP.rect.height = bitmap.height - 2;
					
					bitmap.fillRect(FP.rect, bgColor);
					
					stamp = new Stamp(bitmap);
					stamp.scrollX = 0;
					stamp.scrollY = 0;
					stamp.relative = false;
					stamp.x = FP.width*0.25;
					stamp.y = FP.height*0.25;
					
					addGraphic(stamp);
					
					var text:Text = new Text("Test");
					
					text.scrollX = 0;
					text.scrollY = 0;
					text.relative = false;
					text.x = (FP.width - text.width) * 0.5;
					text.y = (FP.height - text.height) * 0.5;
					
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

