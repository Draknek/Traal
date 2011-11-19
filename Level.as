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
		public static const BREAKABLE:int = 5;
		
		public var fadedBuffer:BitmapData; 
		public static var maskBuffer:BitmapData;
		
		public function Level ()
		{
			fadedBuffer = new BitmapData(FP.width, FP.height, true, 0x00000000);
			maskBuffer = new BitmapData(FP.width, FP.height, true, 0x00000000);
		
			src = new Tilemap(Editor.EditTilesGfx, FP.width, FP.height, 16, 16);
			src.loadFromString(new DefaultLevel);
			
			staticTilemap = new Tilemap(StaticTilesGfx, FP.width, FP.height, src.tileWidth, src.tileHeight);
			wallGrid = new Grid(FP.width, FP.height, src.tileWidth, src.tileHeight);
			spikeGrid = new Grid(FP.width, FP.height, src.tileWidth, src.tileHeight);
			
			reloadState();
		}
		
		public override function update (): void
		{
			Input.mouseCursor = "auto";
			
			if (Input.pressed(Key.E)) {
				editMode = ! editMode;
				reloadState();
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
		
		private function swapColour(image:BitmapData, source:uint, dest:uint):void
		{
			image.threshold(image, image.rect, new Point(0,0), "==", source, dest);
		}		
		
		public override function render (): void
		{
			maskBuffer.fillRect(maskBuffer.rect, 0x00000000);
			if (player && player.eyesShut && ! player.dead) {
				Draw.rect(0, 0, FP.width, FP.height, 0x0);
				player.render();
			} else {
				super.render();
			}
			
			if (editMode) {
				Editor.render(this);
			}	
			
			fadedBuffer.copyPixels(FP.buffer, FP.buffer.rect, new Point(0,0));
			swapColour(fadedBuffer, 0xff09141d, 0xff1c2833);
			swapColour(fadedBuffer, 0xff403152, 0xff39303b);
			swapColour(fadedBuffer, 0xff7dbd43, 0xff3f7051);
			swapColour(fadedBuffer, 0xff55d4dc, 0xff4a6285);
			swapColour(fadedBuffer, 0xfff5f8c0, 0xffd2ed93);
			fadedBuffer.threshold(maskBuffer, maskBuffer.rect, new Point(0,0), "==", 0xffffffff, 0x00000000);
			FP.buffer.copyPixels(fadedBuffer, fadedBuffer.rect, new Point(0,0));
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
			
			removeAll();
			
			addGraphic(staticTilemap);
			
			addMask(wallGrid, "solid");
			addMask(spikeGrid, "spikes");
			
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
							player = new Player;
							player.x = (i+0.5) * src.tileWidth;
							player.y = (j+0.5) * src.tileHeight;
							add(player);
						break;
						case ENEMY_1:
							add(new Blob(i * src.tileWidth, j * src.tileHeight));
						break;
						case BREAKABLE:
							add(new Breakable(i * src.tileWidth, j * src.tileHeight));
						break;
					}
				}
			}
		}
	}
}

