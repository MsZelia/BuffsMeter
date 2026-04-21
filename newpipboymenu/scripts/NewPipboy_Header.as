package
{
   import Shared.AS3.BSButtonHint;
   import Shared.AS3.BSButtonHintData;
   import Shared.AS3.Data.BSUIDataManager;
   import Shared.AS3.Events.CustomEvent;
   import Shared.GlobalFunc;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import scaleform.gfx.Extensions;
   import scaleform.gfx.TextFieldEx;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol44")]
   public class NewPipboy_Header extends MovieClip
   {
      
      public static var SHOW_ALL_TABS:Boolean = false;
      
      public static var INV_TAB_NAMES:Array = [];
      
      public static var MAX_TABS:int = 13;
      
      private static const INVALID_VALUE:uint = uint.MAX_VALUE;
      
      private static const SELECTED_INDEX:uint = 3;
      
      private static const TAB_SPACING:Number = 12.5;
      
      public var PageHeader_mc:MovieClip;
      
      public var TabHeader_mc:MovieClip;
      
      public var LeftTriggerButton_mc:BSButtonHint;
      
      public var RightTriggerButton_mc:BSButtonHint;
      
      private var LeftTriggerButton:BSButtonHintData;
      
      private var RightTriggerButton:BSButtonHintData;
      
      private var m_PageTextFields:Vector.<TextField>;
      
      private var m_PageTextXBounds:Vector.<Point>;
      
      private var m_TabTextFields:Vector.<TextField>;
      
      private var m_CurrPageIndex:uint;
      
      private var m_PrevTabIndex:uint;
      
      private var m_CurrTabIndex:uint;
      
      private var m_TabNames:Array;
      
      private var customTabs:Array;
      
      private var tabFormat:TextFormat;
      
      private var selectedTabFormat:TextFormat;
      
      private var selectedTabText:String = "";
      
      public function NewPipboy_Header()
      {
         var _loc3_:TextField = null;
         var _loc4_:Point = null;
         var _loc5_:int = 0;
         var _loc6_:TextField = null;
         this.LeftTriggerButton = new BSButtonHintData("","","PSN_L2_Alt","Xenon_L2_Alt",1,null);
         this.RightTriggerButton = new BSButtonHintData("","","PSN_R2_Alt","Xenon_R2_Alt",0,null);
         super();
         Extensions.enabled = true;
         this.m_CurrPageIndex = INVALID_VALUE;
         this.m_PrevTabIndex = INVALID_VALUE;
         this.m_CurrTabIndex = INVALID_VALUE;
         this.m_PageTextFields = new <TextField>[null,this.PageHeader_mc.STAT_tf,this.PageHeader_mc.INV_tf,this.PageHeader_mc.DATA_tf,this.PageHeader_mc.RADIO_tf];
         this.m_PageTextFields.fixed = true;
         this.m_PageTextXBounds = new Vector.<Point>();
         var _loc1_:uint = 0;
         while(_loc1_ < this.m_PageTextFields.length)
         {
            if(this.m_PageTextFields[_loc1_])
            {
               _loc3_ = this.m_PageTextFields[_loc1_];
               _loc3_.addEventListener(MouseEvent.CLICK,this.onPageClicked);
               TextFieldEx.setTextAutoSize(_loc3_,TextFieldEx.TEXTAUTOSZ_SHRINK);
               _loc4_ = new Point();
               _loc5_ = _loc3_.x;
               _loc4_.x = _loc5_ + _loc3_.getCharBoundaries(0).x;
               _loc4_.y = _loc5_ + _loc3_.getCharBoundaries(_loc3_.text.length - 1).right;
               this.m_PageTextXBounds.push(_loc4_);
            }
            else
            {
               this.m_PageTextXBounds.push(null);
            }
            _loc1_++;
         }
         this.m_PageTextXBounds.fixed = true;
         this.m_TabTextFields = new <TextField>[null,this.TabHeader_mc.AlphaHolder.LeftTwo.textField_tf,this.TabHeader_mc.AlphaHolder.LeftOne.textField_tf,this.TabHeader_mc.AlphaHolder.Selected.textField_tf,this.TabHeader_mc.AlphaHolder.RightOne.textField_tf,this.TabHeader_mc.AlphaHolder.RightTwo.textField_tf];
         this.m_TabTextFields.fixed = true;
         var _loc2_:uint = 0;
         while(_loc2_ < this.m_TabTextFields.length)
         {
            if(this.m_TabTextFields[_loc2_])
            {
               _loc6_ = this.m_TabTextFields[_loc2_] as TextField;
               _loc6_.autoSize = TextFieldAutoSize.CENTER;
               _loc6_.addEventListener(MouseEvent.CLICK,this.onTabClicked);
            }
            _loc2_++;
         }
         this.LeftTriggerButton_mc.ButtonHintData = this.LeftTriggerButton;
         this.RightTriggerButton_mc.ButtonHintData = this.RightTriggerButton;
         this.initCustomTabs();
      }
      
      private function initCustomTabs() : void
      {
         this.customTabs = [];
         var i:int = 0;
         while(i < MAX_TABS)
         {
            this.customTabs.push(createTab());
            i++;
         }
      }
      
      private function createTab() : TextField
      {
         selectedTabFormat = this.PageHeader_mc.STAT_tf.getTextFormat();
         tabFormat = this.PageHeader_mc.STAT_tf.getTextFormat();
         selectedTabFormat.underline = true;
         selectedTabFormat.size = 24;
         tabFormat.underline = false;
         tabFormat.size = 24;
         var tf:TextField = new TextField();
         tf.visible = false;
         tf.setTextFormat(tabFormat);
         tf.defaultTextFormat = tabFormat;
         TextFieldEx.setTextAutoSize(tf,TextFieldEx.TEXTAUTOSZ_SHRINK);
         tf.x = (this.customTabs.length - 1) * 70;
         tf.y = 50;
         tf.width = 300;
         tf.height = 40;
         tf.selectable = false;
         tf.addEventListener(MouseEvent.CLICK,this.onCustomTabClicked);
         addChild(tf);
         return tf;
      }
      
      public function onCustomTabClicked(event:MouseEvent) : void
      {
         var tf:TextField = event.target as TextField;
         var index:int = int(this.customTabs.indexOf(tf) + 1);
         if(index != 0)
         {
            BSUIDataManager.dispatchEvent(new CustomEvent(NewPipBoyShared.TAB_SET,{"tabIndex":uint(index)}));
         }
      }
      
      public function UpdateHeader(param1:Array, param2:uint, param3:uint) : void
      {
         if(this.m_CurrPageIndex != param2)
         {
            this.m_PrevTabIndex = INVALID_VALUE;
         }
         else
         {
            this.m_PrevTabIndex = this.m_CurrTabIndex;
         }
         this.m_CurrPageIndex = param2;
         this.m_CurrTabIndex = param3;
         this.m_TabNames = param1;
         var useCustomTabNames:Boolean = this.m_CurrPageIndex == 2 && INV_TAB_NAMES.length == 12;
         var tabNamesLen:int = int(Boolean(this.m_TabNames) ? this.m_TabNames.length - 1 : 0);
         var xPos:int = -75;
         var xDelta:int = 860 / Math.max(tabNamesLen,1);
         var i:int = 0;
         while(i < this.customTabs.length)
         {
            if(tabNamesLen > i)
            {
               this.customTabs[i].text = useCustomTabNames ? INV_TAB_NAMES[i] : this.m_TabNames[i + 1];
               this.customTabs[i].visible = SHOW_ALL_TABS;
               this.customTabs[i].x = xPos;
               this.customTabs[i].width = xDelta;
               xPos += xDelta;
            }
            else
            {
               this.customTabs[i].visible = false;
            }
            i++;
         }
         this.updateDisplay();
      }
      
      private function onPageClicked(param1:MouseEvent) : void
      {
         var _loc2_:TextField = param1.target as TextField;
         var _loc3_:int = int(this.m_PageTextFields.indexOf(_loc2_));
         if(_loc3_ > 0)
         {
            dispatchEvent(new CustomEvent(NewPipBoyShared.PAGE_CLICKED,_loc3_ as uint,true,true));
         }
      }
      
      private function onTabClicked(param1:MouseEvent) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc2_:TextField = param1.target as TextField;
         var _loc3_:int = int(this.m_TabTextFields.indexOf(_loc2_));
         if(_loc3_ > 0)
         {
            _loc4_ = _loc3_ - SELECTED_INDEX;
            _loc5_ = this.m_CurrTabIndex + _loc4_;
            if(_loc3_ > 0)
            {
               dispatchEvent(new CustomEvent(NewPipBoyShared.TAB_CLICKED,_loc5_ as uint,true,true));
            }
         }
      }
      
      private function updateDisplay() : void
      {
         this.redrawPages();
         this.redrawTabs();
      }
      
      private function redrawPages() : void
      {
         var _loc1_:Shape = null;
         var _loc2_:Shape = null;
         if(this.m_CurrPageIndex != INVALID_VALUE && this.m_CurrPageIndex > 0)
         {
            this.PageHeader_mc.Selector_Left.x = this.m_PageTextXBounds[this.m_CurrPageIndex].x - 12.5;
            this.PageHeader_mc.Selector_Right.x = this.m_PageTextXBounds[this.m_CurrPageIndex].y + 12.5;
            _loc1_ = new Shape();
            if(this.PageHeader_mc.getChildByName("leftLine"))
            {
               this.PageHeader_mc.removeChild(this.PageHeader_mc.getChildByName("leftLine"));
            }
            _loc1_.name = "leftLine";
            _loc1_.graphics.lineStyle(3,16777215,1,false,"none");
            _loc1_.graphics.moveTo(this.PageHeader_mc.LeftBorder.x,this.PageHeader_mc.LeftBorder.y);
            _loc1_.graphics.lineTo(this.PageHeader_mc.Selector_Left.x,this.PageHeader_mc.LeftBorder.y);
            this.PageHeader_mc.addChild(_loc1_);
            _loc2_ = new Shape();
            if(this.PageHeader_mc.getChildByName("rightLine"))
            {
               this.PageHeader_mc.removeChild(this.PageHeader_mc.getChildByName("rightLine"));
            }
            _loc2_.name = "rightLine";
            _loc2_.graphics.lineStyle(3,16777215,1,false,"none");
            _loc2_.graphics.moveTo(this.PageHeader_mc.Selector_Right.x,this.PageHeader_mc.RightBorder.y);
            _loc2_.graphics.lineTo(this.PageHeader_mc.RightBorder.x,this.PageHeader_mc.RightBorder.y);
            this.PageHeader_mc.addChild(_loc2_);
         }
      }
      
      public function redrawTabs() : void
      {
         var _loc1_:Array = null;
         var _loc2_:String = null;
         if(SHOW_ALL_TABS)
         {
            var useCustomTabNames:Boolean = this.m_CurrPageIndex == 2 && INV_TAB_NAMES.length == 12;
            this.TabHeader_mc.visible = false;
            var i:int = 0;
            while(i < this.customTabs.length)
            {
               if(this.m_TabNames && i < this.m_TabNames.length - 1)
               {
                  this.customTabs[i].text = useCustomTabNames ? INV_TAB_NAMES[i] : this.m_TabNames[i + 1];
               }
               if(i == this.m_CurrTabIndex - 1)
               {
                  selectedTabText = this.customTabs[i].text;
                  if(!this.customTabs[i].defaultTextFormat.underline)
                  {
                     this.customTabs[i].setTextFormat(selectedTabFormat);
                     this.customTabs[i].defaultTextFormat = selectedTabFormat;
                  }
               }
               else if(this.customTabs[i].defaultTextFormat.underline)
               {
                  this.customTabs[i].setTextFormat(tabFormat);
                  this.customTabs[i].defaultTextFormat = tabFormat;
               }
               i++;
            }
         }
         if(this.m_PrevTabIndex != this.m_CurrTabIndex)
         {
            _loc1_ = this.m_TabNames;
            this.TabHeader_mc.x = (this.m_PageTextXBounds[this.m_CurrPageIndex].x + this.m_PageTextXBounds[this.m_CurrPageIndex].y) / 2;
            if(_loc1_ != null && _loc1_.length > 0 && this.m_CurrTabIndex > 0)
            {
               GlobalFunc.SetText(this.m_TabTextFields[SELECTED_INDEX],_loc1_[this.m_CurrTabIndex],false);
               _loc2_ = this.m_CurrTabIndex >= 1 ? _loc1_[this.m_CurrTabIndex - 1] : "";
               GlobalFunc.SetText(this.m_TabTextFields[SELECTED_INDEX - 1],_loc2_,false);
               this.TabHeader_mc.AlphaHolder.LeftOne.x = this.TabHeader_mc.AlphaHolder.Selected.x - this.TabHeader_mc.AlphaHolder.Selected.width / 2 - this.TabHeader_mc.AlphaHolder.LeftOne.width / 2 - TAB_SPACING;
               _loc2_ = this.m_CurrTabIndex >= 2 ? _loc1_[this.m_CurrTabIndex - 2] : "";
               GlobalFunc.SetText(this.m_TabTextFields[SELECTED_INDEX - 2],_loc2_,false);
               this.TabHeader_mc.AlphaHolder.LeftTwo.x = this.TabHeader_mc.AlphaHolder.LeftOne.x - this.TabHeader_mc.AlphaHolder.LeftOne.width / 2 - this.TabHeader_mc.AlphaHolder.LeftTwo.width / 2 - TAB_SPACING;
               _loc2_ = this.m_CurrTabIndex < _loc1_.length - 1 ? _loc1_[this.m_CurrTabIndex + 1] : "";
               GlobalFunc.SetText(this.m_TabTextFields[SELECTED_INDEX + 1],_loc2_,false);
               this.TabHeader_mc.AlphaHolder.RightOne.x = this.TabHeader_mc.AlphaHolder.Selected.x + this.TabHeader_mc.AlphaHolder.Selected.width / 2 + this.TabHeader_mc.AlphaHolder.RightOne.width / 2 + TAB_SPACING;
               _loc2_ = this.m_CurrTabIndex < _loc1_.length - 2 ? _loc1_[this.m_CurrTabIndex + 2] : "";
               GlobalFunc.SetText(this.m_TabTextFields[SELECTED_INDEX + 2],_loc2_,false);
               this.TabHeader_mc.AlphaHolder.RightTwo.x = this.TabHeader_mc.AlphaHolder.RightOne.x + this.TabHeader_mc.AlphaHolder.RightOne.width / 2 + this.TabHeader_mc.AlphaHolder.RightTwo.width / 2 + TAB_SPACING;
               this.TabHeader_mc.visible = !SHOW_ALL_TABS;
            }
            else
            {
               this.TabHeader_mc.visible = false;
            }
            if(this.m_PrevTabIndex != uint.MAX_VALUE)
            {
               if(this.m_PrevTabIndex < this.m_CurrTabIndex)
               {
                  this.TabHeader_mc.gotoAndPlay("prevPage");
               }
               else if(this.m_PrevTabIndex > this.m_CurrTabIndex)
               {
                  this.TabHeader_mc.gotoAndPlay("nextPage");
               }
            }
         }
      }
   }
}

