package com.gawk.UI.VideoTileOverlay {
	import com.gawk.Engine.Engine;
	import com.gawk.Graphics.VideoTileOverlay;
	import com.gawk.Graphics.VideoTileOverlay.*;
	import com.gawk.Member.Event.MemberEvent;
	import com.gawk.Member.Member;
	import com.gawk.Member.VideoAction.MemberVideoRatingAction;
	import com.gawk.Tile.VideoTile;
	import com.gawk.UI.TileButton;
	
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.ui.Mouse;
	
	public class VideoTileOverlayController extends EventDispatcher {
		
		protected var panel:VideoTileOverlay;
		protected var parentTile:VideoTile;
		protected var favouriteButton:TileButton;
		protected var hateButton:TileButton;
		protected var removeButton:TileButton;
		
		protected var profileVideo:ProfileVideo;
		protected var engine:Engine;
		
		public function VideoTileOverlayController(parentTile:VideoTile, engine:Engine)	{
			this.parentTile = parentTile;
			this.engine = engine;
			this.panel = new VideoTileOverlay();
			this.panel.visible = false;
			
			this.addUiEventListeners();
			this.setName(this.parentTile.getVideoObject().member.alias);
			this.setDeleteGawkVisible(this.parentTile.getVideoObject().videoControlAuthorised);
		}
		
		protected function addUiEventListeners():void {
			this.parentTile.addEventListener(MouseEvent.MOUSE_OVER, function (event:MouseEvent):void {
				panel.visible = true;
				setProfileVideo();
			});
			this.parentTile.addEventListener(MouseEvent.MOUSE_OUT, function (event:MouseEvent):void {
				panel.visible = false;
			});
			this.panel.favouriteButton.addEventListener(MouseEvent.CLICK, onFavouriteClick);
			this.panel.viewButton.addEventListener(MouseEvent.CLICK, onViewClick);
			
			this.panel.deleteButton.addEventListener(MouseEvent.CLICK, onDeleteClick);
			
		}
		
		protected function setName(name:String):void {
			this.panel.profile.aliasText.text = name;
		}
		
		protected function setDeleteGawkVisible(show:Boolean):void {
			this.panel.deleteButton.visible = show;
		}
		
		protected function setProfileVideo():void {
			var profileVideoLocation:String = this.parentTile.getVideoObject().member.profileVideoLocation;
			if ((profileVideoLocation != "") && (this.profileVideo == null)) {
				this.profileVideo = new ProfileVideo(this, this.engine, profileVideoLocation);
				this.profileVideo.loadVideo();
				this.panel.profile.addChild(this.profileVideo.getVideo());
			}
		}
		
		public function onProfileClick():void {
			navigateToURL(new URLRequest("/u/" + this.parentTile.getVideoObject().member.alias), "_SELF");
		}
		
		protected function onFavouriteClick(event:MouseEvent):void {
			var action:MemberVideoRatingAction = new MemberVideoRatingAction();
			action.setVideoSecureId(this.parentTile.getVideoObject().secureId);
			action.setPositiveRating(true);
			this.engine.getMemberControl().addEventListener(
				MemberEvent.MEMBER_VIDEO_ADD_RATING_RESPONSE, this.onFavouriteClickResponse);
			
			this.engine.getMemberControl().dispatchEvent(
				new MemberEvent(MemberEvent.MEMBER_VIDEO_ADD_RATING_REQUEST, action));
		}
		
		protected function onFavouriteClickResponse(event:MemberEvent):void {
			this.engine.getMemberControl().removeEventListener(
				MemberEvent.MEMBER_VIDEO_ADD_RATING_RESPONSE, this.onFavouriteClickResponse);
			
			if (event.data.success) {
				showFavouriteButtonIsActive();
			}
		}
		
		protected function showFavouriteButtonIsActive():void {
			this.panel.favouriteButton.alpha = 1;
		}
		
		protected function onHateClick(event:MouseEvent):void {
			var action:MemberVideoRatingAction = new MemberVideoRatingAction();
			action.setVideoSecureId(this.parentTile.getVideoObject().secureId);
			action.setPositiveRating(false);
			this.engine.getMemberControl().addEventListener(
				MemberEvent.MEMBER_VIDEO_ADD_RATING_RESPONSE, this.onHateClickResponse);
			this.engine.getMemberControl().dispatchEvent(
				new MemberEvent(MemberEvent.MEMBER_VIDEO_ADD_RATING_REQUEST, action));
		}
		
		protected function onHateClickResponse(event:MemberEvent):void {
			this.engine.getMemberControl().removeEventListener(
				MemberEvent.MEMBER_VIDEO_ADD_RATING_RESPONSE, this.onHateClickResponse);
			showHateButtonIsActive();
		}
		
		protected function showHateButtonIsActive():void {
			this.panel.hateButton.alpha = 0.5;
		}
		
		protected function onDeleteClick(event:MouseEvent):void {
			this.panel.deleteButton.removeEventListener(MouseEvent.CLICK, onDeleteClick);

			this.engine.getMemberControl().addEventListener(
				MemberEvent.MEMBER_VIDEO_DELETE_RESPONSE, this.onMemberVideoDeleteResponse);
			
			this.engine.getMemberControl().dispatchEvent(
				new MemberEvent(MemberEvent.MEMBER_VIDEO_DELETE_REQUEST, this.parentTile.getVideoObject().secureId));
		}
		
		protected function onMemberVideoDeleteResponse(event:MemberEvent):void {
			this.engine.getMemberControl().removeEventListener(
				MemberEvent.MEMBER_VIDEO_DELETE_RESPONSE, this.onMemberVideoDeleteResponse);
			this.panel.deleteButton.addEventListener(MouseEvent.CLICK, onDeleteClick);
		}
		
		protected function onViewClick(event:MouseEvent):void {
			navigateToURL(new URLRequest("/u/" + this.parentTile.getVideoObject().member.alias + "/gawk/" + 
				this.parentTile.getVideoObject().secureId), "_self");
		}
		
		public function getPanel():VideoTileOverlay {
			return this.panel;
		}
		
		public function getParentTile():VideoTile {
			return this.parentTile;
		}
	}
}