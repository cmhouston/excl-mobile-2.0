package modules 
{
	import content.Post;
	import flash.display.MovieClip;
	import utilities.AppUtility;
	import flash.display.Sprite;
	import utilities.LoadedImage;
	import utilities.LoadedImageEvent;
	import com.greensock.TweenMax;
	import com.greensock.easing.*
	/**
	 * ...
	 * @author Darius Portilla
	 */
	public class PostRow extends Post_Row
	{
		public var img:LoadedImage;
		private var image:String;
		public var NUM:Number;
		public var icon:Icon_agefilter;
		public var ROW:Sprite;
		private var AGERANGE:Array;
		private var RANGES:Array=["under 3", " 3-4 yr", " 5 yr", " 6 yr", " 7 yr", " 8 yr", " 9 yr", " 10 yr", " 11 yr", " 12 yr", " 13+ yr", " Adult"];
		
		public function PostRow(p:Post) 
		{
			//back.width = GlobalVarContainer.ScreenW - 20;
			
			title_txt.htmlText = p.TITLE;
			title_txt.mouseEnabled = false;
			trace("POST: " + p.TITLE);
			imgMask.visible = false;
			image = p.IMAGE;
			AGERANGE = p.AGE_RANGE;
			this.mouseChildren = false;
			
			CheckAgeIcons();
		}
		
		public function CheckAgeIcons():void 
		{
			var AR:Array = GlobalVarContainer.AGE_RANGE;
			var age:String;
			var mc:MovieClip;
			var r:String;
			trace("SELECTED AGE RANGE: " + AR);
			trace("POST AGE RANGE: " + AGERANGE);
			for (var i:uint = 0; i < 12; ++i){
				
				mc = ages["age_" + i];
				r = RANGES[i];
				trace("Checking for: " + r);
				if (AR.indexOf(r) >= 0){ 					
					trace("ICON: " + r);
					if (AGERANGE.indexOf(r) >-1){		
						trace("    YES");			
						AppUtility.ChangeColor(mc, 0xE58525);
					}else{
						trace("    NO");			 
						AppUtility.ChangeColor(mc, 0xA9A9A9);
					}
					
				}else{
					trace("THIS AGE RANGE IS NOT INCLUDED: " + AR);
					AppUtility.ChangeColor(mc, 0xA9A9A9);
				}
			}
		}
		
		public function LoadRow():void{
			
			img = new LoadedImage(image);
			img.addEventListener(LoadedImageEvent.LOADED_IMAGE_COMPLETE, onImgComplete),
			img.loadImage();
		}
		
		private function onImgComplete(e:LoadedImageEvent):void 
		{
			img.removeEventListener(LoadedImageEvent.LOADED_IMAGE_COMPLETE, onImgComplete),
			CenterImage();
			
		}
		
		private function CenterImage():void{
			var scw:Number = imgBase.width / img.width;
			var sch:Number = imgBase.height / img.height;
			var sc:Number;
			
			if (scw > sch) {
				sc = scw;
			}else {
				sc = sch;
			}
			img.scaleX = img.scaleY = sc;
			
			img.x = imgBase.x+imgBase.width / 2 - img.width / 2;
			img.y = imgBase.y + imgBase.height / 2 - img.height / 2;
			
			addChild(img);
			img.mask = imgMask;
			imgMask.visible = true;
			removeChild(gears);
			removeChild(imgBase);
			gears = null;
			
			img.alpha = 0;
			TweenMax.to(img, 1, {alpha:1, ease:Strong.easeOut});
			//this.dispatchEvent(new MoreEvent(MoreEvent.SLIDE_LOADED));
		}
	}

}