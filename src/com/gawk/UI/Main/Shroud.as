package com.gawk.UI.Main {
import com.gawk.Engine.Engine;
import com.gawk.Engine.Event.EngineEvent;
import com.gawk.Tile.Event.TileEvent;
import com.gawk.Wall.Wall;

import flash.display.MovieClip;

public class Shroud extends MovieClip {		protected var wall:Wall;		protected var engine:Engine;				protected var existingTileIndex:int = 0;	
		public function Shroud(wall:Wall, engine:Engine, shroudWidth:Number, shroudHeight:Number) {			this.wall = wall;			this.engine = engine;						this.createShroud(shroudWidth, shroudHeight);
			this.addEventListeners();		}				protected function createShroud(shroudWidth:Number, shroudHeight:Number):void {			this.graphics.clear();			this.graphics.beginFill(0x000000);			this.graphics.drawRect(0, 0, shroudWidth, shroudHeight);			this.alpha = 0.68;		}				protected function addEventListeners():void {			this.engine.addEventListener(TileEvent.CAMERA_ADDED, function (event:TileEvent):void {				showShroud();			});						this.engine.addEventListener(TileEvent.CAMERA_CANCELLED, function (event:TileEvent):void {				hideShroud();			});						this.engine.addEventListener(EngineEvent.VIDEO_SAVED, function (event:EngineEvent):void {				hideShroud();			});					}				protected function showShroud():void {			this.visible = true;							this.wall.setChildIndex(this.wall.getCameraTile().getParentTile().movieClip, this.wall.numChildren - 1);			this.wall.setChildIndex(this, this.wall.numChildren - 1);			this.wall.swapChildren(this.wall.getCameraTile().getParentTile().movieClip, this);					}				protected function hideShroud():void {			this.visible = false;		}	}
}