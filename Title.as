package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.utils.*;
	import flash.display.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.events.*;
	import flash.net.*;
	import flash.text.*;
	
	public class Title extends World
	{
		[Embed(source="images/title.png")]
		public static const TitleGfx: Class;
		
		[Embed(source="images/jonathan.png")]
		public static const JonathanGfx: Class;

		[Embed(source="images/alan.png")]
		public static const AlanGfx: Class;
		
		[Embed(source="images/best-icons.png")]
		public static const BestIconsGfx: Class;
		
		private static const ALAN:int=2;
		private static const JONATHAN:int=3;
    
		public var timer:int;
    
		public var title:Image;
		public var jonathan:Image;
		public var alan:Image;
		public var hover:int;
		public var rect:Rectangle;
		public var canResume:Boolean;
		
		public var buttons:Array = [];
		
		public var bg2:Shape = new Shape;
		public var buttonsContainer:Sprite = new Sprite;
		public var bestInfo:Sprite;
		public var offsetY:int = 0;
		
		public function Title ()
		{
			canResume = Main.so.data.save != null;
			
			if (canResume) {
				if (Main.so.data.save.startAtStart && Main.so.data.save.scrollcount == Player.scrollCountTotal) {
					canResume = false;
				}
			}
			
			title = new Image(TitleGfx);
			title.scale = 4;
			addGraphic(title);
			
			jonathan = new Image(JonathanGfx);
			jonathan.scale = 2;
			addGraphic(jonathan, 0, 217, 165);
			alan = new Image(AlanGfx);
			alan.scale = 2;
			addGraphic(alan, 0, 20, 166);
			timer = 0;
			hover = -1;
			rect = new Rectangle();
			
			if (Main.touchscreen) {
				FP.stage.addEventListener(MouseEvent.MOUSE_UP, clickEvent);
			} else {
				FP.stage.addEventListener(MouseEvent.MOUSE_DOWN, clickEvent);
			}
			
			addBestInfo();
		}

		public override function update (): void
		{
			Input.mouseCursor = "auto";
			
			super.update();
      
			updateButtons();
		}
		
		public function updateButtons(fromEvent:Boolean = false):void
		{
			if (Main.touchscreen && ! Input.mouseDown && ! fromEvent) return;
			
			hover = -1;	
			rect.x =  20; rect.y = 166; rect.width = 37*2; rect.height = 14*2;
			if(rect.contains(Input.mouseX, Input.mouseY)) hover = ALAN;
			rect.x = 217; rect.y = 165; rect.width = 40*2; rect.height = 15*2;
			if(rect.contains(Input.mouseX, Input.mouseY)) hover = JONATHAN;
			
			if (hover >= 0) {
				Input.mouseCursor = "button";
			}
			
			timer = (timer+1)%16;
			var shft:Number = ((timer-8)/8);
			shft *= shft;
			shft *= 2;
			
			if(hover == ALAN) alan.y = shft;
			else alan.y = 0;
			if(hover == JONATHAN) jonathan.y = shft;
			else jonathan.y = 0;
			
			for each (var buttonData:Array in buttons) {
				var collisionShape:Sprite = buttonData[0];
				var text:DisplayObject = buttonData[1];
				
				var w:Number = collisionShape.width;
				var h:Number = collisionShape.height;
				
				var mx:Number = collisionShape.mouseX;
				var my:Number = collisionShape.mouseY;
				
				if (mx >= 0 && my >= 0 && mx <= w && my <= h) {
					text.y = shft * FP.screen.scale;
					Input.mouseCursor = "button";
				} else {
					text.y = 0;
				}
			}
		}
    
		public function clickEvent(event:MouseEvent):void
		{
			updateButtons(true);
			
			var address:String = null;
			
			switch(hover)
			{
				case ALAN: address = "http://www.draknek.org/"; break;
				case JONATHAN: address = "http://jonathanwhiting.com/"; break;
			}
			
			if(address != null)
			{
				var urlRequest:URLRequest = new URLRequest(address);
				navigateToURL(urlRequest,'_blank');
			}
		}
			
		public override function render (): void
		{
			FP.screen.y = offsetY;
			super.render();
		}
		
		public function startGame (resume:Boolean = false):void
		{
			FP.stage.removeEventListener(MouseEvent.MOUSE_DOWN, clickEvent);
			FP.stage.removeEventListener(MouseEvent.MOUSE_UP, clickEvent);
			
			Player.clearPersistentData();
			FP.world = new Room(null,null,null,resume);
			Audio.startMusic();
		}
		
		public function resumeGame ():void
		{
			startGame(true);
		}
		
		private static function makeURLCallback (url:String):Function
		{
			return function ():void
			{
				var urlRequest:URLRequest = new URLRequest(url);
				navigateToURL(urlRequest,'_blank');
			}
		}
    
		public override function begin ():void
		{
			Audio.stopMusic();
			
			FP.engine.parent.addChildAt(bg2, 0);
			FP.engine.addChild(buttonsContainer);
			
			extendBG();
			
			var textButtons:Array = [];
			
			textButtons.push(["New Game", startGame]);
			if (canResume) textButtons.push(["Continue", resumeGame]);
			
			if (Main.platform) {
				textButtons.push(["More Games", makeURLCallback("http://www.draknek.org/games/" + Main.platform + "/?from=traal")]);
			}
			
			addTextButtons(textButtons);
		}
		
		public function extendBG ():void
		{
			var stage:Stage = Preloader.stage;
			
			var lineY:int = (FP.height*0.5 + title.scale)*FP.screen.scale + offsetY;
			
			bg2.graphics.clear();
			
			bg2.graphics.beginFill(0x403152);
			bg2.graphics.drawRect(0, 0, stage.stageWidth, lineY);
			bg2.graphics.endFill();
			
			bg2.graphics.beginFill(0x09141d);
			bg2.graphics.drawRect(0, lineY, stage.stageWidth, stage.stageHeight);
			bg2.graphics.endFill();
			
			if (bestInfo) {
				bestInfo.x = stage.stageWidth;
			}
		}
		
		public static function saveBest ():void
		{
			var save:Object = Main.so.data.save;
			
			Main.so.data.best = {
				time: save.playTime,
				scrolls: save.scrollcount,
				deaths: save.numDeaths
			};
			Main.so.flush();
		}
		
		public function addBestInfo ():void
		{
			var save:Object = Main.so.data.save;
			
			if (save.startAtStart && save.scrollcount == Player.scrollCountTotal)
			{
				if (! Main.so.data.best) {
					Main.so.data.best = {
						time: 1000000,
						scrolls: -1,
						deaths: 1000000
					};
				}
				
				var best:Object = Main.so.data.best;
				
				if (save.scrollcount > best.scrolls) {
					saveBest();
				} else if (save.scrollcount < best.scrolls) {
					// Nothing
				} else if (int(save.playTime) < int(best.time)) {
					saveBest();
				} else if (int(save.playTime) > int(best.time)) {
					// Nothing
				} else if (save.numDeaths < best.deaths) {
					saveBest();
				}
			} else if (! Main.so.data.best) {
				return;
			}
			
			bestInfo = new Sprite;
			
			var image:BitmapData = new BitmapData(120, 50, true, 0x0);
			
			Draw.setTarget(image);
			
			var x:int = image.width - 2;
			var y:int = 1;
			
			var text:Text = new Text("Best: " + Credits.timeToString(Main.so.data.best.time), x, y, {size: 8, color: 0x55d4dc});
			
			text.x = x - text.textWidth;
			
			Draw.graphic(text);
			
			text.text = "x" + Main.so.data.best.deaths;
			text.x = x - text.textWidth;
			text.y += 15;
			
			Draw.graphic(text);
			
			var sprite:Spritemap = new Spritemap(BestIconsGfx, 16, 16);
			sprite.frame = 1;
			Draw.graphic(sprite, text.x - 16, text.y - 1);
			
			text.text = "x" + Main.so.data.best.scrolls;
			text.x = text.x - 20 - text.textWidth;
			
			Draw.graphic(text);
			
			sprite.frame = 0;
			Draw.graphic(sprite, text.x - 16 + 2, text.y - 1);
			
			
			var bitmap:Bitmap = new Bitmap(image);
			
			bitmap.scaleX = bitmap.scaleY = Main.normalScale;
			bitmap.x = -image.width * Main.normalScale;
			
			bestInfo.addChild(bitmap);
			
			buttonsContainer.addChild(bestInfo);
		}
		
		public function addTextButtons (textButtons:Array):void
		{
			var y:Number = 52 * title.scale * FP.screen.scale;
			
			var space:Number = FP.stage.stageHeight - y;
			
			var width:Number = 0;
			var height:Number = 0;
			
			for each (var data:Array in textButtons) {
				var text:TextField = new TextField();
				text.textColor = 0x55d4dc;
				text.selectable = false;
				text.mouseEnabled = false;
				
				var fontSize:int = FP.screen.scale;
				if (Main.touchscreen) fontSize += 1;
				fontSize *= 8;
				
				var textFormat:TextFormat = new TextFormat(Text.font, fontSize);
				text.defaultTextFormat = textFormat;
				
				text.autoSize = "left";
				text.embedFonts = true;
				text.text = data[0];
				
				if (text.width > width) width = text.width;
				if (text.height > height) height = text.height;
				
				data.push(text);
			}
			
			width += 2;
			height += 2;
			
			var rows:int = Math.floor(space / height);
			
			if (rows < 1) rows = 1;
			else if (rows > textButtons.length) rows = textButtons.length;
			
			space -= height * rows;
			
			if (space >= height*(rows+1)) {
				offsetY = space * 0.4;
				
				extendBG();
				
				space -= offsetY;
				y += offsetY;
			}
			
			var padding:Number = space / (rows + 1);
		
			y += padding;
			
			var perRow:int = Math.ceil(textButtons.length / rows);
			
			for (var i:int = 0; i < textButtons.length; i++) {
				data = textButtons[i];
				
				text = data[2];
				var callback:Function = data[1];
				
				var buttonsOnThisRow:int = perRow;
				var positionOnThisRow:int = i % perRow;
				if (perRow == 2 && i == 2) buttonsOnThisRow = 1; // Not quite right but it'll do here
				
				var xPadding:Number = (FP.stage.stageWidth - width * buttonsOnThisRow) / (buttonsOnThisRow + 3);
				
				var rowWidth:Number = buttonsOnThisRow*width + (buttonsOnThisRow-1) * xPadding;
				
				var startX:Number = (FP.stage.stageWidth - rowWidth)*0.5;
				
				var collisionShape:Sprite = new Sprite();
				collisionShape.x = int(startX + (width + xPadding) * positionOnThisRow);
				collisionShape.y = int(y);
				
				collisionShape.graphics.beginFill(0x09141d);
				collisionShape.graphics.drawRect(0, 0, width, height);
				collisionShape.graphics.endFill();
				
				var positioner:Sprite = new Sprite();
				positioner.x = int((width - text.width)*0.5);
				positioner.y = int((height - text.height)*0.5);
				
				positioner.addChild(text);
				collisionShape.addChild(positioner);
				buttonsContainer.addChild(collisionShape);
				
				var eventType:String = Main.touchscreen ? MouseEvent.MOUSE_UP : MouseEvent.MOUSE_DOWN;
				
				collisionShape.addEventListener(eventType, makeCallbackWrapper(callback));
				
				buttons.push([collisionShape, text, callback]);
				
				if (((i+1) % perRow) == 0) {
					y += height + padding;
				}
			}
		}
		
		private static function makeCallbackWrapper (f:Function):Function
		{
			return function (e:* = null):void
			{
				f();
			}
		}
		
		public override function end ():void
		{
			FP.engine.parent.removeChild(bg2);
			FP.engine.removeChild(buttonsContainer);
			
			Main.resizeHandler();
		}
	}
}
