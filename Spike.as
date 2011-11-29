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
		public static var frame:int = 0;
		public var fake:Boolean;
	
		public function Spike(_x:Number, _y:Number, _fake:Boolean=false)
		{
			x = _x;
			y = _y;
			
			sprite = new Spritemap(Gfx, 16, 16);
			sprite.frame = 2;
			graphic = sprite;
			fake = _fake;
			if(!fake) type = "spikes";
			setHitbox(16, 16);
		}
		
		public static function updateFrame():void
		{			
			frame=(frame+1)%24;
		}
		
		public override function update():void
		{
			if(fake)
			{
				sprite.frame = 2;
				return;
			}
			var closeToPlayer:Boolean=false;
			array.length = 0;
			world.getType("player", array)
			for each (var p:Player in array) {
				var vx:Number = (x+8) - (p.x);
				var vy:Number = (y+8) - (p.y+4);
				if(vx*vx + vy*vy < 40*40) closeToPlayer = true;	
			}
			
			if(closeToPlayer || sprite.frame != 2)
				sprite.frame=frame/6;
				
			layer = -y;
		}
		
		private static var array:Array = [];
	}
}
