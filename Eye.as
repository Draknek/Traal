package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	public class Eye extends Entity
	{
		public var sprite:Spritemap;
		
		[Embed(source="images/eye.png")]
		public static const Gfx: Class;
		public var dir:int;
		public var shouldTurn:Boolean;
		
		public function Eye (_x:Number, _y:Number)
		{
			dir = 0;
			shouldTurn = false;
			x = _x + 8;
			y = _y + 8;
			
			sprite = new Spritemap(Gfx, 16, 16);
			sprite.add("bounce", FP.frames(0, sprite.frameCount-1), 0.1);			
			sprite.play("bounce");
			
			sprite.centerOO();
			
			graphic = sprite;			
			setHitbox(16, 16, 8, 8);
			
			type = "enemy";
		}
		
		public override function moveCollideX(e:Entity):Boolean
		{
			shouldTurn = true;
			return true;
		}
		
		public override function moveCollideY(e:Entity):Boolean
		{
			shouldTurn = true;
			return true;
		}		
		
		public override function update (): void
		{
			var speed:Number = 0.5;
			var vx:Number = 0;
			var vy:Number = 0;
			switch(dir)
			{
				case 0: vy -= speed; break;
				case 1: vx += speed; break;
				case 2: vy += speed; break;
				case 3: vx -= speed; break;
			}
			
			moveBy(vx, vy, ["solid", "spikes", "enemy"]);
			
			if(shouldTurn)
			{
				dir = (dir+1)%4;
				shouldTurn = false;
			}
		}
	}
}