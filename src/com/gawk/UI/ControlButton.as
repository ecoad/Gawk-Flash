package com.gawk.UI {
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class ControlButton	extends MovieClip {
		
		public var labelText:String;
		protected var label:TextField;
		
		public function ControlButton(buttonWidth:Number, buttonHeight:Number, labelText:String, labelY:Number) {
			
			this.buttonMode = true;
			this.useHandCursor = true;
			
			this.graphics.clear();
			this.graphics.beginFill(0x999999);
			this.graphics.drawRoundRect(0, 0, buttonWidth, buttonHeight, 10, 10);
			
			this.graphics.beginFill(0xFFFFFF);
			this.graphics.drawRoundRect(2, 2, buttonWidth - 4, buttonHeight - 4, 10, 10);
			this.width = buttonWidth;
			this.height = buttonHeight;
			
			this.label = new TextField();
			this.label.width = buttonWidth;
			
			var textFormat:TextFormat = new TextFormat("Tahoma");
			textFormat.size = 15;

			label.defaultTextFormat = textFormat;
			label.mouseEnabled = true;
			
			label.x = 5;
			label.y = labelY;
			label.selectable = false;
			
			this.setLabelText(labelText);
			
			this.mouseChildren = false;
			this.addChild(label);
		}
		
		public function setLabelText(labelText:String):void {
			this.labelText = labelText;
			this.label.text = this.labelText;
			this.label.height = this.label.textHeight + 5;
		}
	}
}