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
		
		public var hasSquished:Boolean;
		
		public function Blob (_x:Number, _y:Number)
		{
			x = _x + 8;
			y = _y + 8;
			
			sprite = new Spritemap(Gfx, 16, 16);
			
			sprite.add("bounce", FP.frames(0, sprite.frameCount-1), 0.1);
			
			sprite.play("bounce");
			
			sprite.centerOO();
			
			graphic = sprite;
			
			setHitbox(16, 16, 8, 8);
			
			type = "enemy";
			
			hasSquished = false;
		}
		
		public override function update (): void
		{	
			if(sprite.frame == 1)
			{
				if(!hasSquished)
				{
					Room(world).particles.addBurst(Particles.SQUISH, x-2, y+7);
					hasSquished = true;
				}
			} else
			{
				hasSquished = false;
			}
			
			layer = -y;			
		}
	}
}

