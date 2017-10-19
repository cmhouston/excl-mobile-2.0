package utilities 
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import flash.system.Capabilities;
	/**
	 * ...
	 * @author Darius Portilla
	 */
	public class AppUtility 
	{
		
		public function AppUtility() 
		{
			
		}
		public static function isAndroid():Boolean
		{
			return (Capabilities.version.substr(0,3) == "AND");
		}
		public static function isIOS():Boolean
		{
			return (Capabilities.version.substr(0,3) == "IOS");
		}
		

		public static function isMobile():Boolean
		{
			return (isAndroid() || isIOS()); 
		}
		public static function SizeAndCenter(d:DisplayObject, dw:Number, dh:Number):void{
			
			var scw:Number = GlobalVarContainer.ScreenW / dw;
			var sch:Number = GlobalVarContainer.ScreenH / dh;
			var sc:Number;
			
			if (scw > sch) {
				sc = scw;
			}else {
				sc = sch;
			}
			d.scaleX = d.scaleY = sc;
			
			d.x = GlobalVarContainer.ScreenW  / 2 - d.width / 2;
			d.y = GlobalVarContainer.ScreenH / 2 - d.height / 2;
			
			//trace("DH: " + d.height + " /SH: " + GlobalVarContainer.ScreenH);
		}
		public static  function randomRange(minNum:Number, maxNum:Number):Number 
		{
			return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);
		}
		
		public static function CreateBack(w:Number, h:Number, c:uint=0x000000):MovieClip {
							
			var rect:MovieClip = new MovieClip();
			
			rect.graphics.beginFill(c, 1);
			rect.graphics.drawRect(0, 0, w, h);
			rect.graphics.endFill();
			return rect;
		}
			
				
		public static function ChangeColor(mc:DisplayObject, color:uint, a:Number=1):void
		{
			var ct:ColorTransform = new ColorTransform();
			ct.color = color;
			mc.transform.colorTransform = ct;
			mc.alpha = a;
		}	
		
		public static function stripHTML(value:String):String{
			return value.replace(/<.*?>/g, "");
		}
	}

}
