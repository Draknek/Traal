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
	
	public class Room extends LoadableWorld
	{
		[Embed(source="images/static-tiles.png")]
		public static const StaticTilesGfx: Class;		
		
		[Embed(source="levels/demo.lvl", mimeType="application/octet-stream")]
		public static const DefaultRoom: Class;		
		
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
		
		public function Room ()
		{
			fadedBuffer = new BitmapData(FP.width, FP.height, true, 0x00000000);
			maskBuffer = new BitmapData(FP.width, FP.height, true, 0x00000000);
		
			src = new Tilemap(Editor.EditTilesGfx, FP.width, FP.height, 16, 16);
			src.loadFromString(new DefaultRoom);
			
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
				Spike.updateFrame();
			}
		}
		
		private function swapColour(image:BitmapData, source:uint, dest:uint):void
		{
			image.threshold(image, image.rect, FP.zero, "==", source, dest);
		}		
		
		public override function render (): void
		{
			maskBuffer.fillRect(maskBuffer.rect, editMode ? 0xffffffff : 0x00000000);
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
			swapColour(fadedBuffer, 0xff09141d, 0xff05080b);
			swapColour(fadedBuffer, 0xff403152, 0xff222231);
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
							Editor.autoWall(src, staticTilemap, i, j);
						break;
						case SPIKE:
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

