package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.utils.*;
	
	import flash.net.*;
	
	[SWF(width = "640", height = "480", backgroundColor="#000000")]
	public class Main extends Engine
	{
		public static const so:SharedObject = SharedObject.getLocal("traal", "/");
		
		public function Main () 
		{
			super(320*2, 240*2, 60, true);
			//FP.console.enable();
			FP.screen.scale = 2;
			
			Text.size = 16;
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
		}
		
		public override function update (): void
		{
			if (FP.focused) {
				super.update();
			}
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

