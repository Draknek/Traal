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
		public var chaseTimer:int;
		public var tx:int;
		public var ty:int;
		public var t:Entity;
		
		public function Eye (_x:Number, _y:Number)
		{
			chaseTimer = 0;
			x = _x + 8;
			y = _y + 8;
			
			sprite = new Spritemap(Gfx, 16, 16);
			sprite.add("freeze", FP.frames(0, 1), 0.015);
			sprite.add("bounce", FP.frames(2, sprite.frameCount-1), 0.15);
			sprite.play("freeze");
			
			sprite.centerOO();
			sprite.callback = squish;
			
			graphic = sprite;			
			setHitbox(16, 16, 8, 8);
			
			type = "enemy";
		}
		
		public function chase(_t:Entity):void
		{
			chaseTimer = 35;
			t = _t;
		}
		
		public function squish():void
		{
			if(sprite.currentAnim == "bounce")
				Room(world).particles.addBurst(Particles.SQUISH, x-2, y+7);
		}
		
		public override function update (): void
		{			
			if(chaseTimer)
			{
				chaseTimer--;
				moveTowards(t.x, t.y, 1.5);
				if(tx == x && ty == y) chaseTimer = 0;
				sprite.play("bounce");
				
				Room.chaseDistance = Math.min(
					Room.chaseDistance,
					FP.distance(this.x, this.y, t.x, t.y)
				);
			}
			else
			{
				sprite.play("freeze");
			}

			layer = -y;			
		}
	}
}
