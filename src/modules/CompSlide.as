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
	public class CompSlide extends Sprite
	{
		
		private var img:CachedImage;
		//private var img:LoadedImage;
		private var header:SlideHeader = new SlideHeader();
		private var sw:Number = GlobalVarContainer.ScreenW;
		private var sh:Number = GlobalVarContainer.ScreenH;
		public var NUM:Number;
		public var MAX_HEIGHT:Number;
		
		public function CompSlide(image:String, title:String, h:Number) 
		{
			MAX_HEIGHT = h;
		//	trace("MAX HEIGHT: "+MAX_HEIGHT);
		
			header.title_txt.autoSize = "left";
			header.title_txt.mouseEnabled = false;
			addChild(header);
			/*if (GlobalVarContainer.XLARGE_DISPLAY){
				header.back.height = 80;
				header.title_txt.htmlText = "<font size='"+GlobalVarContainer.LARGE_FONT+"'>" + title+"</font>";
				header.title_txt.y = 40 - header.title_txt.height / 2;
			}else{				
				//header.back.height = 60;
				header.title_txt.htmlText = title;
				//header.title_txt.y = 30 - header.title_txt.height / 2;
			}*/
			header.back.height = GlobalVarContainer.HEIGHT_SCALE * 60;
			var fontsize:String = String(Math.round(32 * GlobalVarContainer.HEIGHT_SCALE)) + "px";
			header.title_txt.htmlText = "<font size='" + fontsize+"'>" + title+"</font>";
			header.title_txt.y = GlobalVarContainer.HEIGHT_SCALE * 30 - header.title_txt.height / 2;
			img = new CachedImage(image, h, 0);
			img.addEventListener(LoadedImageEvent.LOADED_IMAGE_COMPLETE, onImgComplete);
			//img.loadImage();
			
			
		}
		
		private function onImgComplete(e:LoadedImageEvent):void 
		{			
			img.removeEventListener(LoadedImageEvent.LOADED_IMAGE_COMPLETE, onImgComplete);
			this.addChild(img);
			img.height = MAX_HEIGHT - header.height - 4;
			img.scaleX = img.scaleY;
			img.y = header.height;
			header.back.width = img.width;
		//	trace("Title: " + header.title_txt.width + " /Back: " + header.back.width);
			if (header.title_txt.width > header.back.width - 20){
				header.title_txt.autoSize = "none";
				header.title_txt.width = header.back.width - 20;
				header.title_txt.scaleY = header.title_txt.scaleX;
			}
			this.dispatchEvent(new MoreEvent(MoreEvent.SLIDE_LOADED));
		}
		
	}

}