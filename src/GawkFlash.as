package {
	import com.gawk.Engine.Engine;
	import com.gawk.Engine.Event.EngineEvent;
	import com.gawk.UI.Main.*;
	import com.gawk.Wall.Wall;
	
	import flash.display.Sprite;
	import flash.system.Security;

	[SWF(backgroundColor="#111111", frameRate="15", width="1050", height="655")]
	public class GawkFlash extends Sprite {
		
		protected var wall:Wall;
		protected var engine:Engine;
		
		public static const GAWK_WIDTH:int = 1050;
		public static const GAWK_HEIGHT:int = 655;
		
		protected var wallId:String = "";
		protected var apiLocation:String = "";
		
		protected var loggedInAtInit:Boolean = false;
		protected var testSettings:Boolean = false;
		
		public function GawkFlash() {
			Security.allowDomain("staging.gawkwall.com");
			this.assignStartupSettings();
			
			this.engine = new Engine(this.apiLocation, this.wallId, this.loggedInAtInit, this.testSettings);
			this.engine.addEventListener(EngineEvent.WALL_CONFIG_LOADED, this.onWallConfigLoaded);
		}
		
		protected function assignStartupSettings():void {
			this.apiLocation = this.loaderInfo.parameters.apiLocation;
			this.wallId = this.loaderInfo.parameters.wallId;
			this.loggedInAtInit = this.loaderInfo.parameters.loggedInAtInit;
			
			if (!this.apiLocation) {
				throw new Error("Must provide API Location");
			} 
			this.testSettings = true;
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