package
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.utils.ByteArray;
	import flash.net.FileReference;
	
	import net.flashpunk.FP;
	import net.flashpunk.World;
	import net.flashpunk.utils.Key;
	
	public class LoadableWorld extends World
	{
		// Must be implemented by superclass
		
		public function getWorldData (): *
		{
			return "";
		}
		
		public function setWorldData (data: ByteArray): void {}
		
		// Must be called even if overridden
		
		public override function begin (): void
		{
			FP.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownListener);
		}
		
		public override function end (): void
		{
			FP.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownListener);
		}
		
		// Private functions
		
		private function keyDownListener (e:KeyboardEvent): void
		{
			if (e.ctrlKey || e.shiftKey)
			{
				if (e.keyCode == Key.S)
				{
					save();
				}
				else if (e.keyCode == Key.O)
				{
					load();
				}
			}
		}
		
		public function save (): void
		{
			new FileReference().save(getWorldData());
		}
		
		public function load (): void
		{
			var file: FileReference = new FileReference();
			file.addEventListener(Event.SELECT, fileSelect);
			file.browse();
			
			function fileSelect (event:Event):void {
				file.addEventListener(Event.COMPLETE, loadComplete);
				file.load();
			}

			function loadComplete (event:Event):void {
				setWorldData(file.data);
			}
		}
		
		
	}
}
