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
			/*sprite.add("prod", FP.frames(0, sprite.frameCount-1), 0.175);
			sprite.play("prod");*/
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
				var vx:Number = x - e.x;
				var vy:Number = y - e.y;
				if(vx*vx + vy*vy < 64*64) closeToPlayer = true;	
			}
			if(closeToPlayer)
				sprite.frame=frame/6;
			else
				sprite.frame=0;
		}
	}
}