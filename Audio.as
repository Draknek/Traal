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
		
		private static var sounds:Object = {};
		
		private static var _mute:Boolean = false;
		private static var so:SharedObject;
		private static var menuItem:ContextMenuItem;
		
		private static var bg:Sfx = new Sfx(BgSfx);
		
		private static var blindfoldLoop:Sfx = new Sfx(BlindfoldSfx);
		
		public static var volTween:VarTween = new VarTween;
		public static var volTween2:VarTween = new VarTween;
		
		public static function init (o:InteractiveObject):void
		{
			// Setup
			
			/*so = SharedObject.getLocal("audio");
			
			_mute = so.data.mute;
			
			addContextMenu(o);
			
			if (o.stage) {
				addKeyListener(o.stage);
			} else {
				o.addEventListener(Event.ADDED_TO_STAGE, stageAdd);
			}*/
			
			// Create sounds
			
			sounds["death"] = new Sfx(DeathSfx);
			sounds["spotted"] = new Sfx(SpottedSfx);
			sounds["eye"] = new Sfx(EyeSfx);
			sounds["endgame"] = new Sfx(EndgameSfx);
			
			bg.loop();
			blindfoldLoop.loop(0.0);
			
			FP.tweener.addTween(volTween);
			FP.tweener.addTween(volTween2);
		}
		
		public static function play (sound:String):void
		{
			if (! _mute && sounds[sound]) {
				sounds[sound].play();
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
		
		private static function stageAdd (e:Event):void
		{
			addKeyListener(e.target.stage);
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
		
		private static function addKeyListener (stage:Stage):void
		{
			//stage.addEventListener(KeyboardEvent.KEY_DOWN, keyListener);
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
	}
}

