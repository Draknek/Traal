package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.utils.*;
	
	public class Level extends LoadableWorld
	{
		[Embed(source="images/static-tiles.png")]
		public static const StaticTilesGfx: Class;		
		
		[Embed(source="levels/demo.lvl", mimeType="application/octet-stream")]
		public static const DefaultLevel: Class;		
		
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
			src.loadFromString(new DefaultLevel);
			
			staticTilemap = new Tilemap(StaticTilesGfx, FP.width, FP.height, src.tileWidth, src.tileHeight);
			addGraphic(staticTilemap);
			
			wallGrid = new Grid(FP.width, FP.height, src.tileWidth, src.tileHeight);
			spikeGrid = new Grid(FP.width, FP.height, src.tileWidth, src.tileHeight);
			
			addMask(wallGrid, "solid");
			addMask(spikeGrid, "spikes");
			
			add(player = new Player());
			
			reloadState();
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
			
			if (Input.pressed(Key.R)) {
				reloadState();
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
		
		public function GetTile(i:int, j:int):uint
		{
			if(i<0 || i>=src.columns || j<0 || j>=src.rows) return WALL;		
			return src.getTile(i,j);
		}
		
		public function autoWall(map:Tilemap, i:int, j:int):void
		{
			var flags:int = 0;
			if(GetTile(i, j-1)==WALL) flags |= 1;
			if(GetTile(i+1, j)==WALL) flags |= 2;
			if(GetTile(i, j+1)==WALL) flags |= 4;
			if(GetTile(i-1, j)==WALL) flags |= 8;
			
			var allWall:Boolean = false;
			var tx:int=0;
			var ty:int=0;
			switch(flags)
			{
				case 0: tx=4; ty=1; break;
				case 1: tx=1; ty=0; break;
				case 2: tx=2; ty=1; break;
				case 3:	tx=2; ty=0;
					if(GetTile(i+1,j-1)==WALL) tx+=3;
					break;
				case 4: tx=1; ty=2; break;
				case 5: tx=4; ty=1; break;
				case 6: tx=2; ty=2;
					if(GetTile(i+1,j+1)==WALL) tx+=3;
					break;
				case 7: tx=2; ty=1; break;
				case 8: tx=0; ty=1; break;
				case 9: tx=0; ty=0;
					if(GetTile(i-1,j-1)==WALL) tx+=3;
					break;
				case 10: tx=4; ty=1; break;
				case 11: tx=1; ty=0; break;
				case 12: tx=0; ty=2;
					if(GetTile(i-1,j+1)==WALL) tx+=3;
					break;
				case 13: tx=0; ty=1; break;
				case 14: tx=1; ty=2; break;
				case 15: allWall = true; break;
			}
			
			if(allWall)
			{
				flags = 0;
				if(GetTile(i+1, j-1)==WALL) flags |= 1;
				if(GetTile(i+1, j+1)==WALL) flags |= 2;
				if(GetTile(i-1, j+1)==WALL) flags |= 4;
				if(GetTile(i-1, j-1)==WALL) flags |= 8;
				switch(flags)
				{
					default: tx=1; ty=3; break;
					case 7: tx=2; ty=2; break;
					case 11: tx=2; ty=0; break;
					case 13: tx=0; ty=0; break;
					case 14: tx=0; ty=2; break;
				}
			}
			
			map.setTile(i, j, tx+ty*6);
		}
		
		public function reloadState ():void
		{
			src.createGrid([WALL], wallGrid);
			src.createGrid([SPIKE], spikeGrid);
			
			var a:Array = [];
			var e:Entity;
			
			getType("enemy", a);			
			for each (e in a) {
				remove(e);
			}
			
			getType("spikes", a);
			for each (e in a) {
				remove(e);
			}
			
			staticTilemap.setRect(0, 0, staticTilemap.columns, staticTilemap.rows, 7);
			
			for (var i:int = 0; i < src.columns; i++) {
				for (var j:int = 0; j < src.rows; j++) {
					var tile:uint = src.getTile(i, j);
					
					switch (tile) {
						case FLOOR:
							staticTilemap.setTile(i, j, 7);
						break;
						case WALL:
							// TODO: calculate auto-tilingness
							autoWall(staticTilemap, i, j);
						break;
						case SPIKE:
							staticTilemap.setTile(i, j, 18);
							add(new Spike(i * src.tileWidth, j * src.tileHeight));
						break;
						case PLAYER:
							player.x = (i+0.5) * src.tileWidth;
							player.y = (j+0.5) * src.tileHeight;
						break;
						case ENEMY_1:
							add(new Blob(i * src.tileWidth, j * src.tileHeight));
						break;
					}
				}
			}
		}
		
	}
}

