package 
{
	import Pages.ComponentPage;
	import Pages.ExhibitsInterface;
	import Pages.HomePage;
	import Pages.InfoPage;
	import Pages.MapPage;
	import content.Component;
	import flash.display.MovieClip;
	import modules.AgePopup;
	import utilities.AppUtility;
	import utilities.BrowserWindow;
	import utilities.LoadedImage;
	import utilities.LoadedImageEvent;
	import com.greensock.TweenMax;
	import com.greensock.easing.*
	import flash.events.Event;
	/**
	 * ...
	 * @author Darius Portilla
	 */
	public class MainInterface extends MovieClip
	{
		private var homePage:HomePage = new HomePage();
		private var cPage:ComponentPage
		private var exInterface:ExhibitsInterface;
		private var infoPage:InfoPage;
		private var mapPage:MapPage;
		private var img:LoadedImage;
		private var cover:LoadingCover = new LoadingCover();
		private var sw:Number = GlobalVarContainer.ScreenW;
		private var sh:Number = GlobalVarContainer.ScreenH;
		private var HWidth:Number;
		private var HHeight:Number;
		private var webpage:BrowserWindow;
		private var APPSTATE:String;
		private var agePopup:AgePopup;
		private var COVER_QUOTES:Array = [];
		public function MainInterface() 
		{
			HWidth = homePage.width;
			HHeight = homePage.height;
			AppUtility.SizeAndCenter(homePage,HWidth,HHeight);
			this.addChild(homePage);
			
			cover.back.width = sw;
			cover.back.height = sh;
			cover.back.alpha = .6;
			cover.loader.scaleX = cover.loader.scaleY = GlobalVarContainer.HEIGHT_SCALE;
			cover.loader.x = sw / 2;
			cover.loader.y = sh / 2;
			cover.title_txt.autoSize = "center";
			cover.title_txt.x = sw / 2;
			cover.title_txt.x = sw / 2-cover.title_txt.width/2;
			cover.title_txt.y = cover.loader.y + cover.loader.height/2+10;
			
			GlobalVarContainer.MainStage.addEventListener(Event.RESIZE, onStageResize);
		}
		
		private function onStageResize(e:Event):void 
		{
			sw = GlobalVarContainer.ScreenW;
			sh = GlobalVarContainer.ScreenH;
			AppUtility.SizeAndCenter(homePage, HWidth, HHeight);
			
			cover.back.width = sw;
			cover.back.height = sh;
			cover.back.alpha = .6;
			cover.loader.x = sw / 2;
			cover.loader.y = sh / 2;
			cover.loader.scaleX = cover.loader.scaleY = GlobalVarContainer.HEIGHT_SCALE;
			cover.title_txt.x = sw / 2-cover.title_txt.width/2;
			cover.title_txt.y = cover.loader.y + cover.loader.height/2+10;
		}
		
		
		public function InitHome():void{
			COVER_QUOTES = GlobalVarContainer.QUOTES;
			homePage.init();
			img = new LoadedImage(GlobalVarContainer.HOME_ICON);
			img.addEventListener(LoadedImageEvent.LOADED_IMAGE_COMPLETE, onImgComplete);
			img.loadImage();
			
			APPSTATE = APP_STATE.HOME;
		}
		
		private function onImgComplete(e:LoadedImageEvent):void 
		{
			img.removeEventListener(LoadedImageEvent.LOADED_IMAGE_COMPLETE, onImgComplete);
			this.addChild(img);
			img.width = sw*.4;
			img.scaleY = img.scaleX;
			img.x = GlobalVarContainer.ScreenW / 2 - img.width / 2;
			img.y = GlobalVarContainer.ScreenH / 2 - img.height / 2;
			
			GlobalVarContainer.MainBase.homeLoaded();
		}
		
		//********* EXHIBITS FUNCTIONS ***************//
		public function ShowExhibits():void{
			GlobalVarContainer.MainBase.dropMenu.SELECTED = 1;
			
			if (!exInterface){
				exInterface = new ExhibitsInterface();
				exInterface.init();
			}
			
			exInterface.visible = true;
			TweenMax.killTweensOf(exInterface);
			this.addChild(exInterface);
			exInterface.addBackEvent();
			TweenMax.to(exInterface, .6, {alpha:1, ease:Strong.easeOut, onComplete:RemoveHome});
			
			
			APPSTATE = APP_STATE.EXHIBITS;
		}
		
		private function RemoveHome():void 
		{			
			homePage.visible = false;
			img.visible = false;
			
			trace("SHOW TUT: " + GlobalVarContainer.SHOW_TUTORIAL);
			if (GlobalVarContainer.SHOW_TUTORIAL && GlobalVarContainer.TUTORIAL_ARRAY[1] == 0)
			GlobalVarContainer.MainBase.ShowTutorial(1);
		}
		
		public function ShowComponent(c:Component):void{
			GlobalVarContainer.MainBase.dropMenu.SELECTED = 9;
			addChild(cover);
			cover.alpha = 1; 
					
			if(COVER_QUOTES.length>0){
				var rand:Number = AppUtility.randomRange(0, COVER_QUOTES.length - 1);
				var fsize:Number = Math.round(26 * GlobalVarContainer.HEIGHT_SCALE);
				
				cover.title_txt.htmlText = "<font size='"+String(fsize)+"px'>"+COVER_QUOTES[rand]+"</font>";
				cover.title_txt.x = sw / 2 - cover.title_txt.width / 2;
				cover.title_txt.y = cover.loader.y + cover.loader.height/2+10;
			}
			
			cPage = new ComponentPage(c);
			cPage.addEventListener(MoreEvent.PAGE_LOADED, onPageLoaded);
			cPage.init();
			
			APPSTATE = APP_STATE.COMPONENT;
		}
		
		private function onPageLoaded(e:MoreEvent):void 
		{
			
			exInterface.visible = false;
			addChild(cPage);
			addChild(cover);
			TweenMax.to(cover, 1, {alpha:0, ease:Strong.easeOut, onComplete:RemoveCover});
			cPage.addEventListener(MoreEvent.UNLOAD_PAGE, onUnloadComponent);
			
			if (GlobalVarContainer.SHOW_TUTORIAL && GlobalVarContainer.TUTORIAL_ARRAY[2] == 0)
			GlobalVarContainer.MainBase.ShowTutorial(2);
		}
		
		private function onUnloadComponent(e:MoreEvent):void 
		{
			exInterface.visible = true;
			TweenMax.to(cPage, 1, {autoAlpha:0, ease:Strong.easeOut, onComplete:RemoveComponent});
		}
		
		private function onQuickUnloadComponent(e:MoreEvent):void 
		{
			exInterface.visible = true;
			TweenMax.to(cPage, 0, {autoAlpha:0, ease:Strong.easeOut, onComplete:RemoveComponent});
		}
		
		private function RemoveComponent():void 
		{
			if(this.getChildByName(cPage.name)){
				this.removeChild(cPage);
				cPage = null;
			}
			
			APPSTATE = APP_STATE.EXHIBITS;
		}
		
		//*****Browser Functions*****//
		public function ShowWebPage(s:String):void{
			webpage = new BrowserWindow(s);
			webpage.addEventListener(MoreEvent.CLOSE_BROWSER, onCloseWebPage);
			this.addChild(webpage);
		}
		
		private function onCloseWebPage(e:MoreEvent):void 
		{
			webpage.removeEventListener(MoreEvent.CLOSE_BROWSER, onCloseWebPage);
			this.removeChild(webpage);
			webpage = null;
		}
		
		private function RemoveCover():void 
		{
			this.removeChild(cover);
			
		}
		
		public function CloseExhibits(t:Number=.6):void{
			TweenMax.killTweensOf(exInterface);
			TweenMax.to(exInterface, t, {alpha:0, ease:Strong.easeOut, onComplete:RemoveExhibits});
			
			homePage.visible = true;
			img.visible = true;
			
			APPSTATE = APP_STATE.HOME;
		}
		
		private function RemoveExhibits():void 
		{			
			//this.removeChild(exInterface);
			exInterface.visible = false;
		}
		
		//************** INFO FUNCTIONS ****************//
		public function ShowInfo():void{
			GlobalVarContainer.MainBase.dropMenu.SELECTED = 3;
			infoPage = new InfoPage();
			this.addChild(infoPage);
			infoPage.init();
			infoPage.addEventListener(MoreEvent.CLOSE_BROWSER, onCloseInfoPage);
			APPSTATE = APP_STATE.INFO;
		}
		
		private function onCloseInfoPage(e:MoreEvent):void 
		{
			infoPage.removeEventListener(MoreEvent.CLOSE_BROWSER, onCloseInfoPage);
			removeChild(infoPage);
			infoPage = null;
			APPSTATE = APP_STATE.HOME;
		}
		
		
		//************** Map FUNCTIONS ****************//
		public function ShowMap():void{
			GlobalVarContainer.MainBase.dropMenu.SELECTED = 2;
			mapPage = new MapPage();
			this.addChild(mapPage);
			mapPage.init();
			mapPage.addEventListener(MoreEvent.UNLOAD_PAGE, onCloseMapPage);
			APPSTATE = APP_STATE.MAP;
		}
		
		private function onCloseMapPage(e:MoreEvent):void 
		{
			mapPage.removeEventListener(MoreEvent.UNLOAD_PAGE, onCloseMapPage);
			removeChild(mapPage);
			mapPage = null;
			APPSTATE = APP_STATE.HOME;
		}
		
		//****************************************************//
		//*************** DROP MENU FUNCTIONS ****************//
		public function GoMenuSelection(n:Number):void{
			trace("Menu Selected: " + n);
			switch(n){
				case 0: MenuToHome(); break;
				case 1: MenuToExhibit(); break;
				case 2: MenuToMap(); break;
				case 3: MenuToInfo(); break;
				case 4: ShowAgePopup(); break;
			}
			
		}
		
		private function ShowAgePopup():void 
		{
			agePopup = new AgePopup();
			GlobalVarContainer.MainBase.addChild(agePopup);
			GlobalVarContainer.MainBase.RemoveCoverEvent();
			GlobalVarContainer.MainBase.dropCover.height=sh;
			GlobalVarContainer.MainBase.dropCover.y=0;
			GlobalVarContainer.MainBase.dropCover.alpha = .8;
			
			/*if (agePopup.width > sw - 20 || agePopup.height > sh - 20){
				ResizeAgePopup();
			}*/
			ResizeAgePopup();
			agePopup.addEventListener(MoreEvent.CLOSE_POPUP, onCloseAgePopup);
			
			agePopup.y = sh;
			agePopup.x = sw / 2 - agePopup.width / 2;
			
			var goY:Number = sh / 2 - agePopup.height / 2;
			
			TweenMax.to(agePopup, .6, {y:goY, ease:Strong.easeOut});
		}
		
		private function ResizeAgePopup():void 
		{
			var scw:Number = (GlobalVarContainer.ScreenW-40) / agePopup.width;
			var sch:Number = (GlobalVarContainer.ScreenH-40) / agePopup.height;
			var sc:Number;
			
			if (scw < sch) {
				sc = scw;
			}else {
				sc = sch;
			}
			agePopup.scaleX = agePopup.scaleY = sc;
		}
		
		private function onCloseAgePopup(e:MoreEvent):void 
		{
			agePopup.removeEventListener(MoreEvent.CLOSE_POPUP, onCloseAgePopup);
			if (GlobalVarContainer.MainBase.getChildByName(agePopup.name)){
				GlobalVarContainer.MainBase.removeChild(agePopup);
				agePopup = null;
			}
			GlobalVarContainer.MainBase.HideCover();
			if (APPSTATE == APP_STATE.INFO){
				infoPage.UnFreezePage();
			}else if (APPSTATE == APP_STATE.COMPONENT){
				cPage.CheckForPostFreeze();
			}
		}
		
		private function MenuToHome():void 
		{
			trace("Going Home From: " + APPSTATE);
			if (GlobalVarContainer.SHOW_TUTORIAL && GlobalVarContainer.TUTORIAL_ARRAY[0] == 0) GlobalVarContainer.MainBase.ShowTutorial(0);
			GlobalVarContainer.MainBase.HideCover();
			
			switch(APPSTATE){
				case APP_STATE.MAP: onCloseMapPage(null); break;
				
				case APP_STATE.EXHIBITS: CloseExhibits(); break;				
				
				case APP_STATE.INFO: infoPage.ClosePageEvent(); break;
				
				case APP_STATE.COMPONENT: cPage.CheckForPosts(); RemoveComponent(); CloseExhibits(); break;
				
			}
		}
		
		private function MenuToExhibit():void 
		{
			trace("Going Exhibit From: " + APPSTATE);
			
			GlobalVarContainer.MainBase.HideCover();
			
			switch(APPSTATE){
				case APP_STATE.MAP: onCloseMapPage(null);ShowExhibits();  break;			
				
				case APP_STATE.INFO: infoPage.ClosePageEvent(); ShowExhibits(); break;
				
				case APP_STATE.COMPONENT: cPage.CheckForPosts(); onUnloadComponent(null); break;
				
			}
		}
		
		private function MenuToMap():void 
		{
			trace("Going Map From: " + APPSTATE);
			
			GlobalVarContainer.MainBase.HideCover();
			
			switch(APPSTATE){
				
				case APP_STATE.EXHIBITS: CloseExhibits(0); ShowMap(); break;				
				
				case APP_STATE.INFO: infoPage.ClosePageEvent(); ShowMap(); break;
				
				case APP_STATE.COMPONENT: cPage.CheckForPosts(); RemoveComponent(); CloseExhibits(0);  ShowMap(); break;
				
			}
		}
		
		private function MenuToInfo():void 
		{
			trace("Going Home From: " + APPSTATE);
			
			GlobalVarContainer.MainBase.HideCover();
			
			switch(APPSTATE){
				case APP_STATE.MAP: onCloseMapPage(null); ShowInfo(); break;
				
				case APP_STATE.EXHIBITS: CloseExhibits(0); ShowInfo(); break;							
				
				case APP_STATE.COMPONENT: cPage.CheckForPosts(); RemoveComponent(); CloseExhibits(0);  ShowInfo(); break;
				
			}
		}
		
		//********** WORKER TEST FUNCTIONS *************//
		public function Mssg2Ex(s:String):void{
			exInterface.ShowCache(s);
		}
	}

}