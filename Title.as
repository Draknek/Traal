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
		
		[Embed(source="images/press_space.png")]
		public static const SpaceGfx: Class;

		[Embed(source="images/jonathan.png")]
		public static const JonathanGfx: Class;

		[Embed(source="images/alan.png")]
		public static const AlanGfx: Class;		
    
    public var timer:int;
    
    public var title:Image;
    public var space:Image;
    public var jonathan:Image;
    public var alan:Image;
    public var hover:int;
    public var rect:Rectangle;
		
		public function Title ()
		{
			title = new Image(TitleGfx);
			title.scale = 4;
			addGraphic(title);
			space = new Image(SpaceGfx);
			addGraphic(space, 0, 93, 216);
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
			
			var next:Boolean = Input.pressed(Key.X) || Input.pressed(Key.SPACE);
			
			if (Main.mouseControl) {
				next = next || Input.mousePressed;
			}
			
			if (next)
			{
				FP.world = new Room();
				Audio.startMusic();
			}
      
      timer = (timer+1)%64;
      if(timer > 24) space.alpha = 1;     
      else space.alpha = 0;
      
      hover = -1;
      rect.x =  20; rect.y = 166; rect.width = 37*2; rect.height = 14*2;
      if(rect.contains(Input.mouseX, Input.mouseY)) hover = 0;
      rect.x = 217; rect.y = 165; rect.width = 40*2; rect.height = 15*2;
      if(rect.contains(Input.mouseX, Input.mouseY)) hover = 1;
      
      var shft:Number = (((timer%16)-8)/8);
			shft *= shft;
			shft *= 2;
      if(hover == 0) alan.y = shft;
      if(hover == 1) jonathan.y = shft;
		}
    
    public function onMouseDown(evebt:MouseEvent):void
    {
      var address:String = null;
      switch(hover)
      {
        case 0: address = "http://www.draknek.org/"; break;
        case 1: address = "http://jonathanwhiting.com/"; break;
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
