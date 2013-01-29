package
{
	import com.newgrounds.*;
	import com.newgrounds.components.MedalPopup;
	
	import net.flashpunk.FP;
	
	public class Newgrounds
	{
		public static var medalPopup:MedalPopup;
		
		public static function init ():void
		{
			API.connect(FP.stage, NGSecret.NG_API_ID, NGSecret.NG_KEY);
		}
		
		public static function testMedals ():void
		{
			showMedal(".");
			
			var save:Object = Main.so.data.save;
			
			if (save.scrollcount < Player.scrollCountTotal) {
				return;	
			}
			
			showMedal("..");
			
			if (save.playTime > 60*10) {
				return;
			}
			
			showMedal("...");
		}
		
		public static function showMedal (name:String):void
		{
			if (! medalPopup) {
				medalPopup = new MedalPopup;

				medalPopup.x = 8;
				medalPopup.y = 8;

				FP.engine.addChild(medalPopup);
			}
			
			var medal:Medal = API.getMedal(name);

			if (! medal) return;

			if (! medal.unlocked) {
				medal.unlock();
			}
		}
	}
}