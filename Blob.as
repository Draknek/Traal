package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	public class Blob extends Entity
	{
		public var sprite:Spritemap;
		
		[Embed(source="images/blob.png")]
		public static const Gfx: Class;
		
		public function Blob (_x:Number, _y:Number)
		{
			x = _x;
			y = _y;
			
			sprite = new Spritemap(Gfx, 16, 16);
			
			sprite.add("bounce", FP.frames(0, sprite.frameCount-1), 0.1);
			
			sprite.play("bounce");
			
			graphic = sprite;
			
			setHitbox(16, 16);
		}
		
		public override function update (): void
		{
			
		}
	}
}

