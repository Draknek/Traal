package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	import flash.geom.Rectangle;
	import flash.geom.Point;	
	
	public class SecretEnding extends Entity
	{
		public static const ST_WAIT:int = 0;
		public static const ST_ALERT:int = 1;
		public static const ST_ZOOM:int = 2;
		public static const ST_MOREZOOM:int = 3;
		public static const ST_EYEOPEN:int = 4;
		public static const ST_FADEOUT:int = 5;
		public static const ST_MAX:int = 6;
	
		public var timer:int = 0;
		public var timeout:int = 0;
		public var stage:int = 0;
		public var screenCover:Image;
		public var eyeman:Spritemap;
		public var cameraShake:Number;
		public var cx:int;
		public var cy:int;
		
		[Embed(source="images/eyeman.png")]
		public static const EyemanGfx: Class;		
		
		public function SecretEnding(_x:Number, _y:Number, _screenCover:Image)
		{			
			x = _x;
			y = _y;
			screenCover = _screenCover;
			stage = -1;
			nextStage();		
		}
		
		public override function added (): void
		{
			var array:Array = new Array();
			world.getType("player", array);
			array[0].sprite.alpha = 0;
			
			eyeman = new Spritemap(EyemanGfx, 32, 32);
			eyeman.frame = 0;
			world.addGraphic(eyeman, -2025, x-11, y-21);
		}
		
		public function focusCamera():void
		{
			world.camera.x = x - 320/FP.screen.scale;
			world.camera.y = y - (240+16)/FP.screen.scale;
			cx = world.camera.x;
			cy = world.camera.y;
		}
		
		public function nextStage():void
		{
			if(stage == ST_MAX)
				return;
			
			timer = 0;
			stage++;			

			timeout = 0;
			switch(stage)
			{
				case ST_WAIT:
					Audio.endgameOut();
					timeout = 100;
					break;
				case ST_ALERT: 
					screenCover.alpha = 0;
					timeout = 100;
					FP.screen.scale = 3;
					focusCamera();
					Audio.play("spotted");
					cameraShake = 1;
					break;
				case ST_ZOOM:
					timeout = 100;
					FP.screen.scale = 6;
					focusCamera();
					Audio.play("spotted");
					cameraShake = 2;
					break;
				case ST_MOREZOOM:
					timeout = 100;
					FP.screen.scale = 10;
					focusCamera();
					Audio.play("spotted");
					cameraShake = 3;
					break;
				case ST_EYEOPEN:
					timeout = 100;
					Audio.play("eye");
					eyeman.frame = 1;
					cameraShake = 8;
					break;
				case ST_FADEOUT:
					screenCover.alpha = 1;
					timeout = 300;
					break;
				case ST_MAX:					
					FP.screen.scale = 2;
					FP.world = new Credits;
					break;
			}
		}
		
		public override function update():void
		{
			timer++;
			if(timer > timeout) nextStage();
			world.camera.x = cx + Math.random() * cameraShake;
			world.camera.y = cy + Math.random() * cameraShake;
			cameraShake = cameraShake*0.97;
		}
	}
}