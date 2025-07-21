package
{
   import Pipboy.COMPANIONAPP.MobileBackButtonEvent;
   import Shared.AS3.BGSExternalInterface;
   import Shared.AS3.BSButtonHintBar;
   import Shared.AS3.BSButtonHintData;
   import Shared.AS3.BSScrollingList;
   import Shared.AS3.COMPANIONAPP.CompanionAppMode;
   import Shared.AS3.COMPANIONAPP.PipboyLoader;
   import Shared.AS3.Events.CustomEvent;
   import Shared.AS3.IMenu;
   import Shared.GlobalFunc;
   import com.adobe.serialization.json.*;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.*;
   import flash.net.*;
   import flash.system.*;
   import flash.utils.*;
   import mx.utils.Base64Encoder;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol75")]
   public class PipboyMenu extends IMenu
   {
      
      public static const PIPBOY_PAGE_STATS:uint = 0;
      
      public static const PIPBOY_PAGE_INV:uint = 1;
      
      public static const PIPBOY_PAGE_DATA:uint = 2;
      
      public static const PIPBOY_PAGE_RADIO:uint = 3;
      
      public static const CONFIG_FILE:String = "../BuffsMeter.json";
       
      
      public var Header_mc:Pipboy_Header;
      
      public var BottomBar_mc:Pipboy_BottomBar;
      
      public var ButtonHintBar_mc:BSButtonHintBar;
      
      public var MainBackground_mc:MovieClip;
      
      public var BGSCodeObj:Object;
      
      private var PageA:Vector.<PipboyLoader>;
      
      public var DataObj:Pipboy_DataObj;
      
      private var _IsLoadingPage:Boolean;
      
      private var _WasPerkChartPressRegistered:Boolean = false;
      
      private var GridViewButton:BSButtonHintData;
      
      private var PlaceCampButton:BSButtonHintData;
      
      private var ToggleQuickboyButton:BSButtonHintData;
      
      private var ReadOnlyWarning:MovieClip;
      
      private var controlsBlockTimer:Timer;
      
      public var READ_ONLY_WARNING_NONE:* = 0;
      
      public var READ_ONLY_WARNING_DEFAULT:* = 1;
      
      public var READ_ONLY_WARNING_OFFLINE:* = 2;
      
      public var READ_ONLY_WARNING_DEMO:* = 3;
      
      public var lastPipboyChangeData:Object;
      
      public var isPipboySaveInit:Boolean = false;
      
      public var enableWidget:Boolean = false;
      
      public var enableManualPipBuffDataSync:Boolean = false;
      
      public var pipBuffDataSyncHotkey:int = 0;
      
      public var __SFCodeObj:Object;
      
      public var modLoader:Loader;
      
      public var modLoader2:Loader;
      
      private var hudTools:SharedHUDTools;
      
      public function PipboyMenu()
      {
         this.__SFCodeObj = new Object();
         this.GridViewButton = new BSButtonHintData("$Grid View","T","PSN_Y","Xenon_Y",1,this.onGridViewPress);
         this.PlaceCampButton = new BSButtonHintData("$$PlaceCampButton (0)","Z","PSN_L1","Xenon_L1",1,this.onPlaceCamp);
         this.ToggleQuickboyButton = new BSButtonHintData("$ToggleQuickboyButton","V","PSN_Select","Xenon_Select",1,null);
         this.controlsBlockTimer = new Timer(150,1);
         super();
         this.BGSCodeObj = new Object();
         this.DataObj = new Pipboy_DataObj();
         this._IsLoadingPage = false;
         this.PageA = new <PipboyLoader>[new PipboyLoader(),new PipboyLoader(),new PipboyLoader(),new PipboyLoader()];
         this.PageA.fixed = true;
         addEventListener(BSScrollingList.PLAY_FOCUS_SOUND,this.onListPlayFocus);
         addEventListener(Pipboy_Header.PAGE_CLICKED,this.onPageClicked);
         addEventListener(Pipboy_Header.TAB_CLICKED,this.onTabClicked);
         addEventListener(Pipboy_Header.TAB_CHANGE_ATTEMPT,this.onTabChangeAttempt);
         addEventListener(PipboyPage.LOWER_PIPBOY_ALLOW_CHANGE,this.onLowerPipboyAllowChange);
         addEventListener(PipboyPage.BOTTOM_BAR_UPDATE,this.onRequestBottomBarUpdate);
         this.controlsBlockTimer.addEventListener(TimerEvent.TIMER,this.HandleControlsBlockTimer);
         this.controlsBlockTimer.stop();
         this.initBuffsMeter();
         this.loadCSL();
      }
      
      private static function toString(param1:Object) : String
      {
         return new JSONEncoder(param1).getString();
      }
      
      public function loadCSL() : *
      {
         try
         {
            this.modLoader2 = new Loader();
            addChild(this.modLoader2);
            this.modLoader2.load(new URLRequest("CSL.swf"),new LoaderContext(false,ApplicationDomain.currentDomain));
            trace("CSL loaded");
         }
         catch(e:*)
         {
            GlobalFunc.ShowHUDMessage("Error loading CSL: " + e);
         }
      }
      
      public function initBuffsMeter() : void
      {
         var loaderComplete:Function;
         var url:URLRequest = null;
         var loader:URLLoader = null;
         try
         {
            stage.addEventListener(PipboyChangeEvent.PIPBOY_CHANGE_EVENT,this.pipboyChangeEvent);
            loaderComplete = function(param1:Event):void
            {
               var jsonData:Object;
               try
               {
                  jsonData = new JSONDecoder(loader.data,true).getValue();
                  enableWidget = Boolean(jsonData.enableWidgetInPipboy);
                  Pipboy_Header.SHOW_ALL_TABS = Boolean(jsonData.showAllPipboyTabs);
                  if(jsonData.pipInventoryTabNames != null && jsonData.pipInventoryTabNames && jsonData.pipInventoryTabNames.length == 12)
                  {
                     Pipboy_Header.INV_TAB_NAMES = jsonData.pipInventoryTabNames;
                  }
                  enableManualPipBuffDataSync = Boolean(jsonData.enableManualPipBuffDataSync);
                  pipBuffDataSyncHotkey = jsonData.pipBuffDataSyncHotkey != null && !isNaN(jsonData.pipBuffDataSyncHotkey) ? jsonData.pipBuffDataSyncHotkey : pipBuffDataSyncHotkey;
                  if(enableManualPipBuffDataSync)
                  {
                     stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler);
                  }
                  setTimeout(loadBuffsMeter,100);
               }
               catch(e:Error)
               {
                  GlobalFunc.ShowHUDMessage("error parsing config");
               }
            };
            url = new URLRequest(CONFIG_FILE);
            loader = new URLLoader();
            loader.load(url);
            loader.addEventListener(Event.COMPLETE,loaderComplete);
         }
         catch(e:Error)
         {
            GlobalFunc.ShowHUDMessage("Error loading config: " + e);
         }
      }
      
      public function loadBuffsMeter() : *
      {
         try
         {
            if(this.enableWidget && !(this.enableManualPipBuffDataSync || this.__SFCodeObj != null && this.__SFCodeObj.call != null))
            {
               this.modLoader = new Loader();
               this.modLoader.load(new URLRequest("BuffsMeter.swf"),new LoaderContext(false,ApplicationDomain.currentDomain));
               this.modLoader.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR,this.uncaughtErrorHandler);
               this.modLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onBuffsMeterLoaded);
               addChild(this.modLoader);
            }
         }
         catch(e:Error)
         {
            GlobalFunc.ShowHUDMessage("Error loading BuffsMeter.swf: " + e.toString());
         }
      }
      
      public function uncaughtErrorHandler(param1:UncaughtErrorEvent) : *
      {
         GlobalFunc.ShowHUDMessage(param1.toString());
      }
      
      public function onBuffsMeterLoaded(event:*) : void
      {
         try
         {
            if(!lastPipboyChangeData || !lastPipboyChangeData.DataObj)
            {
               setTimeout(onBuffsMeterLoaded,500);
               return;
            }
            updateWidgetData("onBuffsMeterLoaded");
         }
         catch(e:Error)
         {
            GlobalFunc.ShowHUDMessage("onBuffsMeterLoaded error: " + e.toString());
         }
      }
      
      public function updateWidgetData(message:String = "updateWidgetData") : void
      {
         var errorCode:String = "updateWidgetData";
         try
         {
            if(this.modLoader != null && this.modLoader.content != null)
            {
               errorCode = "getBuffsData";
               this.modLoader.content.BuffData = getBuffsData(message);
               errorCode = "content.processEvents";
               this.modLoader.content.processEvents();
            }
         }
         catch(e:Error)
         {
            GlobalFunc.ShowHUDMessage("updateWidgetData error: " + errorCode + " : " + e.toString());
         }
      }
      
      private function pipboyChangeEvent(param1:PipboyChangeEvent) : void
      {
         this.lastPipboyChangeData = {};
         this.lastPipboyChangeData.DataObj = param1.DataObj;
         if(!this.isPipboySaveInit)
         {
            savePipboy();
            this.isPipboySaveInit = true;
         }
      }
      
      private function savePipboy(message:String = "savePipboy") : void
      {
         if(this.__SFCodeObj != null && this.__SFCodeObj.call != null)
         {
            if(this.lastPipboyChangeData == null)
            {
               GlobalFunc.ShowHUDMessage("[BuffsMeter] ERROR: No effects data");
            }
            else
            {
               this.__SFCodeObj.call("writeBuffDataFile",toString(getBuffsData(message)));
            }
         }
      }
      
      public function keyDownHandler(event:Event) : void
      {
         if(event.keyCode == this.pipBuffDataSyncHotkey && this.lastPipboyChangeData != null)
         {
            if(this.__SFCodeObj == null || this.__SFCodeObj.call == null)
            {
               this.syncPipBuffData();
            }
            else
            {
               this.savePipboy("keyDownHandler");
            }
         }
      }
      
      private function syncPipBuffData() : void
      {
         var buffs:*;
         var baZlib:ByteArray;
         var b64:Base64Encoder;
         var b64str:String;
         var baZlib2:ByteArray;
         var errorCode:String = "";
         try
         {
            errorCode = "getBuffs";
            buffs = toString(getBuffsData("HUDMessage"));
            buffs = buffs.replace(/\"text\":/g,"\"x\":").replace(/\"iconText\":/g,"\"n\":").replace(/\"type\":/g,"\"y\":").replace(/\"effects\":/g,"\"f\":").replace(/\"value\":/g,"\"v\":").replace(/\"duration\":/g,"\"d\":").replace(/\"showAsPercent\":/g,"\"p\":").replace(/\"initTime\":/g,"\"i\":").replace(/\"usesCustomDesc\":/g,"\"c\":").replace(/\"keywordSortIndex\":/g,"\"k\":").replace(/\"PlusMinus\":/g,"\"m\":");
            errorCode = "zlib";
            baZlib = new ByteArray();
            errorCode = "zlib write";
            baZlib.writeObject(buffs);
            errorCode = "zlib compress";
            baZlib.compress("zlib");
            errorCode = "Base64Encoder";
            b64 = new Base64Encoder();
            errorCode = "encodeBytes";
            b64.encodeBytes(baZlib);
            errorCode = "b64 string";
            b64str = b64.toString();
            errorCode = "HUD message";
            if(!this.hudTools)
            {
               this.hudTools = new SharedHUDTools("BuffsMeter_Pipboy");
            }
            this.hudTools.SendMessage("BuffsMeter","syncPipBuffData:" + b64str);
         }
         catch(e:*)
         {
            GlobalFunc.ShowHUDMessage("Error syncPipBuffData " + errorCode + ", " + e);
         }
      }
      
      public function getBuffsData(message:String = "default") : *
      {
         if(!lastPipboyChangeData || !lastPipboyChangeData.DataObj)
         {
            return null;
         }
         var data:Object = {};
         data.saveFrom = message;
         data.time = new Date().time;
         data.serverTime = lastPipboyChangeData.DataObj.TimeHour;
         data.activeEffects = lastPipboyChangeData.DataObj.ActiveEffects.concat();
         return data;
      }
      
      private function HandleControlsBlockTimer() : void
      {
         this.controlsBlockTimer.stop();
         this.controlsBlockTimer.reset();
      }
      
      private function loadMobileSettings() : void
      {
         var _loc1_:PipboyLoader = new PipboyLoader();
         var _loc2_:URLRequest = new URLRequest();
         var _loc3_:LoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain);
         _loc2_.url = "PipboyMobileSettings.swf";
         _loc1_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onMobileSettingsLoaded);
         _loc1_.load(_loc2_,_loc3_);
      }
      
      private function onMobileSettingsLoaded(param1:Event) : *
      {
         param1.target.removeEventListener(Event.COMPLETE,this.onMobileSettingsLoaded);
         var _loc2_:MovieClip = param1.target.content as MovieClip;
         addChild(_loc2_);
         BGSExternalInterface.call(this.BGSCodeObj,"OnMobileSettingsLoaded",_loc2_);
         _loc2_.addEventListener("WindowOpened",this.onSettingsOpened);
         _loc2_.addEventListener("WindowClosed",this.onSettingsClosed);
         BGSExternalInterface.call(this.BGSCodeObj,"RegisterMovie",this);
      }
      
      private function onSettingsOpened(param1:Event) : void
      {
         this.Header_mc.tabSwipeZone.deactivate();
      }
      
      private function onSettingsClosed(param1:Event) : void
      {
         this.Header_mc.tabSwipeZone.activate();
      }
      
      private function SetReadOnlyWarningMessage(param1:int) : void
      {
         var _loc2_:* = "";
         var _loc3_:* = false;
         if(param1 == this.READ_ONLY_WARNING_DEFAULT)
         {
            _loc2_ = "$Companion_ReadOnly";
            _loc3_ = true;
         }
         else if(param1 == this.READ_ONLY_WARNING_OFFLINE)
         {
            _loc2_ = "$Companion_OfflineMode";
            _loc3_ = true;
         }
         else if(param1 == this.READ_ONLY_WARNING_DEMO)
         {
            _loc2_ = "$Companion_DemoMode";
            _loc3_ = true;
         }
         if(_loc3_)
         {
            if(this.ReadOnlyWarning != null)
            {
               removeChild(this.ReadOnlyWarning);
               this.ReadOnlyWarning = null;
            }
            this.ReadOnlyWarning = new (getDefinitionByName("ReadOnlyWarning") as Class)() as MovieClip;
            this.ReadOnlyWarning.readOnlyMc.readOnlyTxt.text = _loc2_;
            addChild(this.ReadOnlyWarning);
            this.ReadOnlyWarning.mouseEnabled = false;
            this.ReadOnlyWarning.mouseChildren = false;
            this.ReadOnlyWarning.x = stage.stageWidth / 2;
            this.ReadOnlyWarning.y = 128;
         }
         else if(this.ReadOnlyWarning != null)
         {
            removeChild(this.ReadOnlyWarning);
            this.ReadOnlyWarning = null;
         }
      }
      
      private function onPageClicked(param1:CustomEvent) : *
      {
         var _loc2_:uint = param1.params as uint;
         this.TryToSetPage(_loc2_);
      }
      
      private function onTabClicked(param1:CustomEvent) : *
      {
         var _loc2_:uint = param1.params as uint;
         this.TryToSetTab(_loc2_,"CLICK");
      }
      
      private function onTabChangeAttempt(param1:CustomEvent) : *
      {
         var _loc2_:uint = param1.params as uint;
         this.TryToSetTab(_loc2_);
      }
      
      public function onCodeObjCreate() : *
      {
         BGSExternalInterface.call(this.BGSCodeObj,"PopulatePipboyInfoObj",this.DataObj);
      }
      
      public function onCodeObjDestruction() : *
      {
         this.ClearPages();
         this.BGSCodeObj = null;
         this.DataObj = null;
      }
      
      public function get CurrentPage() : PipboyPage
      {
         return this.GetPage(this.DataObj.CurrentPage);
      }
      
      public function GetPage(param1:uint) : PipboyPage
      {
         return param1 < this.PageA.length ? this.PageA[param1].contentLoaderInfo.content as PipboyPage : null;
      }
      
      private function ClearPages() : *
      {
         var _loc2_:PipboyPage = null;
         var _loc1_:uint = 0;
         while(_loc1_ < this.PageA.length)
         {
            _loc2_ = this.GetPage(_loc1_);
            if(_loc2_)
            {
               removeChild(_loc2_);
            }
            _loc1_++;
         }
      }
      
      public function InvalidateData() : void
      {
         this.InvalidatePartialData(4294967295);
      }
      
      public function InvalidatePartialData(param1:uint) : *
      {
         if(!this._IsLoadingPage)
         {
            if(this.CurrentPage == null)
            {
               this.LoadCurrentPage();
            }
            else
            {
               this.SetReadOnlyWarningMessage(this.DataObj.ReadOnlyMode);
               PipboyChangeEvent.DispatchEvent(new PipboyUpdateMask(param1),stage,this.DataObj,this.CurrentPage.TabNames);
               this.GridViewButton.ButtonText = this.DataObj.PerkPoints > 0 ? "$$LEVELUP (" + this.DataObj.PerkPoints + ")" : "$Grid View";
               this.GridViewButton.ButtonFlashing = this.DataObj.PerkPoints > 0;
               this.GridViewButton.ButtonVisible = this.CurrentPage == null || this.CurrentPage.CanLowerPipboy();
               if(this.DataObj.FreeCampMoves > 0)
               {
                  this.PlaceCampButton.ButtonText = "$PlaceCampButton";
               }
               else
               {
                  this.PlaceCampButton.ButtonText = "$$PlaceCampButton (" + this.DataObj.NumCamps + " $$CapsGlyph)";
               }
               this.PlaceCampButton.ButtonFlashing = this.DataObj.NumCamps > 0 && this.DataObj.CanPlaceCamp;
               this.PlaceCampButton.ButtonEnabled = this.DataObj.CanPlaceCamp;
               this.PlaceCampButton.ButtonVisible = this.CurrentPage == null || this.CurrentPage.CanLowerPipboy();
            }
         }
      }
      
      public function SetPageVisibility() : *
      {
         var _loc2_:PipboyPage = null;
         var _loc1_:uint = 0;
         while(_loc1_ < this.PageA.length)
         {
            _loc2_ = this.GetPage(_loc1_);
            if(_loc2_)
            {
               _loc2_.onPageChange(_loc1_ == this.DataObj.CurrentPage,this.DataObj.CurrentTab);
               if(_loc1_ == this.DataObj.CurrentPage)
               {
                  this.ButtonHintBar_mc.SetButtonHintData(_loc2_.buttonHintDataV);
               }
            }
            _loc1_++;
         }
      }
      
      private function onLowerPipboyAllowChange() : *
      {
         this.GridViewButton.ButtonVisible = this.CurrentPage == null || this.CurrentPage.CanLowerPipboy();
         this.PlaceCampButton.ButtonVisible = this.CurrentPage == null || this.CurrentPage.CanLowerPipboy();
      }
      
      private function onRequestBottomBarUpdate() : *
      {
         PipboyChangeEvent.DispatchEvent(PipboyUpdateMask.BottomBar,stage,this.DataObj,this.CurrentPage.TabNames);
      }
      
      private function LoadCurrentPage() : *
      {
         var _loc1_:URLRequest = null;
         var _loc2_:LoaderContext = null;
         if(this.DataObj.CurrentPage < this.PageA.length)
         {
            _loc1_ = new URLRequest();
            _loc2_ = new LoaderContext(false,ApplicationDomain.currentDomain);
            switch(this.DataObj.CurrentPage)
            {
               case 0:
                  _loc1_.url = "Pipboy_StatsPage.swf";
                  break;
               case 1:
                  _loc1_.url = "Pipboy_InvPage.swf";
                  break;
               case 2:
                  _loc1_.url = "Pipboy_DataPage.swf";
                  break;
               case 3:
                  _loc1_.url = "Pipboy_RadioPage.swf";
            }
            this.PageA[this.DataObj.CurrentPage].contentLoaderInfo.addEventListener(Event.COMPLETE,this.onPageLoadComplete);
            this.PageA[this.DataObj.CurrentPage].load(_loc1_,_loc2_);
            this._IsLoadingPage = true;
         }
      }
      
      private function onPageLoadComplete(param1:Event) : *
      {
         param1.target.removeEventListener(Event.COMPLETE,this.onPageLoadComplete);
         var _loc2_:PipboyPage = param1.target.content as PipboyPage;
         _loc2_.InitCodeObj(this.BGSCodeObj);
         _loc2_.SetHeader(this.Header_mc);
         addChild(_loc2_);
         if(!CompanionAppMode.isOn)
         {
            if(this.DataObj.IsInPowerArmor == false)
            {
               _loc2_.buttonHintDataV.splice(0,0,this.ToggleQuickboyButton);
            }
            _loc2_.buttonHintDataV.splice(0,0,this.PlaceCampButton);
            _loc2_.buttonHintDataV.splice(Math.floor(_loc2_.buttonHintDataV.length / 2),0,this.GridViewButton);
         }
         this.ButtonHintBar_mc.SetButtonHintData(_loc2_.buttonHintDataV);
         if(CompanionAppMode.isOn)
         {
            if(this.DataObj.CurrentPage != 3)
            {
               swapChildren(this.ButtonHintBar_mc,_loc2_);
            }
            this.ButtonHintBar_mc.x = this.BottomBar_mc.x;
            this.ButtonHintBar_mc.y = this.DataObj.CurrentPage == 3 ? 631.55 : 584;
            if(this.ReadOnlyWarning != null)
            {
               swapChildren(this.ReadOnlyWarning,this.ButtonHintBar_mc);
            }
         }
         this._IsLoadingPage = false;
         this.InvalidateData();
      }
      
      public function ProcessUserEvent(param1:String, param2:Boolean) : Boolean
      {
         var _loc3_:Boolean = this.CurrentPage != null && this.CurrentPage.ProcessUserEvent(param1,param2);
         if(!_loc3_)
         {
            if(!param2)
            {
               _loc3_ = true;
               if(param1 == "Forward" || param1 == "LTrigger")
               {
                  this.gotoPrevPage();
               }
               else if(param1 == "Back" || param1 == "RTrigger")
               {
                  this.gotoNextPage();
               }
               else if(param1 == "StrafeLeft" || param1 == "Left")
               {
                  this.gotoPrevTab(param1);
               }
               else if(param1 == "StrafeRight" || param1 == "Right")
               {
                  this.gotoNextTab(param1);
               }
               if(param1 == "YButton" && this.GridViewButton.ButtonVisible)
               {
                  if(this._WasPerkChartPressRegistered)
                  {
                     this.onGridViewPress();
                  }
                  this._WasPerkChartPressRegistered = false;
               }
               else if(param1 == "LShoulder" && this.PlaceCampButton.ButtonVisible)
               {
                  this.onPlaceCamp();
               }
               else
               {
                  _loc3_ = false;
               }
            }
            else if(param1 == "YButton" && this.GridViewButton.ButtonVisible)
            {
               this._WasPerkChartPressRegistered = true;
            }
         }
         return _loc3_;
      }
      
      private function onListPlayFocus() : *
      {
         BGSExternalInterface.call(this.BGSCodeObj,"PlaySound","UIGeneralFocus");
      }
      
      public function gotoNextPage() : *
      {
         this.TryToSetPage(this.DataObj.CurrentPage + 1);
      }
      
      public function gotoPrevPage() : *
      {
         this.TryToSetPage(this.DataObj.CurrentPage - 1);
      }
      
      public function TryToSetPage(param1:uint) : *
      {
         if(!this.controlsBlockTimer.running && param1 < this.PageA.length && this.CurrentPage != null && this.CurrentPage.CanSwitchFromCurrentPage())
         {
            this.controlsBlockTimer.start();
            if(param1 != this.DataObj.CurrentPage)
            {
               BGSExternalInterface.call(this.BGSCodeObj,"onNewPage",param1);
               this.SetPageVisibility();
            }
         }
      }
      
      public function gotoNextTab(param1:String = "") : *
      {
         this.TryToSetTab(this.DataObj.CurrentTab + 1,param1);
      }
      
      public function gotoPrevTab(param1:String = "") : *
      {
         this.TryToSetTab(this.DataObj.CurrentTab - 1,param1);
      }
      
      public function TryToSetTab(param1:uint, param2:String = "") : *
      {
         var _loc3_:PipboyPage = null;
         if(!this.controlsBlockTimer.running && this.CurrentPage != null && this.CurrentPage.CanSwitchTabs(param1,param2))
         {
            this.controlsBlockTimer.start();
            if(param1 != this.DataObj.CurrentTab)
            {
               BGSExternalInterface.call(this.BGSCodeObj,"onNewTab",param1);
               _loc3_ = this.CurrentPage;
               if(_loc3_)
               {
                  this.ButtonHintBar_mc.SetButtonHintData(_loc3_.buttonHintDataV);
                  _loc3_.onTabChange();
               }
            }
         }
      }
      
      public function ProcessRightThumbstickInput(param1:uint) : Boolean
      {
         var _loc2_:Boolean = false;
         if(this.CurrentPage)
         {
            _loc2_ = this.CurrentPage.ProcessRightThumbstickInput(param1);
         }
         return _loc2_;
      }
      
      private function onGridViewPress() : *
      {
         BGSExternalInterface.call(this.BGSCodeObj,"ShowPerksMenu");
      }
      
      private function isCampPlaceProtected() : Boolean
      {
         return modLoader2 != null && modLoader2.content != null && modLoader2.content.isCampPlaceProtected;
      }
      
      private function onPlaceCamp() : *
      {
         if(!this.isCampPlaceProtected())
         {
            BGSExternalInterface.call(this.BGSCodeObj,"RequestPlaceCampMode");
         }
      }
      
      public function onMobileBackButtonPressed() : void
      {
         MobileBackButtonEvent.DispatchEvent(stage);
      }
      
      public function onMobileItemPress(param1:Event) : void
      {
      }
      
      public function SetToQuickBoyMode() : *
      {
         this.MainBackground_mc.visible = true;
      }
      
      public function SetToPipBoyMode() : *
      {
         this.MainBackground_mc.visible = false;
      }
   }
}
