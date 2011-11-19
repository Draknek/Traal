package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	public class Spike extends Entity
	{
		public var sprite:Spritemap;
	
		[Embed(source="images/spikes.png")]
		public static const Gfx:Class;
	
		public function Spike(_x:Number, _y:Number)
		{
			x = _x;
			y = _y;
			
			sprite = new Spritemap(Gfx, 16, 16);
			sprite.add("prod", FP.frames(0, sprite.frameCount-1), 0.175);
			sprite.play("prod");
			graphic = sprite;			
			type = "spikes";
		}
	}
}