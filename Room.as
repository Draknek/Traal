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
	
	public class Room extends World
	{
		[Embed(source="images/static-tiles.png")]
		public static const StaticTilesGfx: Class;		
		
		[Embed(source="levels/demo.lvl", mimeType="application/octet-stream")]
		public static const DefaultRoom: Class;		
		
		public var src:Tilemap;
		
		public var staticTilemap:Tilemap;
		public var wallGrid:Grid;
		public var altarGrid:Grid;
		
		public var player:Player;
		
		public static const FLOOR:int = 0;
		public static const WALL:int = 1;
		public static const SPIKE:int = 2;
		public static const PLAYER:int = 3;
		public static const ENEMY_1:int = 4;
		public static const BREAKABLE:int = 5;
		public static const ENEMY_2:int = 6;
		public static const ALTAR:int = 7;
		
		public var fadedBuffer:BitmapData; 
		public static var maskBuffer:BitmapData;
		
		public static const WIDTH:int = 320;
		public static const HEIGHT:int = 240;
		
		public function Room (editor:Editor = null, _player:Player = null)
		{
			if (editor) {
				var ix:int = Math.floor(editor.camera.x / WIDTH) + 1;
				var iy:int = Math.floor(editor.camera.y / HEIGHT) + 1;
			} else {
				ix = iy = 0;
			}
			
			fadedBuffer = new BitmapData(FP.width, FP.height, true, 0x00000000);
			maskBuffer = new BitmapData(FP.width, FP.height, true, 0x00000000);
			
			camera.x = ix * WIDTH;
			camera.y = iy * HEIGHT;
			
			var tileW:int = 16;
			var tileH:int = 16;
			
			var tilesWide:int = WIDTH / tileW;
			var tilesHigh:int = HEIGHT / tileH;
			
			src = Editor.src.getSubMap(ix*tilesWide, iy * tilesHigh, tilesWide, tilesHigh);
			
			staticTilemap = new Tilemap(StaticTilesGfx, FP.width, FP.height, src.tileWidth, src.tileHeight);
			wallGrid = new Grid(FP.width, FP.height, src.tileWidth, src.tileHeight);
			altarGrid = new Grid(FP.width, FP.height, src.tileWidth, src.tileHeight);
			
			if (_player) {
				player = player;
			}
			
			reloadState();
			
			if (! player) {
				player = new Player();
				player.x = editor.mouseX;
				player.y = editor.mouseY;
			}
			
			if (! player.world) {
				add(player);
			}
		}
		
		public override function update (): void
		{
			if (Input.pressed(Key.E)) {
				FP.world = new Editor(this);
				return;
			}
			
			if (Input.pressed(Key.R)) {
				reloadState();
			}
			
			super.update();
			Spike.updateFrame();
		}
		
		private function swapColour(image:BitmapData, source:uint, dest:uint):void
		{
			image.threshold(image, image.rect, FP.zero, "==", source, dest);
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
			
			fadedBuffer.copyPixels(FP.buffer, FP.buffer.rect, new Point(0,0));
			swapColour(fadedBuffer, 0xff09141d, 0xff05080b);
			swapColour(fadedBuffer, 0xff403152, 0xff222231);
			swapColour(fadedBuffer, 0xff7dbd43, 0xff3f7051);
			swapColour(fadedBuffer, 0xff55d4dc, 0xff4a6285);
			swapColour(fadedBuffer, 0xfff5f8c0, 0xffd2ed93);
			fadedBuffer.threshold(maskBuffer, maskBuffer.rect, new Point(0,0), "==", 0xffffffff, 0x00000000);
			FP.buffer.copyPixels(fadedBuffer, fadedBuffer.rect, new Point(0,0));
		}
		
		public function reloadState ():void
		{
			src.createGrid([WALL], wallGrid);
			src.createGrid([ALTAR], altarGrid);
			
			removeAll();
			
			addGraphic(staticTilemap, 0, camera.x, camera.y);
			
			addMask(wallGrid, "solid", camera.x, camera.y);
			addMask(altarGrid, "altar", camera.x, camera.y);
			
			staticTilemap.setRect(0, 0, staticTilemap.columns, staticTilemap.rows, 7);
			
			for (var i:int = 0; i < src.columns; i++) {
				for (var j:int = 0; j < src.rows; j++) {
					var tile:uint = src.getTile(i, j);
					
					var x:Number = camera.x + i * src.tileWidth;
					var y:Number = camera.y + j * src.tileHeight;
					
					switch (tile) {
						case FLOOR:
							staticTilemap.setTile(i, j, 7);
						break;
						case WALL:
							Editor.autoWall(src, staticTilemap, i, j);
						break;
						case SPIKE:
							add(new Spike(x, y));
						break;
						case PLAYER:
							if (! player) {
								player = new Player;
								player.x = x + src.tileWidth*0.5;
								player.y = y + src.tileHeight*0.5;
								add(player);
							}
						break;
						case ENEMY_1:
							add(new Blob(x, y));
						break;
						case BREAKABLE:
							add(new Breakable(x, y));
						break;
						case ENEMY_2:
							add(new Eye(x, y));
						break;
						case ALTAR:
							staticTilemap.setTile(i, j, 20);
						break;
					}
				}
			}
		}
	}
}

