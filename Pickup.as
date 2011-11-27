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
		
		public var scroll:Scroll;
		
		[Embed(source="images/pickups.png")]
		public static const Gfx: Class;
		
		public static var ignore:Object = {};
		
		public var id:String;
		
		public var readable:Boolean;
		public var message:String;
		
		public var action:Function;
		
		public var tileID:int;
		
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
			
			tileID = tile;
			
			sprite = new Spritemap(Gfx, 16, 16);
			
			var frames:Array;
			
			if (tile == Room.SCROLL) {
				frames = [0,1];
				readable = false;
				message = "An abandoned scroll, written in an ancient language you don't recognise.";
			} else if (tile == Room.BLINDFOLD) {
				frames = [2,3];
				readable = true;
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
				if (! scroll) {
					p.pickups[id] = this;
					
					if (action != null) {
						action();
					}
					
					var text:Text;
					var glyph:Glyph;
					
					if(readable)
					{
						text = new Text(message, 0, 0, {align: "center", width: FP.width * 0.45, wordWrap: true, color: 0x08131b});					
						text.scrollX = 0;
						text.scrollY = 0;
						text.relative = false;
						text.x = (FP.width - text.width) * 0.5;
						text.y = (FP.height - text.textHeight) * 0.5;
						scroll = new Scroll(text.textWidth, text.textHeight);
					} else
					{
						glyph = new Glyph(message, FP.width * 0.45);
						glyph.scrollX = 0;
						glyph.scrollY = 0;
						glyph.relative = false;					
						glyph.x = (FP.width - glyph.width)*0.5-7;
						glyph.y = (FP.height - glyph.height)*0.5;
						scroll = new Scroll(glyph.width, glyph.height);
					}				
					
					FP.rect.x = 1;
					FP.rect.y = 1;
					FP.rect.width = scroll.width - 2;
					FP.rect.height = scroll.height - 2;
					
					scroll.scrollX = 0;
					scroll.scrollY = 0;
					scroll.relative = false;
					scroll.x = (FP.width - scroll.width)*0.5;
					scroll.y = (FP.height - scroll.height)*0.5;
					
					addGraphic(scroll);
					if(readable) {
						addGraphic(text);
					} else {
						addGraphic(glyph);
					}
					
					layer = -20;
				}
				
				p.active = false;
				p.sprite.stop();
				
				if (Main.mouseControl ? Input.mousePressed : Input.pressed(Key.SPACE)) {
					world.remove(this);
					p.active = true;
				}
			}
		}
		
		public override function render (): void
		{
			super.render();
			
			if (scroll) {       
        scroll.renderMask(Room.maskBuffer, FP.zero, FP.zero);        
			}	
		}
	}
}

