package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	
	public class Main extends Engine
	{
		public static const so:SharedObject = SharedObject.getLocal("traal", "/");
		
		[Embed(source = 'fonts/amiga4ever pro2.ttf', embedAsCFF="false", fontFamily = 'amiga')]
		public static const FONT:Class;
		
		public static var mouseControl:Boolean = false;
		
		public function Main () 
		{
			super(320*2, 240*2, 60, true);
			FP.screen.scale = 2;
			FP.screen.color = 0x403152;
			
			Text.size = 8;
			Text.font = "amiga";
			Text.defaultColor = 0xf5f8c0;
		}
		
		public override function init (): void
		{
			Audio.init(this);
			Editor.init();
			
			FP.width *= 0.5;
			FP.height *= 0.5;
			
			FP.world = new Title();
			
			sitelock(["draknek.org", "jonathanwhiting.com"]);
			
			super.init();
			
			stage.addEventListener(Event.RESIZE, resizeHandler);
			resizeHandler();
		}
		
		public override function update (): void
		{
			if (FP.focused) {
				super.update();
			}
		}
		
		private function resizeHandler (e:Event = null):void
		{
			FP.screen.x = (stage.stageWidth - 640) * 0.5;
			FP.screen.y = (stage.stageHeight - 480) * 0.5;
		}
		
		public function sitelock (allowed:*):Boolean
		{
			var url:String = FP.stage.loaderInfo.url;
			var startCheck:int = url.indexOf('://' ) + 3;
			
			if (url.substr(0, startCheck) == 'file://') return true;
			
			var domainLen:int = url.indexOf('/', startCheck) - startCheck;
			var host:String = url.substr(startCheck, domainLen);
			
			if (allowed is String) allowed = [allowed];
			for each (var d:String in allowed)
			{
				if (host.substr(-d.length, d.length) == d) return true;
			}
			
			parent.removeChild(this);
			throw new Error("Error: this game is sitelocked");
			
			return false;
		}
	}
}

