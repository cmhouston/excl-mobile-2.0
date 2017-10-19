package Pages 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	import flash.utils.Timer;
	import utilities.AppUtility;;
	import flash.events.MouseEvent;
	import com.greensock.TweenMax;
	import com.greensock.easing.*
	/**
	 * ...
	 * @author Darius Portilla
	 */
	public class InfoPage extends Sprite
	{
		private var header:SectionHeader = new SectionHeader();
		private var cover:Sprite;
		private var cback:MovieClip;
		private var logo:FundingImg = new FundingImg();
		private var webview:StageWebView;
		private var rect:Rectangle;
		private var sw:Number = GlobalVarContainer.ScreenW;
		private var sh:Number = GlobalVarContainer.ScreenH;
		private var SHOWING_MENU:Boolean = false;
		
		
		private var freezeData:BitmapData;
		private var webViewBitmap:Bitmap;
		private var freezeTimer:Timer = new Timer(200, 2)
		
		public function InfoPage() 
		{
			this.addChild(header);
			header.title_txt.autoSize = "center";
			
			header.width = sw;
			header.scaleY = header.scaleX;
			GlobalVarContainer.HEADER_HEIGHT = header.height;
			
			header.title_txt.htmlText = "Info";
			header.title_txt.x = header.back.width / 2- header.title_txt.width/2
			
			header.btn_menu.x = sw - header.btn_menu.width -10;
			header.btn_menu.buttonMode = true;
			header.btn_back.buttonMode = true;
			header.btn_back.addEventListener(MouseEvent.MOUSE_DOWN, onBack);
			
			//header.btn_menu.visible = false;
			header.btn_menu.addEventListener(MouseEvent.MOUSE_DOWN, onShowMenu);
			
			header.y = sh;
			
			cover = new Sprite();
			cback = AppUtility.CreateBack(sw, sh, 0xffffff);
			cover.addChild(cback);
			
			logo.width = sw * .6;
			logo.scaleY = logo.scaleX;
			
			cover.addChild(logo);
			logo.x = sw / 2;
			logo.y = sh / 2;
			
			addChild(cover);
			
			cover.alpha = 0;
			webview = new StageWebView();
			
			
			rect = new Rectangle(0, sh+header.height, sw, sh - header.height);
			
			webview.stage = GlobalVarContainer.MainStage;
			
			webview.viewPort = rect;
			
			
			
		}
		
		
		private function onShowMenu(e:MouseEvent):void 
		{
			GlobalVarContainer.MainBase.ShowMenu();
			if(!SHOWING_MENU){
				FreezePage();
				SHOWING_MENU = true;
			}else{				
				UnFreezePage();
				SHOWING_MENU = false;
			}
		}
		
		public function MenuSlideWeb(w:Number):void{
			TweenMax.to(rect, .6, {x:w, ease:Strong.easeOut, onUpdate:ResetWeb});
		}
		
		public function FreezePage():void{
			freezeData = new BitmapData(webview.viewPort.width, webview.viewPort.height,true,0xffffff);
			webview.drawViewPortToBitmapData(freezeData);
			webViewBitmap = new Bitmap(freezeData);
			
			webview.stage = null;
			webViewBitmap.y = rect.y-this.y;
			addChild(webViewBitmap);
		}
		
		public function UnFreezePage():void{
			freezeTimer.start();
		}
		
		private function onFreezeComplete(e:TimerEvent):void 
		{
			freezeTimer.reset();
			removeChild(webViewBitmap);
			webViewBitmap = null;
			webview.stage = GlobalVarContainer.MainStage;
			SHOWING_MENU = false;
		}
		
		private function ResetWeb():void 
		{
			
			if(webview)
			webview.viewPort = rect;
			
		}
		
		public function init():void{
			
			TweenMax.to(cover, .6, {alpha:1, ease:Strong.easeOut, onComplete:InitWebView});
		}
		
		private function InitWebView():void 
		{
			this.addChild(header);
			webview.loadURL(GlobalVarContainer.INFO_PAGE_PATH);
			TweenMax.to(rect, .8, {y:header.height, ease:Strong.easeOut, delay:2, onUpdate:UpdateWebView, onComplete:RemoveCover});
			//TweenMax.to(header, .8, {y:0, ease:Strong.easeOut, delay:3});
		}
		
		private function RemoveCover():void 
		{
			this.removeChild(cover);
			cover = null;
		}
		
		private function onBack(e:MouseEvent):void 
		{
			header.btn_back.removeEventListener(MouseEvent.MOUSE_DOWN, onBack);
			TweenMax.to(rect, .6, {y:sh+header.height, ease:Strong.easeOut, onUpdate:UpdateWebView, onComplete:ClosePageEvent});
			//TweenMax.to(header, .6, {y:sh, ease:Strong.easeOut});
		}
		
		public function ClosePageEvent():void 
		{
			webview.stage = null;
			webview.dispose();
			webview = null;
			
			this.dispatchEvent(new MoreEvent(MoreEvent.CLOSE_BROWSER));
		}
		
		private function UpdateWebView():void 
		{
			header.y = rect.y - header.height;	
			if(webview)
			webview.viewPort = rect;
		}
		
	}

}