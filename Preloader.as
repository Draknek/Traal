
package
{
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.system.*;
	import flash.utils.getDefinitionByName;

	[SWF(width = "640", height = "480", backgroundColor="#05080b")]
	public class Preloader extends Sprite
	{
		// Change these values
		private static const mustClick: Boolean = false;
		private static const mainClassName: String = "Main";
		
		private static const BG_COLOR:uint = 0x05080b;
		private static const FG_COLOR:uint = 0x7dbd43;
		
		public static var hideProgress:Boolean = false;
		
		
		
		// Ignore everything else
		
		public static var stage:Stage;
		
		
		
		private var progressBar: Shape;
		private var text: TextField;
		
		private var px:int;
		private var py:int;
		private var w:int;
		private var h:int;
		private var sw:int;
		private var sh:int;
		
		[Embed(source = 'net/flashpunk/graphics/04B_03__.TTF', fontFamily = 'default')]
		private static const FONT:Class;
		
		public function Preloader ()
		{
			Preloader.stage = this.stage;
			
			fixAndroidOrientation();
			fixIOSOrientation();
			
			var url:String = stage.loaderInfo.url;
			var startCheck:int = url.indexOf('://' ) + 3;
			
			if (url.substr(0, startCheck) != 'http://'
				&& url.substr(0, startCheck) != 'https://'
				&& url.substr(0, startCheck) != 'ftp://') hideProgress = true;
			
			sw = stage.stageWidth;
			sh = stage.stageHeight;
			
			w = stage.stageWidth * 0.8;
			h = 20;
			
			px = (sw - w) * 0.5;
			py = (sh - h) * 0.5;
			
			text = new TextField();
			
			text.textColor = FG_COLOR;
			text.selectable = false;
			text.mouseEnabled = false;
			text.defaultTextFormat = new TextFormat("default", 16);
			text.embedFonts = true;
			text.autoSize = "left";
			text.text = "0%";
			text.x = (sw - text.width) * 0.5;
			text.y = sh * 0.5 + h;
			
			if (! hideProgress) {
				graphics.beginFill(BG_COLOR);
				graphics.drawRect(0, 0, sw, sh);
				graphics.endFill();
				
				graphics.beginFill(FG_COLOR);
				graphics.drawRect(px - 2, py - 2, w + 4, h + 4);
				graphics.endFill();
				
				progressBar = new Shape();
				
				addChild(progressBar);
				
				addChild(text);
			}
			
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			if (mustClick) {
				stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			}
		}
		
		private var landscapeDevice:Boolean = false;
		
		private function fixAndroidOrientation ():void
		{
			if (Capabilities.manufacturer.toLowerCase().indexOf("android") < 0) {
				return;
			}
			
			var orientation:String = Preloader.stage["orientation"];
			
			if (orientation != "rotatedLeft" && orientation != "rotatedRight") {
				landscapeDevice = true;
			}
			
			if (Preloader.stage.fullScreenWidth < Preloader.stage.fullScreenHeight) {
				landscapeDevice = ! landscapeDevice;
			}
			
			Preloader.stage.addEventListener(Event.ACTIVATE, fixAndroidOrientationCallback);
			Preloader.stage.addEventListener(Event.ENTER_FRAME, fixAndroidOrientationCallback);
			
			fixAndroidOrientationCallback();
		}
		
		private function fixAndroidOrientationCallback (e:* = null):void
		{
			var deviceOrientation:String = Preloader.stage["deviceOrientation"];
			
			if (landscapeDevice) {
				if (deviceOrientation == "upsideDown") {
					Preloader.stage["setOrientation"]("upsideDown");
				} else if (deviceOrientation == "default") {
					Preloader.stage["setOrientation"]("default");
				}
			} else {
				if (deviceOrientation == "rotatedRight") {
					Preloader.stage["setOrientation"]("rotatedLeft");
				} else if (deviceOrientation == "rotatedLeft") {
					Preloader.stage["setOrientation"]("rotatedRight");
				}
			}
		}

		private function fixIOSOrientation ():void
		{
			if (Capabilities.manufacturer.toLowerCase().indexOf("ios") != -1) {
				try {
					var StageAspectRatio:Class = getDefinitionByName("flash.display.StageAspectRatio") as Class;
					var StageOrientation:Class = getDefinitionByName("flash.display.StageOrientation") as Class;
					var StageOrientationEvent:Class = getDefinitionByName("flash.events.StageOrientationEvent") as Class;
					
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
		
		public function onEnterFrame (e:Event): void
		{
			if (hasLoaded())
			{
				graphics.clear();
				graphics.beginFill(BG_COLOR);
				graphics.drawRect(0, 0, sw, sh);
				graphics.endFill();
				
				if (! mustClick) {
					startup();
				} else {
					text.scaleX = 2.0;
					text.scaleY = 2.0;
				
					text.text = "Click to start";
			
					text.y = (sh - text.height) * 0.5;
				}
			} else {
				var p:Number = (loaderInfo.bytesLoaded / loaderInfo.bytesTotal);
				
				progressBar.graphics.clear();
				progressBar.graphics.beginFill(BG_COLOR);
				progressBar.graphics.drawRect(px, py, p * w, h);
				progressBar.graphics.endFill();
				
				text.text = int(p * 100) + "%";
			}
			
			text.x = (sw - text.width) * 0.5;
		}
		
		private function onMouseDown(e:MouseEvent):void {
			if (hasLoaded())
			{
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				startup();
			}
		}
		
		private function hasLoaded (): Boolean {
			return (loaderInfo.bytesLoaded >= loaderInfo.bytesTotal);
		}
		
		private function startup (): void {
			stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			var mainClass:Class = getDefinitionByName(mainClassName) as Class;
			parent.addChild(new mainClass as DisplayObject);
			
			parent.removeChild(this);
		}
	}
}


