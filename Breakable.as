package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	public class Breakable extends Entity
	{
		public var sprite:Spritemap;
	
		[Embed(source="images/breakable.png")]
		public static const Gfx:Class;
	
		public function Breakable(_x:Number, _y:Number)
		{
			x = _x;
			y = _y;
			
			sprite = new Spritemap(Gfx, 16, 16);
			graphic = sprite;			
			type = "breakable";
			setHitbox(16, 16);
		}
	}
}
