package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.utils.*;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.events.*;
	import flash.net.*;  
	
	public class Title extends World
	{
		[Embed(source="images/title.png")]
		public static const TitleGfx: Class;
		
		[Embed(source="images/jonathan.png")]
		public static const JonathanGfx: Class;

		[Embed(source="images/alan.png")]
		public static const AlanGfx: Class;
		
		private static const NEW_GAME:int=0;
		private static const CONTINUE:int=1;
		private static const ALAN:int=2;
		private static const JONATHAN:int=3;
    
		public var timer:int;
    
		public var title:Image;
		public var newGame:Text;
		public var resume:Text;
		public var jonathan:Image;
		public var alan:Image;
		public var hover:int;
		public var rect:Rectangle;
		public var canResume:Boolean;
		
		public function Title ()
		{
			canResume = Main.so.data.save != null;
			
			title = new Image(TitleGfx);
			title.scale = 4;
			addGraphic(title);
			
			newGame = new Text("New Game", 0, 209, {align: "center", color: 0x55d4dc});
			newGame.x = (FP.width - newGame.width)/2;  			
			addGraphic(newGame);
			
			resume = new Text("Continue", 0, 223, {align: "center", color: 0x55d4dc});
			resume.x = (FP.width - resume.width)/2;
			if(canResume) addGraphic(resume);
			
			jonathan = new Image(JonathanGfx);
			jonathan.scale = 2;
			addGraphic(jonathan, 0, 217, 165);
			alan = new Image(AlanGfx);
			alan.scale = 2;
			addGraphic(alan, 0, 20, 166);
			timer = 0;
			hover = -1;
			rect = new Rectangle();
			FP.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}

		public override function update (): void
		{
			Input.mouseCursor = "auto";
			
			super.update();
      
			hover = -1;
			rect.x = newGame.x; rect.y = newGame.y; rect.width = newGame.textWidth; rect.height = newGame.textHeight;
			if(rect.contains(Input.mouseX, Input.mouseY)) hover = NEW_GAME;
			rect.x = resume.x; rect.y = resume.y; rect.width = resume.textWidth; rect.height = resume.textHeight;
			if(rect.contains(Input.mouseX, Input.mouseY) && canResume) hover = CONTINUE;			
			rect.x =  20; rect.y = 166; rect.width = 37*2; rect.height = 14*2;
			if(rect.contains(Input.mouseX, Input.mouseY)) hover = ALAN;
			rect.x = 217; rect.y = 165; rect.width = 40*2; rect.height = 15*2;
			if(rect.contains(Input.mouseX, Input.mouseY)) hover = JONATHAN;
		
			timer = (timer+1)%16;
			var shft:Number = ((timer-8)/8);
				shft *= shft;
			shft *= 2;
			if(hover == NEW_GAME) newGame.y = 209+shft;
			if(hover == CONTINUE) resume.y = 223+shft;
			if(hover == ALAN) alan.y = shft;
			if(hover == JONATHAN) jonathan.y = shft;
		}
    
		public function onMouseDown(event:MouseEvent):void
		{
			var address:String = null;
			var next:Boolean = false;
			var resume:Boolean = false;
			switch(hover)
			{
				case NEW_GAME: next = true; break;
				case CONTINUE: next = true; resume = true; break;
				case ALAN: address = "http://www.draknek.org/"; break;
				case JONATHAN: address = "http://jonathanwhiting.com/"; break;				
			}
			if(next)
			{
				Player.clearPersistentData();
				FP.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				FP.world = new Room(null,null,null,resume);
				Audio.startMusic();
			}
			if(address != null)
			{
				var urlRequest:URLRequest = new URLRequest(address);
				navigateToURL(urlRequest,'_blank');      
			}
		}
			
		public override function render (): void
		{
			super.render();
		}		
	}
}
