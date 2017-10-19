package 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.greensock.TweenMax;
	import com.greensock.easing.*
	import flash.geom.ColorTransform;
	import utilities.AppUtility;
	/**
	 * ...
	 * @author Darius Portilla
	 */
	public class DropMenu extends Sprite
	{
		private var btn:DropMenuButton;
		private var btnArray:Array = [];
		public var SELECTED:Number = -1;
		private var menuArray:Array = ["Home", "Exhibits", "Map", "Info", "Filter by Age", "Turn Tutorial On"];
		private var btnHolder:Sprite = new Sprite();
		private var menuBack:Btn_Black = new Btn_Black();
		public var SHOWING_MENU:Boolean = false;
		private var sw:Number = GlobalVarContainer.ScreenW;
		private var sh:Number = GlobalVarContainer.ScreenH;
		private var icon_age:Icon_agefilter= new Icon_agefilter();
		
		public function DropMenu() 
		{
			menuBack.width = sw/2;
			menuBack.height = sh - GlobalVarContainer.HEADER_HEIGHT;
			addChild(btnHolder);
			btnHolder.addChild(menuBack);
			var start:Number = 0;
			for (var i:uint = 0; i < menuArray.length; ++i){
				btn = new DropMenuButton();
				btn.icon.gotoAndStop(i + 1);
				btn.title_txt.autoSize = "left";
				btn.title_txt.htmlText = menuArray[i];
				btn.title_txt.mouseEnabled = false;
				btn.x = 0;
				btn.width = sw / 2;
				btn.scaleY = btn.scaleX;
				btn.y = start;
				start += btn.height;
				btnHolder.addChild(btn);
				btnArray.push(btn);
				btn.NUM = i;
				btn.mouseChildren = false;
				btn.buttonMode = true;
				btn.addEventListener(MouseEvent.CLICK, onSelectButton);
				
				if (i == 4){
					btn.addChild(icon_age);
					icon_age.width = icon_age.height = 34;
					icon_age.y = 37;
					icon_age.x = btn.title_txt.x + btn.title_txt.width + 10;
					if (GlobalVarContainer.AGE_RANGE.length > 0) icon_age.gotoAndStop(2);
				}else if (i == 5){
					if(GlobalVarContainer.SHOW_TUTORIAL)
					AppUtility.ChangeColor(btn.icon, 0xF58220);
				}
			}
			
			AppUtility.ChangeColor(menuBack, 0xD4D4D4);
			btnHolder.y = GlobalVarContainer.HEADER_HEIGHT;
			btnHolder.x = sw;
			GlobalVarContainer.MainStage.addEventListener(Event.RESIZE, onResize);
		}
		
		private function onResize(e:Event):void 
		{
			sw = GlobalVarContainer.ScreenW;
			sh = GlobalVarContainer.ScreenH;
		}
		
		
		private function onSelectButton(e:MouseEvent):void 
		{
			var mc:DropMenuButton = e.target as DropMenuButton;
			trace(mc.NUM);
			if (mc.NUM == SELECTED) return;
			
			
			
			
			//Check for age Popup if not then change selected
			if (mc.NUM == 4){
				HideMenu();
				GlobalVarContainer.MAIN_INTERFACE.GoMenuSelection(4);
			}else if (mc.NUM == 5){
				HideMenu();
				SHOWING_MENU = false;
				if (GlobalVarContainer.SHOW_TUTORIAL){		
					
					btnArray[5].transform.colorTransform = new ColorTransform();
					GlobalVarContainer.MainBase.HideCover();
					GlobalVarContainer.SHOW_TUTORIAL=false;
					GlobalVarContainer.DATA_MANAGER.onSaveTutSettings(false);
					btnArray[5].title_txt.htmlText = "Turn Tutorial On";
				}else{					
					GlobalVarContainer.MainBase.ShowTutPopup();
				}
				GlobalVarContainer.TUTORIAL_ARRAY = [0, 0, 0, 0, 0, 0];
			}else{
				SELECTED = mc.NUM;			
				GlobalVarContainer.MAIN_INTERFACE.GoMenuSelection(SELECTED);
			}
			
			
			
			
			btnHolder.x = sw;
		}		
		
		public function ChangeTutorialOn():void{
			
			btnArray[5].title_txt.htmlText = "Turn Tutorial On";
			
			
			btnArray[5].icon.transform.colorTransform = new ColorTransform();
		}
		
		public function ChangeTutorialOff():void{
			
			btnArray[5].title_txt.htmlText = "Turn Tutorial Off";
			AppUtility.ChangeColor(btn.icon, 0xF58220);
		}
		
		public function RemoveEvents():void{
			for (var i:uint = 0; i < btnArray.length; ++i){
				btn = btnArray[i];
				btn.removeEventListener(MouseEvent.CLICK, onSelectButton);
			}
		}
		
		public function AddEvents():void{
			for (var i:uint = 0; i < btnArray.length; ++i){
				btn = btnArray[i];
				btn.addEventListener(MouseEvent.CLICK, onSelectButton);
			}
		}
		
		public function ShowMenu():void{
			
			if (GlobalVarContainer.AGE_RANGE.length > 0){
				icon_age.gotoAndStop(2);
			}else{
				icon_age.gotoAndStop(1);
			}
			
			if (GlobalVarContainer.SHOW_TUTORIAL){
				btnArray[5].title_txt.htmlText = "Turn Tutorial Off";
			}else{
				btnArray[5].title_txt.htmlText = "Turn Tutorial On";
			}
			
			btnHolder.x = sw;
			SHOWING_MENU = true;
			AddEvents();
			TweenMax.to(btnHolder, .6, {x:sw/2, ease:Strong.easeOut});
		}
		
		public function HideMenu():void{
			SHOWING_MENU = false;
			RemoveEvents();
			
			TweenMax.to(btnHolder, .4, {x:sw, ease:Strong.easeOut});
		}
	}

}