package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	import flash.geom.Rectangle;
	import flash.geom.Point;	
	
	public class Fountain extends Entity
	{
		public var sprite:Spritemap;
	
		[Embed(source="images/fountain.png")]
		public static const Gfx:Class;
		
		[Embed(source="images/fountain_circle.png")]
		public static const CircleGfx: Class;		
	
		public function Fountain(_x:Number, _y:Number)
		{
			x = _x;
			y = _y;
			
			sprite = new Spritemap(Gfx, 16, 16);
			sprite.add("cycle", FP.frames(0, sprite.frameCount-1), 0.2);
			sprite.play("cycle");
			graphic = sprite;
			setHitbox(16, 16);
		}

		public override function render (): void
		{
			super.render();
			var circle:BitmapData = FP.getBitmap(CircleGfx);
			FP.point.x = x+8-48-world.camera.x;
			FP.point.y = y+8-48-world.camera.y;
			Room.maskBuffer.copyPixels(circle, circle.rect, FP.point, null, null, true);
		}			
	}
}
