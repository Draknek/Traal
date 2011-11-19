package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	
	public class Editor
	{
		[Embed(source="images/editor-tiles.png")]
		public static const EditTilesGfx: Class;
		
		public static var editTile:Spritemap = new Spritemap(EditTilesGfx, 16, 16);
		public static var palette:Entity = createPalette();
		public static var paletteClicked:Boolean = false;
		public static var paletteMouseover:Stamp;
		
		public static function update (level:Room): void
		{
			if (Input.pressed(Key.SPACE)) {
				togglePalette();
			}
			
			// SPACE: Palette
			// E: Test
			// C: Clear
			// 0-9: choose tile
			
			if (Input.pressed(Key.C)) {
				clear(level);
			}
			
			for (var i:int = 0; i < 10; i++) {
				if (Input.pressed(Key.DIGIT_0 + i)) {
					editTile.frame = i;
				}
			}
			
			//if (Input.mouseCursor != "auto") return;
			
			var mx:int = level.mouseX / editTile.width;
			var my:int = level.mouseY / editTile.height;
			
			var overPalette:Boolean = palette.visible && palette.collidePoint(palette.x, palette.y, level.mouseX, level.mouseY);
			
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
					mx = level.mouseX - palette.x;
					my = level.mouseY - palette.y;
					
					mx /= editTile.width;
					my /= editTile.height;
					
					paletteMouseover.x = -1 + mx * editTile.width;
					paletteMouseover.y = -1 + my * editTile.height;
				} else {
					paletteMouseover.x = -1 + int(editTile.frame % 5) * editTile.width;
					paletteMouseover.y = -1 + int(editTile.frame / 5) * editTile.height;
				}
			}
			
			if (Input.mouseDown) {
				if (overPalette && Input.mousePressed) {
					editTile.frame = mx + (palette.width / editTile.width) * my;
					
					paletteClicked = true;
				}
				
				if (! overPalette && ! paletteClicked) {
					var id:int = getTile(level, mx, my);
				
					if (id != editTile.frame) {
						setTile(level, mx, my, editTile.frame);
					}
				}
				
				palette.visible = false;
			} else {
				paletteClicked = false;
			}
		}
		
		public static function clear (level:Room):void
		{
			level.src.setRect(0, 0, level.src.columns, level.src.rows, Room.WALL);
			level.src.setRect(1, 1, level.src.columns - 2, level.src.rows - 2, Room.FLOOR);
			
			level.reloadState();
		}
		
		public static function getTile (level:Room, mx:int, my:int): int
		{
			return level.src.getTile(mx, my);
		}
		
		public static function setTile (level:Room, mx:int, my:int, tile:int): void
		{
			if (tile == Room.PLAYER) {
				// TODO: remove old player spawn
			}
			
			level.src.setTile(mx, my, tile);
			level.reloadState();
		}
		
		public static function render (level:Room): void
		{
			Draw.entity(palette, palette.x, palette.y);
			Draw.graphic(editTile);
			
			// TODO: render "edit mode" somewhere onscreen
		}
		
		public static function togglePalette ():void
		{
			palette.visible = ! palette.visible;
		}
		
		private static function createPalette ():Entity
		{
			var palette:Entity = new Entity;
			var tiles:Stamp = new Stamp(EditTilesGfx);
			palette.width = tiles.width;
			palette.height = tiles.height;
			
			palette.x = int((FP.width - palette.width)*0.5);
			palette.y = int((FP.height - palette.height)*0.5);
			
			var border:Stamp = new Stamp(new BitmapData(palette.width+2, palette.height+2, false, 0xFFFFFF));
			FP.rect.x = 1;
			FP.rect.y = 1;
			FP.rect.width = palette.width;
			FP.rect.height = palette.height;
			border.source.fillRect(FP.rect, 0x202020);
			
			border.x = -1;
			border.y = -1;
			
			paletteMouseover = new Stamp(new BitmapData(editTile.width+2, editTile.height+2, true, 0xFFFFFFFF));
			
			FP.rect.width = editTile.width;
			FP.rect.height = editTile.height;
			paletteMouseover.source.fillRect(FP.rect, 0x0);
			
			paletteMouseover.x = -1;
			paletteMouseover.y = -1;
			
			palette.graphic = new Graphiclist(border, tiles, paletteMouseover);
			
			return palette;
		}
		
		public static function GetTile(src:Tilemap, i:int, j:int):uint
		{
			if(i<0 || i>=src.columns || j<0 || j>=src.rows) return WALL;		
			return src.getTile(i,j);
		}
		
		public static function autoWall(src:Tilemap, map:Tilemap, i:int, j:int):void
		{
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
		
	}
}

