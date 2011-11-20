package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	public class Particles extends Entity
	{
		public var pA:Array;
		
		public static const SQUISH:int = 0;
		public static const BREAKABLE:int = 1;
		
		[Embed(source="images/particles.png")]
		public static const Gfx: Class;	
		
		public var sprite:Spritemap;

		public function Particles():void
		{
			sprite = new Spritemap(Gfx, 4, 4);
			pA = new Array();
		}
		
		private function addParticle(frame:int, x:Number, y:Number, xv:Number, yv:Number, gravity:Boolean, life:int):void
		{
			var particle:Object = new Object();
			particle.frame = frame;
			particle.x = x;
			particle.y = y;
			particle.xv = xv;
			particle.yv = yv;
			particle.gravity = gravity;
			particle.life = life;
			pA.push(particle);
		}
		
		public function addBurst(burstType:int, x:Number, y:Number):void
		{
			var s:Number;
			var t:int;
			switch(burstType)
			{
				case SQUISH:
					s=0.5
					t = 22;					
					addParticle(0, x, y, -s, -s, true, t);
					addParticle(0, x, y,  s, -s, true, t);
					break;
				case BREAKABLE:					
					s = 1;
					t = 20;
					addParticle(1, x-2, y-2, -s, -s, false, t);
					addParticle(1, x+2, y-2,  s, -s, false, t);
					addParticle(1, x+2, y+2,  s,  s, false, t);
					addParticle(1, x-2, y+2, -s,  s, false, t);
					break;
			}
		}
		
		public override function update():void
		{
			for each (var p:Object in pA)
			{
				p.x += p.xv;
				p.y += p.yv;
				if(p.gravity) p.yv += 0.025;
				p.life--;
			}
			pA = pA.filter(isAlive);
		}
		
		private static function isAlive(element:*, index:int, arr:Array):Boolean
		{
			return element.life > 0;
		}					
		
		public override function render():void
		{
			for each (var p:Object in pA)
			{
				sprite.x = p.x;
				sprite.y = p.y;
				sprite.frame = p.frame;
				sprite.render(FP.buffer, FP.zero, world.camera);
			}
		}
	}
}