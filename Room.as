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
		
		[Embed(source="levels/level.lvl", mimeType="application/octet-stream")]
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
		public static const ENEMY_3:int = 8;
		public static const SCROLL:int = 9;
		public static const BLINDFOLD:int = 10;
		public static const FAKE_SPIKE:int = 11;
		public static const FOUNTAIN:int = 12;
		
		public var fadedBuffer:BitmapData; 
		public static var maskBuffer:BitmapData;
		
		public static const WIDTH:int = 320;
		public static const HEIGHT:int = 240;
		
		private var spawnX:Number = 0;
		private var spawnY:Number = 0;
		private var spawnAngle:Number = 90;
		private var spawnTargetAngle:Number = 90;
		
		public var nextRoom:Room;
		
		public var particles:Particles;
		
		public function Room (_camera:Point = null, _player:Player = null, editor:Editor = null, resume:Boolean = false)
		{
			var tileW:int = 16;
			var tileH:int = 16;
			
			var tilesWide:int = WIDTH / tileW;
			var tilesHigh:int = HEIGHT / tileH;
			
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
				ix = 0;
				iy = 0;
				
				if(resume && !Main.so.data.save["startAtStart"]) {
					ix = Main.so.data.save["x"] / WIDTH;
					iy = Main.so.data.save["y"] / HEIGHT;
				} else {
					label: for (var i:int = 0; i < Editor.src.columns; i++) {
						for (var j:int = 0; j < Editor.src.rows; j++) {
							var tile:uint = Editor.src.getTile(i, j);
							
							if (tile == PLAYER) {
								ix = i / tilesWide;
								iy = j / tilesHigh;
								break label;
							}
						}
					}
				}
			}
			
			fadedBuffer = new BitmapData(FP.width, FP.height, true, 0x00000000);
			maskBuffer = new BitmapData(FP.width, FP.height, true, 0x00000000);
			
			camera.x = ix * WIDTH;
			camera.y = iy * HEIGHT;
			
			src = Editor.src.getSubMap(ix*tilesWide, iy * tilesHigh, tilesWide, tilesHigh);
			
			staticTilemap = new Tilemap(StaticTilesGfx, FP.width, FP.height, src.tileWidth, src.tileHeight);
			wallGrid = new Grid(FP.width, FP.height, src.tileWidth, src.tileHeight);
			altarGrid = new Grid(FP.width, FP.height, src.tileWidth, src.tileHeight);
			
			if (_player) {
				player = _player;
				
				saveGameState(_player);
			} else if (editor) {
				spawnX = editor.mouseX;
				spawnY = editor.mouseY;
			} else if (resume && !Main.so.data.save["startAtStart"])
			{
				spawnX = Main.so.data.save["x"];
				spawnY = Main.so.data.save["y"];
				spawnAngle = Main.so.data.save["angle"];
				spawnTargetAngle = Main.so.data.save["targetAngle"];				
			}
			
			reloadState(false);
			
			spawnAngle = spawnTargetAngle;
			
			if(resume)
			{
				Pickup.ignore = Main.so.data.save["ignore"];
				Player.scrollCount = Main.so.data.save["scrollcount"];
				Player.hasBlindfold = Main.so.data.save["hasBlindfold"];
				Player.playTime = Main.so.data.save["playTime"];
				Player.numDeaths = Main.so.data.save["numDeaths"];
			}
		}
		
		public override function begin ():void
		{
			Main.sprite.visible = true;
		}
		
		public override function end ():void
		{
			Main.sprite.visible = false;
		}
		
		public function saveGameState (p:Player):void
		{
			for (var pickupID:String in p.pickups) {
				Pickup.ignore[pickupID] = true;
				
				if (p.pickups[pickupID].tileID == SCROLL) {
					Player.scrollCount++;
				}
			}
			
			spawnX = p.x;
			spawnY = p.y;
			spawnAngle = p.angle;
			spawnTargetAngle = p.targetAngle;
			
			var save:Object = {};
			save["x"] = p.x;
			save["y"] = p.y;
			save["angle"] = p.angle
			save["targetAngle"] = p.angle;
			save["scrollcount"] = Player.scrollCount;
			save["ignore"] = Pickup.ignore;
			save["hasBlindfold"] = Player.hasBlindfold;
			save["playTime"] = Player.playTime;
			save["numDeaths"] = Player.numDeaths;
			save["startAtStart"] = false;
			Main.so.data.save = save;
			Main.so.flush();
		}
		
		public function loadFromSave(save:Object):void
		{
			spawnX = save["x"];
			spawnY = save["y"];
			spawnAngle = save["angle"];
			spawnTargetAngle = save["targetAngle"];
		}
		
		public override function update (): void
		{
			if (Main.mouseControl) {
				Input.mouseCursor = "auto";
			} else {
				Input.mouseCursor = "hide";
			}
			
			if (Input.check(Key.SHIFT) && Input.pressed(Key.F1)) {
				FP.console.enable();
			}
			
			if (nextRoom) return;
			
			/*if (Input.pressed(Key.E)) {
				FP.world = new Editor(this);
				return;
			}
			
			if (Input.pressed(Key.R)) {
				reloadState();
			}*/
			
			super.update();
			Spike.updateFrame();
			
			const HALF_TILE:Number = 0; // Yes, I know... :/
			
			if (player.x - camera.x < HALF_TILE) scroll(-1, 0);
			else if (player.y + 2 - camera.y < HALF_TILE) scroll(0, -1);
			else if (player.x - camera.x - WIDTH > -HALF_TILE) scroll(1, 0);
			else if (player.y + 2 - camera.y - HEIGHT > -HALF_TILE) scroll(0, 1);
		}
		
		public function scroll (dx:int, dy:int):void
		{
			FP.point.x = camera.x + dx*WIDTH;
			FP.point.y = camera.y + dy*HEIGHT;
			
			nextRoom = new Room(FP.point, player);
			
			nextRoom.updateLists();
			//nextRoom.update();
			
			FP.point.x = camera.x + dx*WIDTH;
			FP.point.y = camera.y + dy*HEIGHT;
			
			FP.tween(camera, {
				x: FP.point.x,
				y: FP.point.y
			}, 30, function():void {
				FP.world = nextRoom;
				nextRoom.camera.x = camera.x;
				nextRoom.camera.y = camera.y;
				remove(player);
			});
		}
		
		private function swapColour(image:BitmapData, source:uint, dest:uint):void
		{
			image.threshold(image, image.rect, FP.zero, "==", source, dest);
			
			if (Player.eyesShut) {
				player.sprite._buffer.threshold(player.sprite._buffer, player.sprite._bufferRect, FP.zero, "==", source, dest);
			}
		}
		
		private static const SCREEN_RECT:Rectangle = new Rectangle(0, 0, WIDTH, HEIGHT);
		
		public override function render (): void
		{
			if (nextRoom) {
				nextRoom.camera.x = camera.x;
				nextRoom.camera.y = camera.y;
				nextRoom.render();
			}
			
			maskBuffer.fillRect(SCREEN_RECT, 0x00000000);
			if (player && Player.eyesShut && ! player.dead) {
				Draw.rect(camera.x, camera.y, FP.width, FP.height, 0x0);
				player.render();
			} else {
				super.render();
			}
			
			fadedBuffer.copyPixels(FP.buffer, SCREEN_RECT, FP.zero);
			swapColour(fadedBuffer, 0xff09141d, 0xff05080b);
			swapColour(fadedBuffer, 0xff403152, 0xff222231);
			swapColour(fadedBuffer, 0xff7dbd43, 0xff3f7051);
			swapColour(fadedBuffer, 0xff55d4dc, 0xff4a6285);
			swapColour(fadedBuffer, 0xfff5f8c0, 0xffd2ed93);
			fadedBuffer.threshold(maskBuffer, SCREEN_RECT, FP.zero, "==", 0xff000000, 0x00000000, 0xFF000000);
			FP.buffer.copyPixels(fadedBuffer, SCREEN_RECT, FP.zero);
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
							add(new Stack(x, y));
						break;
						case ALTAR:
							staticTilemap.setTile(i, j, 20);
						break;
						case ENEMY_3:
							add(new Eye(x, y));
						break;
						case SCROLL:
						case BLINDFOLD:
							add(new Pickup(x, y, tile));
						break;
						case FAKE_SPIKE:
							add(new Spike(x, y, true));
						break;
						case FOUNTAIN:
							add(new Fountain(x, y));
						break;
					}
				}
			}
			
			{
				player = new Player();
				player.x = spawnX;
				player.y = spawnY;
				player.angle = spawnAngle;
				player.targetAngle = spawnTargetAngle;
			}
			
			particles = new Particles();
			add(particles);
			
			/*if (player.world && player.world != this) {
				player.world.remove(player);
			}*/
			
			if (! player.world) {
				add(player);
			}
		}
	}
}

