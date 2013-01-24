package
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.SharedObject;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import net.flashpunk.utils.*;
	import net.flashpunk.tweens.misc.*;
	import net.flashpunk.*;
	
	public class Audio
	{
		[Embed(source="audio/death.mp3")]
		public static var DeathSfx:Class;
		
		[Embed(source="audio/spotted.mp3")]
		public static var SpottedSfx:Class;
		
		[Embed(source="audio/eye.mp3")]
		public static var EyeSfx:Class;
		
		[Embed(source="audio/bg.mp3")]
		public static var BgSfx:Class;
		
		[Embed(source="audio/blindfold.mp3")]
		public static var BlindfoldSfx:Class;
		
		[Embed(source="audio/endgame.mp3")]
		public static var EndgameSfx:Class;
		
		[Embed(source="audio/paper.mp3")]
		public static var PaperSfx:Class;
		
		[Embed(source="audio/smash1.mp3")]
		public static var Smash1Sfx:Class;
		
		[Embed(source="audio/smash2.mp3")]
		public static var Smash2Sfx:Class;
		
		[Embed(source="audio/smash3.mp3")]
		public static var Smash3Sfx:Class;
		
		private static var sounds:Object = {};
		
		private static var _mute:Boolean = false;
		private static var so:SharedObject;
		private static var menuItem:ContextMenuItem;
		
		private static var bg:Sfx = new Sfx(BgSfx);
		
		private static var blindfoldLoop:Sfx = new Sfx(BlindfoldSfx);
		
		public static var volTween:VarTween = new VarTween;
		public static var volTween2:VarTween = new VarTween;
		
		public static var smashCounter:int = 0;
		
		public static function init (o:InteractiveObject):void
		{
			// Setup
			
			/*so = SharedObject.getLocal("audio");
			
			_mute = so.data.mute;
			
			addContextMenu(o);*/
			
			if (o.stage) {
				initStage(o.stage);
			} else {
				o.addEventListener(Event.ADDED_TO_STAGE, stageAdd);
			}
			
			// Create sounds
			
			sounds["death"] = new Sfx(DeathSfx);
			sounds["spotted"] = new Sfx(SpottedSfx);
			sounds["eye"] = new Sfx(EyeSfx);
			sounds["endgame"] = new Sfx(EndgameSfx);
			sounds["paper"] = new Sfx(PaperSfx);
			sounds["smash1"] = new Sfx(Smash1Sfx);
			sounds["smash2"] = new Sfx(Smash2Sfx);
			sounds["smash3"] = new Sfx(Smash3Sfx);
			
			FP.tweener.addTween(volTween);
			FP.tweener.addTween(volTween2);
		}
		
		public static function startMusic ():void
		{
			bg.loop();
			blindfoldLoop.loop(0.0);
		}
		
		public static function stopMusic ():void
		{
			bg.stop();
			blindfoldLoop.stop();
		}
		
		public static function play (sound:String):void
		{
			var volume:Number = 1.0;
			
			if (sound == "smash") {
				smashCounter++;
				
				if (smashCounter > 3) smashCounter = 1;
				
				sound += smashCounter;
				
				volume = 0.6;
			}
			
			if (! _mute && sounds[sound]) {
				sounds[sound].play(volume);
			}
			
			if (sound == "death") {
				blindfold(false);
			}
		}
		
		public static function blindfold (on:Boolean):void
		{
			volTween.tween(blindfoldLoop, "volume", Number(on), on ? 60 : 120);
		}
		
		public static function background (on:Boolean):void
		{
			volTween2.tween(bg, "volume", Number(on), on ? 60 : 30);
		}
		
		public static function endgameOut ():void
		{
			volTween2.tween(sounds["endgame"], "volume", 0.0, 150);
		}
		
		// Getter and setter for mute property
		
		public static function get mute (): Boolean { return _mute; }
		
		public static function set mute (newValue:Boolean): void
		{
			if (_mute == newValue) return;
			
			_mute = newValue;
			
			menuItem.caption = _mute ? "Unmute" : "Mute";
			
			so.data.mute = _mute;
			so.flush();
		}
		
		// Implementation details
		
		private static function stageAdd (e:Event = null):void
		{
			initStage(e.target.stage);
		}
		
		private static function initStage (stage:Stage):void
		{
			//stage.addEventListener(KeyboardEvent.KEY_DOWN, keyListener);
			
			stage.addEventListener(Event.ACTIVATE, onFocusGain);
			stage.addEventListener(Event.DEACTIVATE, onFocusLoss);
		}
		
		private static function addContextMenu (o:InteractiveObject):void
		{
			var menu:ContextMenu = o.contextMenu || new ContextMenu;
			
			menu.hideBuiltInItems();
			
			menuItem = new ContextMenuItem(_mute ? "Unmute" : "Mute");
			
			menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, menuListener);
			
			menu.customItems.push(menuItem);
			
			o.contextMenu = menu;
		}
		
		private static function keyListener (e:KeyboardEvent):void
		{
			if (e.keyCode == Key.M) {
				mute = ! mute;
			}
		}
		
		private static function menuListener (e:ContextMenuEvent):void
		{
			mute = ! mute;
		}
		
		private static var resumeSounds:Array = [];
		
		private static function onFocusGain (e:Event):void
		{
			for each (var sfx:Sfx in resumeSounds) {
				sfx.resume();
			}
			
			resumeSounds.length = 0;
		}
		
		private static function onFocusLoss (e:Event):void
		{
			if (resumeSounds.length != 0) return;
			
			if (bg.playing) resumeSounds.push(bg);
			if (blindfoldLoop.playing) resumeSounds.push(blindfoldLoop);
			if (sounds["endgame"].playing) resumeSounds.push(sounds["endgame"]);
			
			for each (var sfx:Sfx in resumeSounds) {
				sfx.stop();
			}
		}
	}
}

