package Pages 
{
	import com.greensock.TweenMax;
	import com.greensock.easing.*
	import content.Exhibit;
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.text.TextFormat;
	import modules.ComponentSlider;
	import modules.ExhibitsSlider;
	import utilities.AppUtility;
	/**
	 * ...
	 * @author Darius Portilla
	 */
	public class ExhibitsInterface extends MovieClip
	{
		private var back:MovieClip;
		private var header:SectionHeader;
		private var sw:Number = GlobalVarContainer.ScreenW;
		private var sh:Number = GlobalVarContainer.ScreenH;
		private var slider:ExhibitsSlider;
		private var descText:DescText = new DescText();
		private var compSlider:ComponentSlider;
		private var ex:Exhibit;
		private var CURR_EXHIBIT:Number=0;
		private var compSliderArray:Array = [];
		private var cover:LoadingCover = new LoadingCover();
		private var compLoader:SlideHeader = new SlideHeader();
		private var MAX_HEIGHT:Number;
		private var fontsize:String;
		private var darkLoader:LoadingAnimation_Dark = new LoadingAnimation_Dark();
		
		//Setting the font size
		private var format:TextFormat = new TextFormat();
		private var testSize:int = 60;
		private var smallLimit:int = 14;
		private var descHeight:int = 140;
		
		
		public function ExhibitsInterface() 
		{
			
			back = AppUtility.CreateBack(sw, sh, 0xffffff);
			this.addChild(back);
			
			header = new SectionHeader();
			header.title_txt.autoSize = "center";
			
			/*if(GlobalVarContainer.XLARGE_DISPLAY){
				header.width = sw;
				header.scaleY = header.scaleX;
			}else{
				header.back.width = sw;
			}*/
			
			header.width = sw;
			header.scaleY = header.scaleX;
			GlobalVarContainer.HEADER_HEIGHT = header.height;
			trace("HH: " + GlobalVarContainer.HEADER_HEIGHT);
			
			header.title_txt.htmlText = GlobalVarContainer.EXHIBITS_LABEL_PL;
			header.title_txt.x = header.back.width / 2- header.title_txt.width/2
			
			header.btn_menu.x = header.back.width - header.btn_menu.width -10;
			header.btn_menu.buttonMode = true;
			header.btn_back.buttonMode = true;
			this.addChild(header);
			
			header.btn_menu.addEventListener(MouseEvent.MOUSE_DOWN, onShowMenu);
			
			GlobalVarContainer.MainStage.addEventListener(Event.RESIZE, onStageResize);
		}
		
		private function onShowMenu(e:MouseEvent):void 
		{
			GlobalVarContainer.MainBase.ShowMenu();
		}
		
		public function addBackEvent():void{
			GlobalVarContainer.MainBase.HideMenu();
			header.btn_back.addEventListener(MouseEvent.CLICK, onBackToHome);
		}
		
		private function onStageResize(e:Event):void 
		{
			sw = GlobalVarContainer.ScreenW;
			sh = GlobalVarContainer.ScreenH;
		}
		
		private function onBackToHome(e:MouseEvent):void 
		{
			header.btn_back.removeEventListener(MouseEvent.CLICK, onBackToHome);
			GlobalVarContainer.MAIN_INTERFACE.CloseExhibits();
		}
		
		public function init():void{
			trace("INIT EXHIBIT INTERFACE");
			slider = new ExhibitsSlider();
			slider.addEventListener(MoreEvent.SLIDER_LOADED, onSliderLoaded);
			slider.addEventListener(MoreEvent.INIT_SLIDE_LOADED, onSliderInit);
			slider.LoadExhibits();
			this.addChild(slider);
			
			slider.y = header.height;  
			ex = GlobalVarContainer.EXHIBITS[0];
			descText.title_txt.autoSize = "left";
			descText.title_txt.width = sw - 40;
		//	trace("TESTING TEXT: " + GlobalVarContainer.LONG_DESC);
			
			SetDescText(GlobalVarContainer.LONG_DESC);
			//fontsize = String(Math.round(14 * GlobalVarContainer.HEIGHT_SCALE)) + "px";
			//descText.title_txt.htmlText = "<font size='" + fontsize+"'>" + ex.DESC+"</font>";
			
			
			
			/*descText.title_txt.htmlText = ex.DESC;
			//format.size = smallLimit;
			descText.title_txt.setTextFormat( format );*/
			
		}
		
		private function onSliderInit(e:MoreEvent):void 
		{			
			slider.removeEventListener(MoreEvent.INIT_SLIDE_LOADED, onSliderInit);
			this.addChild(darkLoader);
			darkLoader.x = sw / 2;
			darkLoader.y = sh * .6;
			darkLoader.scaleX = darkLoader.scaleY = GlobalVarContainer.HEIGHT_SCALE;
			darkLoader.y = slider.y + slider.height +darkLoader.height / 2 + 20;
			
			
			
			
		}
		
		private function onSliderLoaded(e:MoreEvent):void 
		{
			if(this.getChildByName(darkLoader.name)){
				this.removeChild(darkLoader);
				darkLoader = null;
			}
			
			trace("EXHIBITS SLIDER LOADED");
			slider.removeEventListener(MoreEvent.SLIDER_LOADED, onSliderLoaded);
			
			this.addChild(descText);
			descText.y = slider.y + slider.Min_Height + 10;
			
			MAX_HEIGHT = sh - (descText.y + descHeight);
			if (MAX_HEIGHT > sh * .5){
				trace("MAX HEIGHT TO LARGE! REDOING");
				testSize = 70;
				smallLimit = 14;
				SetDescText(GlobalVarContainer.LONG_DESC, .2);
			}
			
			descText.title_txt.htmlText = ex.DESC;
			//format.size = smallLimit;
			descText.title_txt.setTextFormat( format );
			
			//descText.width = sw - 40;
			//descText.scaleY = descText.scaleX;
			
		//	descText.title_txt.width = sw - 40;
			descText.x = 20;
			
			slider.addEventListener(MoreEvent.SLIDE_CHANGED, onSlideChanged);
			
			
			//GlobalVarContainer.LOADING_COMPONENTS = true;
			trace("**************************");
			MAX_HEIGHT = sh - (descText.y + descHeight);
			trace("Init Max Height: " + MAX_HEIGHT);
			if (MAX_HEIGHT > sh * .4) MAX_HEIGHT = sh * .4;
			trace("New Max Height: " + MAX_HEIGHT);
			compSlider = new ComponentSlider(MAX_HEIGHT);
			compSlider.addEventListener(MoreEvent.SLIDER_LOADED, onCompSliderLoaded);
			compSlider.addEventListener(MoreEvent.UPDATE_COUNTER, onUpdateCounter);
			compSlider.LoadSlider(0);
			addChild(compSlider);
			compSliderArray.push(compSlider);
			compSlider.y =sh-MAX_HEIGHT+4;
			
			
			/*cover.back.width = sw;
			cover.back.height = MaxH;
			cover.back.alpha = .6;
			cover.loader.x = sw / 2;
			cover.loader.y = cover.back.height / 2;
			cover.title_txt.y = cover.loader.y+cover.loader.height/2+5;
			cover.title_txt.x =sw / 2- cover.title_txt.width/2;
			//addChild(cover);
			cover.y = compSlider.y;*/
			
			compLoader.back.alpha = .8;
			compLoader.width = sw;
			compLoader.scaleY = compLoader.scaleX;
			addChild(compLoader);
			compLoader.y = sh - compLoader.height+2;
			
		}
		
		private function onUpdateCounter(e:MoreEvent):void 
		{
			//trace("Updating Counter");
			compLoader.title_txt.htmlText = "<font size='24px'>Loading: "+String(compSlider.cnt+1) + " / " + String(compSlider.TOTAL_SLIDES)+"</font>";
		}
		
		private function onCompSliderLoaded(e:MoreEvent):void 
		{
			
			//trace("SLIDER ARRAY: " + compSliderArray);
			GlobalVarContainer.LOADING_COMPONENTS = false;
			compSlider.removeEventListener(MoreEvent.SLIDER_LOADED, onCompSliderLoaded);
			compSlider.removeEventListener(MoreEvent.UPDATE_COUNTER, onUpdateCounter);
			
			TweenMax.to(compLoader, .6, {alpha:0, ease:Strong.easeOut, onComplete:RemoveCover});
		}
		
		private function RemoveCover():void 
		{
			if (this.getChildByName(compLoader.name))
			this.removeChild(compLoader);
		}
		
		private function onSlideChanged(e:MoreEvent):void 
		{
			CURR_EXHIBIT = slider.CURR_SLIDE;
			var ex:Exhibit = GlobalVarContainer.EXHIBITS[slider.CURR_SLIDE];
			descText.title_txt.htmlText = ex.DESC;
			descText.title_txt.setTextFormat( format );
			//descText.title_txt.htmlText = "<font size='" + fontsize+"'>" + ex.DESC+"</font>";
			compSlider.StopSlider();
			compSlider.removeEventListener(MoreEvent.SLIDER_LOADED, onCompSliderLoaded);
			compSlider.removeEventListener(MoreEvent.UPDATE_COUNTER, onUpdateCounter);
			
			removeChild(compSlider);
			
			if (compSliderArray[CURR_EXHIBIT] == null){
				compSlider = new ComponentSlider(MAX_HEIGHT);
				compSlider.LoadSlider(CURR_EXHIBIT);
				compLoader.title_txt.htmlText = "<font size='24px'>Loading: 1 / " + String(compSlider.TOTAL_SLIDES)+"</font>";
				compSlider.addEventListener(MoreEvent.SLIDER_LOADED, onCompSliderLoaded);
			    compSlider.addEventListener(MoreEvent.UPDATE_COUNTER, onUpdateCounter);
				addChild(compSlider);
				
				compSlider.y =sh-MAX_HEIGHT+4;
				
				compSliderArray.push(compSlider);
				compLoader.alpha = 1;
				addChild(compLoader);
			}else{
				compSlider = compSliderArray[CURR_EXHIBIT];
				addChild(compSlider);
				if(compSlider.IS_FULLY_LOADED){
					compSlider.SetupDragging();
				}else{
					this.addChild(compLoader);
					compLoader.title_txt.htmlText = "<font size='24px'>Loading: "+String(compSlider.cnt+1) + " / " + String(compSlider.TOTAL_SLIDES)+"</font>";
					compSlider.addEventListener(MoreEvent.SLIDER_LOADED, onCompSliderLoaded);
					compSlider.addEventListener(MoreEvent.UPDATE_COUNTER, onUpdateCounter);
				}
			}
			
			
		}
		
		public function ShowCache(s:String):void{
			//descText.title_txt.htmlText = s;
		}
		
		private function SetDescText(s:String, m:Number=.1):void{
			
			var MaxH:Number = sh * m;

			descText.title_txt.htmlText = s;


			while( smallLimit<testSize){
				updateFormat( smallLimit );
				trace( descText.title_txt.height +" /MXH: "+MaxH+" /fsize: "+smallLimit );

				descHeight = descText.height;
				//if( descText.title_txt.numLines >=4 ){
				if( descText.title_txt.height >=MaxH ){
					testSize=smallLimit;
				//	descHeight = descText.height;
				//	trace("DESC_HEIGHT: " + descHeight);
				}else{
					smallLimit++;
				}
			}
				trace("FINAL DESC_HEIGHT: " + descHeight);

		}
			
		private function updateFormat(size:int):void{
			format.size = size;
			descText.title_txt.setTextFormat( format );
		}
	}
}