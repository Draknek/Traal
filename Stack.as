package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	public class Stack extends Entity
	{
		public var sprite:Spritemap;
		
		[Embed(source="images/stack.png")]
		public static const Gfx: Class;
		public var dir:int;
		public var shouldTurn:Boolean;
		
		public var vx:Number;
		public var vy:Number;
		
		public function Stack (_x:Number, _y:Number)
		{
			dir = 0;
			setSpeedsFromDir();
			shouldTurn = false;
			x = _x + 8;
			y = _y + 8;
			
			sprite = new Spritemap(Gfx, 16, 16);
			sprite.add("bounce", FP.frames(0, sprite.frameCount-1), 0.15);			
			sprite.play("bounce");
			
			sprite.centerOO();
			sprite.callback = squish;
			
			graphic = sprite;			
			setHitbox(16, 16, 8, 8);
			
			type = "enemy";
		}
		
		public function squish():void
		{
			Room(world).particles.addBurst(Particles.SQUISH, x-2, y+5);
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
		
		public function setSpeedsFromDir():void
		{
			var speed:Number = 0.5;
			vx = 0;
			vy = 0;
			switch(dir)
			{
				case 0: vy -= speed; break;
				case 1: vx += speed; break;
				case 2: vy += speed; break;
				case 3: vx -= speed; break;
			}		
		}
		
		public override function update (): void
		{			
			var colTypes:Array = ["solid", "spikes", "enemy", "altar"];
			moveBy(vx, vy, colTypes);
			
			if(shouldTurn)
			{
				dir = (dir+1)%4;
				setSpeedsFromDir()
				shouldTurn = false;
				moveBy(vx*8, vy*8, colTypes);
				if(shouldTurn) dir = (dir+2)%4;
				else moveBy(-vx*8, -vy*8, colTypes);
				shouldTurn = false;
				setSpeedsFromDir();
			}
		}
	}
}