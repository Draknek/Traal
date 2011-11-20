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
		
		public function Title ()
		{
			var title:Image = new Image(TitleGfx);
			title.scale = 4;
			addGraphic(title);
			var space:Image = new Image(SpaceGfx);
			addGraphic(space, 0, 93, 216);
			var jonathan:Image = new Image(JonathanGfx);
			jonathan.scale = 2;
			addGraphic(jonathan, 0, 217, 165);
			var alan:Image = new Image(AlanGfx);
			alan.scale = 2;
			addGraphic(alan, 0, 20, 166);
		}

		public override function update (): void
		{
			super.update();
			if (Input.pressed(Key.X) || Input.pressed(Key.SPACE))
			{
				FP.world = new Room();
				Audio.startMusic();
			}
		}
		
		public override function render (): void
		{
			super.render();
		}		
	}
}
