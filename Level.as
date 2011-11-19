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
		
		public var staticTilemap:Tilemap;
		public var wallGrid:Grid;
		public var spikeGrid:Grid;
		
		public var player:Player;
		
		public static const FLOOR:int = 0;
		public static const WALL:int = 1;
		public static const SPIKE:int = 2;
		public static const PLAYER:int = 3;
		public static const ENEMY_1:int = 4;
		
		public function Level ()
		{
			src = new Tilemap(Editor.EditTilesGfx, FP.width, FP.height, 16, 16);
			src.setRect(0, 0, src.columns, src.rows, 0);
			
			staticTilemap = new Tilemap(Editor.EditTilesGfx, FP.width, FP.height, src.tileWidth, src.tileHeight);
			staticTilemap.setRect(0, 0, src.columns, src.rows, 0);
			addGraphic(staticTilemap);
			
			wallGrid = new Grid(FP.width, FP.height, src.tileWidth, src.tileHeight);
			spikeGrid = new Grid(FP.width, FP.height, src.tileWidth, src.tileHeight);
			
			addMask(wallGrid, "solid");
			addMask(spikeGrid, "spikes");
			
			add(player = new Player());
		}
		
		public override function update (): void
		{
			Input.mouseCursor = "auto";
			
			if (Input.pressed(Key.E)) {
				editMode = ! editMode;
				
				if (! editMode) {
					reloadState();
				}
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
			
			reloadState();
		}
		
		public function reloadState ():void
		{
			src.createGrid([WALL], wallGrid);
			src.createGrid([SPIKE], spikeGrid);
			
			for (var i:int = 0; i < src.columns; i++) {
				for (var j:int = 0; j < src.columns; j++) {
					var tile:uint = src.getTile(i, j);
					
					switch (tile) {
						case FLOOR:
							staticTilemap.setTile(i, j, 0);
						break;
						case WALL:
							// TODO: calculate auto-tilingness
							staticTilemap.setTile(i, j, 1);
						break;
						case SPIKE:
							// TODO: calculate auto-tilingness
							staticTilemap.setTile(i, j, 2);
						break;
						case PLAYER:
							player.x = (i+0.5) * src.tileWidth;
							player.y = (j+0.5) * src.tileHeight;
						break;
						default:
							staticTilemap.setTile(i, j, 0);
						break;
					}
				}
			}
		}
		
	}
}

