package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.utils.*;
	import flash.display.*;
	import flash.geom.*;
	
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
		
		public static var fadedBuffer:BitmapData;
		public static var fadedBuffer2:BitmapData;
		public static var maskBuffer:BitmapData;
		public static var maskBuffer2:BitmapData;
		public static var maskBuffer3:BitmapData;
		
		public static const WIDTH:int = 320;
		public static const HEIGHT:int = 240;
		
		public var ix:int;
		public var iy:int;
		
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
				ix = Math.floor(_camera.x / WIDTH);
				iy = Math.floor(_camera.y / HEIGHT);
				
				if (editor) {
					//ix += 1;
					//iy += 1;
				} else {
					ix = Math.round(_camera.x / WIDTH);
					iy = Math.round(_camera.y / HEIGHT);
				}
			} else {
				ix = 0;
				iy = 0;
				
				if(resume && !Main.so.data.save["startAtStart"]) {
					ix = Main.so.data.save["x"] / WIDTH;
					iy = (Main.so.data.save["y"] + 2) / HEIGHT;
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
			
			if (! fadedBuffer) {
				fadedBuffer = new BitmapData(WIDTH, HEIGHT, true, 0x00000000);
				fadedBuffer2 = new BitmapData(WIDTH, HEIGHT, true, 0x00000000);
				maskBuffer = new BitmapData(WIDTH, HEIGHT, true, 0x00000000);
				maskBuffer2 = new BitmapData(WIDTH, HEIGHT, true, 0x00000000);
				maskBuffer3 = new BitmapData(WIDTH, HEIGHT, true, 0x00000000);
			}
			
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
				spawnAngle = Main.so.data.save["targetAngle"];
				spawnTargetAngle = Main.so.data.save["targetAngle"];				
			}
			
			if(resume)
			{
				Pickup.ignore = Main.so.data.save["ignore"];
				Player.scrollCount = Main.so.data.save["scrollcount"];
				Player.hasBlindfold = Main.so.data.save["hasBlindfold"];
				Player.playTime = Main.so.data.save["playTime"];
				Player.numDeaths = Main.so.data.save["numDeaths"];
			}
			
			reloadState(false);
			
			spawnAngle = spawnTargetAngle;
			
			updateLists();
		}
		
		public override function begin ():void
		{
			Main.sprite.visible = true;
			Main.overSprite.visible = true;
		}
		
		public override function end ():void
		{
			Main.sprite.visible = false;
			Main.overSprite.visible = false;
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
			save["targetAngle"] = p.targetAngle;
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
			
			if (Input.pressed(Key.ESCAPE)) {
				FP.world = new Title;
				return;
			}
			
			/*if (Input.pressed(Key.E)) {
				FP.world = new Editor(this);
				return;
			}
			
			/*if (Input.pressed(Key.R)) {
				reloadState();
			}*/
			
			super.update();
			Spike.updateFrame();
			
			var scrollOffset:Number = 0;
			
			if (Main.touchscreen && ! Main.joystick) {
				var w:int = FP.stage.stageWidth - WIDTH * FP.screen.scale;
				var h:int = FP.stage.stageHeight - HEIGHT * FP.screen.scale;
				
				scrollOffset = 16 - Math.min(w, h)*0.5 / FP.screen.scale;
				
				if (scrollOffset < 0) scrollOffset = 0;
				if (scrollOffset > 16) scrollOffset = 16;
			}
			
			if (player.x - camera.x < scrollOffset) scroll(-1, 0);
			else if (player.y + 2 - camera.y < scrollOffset) scroll(0, -1);
			else if (player.x - camera.x - WIDTH > -scrollOffset) scroll(1, 0);
			else if (player.y + 2 - camera.y - HEIGHT > -scrollOffset) scroll(0, 1);
		}
		
		public function scroll (dx:int, dy:int):void
		{
			FP.point.x = camera.x + (1+dx)*WIDTH*0.5;
			FP.point.y = camera.y + (1+dy)*HEIGHT*0.5 - 2;
			
			if (player.running) {
				var canLeave:Boolean = false;
				
				if (Eye.activeEye && Eye.activeEye.world == this) {
					var distance:Number = FP.distance(
						player.x, player.y,
						Eye.activeEye.x, Eye.activeEye.y
					);
					
					if (distance < 30) canLeave = true;
				}
				
				if (! canLeave) {
					if (dx) {
						FP.point.x += - dx - player.vx;
						
						if (dx > 0) player.x = Math.min(player.x, FP.point.x);
						else player.x = Math.max(player.x, FP.point.x);
					}
					if (dy) {
						FP.point.y += - dy - player.vy;
						
						if (dy > 0) player.y = Math.min(player.y, FP.point.y);
						else player.y = Math.max(player.y, FP.point.y);
					}
					return;
				}
			}
			
			if ((dx && FP.sign(player.vx) != dx) || (dy && FP.sign(player.vy) != dy)) {
				return;
			}
			
			var oldX:Number = player.x;
			var oldY:Number = player.y;
			var newX:Number = player.x
			var newY:Number = player.y;
			
			if (dx) {
				newX = FP.point.x;
				player.x = newX + dx*0.1;
			}
			if (dy) {
				newY = FP.point.y;
				player.y = newY + dy*0.1;
			}
			
			FP.point.x = camera.x + dx*WIDTH;
			FP.point.y = camera.y + dy*HEIGHT;
			
			nextRoom = new Room(FP.point, player);
			
			nextRoom.updateLists();
			//nextRoom.update();
			
			FP.point.x = camera.x + dx*WIDTH;
			FP.point.y = camera.y + dy*HEIGHT;
			
			var tweenTime:int = 30;
			
			FP.tween(camera, {
				x: FP.point.x,
				y: FP.point.y
			}, tweenTime, scrollDone);
			
			var nextPlayer:Player = nextRoom.player;
			
			player.x = oldX;
			player.y = oldY;
			nextPlayer.x = oldX;
			nextPlayer.y = oldY;
			
			FP.tween(player, {
				x: newX,
				y: newY
			}, tweenTime, {tweener: FP.tweener});
			FP.tween(nextPlayer, {
				x: newX,
				y: newY
			}, tweenTime, {tweener: FP.tweener});
		}
		
		private function scrollDone ():void
		{
			FP.world = nextRoom;
			nextRoom.camera.x = camera.x;
			nextRoom.camera.y = camera.y;
			remove(player);
		}
		
		public function shadowMagic (lightCone:Sprite, m:Matrix):void
		{
			var g:Graphics = FP.sprite.graphics;
			
			g.clear();
			
			var tiles:Tilemap = staticTilemap;
			var w:int = tiles.columns;
			var h:int = tiles.rows;
			
			var TW:int = tiles.tileWidth;
			var HW:int = TW * 0.5;
			
			FP.rect.width = FP.rect.height = TW;
			
			for (var i:int = 0; i < w; i++) {
				for (var j:int = 0; j < h; j++) {
					var tile:uint = tiles.getTile(i, j);
					
					if (tile == 7 || tile >= 18) {
						continue;
					}
					
					// Duplicate tiles
					if (tile == 4 || tile == 9 || tile == 11 || tile == 16) {
						tile -= 3;
					}
					
					FP.rect.x = TW*i + this.ix*WIDTH - camera.x;
					FP.rect.y = TW*j + this.iy*HEIGHT - camera.y;
					
					maskBuffer3.fillRect(FP.rect, 0xFFFFFFFF);
					
					var x:Number = FP.rect.x - m.tx;
					var y:Number = FP.rect.y - m.ty;
					
					var x1:Number,y1:Number;
					var x2:Number,y2:Number;
					var x3:Number,y3:Number;
					
					var use3:Boolean = false;
					
					if (tile == 0 || tile == 2 || tile == 12 || tile == 14) {
						use3 = true;
						
						x1 = (tile == 0 || tile == 12) ? x : x + TW;
						y1 = (tile == 0 || tile == 2) ? y + TW : y;
						
						x2 = (tile == 0 || tile == 12) ? x : x + TW;
						y2 = (tile == 0 || tile == 2) ? y : y + TW;
						
						x3 = (tile == 0 || tile == 12) ? x + TW : x;
						y3 = (tile == 0 || tile == 2) ? y : y + TW;
					} else if (tile == 1 || tile == 6 || tile == 8 || tile == 13) {
						x1 = (tile == 8)  ? x + TW : x;
						y1 = (tile == 13) ? y + TW : y;
						
						x2 = (tile == 6) ? x : x + TW;
						y2 = (tile == 1) ? y : y + TW;
					} else if (tile == 3 || tile == 5 || tile == 15 || tile == 17) {
						x1 = (tile == 3 || tile == 15) ? x : x + TW;
						y1 = (tile == 3 || tile == 5)  ? y : y + TW;
						
						x2 = (tile == 3 || tile == 15) ? x + TW : x;
						y2 = (tile == 3 || tile == 5)  ? y + TW : y;
					} else if (tile == 10) {
						if (x >= -TW && x <= 0 && Math.abs(y+HW) > Math.abs(x+HW)) {
							use3 = true;
							
							x1 = x;
							y1 = (y > -HW) ? y : y + TW;
							
							x2 = x + HW;
							y2 = y + HW;
							
							x3 = x + TW;
							y3 = y1;
						} else if (y >= -TW && y <= 0 && Math.abs(x+HW) > Math.abs(y+HW)) {
							use3 = true;
							
							x1 = (x > -HW) ? x : x + TW;
							y1 = y;
							
							x2 = x + HW;
							y2 = y + HW;
							
							x3 = x1;
							y3 = y + TW;
						} else {
							var flip:Boolean = (x > -HW) != (y > -HW);
							x1 = x;
							y1 = (flip) ? y : y + TW;
							
							x2 = x + TW;
							y2 = (! flip) ? y : y + TW;
						}
					} else {
						continue;
					}
					
					var scale:Number = 250;
					
					g.beginFill(0xffffff);
					g.moveTo(x1, y1);
					g.lineTo(x2, y2);
					if (use3) {
						g.lineTo(x3, y3);
						g.lineTo(x3*scale, y3*scale);
					}
					g.lineTo(x2*scale, y2*scale);
					g.lineTo(x1*scale, y1*scale);
					g.lineTo(x1, y1);
					g.endFill();
				}
			}
			
			maskBuffer.draw(lightCone, m);
			
			maskBuffer2.draw(FP.sprite, m);
			
			var circle:BitmapData = FP.getBitmap(Player.CircleGfx);
			FP.point.x = m.tx-24;
			FP.point.y = m.ty-24;
			FP.rect.x = 0;
			FP.rect.y = 0;
			FP.rect.width = circle.width;
			FP.rect.height = circle.height;
			maskBuffer.copyPixels(circle, FP.rect, FP.point, null, null, true);
			maskBuffer2.copyPixels(circle, FP.rect, FP.point, null, null, true);
			
			var fountain:Fountain = classFirst(Fountain) as Fountain;
			
			if (fountain) {
				fountain.renderLight();
			}
		}
		
		private function swapColour(image:BitmapData, rect:Rectangle, source:uint, dest:uint):void
		{
			image.threshold(image, rect, FP.zero, "==", source, dest);
			
			if (Player.eyesShut) {
				player.sprite._buffer.threshold(player.sprite._buffer, player.sprite._bufferRect, FP.zero, "==", source, dest);
			}
		}
		
		private static const SCREEN_RECT:Rectangle = new Rectangle(0, 0, WIDTH, HEIGHT);
		
		public static var innerRender:Boolean = false;
		
		public override function render (): void
		{
			if (! innerRender) {
				maskBuffer.fillRect(SCREEN_RECT, 0x00000000);
				maskBuffer2.fillRect(SCREEN_RECT, 0x00000000);
				maskBuffer3.fillRect(SCREEN_RECT, 0x00000000);
			}
			
			if (nextRoom) {
				innerRender = true;
				
				nextRoom.camera.x = camera.x;
				nextRoom.camera.y = camera.y;
				nextRoom.render();
				
				innerRender = false;
			}
			
			if (player && Player.eyesShut && ! player.dead) {
				Draw.rect(camera.x, camera.y, FP.width, FP.height, 0x0);
				player.render();
			} else {
				super.render();
			}
			
			if (innerRender) return;
			
			var brightBuffer:BitmapData = fadedBuffer;
			
			brightBuffer.copyPixels(FP.buffer, SCREEN_RECT, FP.zero);
			
			swapColour(FP.buffer, SCREEN_RECT, 0xff09141d, 0xff05080b);
			swapColour(FP.buffer, SCREEN_RECT, 0xff7dbd43, 0xff3f7051);
			swapColour(FP.buffer, SCREEN_RECT, 0xff55d4dc, 0xff4a6285);
			swapColour(FP.buffer, SCREEN_RECT, 0xfff5f8c0, 0xffd2ed93);
			
			var lessBrightBuffer:BitmapData = fadedBuffer2;
			
			lessBrightBuffer.copyPixels(FP.buffer, SCREEN_RECT, FP.zero);
			
			swapColour(FP.buffer, SCREEN_RECT, 0xff403152, 0xff222231);
			
			lessBrightBuffer.threshold(maskBuffer, SCREEN_RECT, FP.zero, "!=", 0xff000000, 0x00000000, 0xFF000000);
			lessBrightBuffer.threshold(maskBuffer3, SCREEN_RECT, FP.zero, "==", 0xff000000, 0x00000000, 0xFF000000);
			
			FP.buffer.copyPixels(lessBrightBuffer, SCREEN_RECT, FP.zero, null, null, true);
			
			maskBuffer.threshold(maskBuffer2, SCREEN_RECT, FP.zero, "==", 0xffffffff, 0x0);
			
			brightBuffer.threshold(maskBuffer, SCREEN_RECT, FP.zero, "!=", 0xff000000, 0x00000000, 0xFF000000);
			
			FP.buffer.copyPixels(brightBuffer, SCREEN_RECT, FP.zero, null, null, true);
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
			
			var oldPlayer:Player = player;
			
			{
				player = new Player();
				player.x = spawnX;
				player.y = spawnY;
				player.angle = spawnAngle;
				player.targetAngle = spawnTargetAngle;
				
				if (oldPlayer) player.sprite.frame = oldPlayer.sprite.frame;
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

