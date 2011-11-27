package 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import net.flashpunk.*;
  import net.flashpunk.graphics.*;

	public class Scroll extends Graphic
	{
    [Embed(source="images/scroll.png")]
		public static const Gfx: Class;
    
    private static const TILE_SIZE:int = 16;
    
    private var _bitmap:BitmapData;
  
		public function Scroll(width:int, height:int) 
		{
      var sprite:Spritemap = new Spritemap(Gfx, TILE_SIZE, TILE_SIZE);
      var tileW:int = width/TILE_SIZE+3;
      var tileH:int = height/TILE_SIZE+3;
      
      width = tileW*TILE_SIZE;
      height = tileH*TILE_SIZE;
      
      _bitmap = new BitmapData(width, height, true, 0x00000000);
      
      for(var i:int=0; i<tileW; i++) {
        for(var j:int=0; j<tileH; j++) {
          var sprX:int = 1;
          var sprY:int = 1;
          if(i==0) sprX = 0;
          if(i==tileW-1) sprX = 2;
          if(j==0) sprY = 0;
          if(j==tileH-1) sprY = 2;
          sprite.setFrame(sprX,sprY);
          sprite.render(_bitmap, new Point(i*TILE_SIZE,j*TILE_SIZE), FP.zero);
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