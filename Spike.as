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
	
		public function Spike(_x:Number, _y:Number)
		{
			x = _x;
			y = _y;
			
			sprite = new Spritemap(Gfx, 16, 16);
			graphic = sprite;			
			type = "spikes";
			setHitbox(16, 16);
		}
		
		public static function updateFrame():void
		{			
			frame=(frame+1)%24;
			trace('frame:'+frame);
		}
		
		public override function update():void
		{
			var closeToPlayer:Boolean=false;
			var array:Array = new Array();
			world.getType("player", array)
			for each (var e:Entity in array) {
				var vx:Number = (x+8) - (e.x+8);
				var vy:Number = (y+8) - (e.y+4);
				if(vx*vx + vy*vy < 40*40) closeToPlayer = true;	
			}
			if(closeToPlayer)
				sprite.frame=frame/6;
			else
				sprite.frame=0;
		}
	}
}