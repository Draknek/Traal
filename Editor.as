package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	import flash.utils.*;
	
	public class Editor extends LoadableWorld
	{
		[Embed(source="images/editor-tiles.png")]
		public static const EditTilesGfx: Class;
		
		public static var editTile:Spritemap = new Spritemap(EditTilesGfx, 16, 16);
		public static var palette:Entity = createPalette();
		public static var paletteClicked:Boolean = false;
		public static var paletteMouseover:Stamp;
		
		public static var src:Tilemap;
		public static var walls:Tilemap;
		
		public static var clipboard:Tilemap;
		
		public static var PERSISTENT:Boolean = false;
		
		public static function init ():void
		{
			PERSISTENT = Main.devMode;
			
			src = new Tilemap(EditTilesGfx, Room.WIDTH*10, Room.HEIGHT*10, 16, 16);
			
			var startLevel:String;
			
			if (PERSISTENT && Main.so.data.editState) {
				startLevel = Main.so.data.editState;
			} else {
				startLevel = new Room.DefaultRoom;
			}
			src.loadFromString(startLevel);
			
			walls = new Tilemap(Room.StaticTilesGfx, Room.WIDTH*10, Room.HEIGHT*10, 16, 16);
			
			recalculateWalls();
		}
		
		public function Editor (room:Room) {
			camera.x = room.camera.x;// - FP.width * 0.5;
			camera.y = room.camera.y;// - FP.height * 0.5;
		}
		
		public override function begin (): void
		{
			super.begin();
			//FP.screen.scale = 1;
		}
		
		public override function end (): void
		{
			super.end();
			//FP.screen.scale = 2;
		}
		
		public override function update (): void
		{
			Input.mouseCursor = "auto";
			
			if (Input.pressed(Key.SPACE)) {
				togglePalette();
			}
			
			if (Input.pressed(Key.E)) {
				FP.world = new Room(camera, null, this);
				return;
			}
			
			
			// SPACE: Palette
			// E: Test
			// C: Clear
			// 0-9: choose tile
			
			if (Input.check(Key.SHIFT) && Input.pressed(Key.ESCAPE)) {
				clear();
			}
			
			var i:int;
			var j:int;
			
			for (i = 0; i < 10; i++) {
				if (Input.pressed(Key.DIGIT_1 + i)) {
					editTile.frame = i;
				}
			}
			
			var shiftX:int = int(Input.pressed(Key.RIGHT)) - int(Input.pressed(Key.LEFT));
			var shiftY:int = int(Input.pressed(Key.DOWN)) - int(Input.pressed(Key.UP));
			
			var tilesPerRoomX:int = Room.WIDTH / editTile.width;
			var tilesPerRoomY:int = Room.HEIGHT / editTile.height;
			
			var roomStartX:int = (Math.floor(camera.x / Room.WIDTH) + 1) * tilesPerRoomX;
			var roomStartY:int = (Math.floor(camera.y / Room.HEIGHT) + 1) * tilesPerRoomY;
			
			if (Input.check(Key.SHIFT) && Input.pressed(Key.C)) {
				clipboard = src.getSubMap(roomStartX, roomStartY, tilesPerRoomX, tilesPerRoomY);
			}
			
			if (Input.check(Key.SHIFT) && Input.pressed(Key.V) && clipboard) {
				for (i = 0; i < tilesPerRoomX; i++) {
					for (j = 0; j < tilesPerRoomY; j++) {
						tile = clipboard.getTile(i, j);
						src.setTile(roomStartX + i, roomStartY + j, tile);
					}
				}
				
				recalculateWalls();
			}
			
			if (Input.check(Key.SHIFT) && (shiftX || shiftY)) {
				for (i = 0; i < tilesPerRoomX; i++) {
					for (j = 0; j < tilesPerRoomY; j++) {
						var x:int = roomStartX;
						var y:int = roomStartY;
						
						if (shiftX > 0) {
							x += tilesPerRoomX - 1 - i;
						} else {
							x += i;
						}
						
						if (shiftY > 0) {
							y += tilesPerRoomY - 1 - j;
						} else {
							y += j;
						}
						
						var tile:uint = GetTile(src, x - shiftX, y - shiftY);
						src.setTile(x, y, tile);
					}
				}
				
				recalculateWalls();
			} else {
				camera.x += shiftX * Room.WIDTH;
				camera.y += shiftY * Room.HEIGHT;
			}
			
			//if (Input.mouseCursor != "auto") return;
			
			var mx:int = mouseX / editTile.width;
			var my:int = mouseY / editTile.height;
			
			var overPalette:Boolean = palette.visible && palette.collidePoint(palette.x, palette.y, Input.mouseX, Input.mouseY);
			
			if (overPalette) {
				editTile.alpha = 0;
				Input.mouseCursor = "button";
			} else {
				editTile.x = mx * editTile.width;
				editTile.y = my * editTile.height;
				editTile.alpha = 0.5;
			}
			
			if (palette.visible) {
				if (overPalette) {
					mx = Input.mouseX - palette.x;
					my = Input.mouseY - palette.y;
					
					mx /= editTile.width*2;
					my /= editTile.height*2;
					
					paletteMouseover.x = -1 + mx * editTile.width*2;
					paletteMouseover.y = -1 + my * editTile.height*2;
				} else {
					paletteMouseover.x = -1 + 2*int(editTile.frame % 4) * editTile.width;
					paletteMouseover.y = -1 + 2*int(editTile.frame / 4) * editTile.height;
				}
			}
			
			if (Input.mouseDown) {
				if (overPalette && Input.mousePressed) {
					editTile.frame = mx + (palette.width*0.5 / editTile.width) * my;
					
					paletteClicked = true;
				}
				
				if (! overPalette && ! paletteClicked) {
					var id:int = getTile(mx, my);
				
					if (id != editTile.frame) {
						if(Input.check(Key.B))
						{
							for(i = mx-1; i<mx+2; i++)
								for(j = my-1; j<my+2; j++)
									setTile(i, j, editTile.frame);							
						}
						else
						{
							setTile(mx, my, editTile.frame);
						}
					}
				}
				
				palette.visible = false;
			} else {
				paletteClicked = false;
			}
		}
		
		public function clear ():void
		{
			src.setRect(0, 0, src.columns, src.rows, Room.WALL);
			
			recalculateWalls();
		}
		
		public static function getTile (i:int, j:int): int
		{
			return src.getTile(i, j);
		}
		
		public static function setTile (i:int, j:int, tile:int): void
		{
			if(i<0 || i>=src.columns || j<0 || j>=src.rows) return;
			
			if (tile == Room.PLAYER) {
				// TODO: remove old player spawn
			}
			
			src.setTile(i, j, tile);
			recalculateWalls(i, j);
		}
		
		public override function render (): void
		{
			Draw.graphic(src);
			Draw.graphic(walls);
			
			/*FP.point.x = 0;
			FP.point.y = 0;
			
			Draw.setTarget(FP.buffer, FP.point);
			
			Draw.line(FP.width*0.5, -FP.height, FP.width*0.5, FP.height*2, 0x0);
			Draw.line(-FP.width, FP.height*0.5, FP.width*2, FP.height*0.5, 0x0);
			
			FP.point.x = -Room.WIDTH;
			FP.point.y = -Room.HEIGHT;
			
			Draw.line(FP.width*0.5, -FP.height, FP.width*0.5, FP.height*2, 0x0);
			Draw.line(-FP.width, FP.height*0.5, FP.width*2, FP.height*0.5, 0x0);
			
			Draw.setTarget(FP.buffer, camera);*/
			
			Draw.entity(palette, palette.x, palette.y);
			Draw.graphic(editTile);
		}
		
		public static function togglePalette ():void
		{
			palette.visible = ! palette.visible;
		}
		
		private static function createPalette ():Entity
		{
			var palette:Entity = new Entity;
			palette.visible = false;
			var tiles:Image = new Image(EditTilesGfx);
			tiles.scale = 2;
			palette.width = tiles.width*2;
			palette.height = tiles.height*2;
			
			palette.x = int((FP.width - palette.width)*0.5);
			palette.y = int((FP.height - palette.height)*0.5);
			
			tiles.scrollX = tiles.scrollY = 0;
			
			var border:Stamp = new Stamp(new BitmapData(palette.width+4, palette.height+4, false, 0xFFFFFF));
			FP.rect.x = 2;
			FP.rect.y = 2;
			FP.rect.width = palette.width;
			FP.rect.height = palette.height;
			border.source.fillRect(FP.rect, 0x202020);
			
			border.x = -2;
			border.y = -2;
			border.scrollX = border.scrollY = 0;
			
			paletteMouseover = new Stamp(new BitmapData(editTile.width*2+2, editTile.height*2+2, true, 0xFFFFFFFF));
			
			FP.rect.x = FP.rect.y = 1;
			FP.rect.width = editTile.width*2;
			FP.rect.height = editTile.height*2;
			paletteMouseover.source.fillRect(FP.rect, 0x0);
			
			paletteMouseover.x = -1;
			paletteMouseover.y = -1;
			
			paletteMouseover.scrollX = paletteMouseover.scrollY = 0;
			
			palette.graphic = new Graphiclist(border, tiles, paletteMouseover);
			
			return palette;
		}
		
		public static function GetTile(src:Tilemap, i:int, j:int):uint
		{
			if(i<0 || i>=src.columns || j<0 || j>=src.rows) return Room.WALL;
			return src.getTile(i,j);
		}
		
		public static function autoWall(src:Tilemap, map:Tilemap, i:int, j:int):void
		{
			const WALL:int = Room.WALL;
			
			var flags:int = 0;
			if(GetTile(src, i, j-1)==WALL) flags |= 1;
			if(GetTile(src, i+1, j)==WALL) flags |= 2;
			if(GetTile(src, i, j+1)==WALL) flags |= 4;
			if(GetTile(src, i-1, j)==WALL) flags |= 8;
			
			var allWall:Boolean = false;
			var tx:int=0;
			var ty:int=0;
			switch(flags)
			{
				case 0: tx=4; ty=1; break;
				case 1: tx=1; ty=0; break;
				case 2: tx=2; ty=1; break;
				case 3:	tx=2; ty=0;
					if(GetTile(src, i+1,j-1)==WALL) tx+=3;
					break;
				case 4: tx=1; ty=2; break;
				case 5: tx=4; ty=1; break;
				case 6: tx=2; ty=2;
					if(GetTile(src, i+1,j+1)==WALL) tx+=3;
					break;
				case 7: tx=2; ty=1; break;
				case 8: tx=0; ty=1; break;
				case 9: tx=0; ty=0;
					if(GetTile(src, i-1,j-1)==WALL) tx+=3;
					break;
				case 10: tx=4; ty=1; break;
				case 11: tx=1; ty=0; break;
				case 12: tx=0; ty=2;
					if(GetTile(src, i-1,j+1)==WALL) tx+=3;
					break;
				case 13: tx=0; ty=1; break;
				case 14: tx=1; ty=2; break;
				case 15: allWall = true; break;
			}
			
			if(allWall)
			{
				flags = 0;
				if(GetTile(src, i+1, j-1)==WALL) flags |= 1;
				if(GetTile(src, i+1, j+1)==WALL) flags |= 2;
				if(GetTile(src, i-1, j+1)==WALL) flags |= 4;
				if(GetTile(src, i-1, j-1)==WALL) flags |= 8;
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
		
		public override function getWorldData (): *
		{
			return src.saveToString();
		}
		
		public override function setWorldData (data: ByteArray): void {
			var string:String = data.toString();
			
			src.loadFromString(string);
			
			recalculateWalls();
		}
		
		public static function recalculateWalls (x:int=-1, y:int=-1):void
		{
			Player.clearPersistentData();
			
			var minX:int=0;
			var maxX:int=src.columns;
			var minY:int=0;
			var maxY:int=src.rows;
			
			if(x != -1)
			{
				minX = x-2;
				maxX = x+3;
			}
			if(y != -1)
			{
				minY = y-2;
				maxY = y+3;
			}			
			walls.setRect(minX, minY, maxX-minX, maxY-minY, 23); // transparent
			for (var i:int = minX; i < maxX; i++) {
				for (var j:int = minY; j < maxY; j++) {
					var tile:uint = src.getTile(i, j);
					
					if (tile == Room.WALL) {
						autoWall(src, walls, i, j);
					}
					
					if (tile == Room.SCROLL) {
						Player.scrollCountTotal++;
					}
				}
			}
			
			if (PERSISTENT) {
				Main.so.data.editState = src.saveToString();
				Main.so.flush();
			}
		}
	}
}

