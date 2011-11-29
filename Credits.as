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
	
	public class Credits extends World
	{
    [Embed(source="images/logo.png")]
		public static const LogoGfx: Class;
  
    [Embed(source="Credits.txt",mimeType="application/octet-stream")]
    private var Creds : Class;
    
    private var logo:Image;
    private var text:Text;
    private var scroll:Scroll;
    
    private var scrollPos:Number;
  
    public function Credits ()
    {
      logo = new Image(LogoGfx);
      logo.x = (FP.width - logo.width)/2;
    
      var message:String = new Creds;
	  message += "You took "+int(Player.playTime)+" seconds\n";
	  message += "You found "+Player.scrollCount+" of "+Player.scrollCountTotal+" scrolls\n";
	  message += "You died "+Player.numDeaths+" times\n";
      text = new Text(message, 0, 0, {align: "center", width: FP.width * 0.60, wordWrap: true, color: 0x08131b});
      text.x = (FP.width - text.width)/2;      
    
      scroll = new Scroll(text.textWidth, text.textHeight+64);
      scroll.x = (FP.width - scroll.width)/2;
          
      addGraphic(scroll);
      addGraphic(logo);
      addGraphic(text);
      
      scrollPos = -FP.height;
      updateY();
    }
    
    public function updateY():void
    {      
      scroll.y = -scrollPos;
      logo.y = 16-scrollPos;
      text.y = 64-scrollPos;
    }
    
    public override function update (): void
	{
		Input.mouseCursor = "auto";			
		super.update();
      
		var speed:Number = 0.25;
		if(Input.check(Key.X) || Input.check(Key.SPACE))
			speed *= 4;
		
		if(scrollPos < scroll.height+32) {
			scrollPos += speed;
		} else {
			Main.so.data.save = null;
			Main.so.flush();
			FP.world = new Title();
		}
		updateY();
    }
  }
}