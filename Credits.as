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
    [Embed(source="Credits.txt",mimeType="application/octet-stream")]
    private var Creds : Class;
    
    private var text:Text;
    private var scroll:Scroll;
    
    private var scrollPos:Number;
  
    public function Credits ()
    {
      var message:String = new Creds;
      text = new Text(message, 0, 0, {align: "center", width: FP.width * 0.60, wordWrap: true, color: 0x08131b});
      text.x = (FP.width - text.width)/2;      
    
      scroll = new Scroll(text.textWidth, text.textHeight);
      scroll.x = (FP.width - scroll.width)/2;
    
      addGraphic(scroll);
      addGraphic(text);
      
      scrollPos = -FP.height;
      updateY();
    }
    
    public function updateY():void
    {
      scroll.y = -scrollPos;
      text.y = 16-scrollPos;
    }
    
    public override function update (): void
		{
			Input.mouseCursor = "auto";			
			super.update();
      
      if(scrollPos < scroll.height + FP.height)
        scrollPos += 0.2;
      updateY();
    }
  }
}