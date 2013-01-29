package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	import flash.geom.*;
	import flash.events.*;
	import flash.net.*;
	import flash.ui.*;
	import flash.utils.*;
	import flash.system.*;
	import flash.text.*;
	
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
		public static var overSprite:Sprite;
		public static var lightDupe:Sprite;
		public static var playerCircleDupe:Bitmap;
		public static var playerDupe:Bitmap;
		
		public static var joystick:Boolean = false;
		public static var joystickVisible:Boolean = false;
		public static var joystickPos:Point = new Point;
		public static var joystickDir:Point = new Point;
		public static var joystickMinDistance:Number;
		public static var joystickMaxDistance:Number;
		
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
			
			if (touchscreen) {
				mouseControl = true;
				joystick = true;
			}
			
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
			
			//FP.console.enable();
		}
		
		public override function init (): void
		{
			sitelock(["draknek.org", "jonathanwhiting.com", "newgrounds.com", "ungrounded.net"]);
			
			initSO();
			
			Audio.init(this);
			Editor.init();
			
			FP.world = new Title();
			
			super.init();
			
			addEventHandlers();
			
			resizeHandler();
			
			Newgrounds.init();
			
			sprite = new Sprite;
			sprite.visible = false;
			addChildAt(sprite,0);
			
			overSprite = new Sprite;
			overSprite.visible = false;
			addChild(overSprite);
			
			lightDupe = new Sprite;
			//sprite.addChild(lightDupe);
			
			playerCircleDupe = new Bitmap(FP.getBitmap(Player.CircleGfx).clone());
			playerCircleDupe.x = playerCircleDupe.y = -24*FP.screen.scale;
			playerCircleDupe.scaleX = playerCircleDupe.scaleY = FP.screen.scale;
			//sprite.addChild(playerCircleDupe);
			
			playerDupe = new Bitmap;
			playerDupe.scaleX = playerDupe.scaleY = FP.screen.scale;
			sprite.addChild(playerDupe);
		}
		
		public static function initSO ():void
		{
			if (! Main.so.data.version) {
				Main.so.data.version = 2;
				
				if (Main.so.data.save && Main.so.data.save.y) {
					Main.so.data.save.y += 2 - Room.playerYOffset;
				}
				
				Main.so.flush();
			}
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
		
		//private var hackTimer:int = 0;
		
		public override function update (): void
		{
			if (FP.focused) {
				super.update();
			}
			
			/*if (touchscreen) {
				hackTimer--;
				
				if (Input.mousePressed) {
					if (hackTimer > 0) {
						joystick = ! joystick;
					}
					
					hackTimer = 10;
				}
			}*/
			
			if (joystick) {
				overSprite.graphics.clear();
				
				var mx:Number = FP.stage.mouseX;
				var my:Number = FP.stage.mouseY;
				
				if (Input.mousePressed) {
					joystickPos.x = mx;
					joystickPos.y = my;
				}
				
				if (Input.mouseDown) {
					var dx:Number = mx - joystickPos.x;
					var dy:Number = my - joystickPos.y;
					var dz:Number = Math.sqrt(dx*dx + dy*dy);
					
					dx /= dz;
					dy /= dz;
					
					joystickMinDistance = 3 * normalScale;
					joystickMaxDistance = 35 * normalScale;
					
					var joystickSpeed:Number = dz / joystickMaxDistance;
					if (joystickSpeed > 1.0) joystickSpeed = 1.0;
					
					if (dz > joystickMinDistance) {
						joystickDir.x = dx * joystickSpeed;
						joystickDir.y = dy * joystickSpeed;
					}
					
					var moveAmount:Number = normalScale*0.5;
					
					if (dz > joystickMaxDistance) {
						moveAmount = dz - joystickMaxDistance;
					} else /*if (dz < joystickMinDistance*2)*/ {
						moveAmount = 0.0;
					}
					
					if (dz < moveAmount) {
						joystickPos.x = mx;
						joystickPos.y = my;
					} else if (moveAmount) {
						joystickPos.x += dx * moveAmount;
						joystickPos.y += dy * moveAmount;
					}
					
					if (joystickVisible) {
						overSprite.graphics.lineStyle(0.0, 0xFFFFFF);
						overSprite.graphics.drawCircle(joystickPos.x, joystickPos.y, joystickMinDistance);
						overSprite.graphics.drawCircle(joystickPos.x, joystickPos.y, joystickMaxDistance);
					}
				} else {
					joystickDir.x = 0;
					joystickDir.y = 0;
				}
			}
		}
		
		private static function addEventHandlers ():void
		{
			if (isAndroid) {
				try {
					var NativeApplication:Class = getDefinitionByName("flash.desktop.NativeApplication") as Class;
					
					NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, extraKeyListener);
				}
				catch (e:Error) {}
			}
			
			if (! touchscreen) {
				FP.stage.addEventListener(Event.RESIZE, resizeHandler);
			}
			
			//fixIOSOrientation(FP.stage);
		}
		
		public static function resizeHandler (e:Event = null):void
		{
			FP.screen.x = (FP.stage.stageWidth - FP.width*FP.screen.scale) * 0.5;
			FP.screen.y = (FP.stage.stageHeight - FP.height*FP.screen.scale) * 0.5;
			
			if (FP.world is Title) {
				Title(FP.world).extendBG();
			}
		}
		
		private static function fixIOSOrientation (stage:Stage):void
		{
			if (isIOS) {
				try {
					var StageOrientation:Class = getDefinitionByName("flash.display.StageOrientation") as Class;
					var StageOrientationEvent:Class = getDefinitionByName("flash.events.StageOrientationEvent") as Class;
					var StageAspectRatio:Class = getDefinitionByName("flash.display.StageAspectRatio") as Class;
					
					stage["setAspectRatio"]( StageAspectRatio.LANDSCAPE );
					
					var startOrientation:String = stage["orientation"];
					
					if (startOrientation == StageOrientation.DEFAULT || startOrientation == StageOrientation.UPSIDE_DOWN)
					{
						stage["setOrientation"](StageOrientation.ROTATED_RIGHT);
					}
					else
					{
						stage["setOrientation"](startOrientation);
					}

					stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGING, orientationChangeListener);
				} catch (e:Error){}
			}
		}
		
		private static function orientationChangeListener(e:*): void
		{
			if (e.afterOrientation == "default" || e.afterOrientation ==  "upsideDown")
			{
				e.preventDefault();
			}
		}
		
		private static function extraKeyListener(e:KeyboardEvent):void
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
			
			var link:TextField = makeHTMLText('This game is not authorised\nto play on this website.\n\n<a href="http://www.draknek.org/games/traal/">Go to the official site</a>', 24, 0x55d4dc, "a {text-decoration:underline;} a:hover {text-decoration:none;}");
			
			link.x = (FP.stage.stageWidth - link.width) * 0.5;
			link.y = (FP.stage.stageHeight - link.height) * 0.5;
			
			parent.addChild(link);
			
			parent.removeChild(this);
			throw new Error("Error: this game is sitelocked");
			
			return false;
		}
		
		public static function makeHTMLText (html:String, size:Number, color:uint, css:String): TextField
		{
			var ss:StyleSheet = new StyleSheet();
			ss.parseCSS(css);
			
			var textField:TextField = new TextField;
			
			textField.selectable = false;
			textField.mouseEnabled = true;
			
			textField.embedFonts = true;
			
			textField.multiline = true;
			
			textField.autoSize = "center";
			
			textField.textColor = color;
			
			var format:TextFormat = new TextFormat("amiga", size);
			format.align = "center";
			
			textField.defaultTextFormat = format;
			
			textField.htmlText = html;
			
			textField.styleSheet = ss;
			
			return textField;
		}

	}
}

