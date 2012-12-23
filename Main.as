package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.ui.*;
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
		public static var platform:String = "";
		
		public static var devMode:Boolean = false;
		
		public static var sprite:Sprite;
		public static var lightDupe:Sprite;
		public static var playerCircleDupe:Bitmap;
		public static var playerDupe:Bitmap;
		
		public static var normalScale:Number = 1;
		
		public function Main () 
		{
			if (Capabilities.manufacturer.toLowerCase().indexOf("ios") != -1) {
				isIOS = true;
				touchscreen = true;
				platform = "ios";
			}
			else if (Capabilities.manufacturer.toLowerCase().indexOf("android") >= 0) {
				isAndroid = true;
				touchscreen = true;
				platform = "android";
			} else if (Capabilities.os.indexOf("QNX") >= 0) {
				isPlaybook = true;
				touchscreen = true;
				platform = "blackberry";
			}
			
			if (touchscreen) mouseControl = true;
			
			var sw:int = 320;
			var sh:int = 240;
			
			if (touchscreen) {
				try {
					Preloader.stage.displayState = StageDisplayState['FULL_SCREEN_INTERACTIVE'];
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
			
			var scale:int = Math.min(Math.floor(sw/w), Math.floor(sh/h));
			
			if (scale < 1) scale = 1;
			
			normalScale = scale;
			
			super(w, h, 60, true);
			FP.screen.scale = scale;
			FP.screen.color = 0x05080b;
			
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
			
			try {
				var NativeApplication:Class = getDefinitionByName("flash.desktop.NativeApplication") as Class;
				
				NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, extraKeyListener);
			}
			catch (e:Error) {}
			
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
		
		public override function setStageProperties():void
		{
			super.setStageProperties();
			
			if (touchscreen) {
				try {
					stage.displayState = StageDisplayState['FULL_SCREEN_INTERACTIVE'];
				} catch (e:Error) {}
			}
		}
		
		public override function update (): void
		{
			if (FP.focused) {
				super.update();
			}
		}
		
		public static function resizeHandler (e:Event = null):void
		{
			FP.screen.x = (FP.stage.stageWidth - FP.width*FP.screen.scale) * 0.5;
			FP.screen.y = (FP.stage.stageHeight - FP.height*FP.screen.scale) * 0.5;
			
			if (FP.world is Title) {
				Title(FP.world).extendBG();
			}
		}
		
		private function extraKeyListener(e:KeyboardEvent):void
		{
			try {
			const BACK:uint   = ("BACK" in Keyboard)   ? Keyboard["BACK"]   : 0;
			const MENU:uint   = ("MENU" in Keyboard)   ? Keyboard["MENU"]   : 0;
			const SEARCH:uint = ("SEARCH" in Keyboard) ? Keyboard["SEARCH"] : 0;
			
			if(e.keyCode == BACK || e.keyCode == MENU) {
				if (! (FP.world is Title)) {
					FP.world = new Title;
				} else {
					return;
				}
			} else if(e.keyCode == SEARCH) {
				
			} else {
				return;
			}
			
			e.preventDefault();
			e.stopImmediatePropagation();
			} catch (e:Error) {}
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

