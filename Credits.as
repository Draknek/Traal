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
  
    public function Credits ()
    {
      var message:String = new Creds;
      //var message:String = "Traal\nA game by\nAlan Hazelden\nJonathan Whiting\n\nFILL IN SOUND INFO HERE";
      var text:Text = new Text(message, 0, 0, {align: "center", width: FP.width * 0.60, wordWrap: true, color: 0x08131b});
      text.x = (FP.width - text.width)/2;
      text.y = 16;
    
      var scroll:Scroll = new Scroll(text.textWidth, text.textHeight);
      scroll.x = (FP.width - scroll.width)/2;
      scroll.y = 0;
    
      addGraphic(scroll);
      addGraphic(text);
    }
  }
}