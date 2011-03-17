package com.gawk.UI.TileMemberPanel {
	import com.gawk.Member.Action.Action;
	import com.gawk.Tile.VideoTile;
	import com.gawk.UI.TileButton;
	import com.gawk.UI.TileMemberPanel.Event.TileMemberPanelEvent;
	
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	public class TileMemberPanel extends EventDispatcher {
		
		protected var panel:MovieClip;
		protected var parentTile:VideoTile;
		protected var favouriteButton:TileButton;
		protected var hateButton:TileButton;
		protected var removeButton:TileButton;
		
		public function TileMemberPanel(parentTile:VideoTile)	{
			this.parentTile = parentTile;
			this.panel = new MovieClip();
			
			this.addButtons();
		}
		
		public function addButtons():void {
			this.addFavouriteButton();
			this.addHateButton();
			if (this.parentTile.getVideoData().getMemberId() == this.parentTile.getParentTile().getEngine().getMember().getId()) {
				this.addRemoveButton();
			}
		}
		
		public function addFavouriteButton():void {
			this.favouriteButton = new TileButton(50, 30, "Fav", 5);
			this.favouriteButton.x = 5;
			this.favouriteButton.y = 5;
			this.panel.addChild(this.favouriteButton);
			this.favouriteButton.addEventListener(MouseEvent.CLICK, this.onFavouriteButtonClick);
		}
		
		protected function onFavouriteButtonClick(event:MouseEvent):void {
			
			var action:Action = new Action({
				action: "GawkPositiveRating", 
				videoId: this.parentTile.getVideoData().getId(),
				memberId: this.parentTile.getParentTile().getEngine().getMember().getId()
			});
			
			this.parentTile.getParentTile().getEngine().dispatchEvent(new TileMemberPanelEvent(TileMemberPanelEvent.TILE_MEMBER_PANEL_ACTION, action));
		}
		
		public function addHateButton():void {
			this.hateButton = new TileButton(50, 30, "Hate", 5);
			this.hateButton.x = 5;
			this.hateButton.y = 40;
			this.panel.addChild(this.hateButton);
			this.hateButton.addEventListener(MouseEvent.CLICK, this.onHateButtonClick);
		}
		
		protected function onHateButtonClick(event:MouseEvent):void {
			var action:Action = new Action({
				action: "GawkNegativeRating", 
				videoId: this.parentTile.getVideoData().getId(),
				memberId: this.parentTile.getParentTile().getEngine().getMember().getId()
			});
			
			this.parentTile.getParentTile().getEngine().dispatchEvent(new TileMemberPanelEvent(TileMemberPanelEvent.TILE_MEMBER_PANEL_ACTION, action));
		}
		
		public function addRemoveButton():void {
			this.removeButton = new TileButton(50, 30, "Remove", 5);
			this.removeButton.x = 5;
			this.removeButton.y = 90;
			this.panel.addChild(this.removeButton);
			this.removeButton.addEventListener(MouseEvent.CLICK, this.onRemoveButtonClick);
		}
		
		protected function onRemoveButtonClick(event:MouseEvent):void {
			var action:Action = new Action({
				action: "GawkRemove", 
				videoId: this.parentTile.getVideoData().getId(),
				memberId: this.parentTile.getParentTile().getEngine().getMember().getId()
			});
			
			this.parentTile.getParentTile().getEngine().dispatchEvent(new TileMemberPanelEvent(TileMemberPanelEvent.TILE_MEMBER_PANEL_ACTION, action));
		}
		
		public function getPanel():MovieClip {
			return this.panel;
		}
		
		public function showRemoveButton():void {
			this.removeButton.visible = true;
		}
		
		public function hideRemoveButton():void {
			this.removeButton.visible = false;
		}
	}
}