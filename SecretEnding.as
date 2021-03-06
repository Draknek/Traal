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
		public static const ST_FIRSTZOOM:int = 2;
		public static const ST_ZOOM:int = 3;
		public static const ST_MOREZOOM:int = 4;
		public static const ST_EYEOPEN:int = 5;
		public static const ST_FADEOUT:int = 6;
		public static const ST_MAX:int = 7;
	
		public var timer:int = 0;
		public var timeout:int = 0;
		public var stage:int = 0;
		public var screenCover:Image;
		public var eyeman:Spritemap;
		public var cameraShake:Number = 0;
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
			world.typeFirst("player").visible = false;
			
			eyeman = new Spritemap(EyemanGfx, 32, 32);
			eyeman.frame = 0;
			world.addGraphic(eyeman, -2025, x-11, y-21);
			
			cx = world.camera.x;
			cy = world.camera.y;
		}
		
		public function focusCamera():void
		{
			var w:Number = FP.stage.stageWidth;
			var h:Number = FP.stage.stageHeight;
			
			var scale:Number = FP.screen.scale;
			
			FP.screen.x = (w - FP.width*scale) * 0.5;
			FP.screen.y = (h - FP.height*scale) * 0.5;
			world.camera.x = x - FP.width*0.5;
			world.camera.y = (y-8) - FP.height*0.5;
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
					timeout = 200;
					break;
				case ST_ALERT:
					screenCover.alpha = 0;
					timeout = 100;
					Audio.play("spotted");
					break;
				case ST_FIRSTZOOM:
					timeout = 100;
					FP.screen.scale = Math.floor(FP.stage.stageHeight/160);
					focusCamera();
					Audio.play("spotted");
					cameraShake = 1;
					break;
				case ST_ZOOM:
					timeout = 100;
					FP.screen.scale = Math.floor(FP.stage.stageHeight/80);
					focusCamera();
					Audio.play("spotted");
					cameraShake = 2;
					break;
				case ST_MOREZOOM:
					timeout = 180;
					FP.screen.scale = Math.floor(FP.stage.stageHeight/48);
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
