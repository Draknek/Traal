package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.utils.*;
	
	public class Level extends LoadableWorld
	{
		//[Embed(source="images/bg.png")] public static const BgGfx: Class;
		
		public var editMode:Boolean = false;
		
		public var src:Tilemap;
		
		public var grid:Grid;
		
		public var player:Player;
		
		public function Level ()
		{
			src = new Tilemap(Editor.EditTilesGfx, FP.width, FP.height, 16, 16);
			src.setRect(0, 0, src.columns, src.rows, 0);
			addGraphic(src);
			
			grid = new Grid(FP.width, FP.height, 16, 16);
			
			addMask(grid, "solid");
			
			add(player = new Player());
		}
		
		public override function update (): void
		{
			Input.mouseCursor = "auto";
			
			if (Input.pressed(Key.E)) {
				editMode = ! editMode;
			}
			
			if (editMode) {
				Editor.update(this);
			} else {
				super.update();
			}
		}
		
		public override function render (): void
		{
			if (player.eyesShut && ! player.dead) {
				Draw.rect(0, 0, FP.width, FP.height, 0x0);
				player.render();
			} else {
				super.render();
			}
			
			if (editMode) {
				Editor.render(this);
			}
		}
		
		public override function getWorldData (): *
		{
			return src.saveToString();
		}
		
		public override function setWorldData (data: ByteArray): void {
			var string:String = data.toString();
			
			src.loadFromString(string);
			
			grid = src.createGrid([1, 3, 5, 7]);
		}
		
	}
}

