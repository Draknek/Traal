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
		
		private var spawnX:Number = 0;
		private var spawnY:Number = 0;
		private var spawnAngle:Number = 0;
		private var spawnTargetAngle:Number = 0;
		
		public var nextRoom:Room;
		
		public function Room (_camera:Point = null, _player:Player = null, editor:Editor = null)
		{
			if (_camera) {
				var ix:int = Math.floor(_camera.x / WIDTH);
				var iy:int = Math.floor(_camera.y / HEIGHT);
				
				if (editor) {
					ix += 1;
					iy += 1;
				} else {
					ix = Math.round(_camera.x / WIDTH);
					iy = Math.round(_camera.y / HEIGHT);
				}
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
				player = _player;
				spawnX = player.x;
				spawnY = player.y;
				spawnAngle = player.angle;
				spawnTargetAngle = player.targetAngle;
			} else if (editor) {
				spawnX = editor.mouseX;
				spawnY = editor.mouseY;
			}
			
			reloadState(false);
			
			spawnAngle = spawnTargetAngle;
		}
		
		public override function update (): void
		{
			if (nextRoom) return;
			
			if (Input.pressed(Key.E)) {
				FP.world = new Editor(this);
				return;
			}
			
			if (Input.pressed(Key.R)) {
				reloadState();
			}
			
			super.update();
			Spike.updateFrame();
			
			const HALF_TILE:Number = -2; // Yes, I know... :/
			
			if (player.x - camera.x < HALF_TILE) scroll(-1, 0);
			else if (player.y - camera.y < HALF_TILE) scroll(0, -1);
			else if (player.x - camera.x - WIDTH > -HALF_TILE) scroll(1, 0);
			else if (player.y - camera.y - HEIGHT > -HALF_TILE) scroll(0, 1);
		}
		
		public function scroll (dx:int, dy:int):void
		{
			FP.point.x = camera.x + dx*WIDTH;
			FP.point.y = camera.y + dy*HEIGHT;
			
			nextRoom = new Room(FP.point, player);
			
			nextRoom.updateLists();
			//nextRoom.update();
			
			FP.tween(camera, {
				x: FP.point.x,
				y: FP.point.y
			}, 30, function():void {
				FP.world = nextRoom;
				remove(player);
			});
		}
		
		private function swapColour(image:BitmapData, source:uint, dest:uint):void
		{
			image.threshold(image, image.rect, FP.zero, "==", source, dest);
		}		
		
		public override function render (): void
		{
			if (nextRoom) {
				nextRoom.camera.x = camera.x;
				nextRoom.camera.y = camera.y;
				nextRoom.render();
			}
			
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
		
		public function reloadState (hardReset:Boolean = true):void
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
								spawnX = x + src.tileWidth*0.5;
								spawnY = y + src.tileHeight*0.5;
							}
						break;
						case ENEMY_1:
							add(new Blob(x, y));
						break;
						case BREAKABLE:
							add(new Breakable(x, y));
						break;
						case ENEMY_2:
							add(new Stack(i * src.tileWidth, j * src.tileHeight));
						break;
						case ALTAR:
							staticTilemap.setTile(i, j, 20);
						break;
					}
				}
			}
			
			{//if (! player || hardReset) {
				player = new Player();
				player.x = spawnX;
				player.y = spawnY;
				player.angle = spawnAngle;
				player.targetAngle = spawnTargetAngle;
			}
			
			if (player.world && player.world != this) {
				player.world.remove(player);
			}
			
			if (! player.world) {
				add(player);
			}
		}
	}
}

