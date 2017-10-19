package modules 
{
	import flash.display.Sprite;
	import utilities.CachedImage;
	import utilities.LoadedImage;
	import utilities.LoadedImageEvent;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Darius Portilla
	 */
	public class ExhibitSlide extends Sprite
	{
		
		private var img:CachedImage;
		private var header:SlideHeader = new SlideHeader();
		private var sw:Number = GlobalVarContainer.ScreenW;
		private var sh:Number = GlobalVarContainer.ScreenH;
		public var NUM:Number;
		
		public function ExhibitSlide(image:String, title:String) 
		{
			header.back.width = sw;
			header.title_txt.autoSize = "left";
			header.title_txt.mouseEnabled = false;
			addChild(header);
			
			/*if (GlobalVarContainer.XLARGE_DISPLAY){
				header.back.height = 80;
				header.title_txt.htmlText = "<font size='"+GlobalVarContainer.LARGE_FONT+"'>"+title+"</font>";
				header.title_txt.y = 40 - header.title_txt.height / 2;
			}else{				
				header.title_txt.htmlText = title;
			}*/
			
			header.back.height = GlobalVarContainer.HEIGHT_SCALE * 60;
			var fontsize:String = String(Math.round(32 * GlobalVarContainer.HEIGHT_SCALE)) + "px";
			header.title_txt.htmlText = "<font size='" + fontsize+"'>" + title+"</font>";
			header.title_txt.y = GlobalVarContainer.HEIGHT_SCALE * 30 - header.title_txt.height / 2;
			img = new CachedImage(image, 0, sw);
			img.addEventListener(LoadedImageEvent.LOADED_IMAGE_COMPLETE, onImgComplete);
			
			
		}
		
		private function onImgComplete(e:LoadedImageEvent):void 
		{			
			img.removeEventListener(LoadedImageEvent.LOADED_IMAGE_COMPLETE, onImgComplete);
			this.addChild(img);
			img.width = sw;
			img.scaleY = img.scaleX;
			img.y = header.height;
			
			this.dispatchEvent(new MoreEvent(MoreEvent.SLIDE_LOADED));
		}
		
	}

}