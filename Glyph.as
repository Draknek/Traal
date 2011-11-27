package 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import net.flashpunk.*;
	import net.flashpunk.graphics.*;

	public class Glyph extends Graphic
	{
		[Embed(source="images/glyph.png")]
		public static const Gfx: Class;
    
		private static const TILE_SIZE:int = 14;
    
		private var _bitmap:BitmapData;
  
		public function Glyph(message:String, width:int)
		{
			message = message.toLowerCase();
			var sprite:Spritemap = new Spritemap(Gfx, TILE_SIZE, TILE_SIZE);
			var tileW:int = width/TILE_SIZE;
			var tileH:int = message.length/tileW;
			if(tileH*tileW < message.length) tileH++;
      
			_bitmap = new BitmapData(tileW*TILE_SIZE, tileH*TILE_SIZE, true, 0x00000000);
      
			var x:int = 0;
			var y:int = 0;
			for(var i:int=0; i<message.length; i++) {
				var char:int = message.charCodeAt(i)-97;
				var valid:Boolean = char >= 0 && char <= 26;
				if(valid) {
					sprite.frame = char;
					sprite.render(_bitmap, new Point(x*TILE_SIZE,y*TILE_SIZE), FP.zero);
				}
				if(valid || x > 0) x++;
				if(x >= tileW) {
					y++;
					x=0;
				}
			}
		}
		
		override public function render(target:BitmapData, point:Point, camera:Point):void 
		{
			_point.x = point.x + x - camera.x * scrollX + TILE_SIZE/2;
			_point.y = point.y + y - camera.y * scrollY;
			target.copyPixels(_bitmap, _bitmap.rect, _point, null, null, true);
		}

		public function get width():uint { return _bitmap.rect.width; }
		public function get height():uint { return _bitmap.rect.height; }
	}  
}