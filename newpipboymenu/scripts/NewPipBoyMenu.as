package
{
   import Shared.AS3.BSAsync;
   import Shared.AS3.BSButtonHintBar;
   import Shared.AS3.BSButtonHintData;
   import Shared.AS3.BSButtonHintHoldProcessor;
   import Shared.AS3.Data.*;
   import Shared.AS3.Events.CustomEvent;
   import Shared.AS3.Events.PlatformChangeEvent;
   import Shared.AS3.IHoldHandler;
   import Shared.AS3.IMenu;
   import Shared.EnumHelper;
   import Shared.GlobalFunc;
   import com.adobe.serialization.json.*;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.*;
   import flash.net.*;
   import flash.system.*;
   import flash.text.*;
   import flash.utils.*;
   import mx.utils.Base64Encoder;
   import utils.*;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol75")]
   public class NewPipBoyMenu extends IMenu implements IHoldHandler
   {
      
      private static var errorMessage:TextField;
      
      private static const CHANGE_REMOVE_WATCH:uint = EnumHelper.GetEnum(0);
      
      private static const CHANGE_PAGE:uint = EnumHelper.GetEnum();
      
      private static const CHANGE_TAB:uint = EnumHelper.GetEnum();
      
      private static const CHANGE_DATA:uint = EnumHelper.GetEnum();
      
      private static const CHANGE_VIEW:uint = EnumHelper.GetEnum();
      
      public static const CONFIG_FILE:String = "../BuffsMeter.json";
      
      private static var clearTimer:Timer = new Timer(17500,1);
      
      public var Header_mc:NewPipboy_Header;
      
      public var BottomBar_mc:NewPipboy_BottomBar;
      
      public var ButtonHintBar_mc:BSButtonHintBar;
      
      public var MainBackground_mc:MovieClip;
      
      private var m_HoldProcessor:BSButtonHintHoldProcessor = null;
      
      private var m_CurrentPage:IPipBoyPage;
      
      private var m_Pages:Vector.<Loader>;
      
      private var m_IsLoadingPage:Boolean = false;
      
      private var m_CurrentPageIndex:uint = 0;
      
      private var m_CurrentTabIndex:uint = 0;
      
      private var m_CurrentBottomBarData:Object = null;
      
      private var m_Buttons:Vector.<BSButtonHintData> = null;
      
      private var m_PlatformDetails:PlatformChangeEvent = null;
      
      private var m_AwaitingPageTabChange:Boolean = false;
      
      public var lastPipboyChangeData:Object;
      
      public var quickEffectsHotkey:int = 0;
      
      public var prioritizeHUDToolsSyncOverSFE:Boolean = false;
      
      public var __SFCodeObj:Object = new Object();
      
      public var modLoaderCSL:Loader;
      
      private var hudTools:SharedHUDTools;
      
      public function NewPipBoyMenu()
      {
         super();
         stage.stageFocusRect = false;
         this.m_IsLoadingPage = false;
         this.m_HoldProcessor = new BSButtonHintHoldProcessor(this);
         this.m_Pages = new <Loader>[null,new Loader(),new Loader(),new Loader(),new Loader()];
         this.m_Pages.fixed = true;
         this.m_Buttons = new Vector.<BSButtonHintData>();
         this.initBuffsMeter();
         this.loadCSL();
      }
      
      private static function toString(param1:Object) : String
      {
         return new JSONEncoder(param1).getString();
      }
      
      public static function displayMessage(param1:*, clear:Boolean = false) : void
      {
         if(clear)
         {
            GlobalFunc.SetText(errorMessage,"");
         }
         if(param1 is String)
         {
            var str:String = param1;
         }
         else
         {
            str = toString(param1);
         }
         GlobalFunc.SetText(errorMessage,errorMessage.text + "\n" + str);
         errorMessage.visible = true;
         errorMessage.scrollV = errorMessage.maxScrollV;
         clearTimer.reset();
         clearTimer.start();
      }
      
      private static function clearMessages() : void
      {
         errorMessage.text = "";
      }
      
      private function displayFormat() : void
      {
         errorMessage = new TextField();
         errorMessage.x = 0;
         errorMessage.y = 0;
         errorMessage.width = 800;
         errorMessage.height = 600;
         GlobalFunc.SetText(errorMessage,"",false);
         errorMessage.wordWrap = true;
         errorMessage.multiline = true;
         var font:TextFormat = new TextFormat("$MAIN_Font",18,16777215);
         errorMessage.defaultTextFormat = font;
         errorMessage.setTextFormat(font);
         errorMessage.selectable = false;
         errorMessage.mouseWheelEnabled = false;
         errorMessage.mouseEnabled = false;
         errorMessage.visible = true;
         addChild(errorMessage);
      }
      
      public function loadCSL() : *
      {
         try
         {
            this.modLoaderCSL = new Loader();
            addChild(this.modLoaderCSL);
            this.modLoaderCSL.load(new URLRequest("CSL.swf"),new LoaderContext(false,ApplicationDomain.currentDomain));
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
            clearTimer.addEventListener(TimerEvent.TIMER,clearMessages,false,0,true);
            displayFormat();
            BSUIDataManager.Subscribe("PipBoySTATSEffectsProvider",this.onEffectsChangeEvent);
            stage.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler);
            loaderComplete = function(param1:Event):void
            {
               var jsonData:Object;
               try
               {
                  jsonData = new JSONDecoder(loader.data,true).getValue();
                  quickEffectsHotkey = Buttons.parseValue(jsonData.quickEffectsTabHotkey);
                  prioritizeHUDToolsSyncOverSFE = Boolean(jsonData.prioritizeHUDToolsSyncOverSFE);
                  NewPipboy_Header.SHOW_ALL_TABS = Boolean(jsonData.showAllPipboyTabs);
                  if(jsonData.pipInventoryTabNames != null && jsonData.pipInventoryTabNames && jsonData.pipInventoryTabNames.length == 12)
                  {
                     NewPipboy_Header.INV_TAB_NAMES = jsonData.pipInventoryTabNames;
                  }
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
      
      public function uncaughtErrorHandler(param1:UncaughtErrorEvent) : *
      {
         GlobalFunc.ShowHUDMessage(param1.toString());
      }
      
      private function onEffectsChangeEvent(param1:*) : void
      {
         if(!param1.data || !param1.data.EffectsA || !param1.data.EffectsA.length || param1.data.EffectsA[0].IconType == "PerkIcon")
         {
            return;
         }
         this.lastPipboyChangeData = {};
         this.lastPipboyChangeData.data = param1.data;
         if(this.__SFCodeObj == null || this.__SFCodeObj.call == null || this.prioritizeHUDToolsSyncOverSFE)
         {
            this.syncPipBuffDataHUDTools();
         }
         else
         {
            this.savePipBuffDataSFE();
         }
      }
      
      public function keyDownHandler(event:Event) : void
      {
         if(event.keyCode == this.quickEffectsHotkey)
         {
            if(this.m_CurrentPageIndex != 1)
            {
               BSUIDataManager.dispatchEvent(new CustomEvent(NewPipBoyShared.PAGE_SET,{"pageIndex":uint(1)}));
               setTimeout(BSUIDataManager.dispatchEvent,200,new CustomEvent(NewPipBoyShared.TAB_SET,{"tabIndex":uint(2)}));
            }
            else if(this.m_CurrentTabIndex != 2)
            {
               BSUIDataManager.dispatchEvent(new CustomEvent(NewPipBoyShared.TAB_SET,{"tabIndex":uint(2)}));
            }
         }
      }
      
      private function savePipBuffDataSFE(message:String = "savePipBuffDataSFE") : void
      {
         if(this.lastPipboyChangeData == null)
         {
            GlobalFunc.ShowHUDMessage("[BuffsMeter] ERROR: No effects data");
         }
         else
         {
            this.__SFCodeObj.call("writeBuffDataFile",toString(this.getBuffsData(message)));
         }
      }
      
      private function syncPipBuffDataHUDTools() : void
      {
         var buffs:*;
         var b64:Base64Encoder;
         var b64str:String;
         var ba:ByteArray;
         var errorCode:String = "";
         try
         {
            errorCode = "getBuffs";
            buffs = toString(getBuffsData("syncHUDTools"));
            buffs = buffs.replace(/\"Name\":/g,"\"n\":").replace(/\"IconLabel\":/g,"\"i\":").replace(/\"IconType\":/g,"\"y\":").replace(/\"TimeRemainingLabel\":/g,"\"t\":").replace(/\"EffectEntriesA\":/g,"\"e\":").replace(/\"Label\":/g,"\"l\":").replace(/\"MagnitudeText\":/g,"\"m\":").replace(/\"isStackedMagnitude\":/g,"\"s\":");
            errorCode = "ba";
            ba = new ByteArray();
            errorCode = "ba write";
            ba.writeObject(buffs);
            errorCode = "Base64Encoder";
            b64 = new Base64Encoder();
            errorCode = "encodeBytes";
            b64.encodeBytes(ba);
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
         if(!this.lastPipboyChangeData || !this.lastPipboyChangeData.data)
         {
            return null;
         }
         var data:Object = {};
         data.saveFrom = message;
         data.time = new Date().time;
         data.activeEffects = [].concat(this.lastPipboyChangeData.data.EffectsA);
         return data;
      }
      
      private function isCampPlaceProtected() : Boolean
      {
         return modLoaderCSL != null && modLoaderCSL.content != null && Boolean(modLoaderCSL.content.isCampPlaceProtected);
      }
      
      override public function onAddedToStage() : void
      {
         this.Header_mc.addEventListener(NewPipBoyShared.PAGE_CLICKED,this.onPageClicked);
         this.Header_mc.addEventListener(NewPipBoyShared.TAB_CLICKED,this.onTabClicked);
         BSUIDataManager.Subscribe("PipBoyFooterProvider",function(param1:FromClientDataEvent):*
         {
            m_CurrentBottomBarData = param1.data;
            if(m_CurrentPage)
            {
               m_CurrentPage.SharedData = m_CurrentBottomBarData;
               UpdateBottomBar();
            }
         });
         BSUIDataManager.Subscribe("PipBoyINVSelectionProvider",function(param1:FromClientDataEvent):*
         {
            var event:FromClientDataEvent = param1;
            if(Boolean(m_CurrentPage) && m_CurrentPageIndex == NewPipBoyShared.INV_PAGE)
            {
               m_CurrentPage.processProvider(event.data,1);
            }
            else
            {
               BSAsync.Await(Header_mc,BSAsync.AWAIT_MILLISECONDS,function():*
               {
                  if(Boolean(m_CurrentPage) && m_CurrentPageIndex == NewPipBoyShared.INV_PAGE)
                  {
                     m_CurrentPage.processProvider(event.data,1);
                  }
               },200);
            }
         });
         BSUIDataManager.Subscribe("PageTabData",function(param1:FromClientDataEvent):*
         {
            SetActivePageTab(param1.data.PageIndex,param1.data.TabIndex);
         });
         BSUIDataManager.Subscribe("ButtonBarData",function(param1:FromClientDataEvent):*
         {
            UpdateButtonBar(param1.data);
         });
         BSUIDataManager.Subscribe("CharacterInfoData",function(param1:FromClientDataEvent):*
         {
            BottomBar_mc.SetMaxCapsInfo(param1.data);
         });
         BSUIDataManager.Subscribe("PipBoyChangesProvider",this.onMenuChange);
         stage.addEventListener(PlatformChangeEvent.PLATFORM_CHANGE,this.onSetPlatformEvent);
      }
      
      private function onMenuChange(param1:FromClientDataEvent) : *
      {
         var _loc9_:String = null;
         var _loc10_:uint = 0;
         var _loc11_:uint = 0;
         var _loc2_:Array = param1.data.changes.sortOn(["type"]);
         var _loc3_:Vector.<String> = new Vector.<String>();
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         var _loc6_:Array = new Array();
         var _loc7_:Object = null;
         var _loc8_:uint = 0;
         while(_loc8_ < _loc2_.length)
         {
            switch(_loc2_[_loc8_].type)
            {
               case CHANGE_REMOVE_WATCH:
                  _loc3_.push(NewPipBoyShared.GetProviderForPageTab(_loc2_[_loc8_].primaryValue,_loc2_[_loc8_].secondaryValue));
                  break;
               case CHANGE_PAGE:
                  if(!_loc4_)
                  {
                     _loc4_ = _loc2_[_loc8_];
                  }
                  break;
               case CHANGE_TAB:
                  if(!_loc5_)
                  {
                     _loc5_ = _loc2_[_loc8_];
                  }
                  break;
               case CHANGE_DATA:
                  _loc6_.push(_loc2_[_loc8_]);
                  break;
               case CHANGE_VIEW:
                  if(!_loc7_)
                  {
                     _loc7_ = _loc2_[_loc8_];
                  }
                  break;
            }
            _loc8_++;
         }
         for each(_loc9_ in _loc3_)
         {
            BSUIDataManager.RemoveWatchFromDataConnector(_loc9_);
         }
         if(Boolean(_loc4_) || Boolean(_loc5_))
         {
            _loc10_ = _loc4_ ? uint(_loc4_.primaryValue) : this.m_CurrentPageIndex;
            _loc11_ = _loc5_ ? uint(_loc5_.primaryValue) : this.m_CurrentTabIndex;
            this.SetActivePageTab(_loc10_,_loc11_);
         }
         if(!this.m_AwaitingPageTabChange)
         {
            _loc8_ = 0;
            while(_loc8_ < _loc6_.length)
            {
               if(_loc6_[_loc8_].primaryValue == this.m_CurrentPageIndex && _loc6_[_loc8_].secondaryValue == this.m_CurrentTabIndex)
               {
                  this.HandleDataUpdate();
                  break;
               }
               _loc8_++;
            }
         }
         if(_loc7_)
         {
            this.SetViewMode(_loc7_.primaryValue);
         }
      }
      
      final private function onSetPlatformEvent(param1:Event) : *
      {
         this.m_PlatformDetails = param1 as PlatformChangeEvent;
         if(this.m_CurrentPage)
         {
            this.m_CurrentPage.SetPlatform(this.m_PlatformDetails.uiPlatform,this.m_PlatformDetails.bPS3Switch,this.m_PlatformDetails.uiController,this.m_PlatformDetails.uiKeyboard);
         }
         this.ButtonHintBar_mc.SetIsDirty();
      }
      
      private function SetViewMode(param1:Boolean) : void
      {
         this.MainBackground_mc.visible = param1;
      }
      
      private function SetActivePageTab(param1:uint, param2:uint) : void
      {
         var _loc3_:Array = null;
         this.m_AwaitingPageTabChange = this.m_CurrentPageIndex != param1 || this.m_CurrentTabIndex != param2;
         if(this.m_AwaitingPageTabChange)
         {
            this.m_CurrentTabIndex = param2;
            this.m_CurrentPageIndex = param1;
            if(!this.GetPage(this.m_CurrentPageIndex))
            {
               this.LoadCurrentPage();
            }
            else
            {
               this.m_CurrentPage = this.GetPage(this.m_CurrentPageIndex);
               if(this.m_CurrentPage)
               {
                  this.m_CurrentPage.SetPlatform(this.m_PlatformDetails.uiPlatform,this.m_PlatformDetails.bPS3Switch,this.m_PlatformDetails.uiController,this.m_PlatformDetails.uiKeyboard);
                  this.m_CurrentPage.CurrentTabIndex = this.m_CurrentTabIndex;
                  this.m_CurrentPage.SharedData = this.m_CurrentBottomBarData;
                  this.m_CurrentPage.OnEntry();
                  this.m_CurrentPage.refreshCurrentTab();
                  this.HandleDataUpdate();
                  this.UpdateBottomBar();
               }
            }
            _loc3_ = new Array();
            switch(this.m_CurrentPageIndex)
            {
               case NewPipBoyShared.STATS_PAGE:
                  _loc3_ = NewPipBoyShared.STATS_TAB_NAMES;
                  break;
               case NewPipBoyShared.INV_PAGE:
                  _loc3_ = NewPipBoyShared.INV_TAB_NAMES;
                  break;
               case NewPipBoyShared.DATA_PAGE:
                  _loc3_ = NewPipBoyShared.DATA_TAB_NAMES;
            }
            this.Header_mc.UpdateHeader(_loc3_,this.m_CurrentPageIndex,this.m_CurrentTabIndex);
         }
      }
      
      private function HandleDataUpdate() : void
      {
         BSAsync.Await(this,BSAsync.AWAIT_MILLISECONDS,function():*
         {
            var _loc1_:UIDataFromClient = BSUIDataManager.GetDataFromClient(NewPipBoyShared.GetProviderForPageTab(m_CurrentPageIndex,m_CurrentTabIndex));
            if(Boolean(_loc1_) && Boolean(m_CurrentPage))
            {
               if(m_AwaitingPageTabChange)
               {
                  UpdatePageVisibility();
                  m_AwaitingPageTabChange = false;
               }
               m_CurrentPage.processProvider(_loc1_.data);
            }
         },80);
      }
      
      private function LoadCurrentPage() : *
      {
         var _loc1_:URLRequest = null;
         var _loc2_:LoaderContext = null;
         if(this.m_CurrentPageIndex < this.m_Pages.length)
         {
            _loc1_ = new URLRequest();
            _loc2_ = new LoaderContext(false,ApplicationDomain.currentDomain);
            switch(this.m_CurrentPageIndex)
            {
               case NewPipBoyShared.STATS_PAGE:
                  _loc1_.url = "NewPipboy_StatsPage.swf";
                  break;
               case NewPipBoyShared.INV_PAGE:
                  _loc1_.url = "NewPipboy_InvPage.swf";
                  break;
               case NewPipBoyShared.DATA_PAGE:
                  _loc1_.url = "NewPipboy_DataPage.swf";
                  break;
               case NewPipBoyShared.RADIO_PAGE:
                  _loc1_.url = "NewPipboy_RadioPage.swf";
                  break;
               default:
                  trace("Invalid page index: " + this.m_CurrentPageIndex);
            }
            this.m_Pages[this.m_CurrentPageIndex].contentLoaderInfo.addEventListener(Event.COMPLETE,this.onPageLoadComplete);
            this.m_Pages[this.m_CurrentPageIndex].load(_loc1_,_loc2_);
            this.m_IsLoadingPage = true;
         }
      }
      
      private function onPageLoadComplete(param1:Event) : *
      {
         param1.target.removeEventListener(Event.COMPLETE,this.onPageLoadComplete);
         var _loc2_:IPipBoyPage = param1.target.content as IPipBoyPage;
         if(_loc2_)
         {
            _loc2_.SetVisibility(false);
            addChild(_loc2_);
            this.m_CurrentPage = _loc2_;
            this.m_CurrentPage.SetPlatform(this.m_PlatformDetails.uiPlatform,this.m_PlatformDetails.bPS3Switch,this.m_PlatformDetails.uiController,this.m_PlatformDetails.uiKeyboard);
            this.m_CurrentPage.CurrentTabIndex = this.m_CurrentTabIndex;
            this.m_CurrentPage.SharedData = this.m_CurrentBottomBarData;
            this.m_CurrentPage.OnEntry();
            this.m_CurrentPage.refreshCurrentTab();
            this.HandleDataUpdate();
            this.UpdateBottomBar();
         }
         else
         {
            trace("NewPipBoyMenu::onPageLoadComplete -- target content failed to load!");
         }
         this.m_IsLoadingPage = false;
      }
      
      private function UpdatePageVisibility() : void
      {
         var _loc2_:IPipBoyPage = null;
         var _loc1_:uint = 1;
         while(_loc1_ < this.m_Pages.length)
         {
            _loc2_ = this.GetPage(_loc1_);
            if(_loc2_ != null)
            {
               _loc2_.SetVisibility(_loc1_ == this.m_CurrentPageIndex);
            }
            _loc1_++;
         }
      }
      
      private function GetPage(param1:uint) : IPipBoyPage
      {
         return param1 < this.m_Pages.length ? this.m_Pages[param1].contentLoaderInfo.content as IPipBoyPage : null;
      }
      
      private function UpdateButtonBar(param1:Object) : void
      {
         var i:uint = 0;
         var entry:Object = null;
         var dispatchEvent:String = null;
         var buttonHint:BSButtonHintData = null;
         var aData:Object = param1;
         if(aData)
         {
            this.m_Buttons = new Vector.<BSButtonHintData>();
            i = 0;
            while(i < aData.EntryList.length)
            {
               if(aData.EntryList[i].IsEnabled)
               {
                  entry = aData.EntryList[i];
                  dispatchEvent = entry.ScriptFunc != "" ? entry.ScriptFunc : entry.Event;
                  buttonHint = new BSButtonHintData(entry.Name,entry.Mappings.PCButton,entry.Mappings.PSNButton,entry.Mappings.XboxButton,1,function():*
                  {
                     onButtonClicked(dispatchEvent);
                  },dispatchEvent,entry.Event);
                  buttonHint.canHold = entry.IsHold;
                  buttonHint.ButtonVisible = entry.IsVisible;
                  buttonHint.ButtonEnabled = entry.IsButtonEnabled;
                  buttonHint.ButtonFlashing = entry.IsFlashing;
                  this.m_Buttons.push(buttonHint);
               }
               i++;
            }
            this.ButtonHintBar_mc.SetButtonHintData(this.m_Buttons);
            this.m_HoldProcessor.reset();
         }
      }
      
      private function onButtonClicked(param1:String) : void
      {
         this.onButtonPressEvent(param1,"",true);
      }
      
      private function UpdateBottomBar() : void
      {
         this.BottomBar_mc.SetInfo(this.m_CurrentPageIndex,this.m_CurrentTabIndex,this.m_CurrentPage.SharedData);
      }
      
      private function onPageClicked(param1:CustomEvent) : void
      {
         var _loc2_:uint = param1.params as uint;
         if(_loc2_ != this.m_CurrentPageIndex)
         {
            BSUIDataManager.dispatchEvent(new CustomEvent(NewPipBoyShared.PAGE_SET,{"pageIndex":_loc2_}));
         }
      }
      
      private function onTabClicked(param1:CustomEvent) : void
      {
         BSUIDataManager.dispatchEvent(new CustomEvent(NewPipBoyShared.TAB_SET,{"tabIndex":param1.params as uint}));
      }
      
      public function ProcessUserEvent(param1:String, param2:Boolean) : Boolean
      {
         var _loc4_:Object = null;
         var _loc5_:BSButtonHintData = null;
         var _loc3_:Boolean = false;
         if(this.m_CurrentPage)
         {
            _loc4_ = {
               "eventName":param1,
               "pressed":param2,
               "buttonsOrBar":this.m_Buttons,
               "handled":false
            };
            _loc5_ = this.m_HoldProcessor.processButtonHold(_loc4_);
            _loc3_ = Boolean(_loc4_.handled);
            if(!_loc3_ && !param2)
            {
               _loc3_ = this.onButtonPressEvent(param1,_loc5_ ? _loc5_.DispatchEvent : "",_loc5_ != null);
            }
         }
         return _loc3_;
      }
      
      public function onButtonPressEvent(param1:String, param2:String, param3:Boolean = false) : Boolean
      {
         var _loc4_:Boolean = Boolean(this.m_CurrentPage) && this.m_CurrentPage.ProcessUserEvent(param1);
         if(!_loc4_)
         {
            if(param3 && param2 != "")
            {
               param1 = param2;
            }
            switch(param1)
            {
               case "Forward":
               case "LTrigger":
                  BSUIDataManager.dispatchEvent(new CustomEvent(NewPipBoyShared.PAGE_CYCLE,{"direction":-1}));
                  _loc4_ = true;
                  break;
               case "Back":
               case "RTrigger":
                  BSUIDataManager.dispatchEvent(new CustomEvent(NewPipBoyShared.PAGE_CYCLE,{"direction":1}));
                  _loc4_ = true;
                  break;
               case "StrafeLeft":
               case "Left":
                  if(Boolean(this.m_CurrentPage) && this.m_CurrentPage.CanSwitchTabs(param1,-1))
                  {
                     BSUIDataManager.dispatchEvent(new CustomEvent(NewPipBoyShared.TAB_CYCLE,{"direction":-1}));
                  }
                  _loc4_ = true;
                  break;
               case "StrafeRight":
               case "Right":
                  if(Boolean(this.m_CurrentPage) && this.m_CurrentPage.CanSwitchTabs(param1,1))
                  {
                     BSUIDataManager.dispatchEvent(new CustomEvent(NewPipBoyShared.TAB_CYCLE,{"direction":1}));
                  }
                  _loc4_ = true;
                  break;
               case "MoveCamp":
                  if(!this.isCampPlaceProtected())
                  {
                     BSUIDataManager.dispatchEvent(new Event(NewPipBoyShared.REQUEST_PLACE_CAMP));
                  }
                  _loc4_ = true;
                  break;
               case "ViewPerks":
                  BSUIDataManager.dispatchEvent(new Event(NewPipBoyShared.VIEW_PERKS));
                  _loc4_ = true;
                  break;
               default:
                  if(Boolean(this.m_CurrentPage) && param3)
                  {
                     BSUIDataManager.dispatchEvent(new CustomEvent(this.m_CurrentPage.EventPrefix + param2,{"ID":this.m_CurrentPage.SelectedID}));
                     _loc4_ = true;
                  }
            }
         }
         return _loc4_;
      }
      
      public function ProcessLeftThumbstickInput(param1:uint) : Boolean
      {
         return Boolean(this.m_CurrentPage) && this.m_CurrentPage.CanSwitchTabs("LeftStick",param1);
      }
      
      public function ProcessRightThumbstickInput(param1:uint) : Boolean
      {
         return Boolean(this.m_CurrentPage) && this.m_CurrentPage.ProcessRightThumbstickInput(param1);
      }
   }
}

