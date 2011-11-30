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
		
		public function getScrollMessage():String
		{
			trace("scrollID:"+id);
			switch(id)
			{
				case "pickup-1648:1408": return "the last person to find this was impaled while getting out";
				case "pickup-2080:1312": return "beware stranger this is an evil place no good will happen here";
				case "pickup-2432:1584": return "only a fool would suffer great danger for little gain";
				case "pickup-2432:1072": return "these scrolls will not help you they exist for my amusement alone";
				case "pickup-2496:832": return "sometimes one will see more when one only looks ahead";
				case "pickup-3056:608": return "broken glass cuts deep and nothing here can fix it";
				case "pickup-1744:592": return "three wise eyes see no evil see no evil and see no evil";
				case "pickup-1120:848": return "evil twins are twins in evil";
				case "pickup-1120:624": return "when all evil faces you wear only darkness";
				case "pickup-992:336": return "an end awaits you beyond here but it is not a pretty one";
				case "pickup-1248:336": return "whatever you do do not collect all of these scrolls a terrible fate awaits";
				default: return "An abandoned scroll, written in an ancient language you don't recognise.";
			}
		}
		
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
				message = getScrollMessage();
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
				
					Audio.play("paper");
					
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
					
					layer = -2001;
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


