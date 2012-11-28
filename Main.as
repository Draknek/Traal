package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.system.*;
	
	public class Main extends Engine
	{
		public static const so:SharedObject = SharedObject.getLocal("traal", "/");
		
		[Embed(source = 'fonts/amiga4ever pro2.ttf', embedAsCFF="false", fontFamily = 'amiga')]
		public static const FONT:Class;
		
		public static var mouseControl:Boolean = false;
		
		public static var touchscreen:Boolean = false;
		public static var isAndroid:Boolean = false;
		public static var isIOS:Boolean = false;
		public static var isPlaybook:Boolean = false;
		
		public static var devMode:Boolean = false;
		
		public static var sprite:Sprite;
		public static var lightDupe:Sprite;
		public static var playerCircleDupe:Bitmap;
		public static var playerDupe:Bitmap;
		
		public function Main () 
		{
			if (Capabilities.manufacturer.toLowerCase().indexOf("ios") != -1) {
				isIOS = true;
				touchscreen = true;
			}
			else if (Capabilities.manufacturer.toLowerCase().indexOf("android") >= 0) {
				isAndroid = true;
				touchscreen = true;
			} else if (Capabilities.os.indexOf("QNX") >= 0) {
				isPlaybook = true;
				touchscreen = true;
			}
			
			if (touchscreen) mouseControl = true;
			
			var sw:int = 320;
			var sh:int = 240;
			
			if (touchscreen) {
				try {
					Preloader.stage.displayState = StageDisplayState.FULL_SCREEN;
				} catch (e:Error) {}
				
				sw = Preloader.stage.fullScreenWidth;
				sh = Preloader.stage.fullScreenHeight;
				
				if (isAndroid && sw < sh) {
					var tmp:int = sw;
					sw = h;
					sh = tmp;
				}
			} else {
				sw = Preloader.stage.stageWidth;
				sh = Preloader.stage.stageHeight;
			}
			
			var w:int = 320;
			var h:int = 240;
			
			var border:int = touchscreen ? 20 : 0;
			
			sw -= border*2;
			sh -= border*2;
			
			var scale:int = Math.min(Math.floor(sw/w), Math.floor(sh/h));
			
			if (scale < 1) scale = 1;
			
			super(w, h, 60, true);
			FP.screen.scale = scale;
			FP.screen.color = 0x09141d;
			
			Text.size = 8;
			Text.font = "amiga";
			Text.defaultColor = 0xf5f8c0;
		}
		
		public override function init (): void
		{
			sitelock(["draknek.org", "jonathanwhiting.com"]);
			
			Audio.init(this);
			Editor.init();
			
			FP.world = new Title();
			
			super.init();
			
			stage.addEventListener(Event.RESIZE, resizeHandler);
			resizeHandler();
			
			sprite = new Sprite;
			sprite.visible = false;
			addChildAt(sprite,0);
			
			lightDupe = new Sprite;
			sprite.addChild(lightDupe);
			
			playerCircleDupe = new Bitmap(FP.getBitmap(Player.CircleGfx).clone());
			playerCircleDupe.x = playerCircleDupe.y = -24*FP.screen.scale;
			playerCircleDupe.scaleX = playerCircleDupe.scaleY = FP.screen.scale;
			sprite.addChild(playerCircleDupe);
			
			playerDupe = new Bitmap;
			playerDupe.scaleX = playerDupe.scaleY = FP.screen.scale;
			sprite.addChild(playerDupe);
		}
		
		public override function update (): void
		{
			if (FP.focused) {
				super.update();
			}
		}
		
		private function resizeHandler (e:Event = null):void
		{
			FP.screen.x = (stage.stageWidth - FP.width*FP.screen.scale) * 0.5;
			FP.screen.y = (stage.stageHeight - FP.height*FP.screen.scale) * 0.5;
			
			if (FP.world is Title) {
				Title(FP.world).extendBG();
			}
		}
		
		public function sitelock (allowed:*):Boolean
		{
			var url:String = FP.stage.loaderInfo.url;
			var startCheck:int = url.indexOf('://' ) + 3;
			
			if (url.substr(0, startCheck) != 'http://'
				&& url.substr(0, startCheck) != 'https://'
				&& url.substr(0, startCheck) != 'ftp://') return true;
			
			devMode = false; // Not running locally
			
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

