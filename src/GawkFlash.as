package {
	import com.gawk.Engine.Engine;
	import com.gawk.Engine.Event.EngineEvent;
	import com.gawk.UI.Main.*;
	import com.gawk.Wall.Wall;
	
	import flash.display.Sprite;
	import flash.system.Security;

	//[SWF(backgroundColor="#111111", frameRate="15", width="175", height="131")] //profile gawk
	//[SWF(backgroundColor="#111111", frameRate="15", width="1050", height="131")] //recent profile
	[SWF(backgroundColor="#111111", frameRate="15", width="1050", height="655")] //main
	//[SWF(backgroundColor="#111111", frameRate="15", width="1920", height="1150")] //booth
	public class GawkFlash extends Sprite {
		
		protected var wall:Wall;
		protected var engine:Engine;
		
		protected var wallId:String = "";
		protected var apiLocation:String = "";
		protected var profileSecureId:String = "";
		protected var loggedInAtInit:Boolean = false;
		
		
		public function GawkFlash() {
			Security.allowDomain("staging.gawkwall.com");

			this.assignStartupSettings();
		
			this.engine = new Engine(this.apiLocation, this.wallId, this.loggedInAtInit, this.profileSecureId);
			this.engine.addEventListener(EngineEvent.WALL_CONFIG_LOADED, this.onWallConfigLoaded);
		}
		
		protected function assignStartupSettings():void {
			this.apiLocation = this.loaderInfo.parameters.apiLocation;
			this.wallId = this.loaderInfo.parameters.wallId;
			this.loggedInAtInit = this.loaderInfo.parameters.loggedInAtInit;
			this.profileSecureId = this.loaderInfo.parameters.profileSecureId;
			
			if (!this.apiLocation) {
				throw new Error("Must provide API Location");
			} 
			
		}
		
		protected function onWallConfigLoaded(event:EngineEvent):void {
			this.addWall();
		}
		
		protected function addWall():void {
			this.wall = new Wall(engine);
			this.addChild(this.wall);
		}
	}
}