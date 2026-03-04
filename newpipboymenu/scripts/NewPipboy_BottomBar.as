package
{
   import Shared.AS3.SecureTradeShared;
   import Shared.EnumHelper;
   import Shared.GlobalFunc;
   import flash.display.MovieClip;
   import scaleform.gfx.Extensions;
   import scaleform.gfx.TextFieldEx;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol71")]
   public class NewPipboy_BottomBar extends MovieClip
   {
      
      public var Info_mc:MovieClip;
      
      private const NEW_TAB:uint = EnumHelper.GetEnum(1);
      
      private const WEAPONS_TAB:uint = EnumHelper.GetEnum();
      
      private const ARMOR_TAB:uint = EnumHelper.GetEnum();
      
      private const APPAREL_TAB:uint = EnumHelper.GetEnum();
      
      private const FOODWATER_TAB:uint = EnumHelper.GetEnum();
      
      private const AID_TAB:uint = EnumHelper.GetEnum();
      
      private var m_MaxDisplayCaps:uint = 4294967295;
      
      private var m_MaxDisplayText:String = "";
      
      private var m_CurrentPageData:Object;
      
      private var m_CurrentPageIndex:uint = 0;
      
      public function NewPipboy_BottomBar()
      {
         super();
         Extensions.enabled = true;
      }
      
      public function SetMaxCapsInfo(param1:Object) : void
      {
         this.m_MaxDisplayCaps = 0;
         var _loc2_:uint = 0;
         while(_loc2_ < param1.currencies.length)
         {
            if(param1.currencies[_loc2_].currencyType == SecureTradeShared.CURRENCY_CAPS)
            {
               this.m_MaxDisplayCaps = param1.currencies[_loc2_].currencyMax;
               break;
            }
            _loc2_++;
         }
         this.m_MaxDisplayText = this.m_MaxDisplayCaps + " ($MAX)";
      }
      
      public function SetInfo(param1:uint, param2:uint, param3:Object) : void
      {
         if(param3)
         {
            this.m_CurrentPageData = param3;
            this.m_CurrentPageIndex = param1;
            switch(param1)
            {
               case NewPipBoyShared.STATS_PAGE:
                  this.SetStatsPageDisplay();
                  break;
               case NewPipBoyShared.INV_PAGE:
                  this.SetInvPageDisplay(param2);
                  break;
               case NewPipBoyShared.DATA_PAGE:
               case NewPipBoyShared.RADIO_PAGE:
                  this.SetDataRadioPageDisplay();
                  break;
               default:
                  this.Info_mc.gotoAndStop("None");
            }
         }
      }
      
      private function SetStatsPageDisplay() : void
      {
         this.Info_mc.gotoAndStop("StatsPage");
         TextFieldEx.setTextAutoSize(this.Info_mc.HP_tf,TextFieldEx.TEXTAUTOSZ_SHRINK);
         TextFieldEx.setTextAutoSize(this.Info_mc.LVL_tf,TextFieldEx.TEXTAUTOSZ_SHRINK);
         TextFieldEx.setTextAutoSize(this.Info_mc.AP_tf,TextFieldEx.TEXTAUTOSZ_SHRINK);
         GlobalFunc.SetText(this.Info_mc.HP_tf,"$HP",false);
         GlobalFunc.SetText(this.Info_mc.HP_tf,this.Info_mc.HP_tf.text + "  " + Math.max(1,Math.floor(this.m_CurrentPageData.CurrentHP)) + "/" + Math.floor(this.m_CurrentPageData.MaxHP),false);
         if(this.m_CurrentPageData.ShowXPInfo)
         {
            GlobalFunc.SetText(this.Info_mc.LVL_tf,"$LEVEL",false);
            GlobalFunc.SetText(this.Info_mc.LVL_tf,this.Info_mc.LVL_tf.text + " " + this.m_CurrentPageData.PlayerLevel,false);
            this.Info_mc.XPMeter_mc.SetMeter(this.m_CurrentPageData.XPPercent * 100,0,100);
         }
         this.Info_mc.LVL_tf.visible = this.m_CurrentPageData.ShowXPInfo;
         this.Info_mc.XPMeter_mc.visible = this.m_CurrentPageData.ShowXPInfo;
         GlobalFunc.SetText(this.Info_mc.AP_tf,"$AP",false);
         if(this.m_CurrentPageData.MaxAP <= 0)
         {
            GlobalFunc.SetText(this.Info_mc.AP_tf,this.Info_mc.AP_tf.text + "  --/--",false);
         }
         else
         {
            GlobalFunc.SetText(this.Info_mc.AP_tf,this.Info_mc.AP_tf.text + "  " + Math.floor(this.m_CurrentPageData.CurrentAP) + "/" + Math.floor(this.m_CurrentPageData.MaxAP),false);
         }
      }
      
      private function SetInvPageDisplay(param1:uint) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc4_:Number = NaN;
         switch(param1)
         {
            case this.WEAPONS_TAB:
               this.Info_mc.gotoAndStop("InvPage_Weapons");
               _loc2_ = this.m_CurrentPageData.DamageTypes;
               this.Info_mc.DMGDRWidget_mc.redraw(true,[_loc2_.Physical,_loc2_.Poison,_loc2_.Fire,_loc2_.Energy,_loc2_.Frost,_loc2_.Rad,_loc2_.Bleed]);
               break;
            case this.ARMOR_TAB:
            case this.APPAREL_TAB:
               this.Info_mc.gotoAndStop("InvPage_Apparel");
               _loc3_ = this.m_CurrentPageData.ResistTypes;
               this.Info_mc.DMGDRWidget_mc.redraw(false,[_loc3_.Physical,_loc3_.Poison,_loc3_.Fire,_loc3_.Energy,_loc3_.Frost,_loc3_.Rad,_loc3_.Bleed]);
               break;
            case this.FOODWATER_TAB:
            case this.AID_TAB:
               this.Info_mc.gotoAndStop("InvPage_Aid");
               _loc4_ = Number(this.m_CurrentPageData.CurrentHP);
               if(this.m_CurrentPageData.CurrentHPGain > 0)
               {
                  _loc4_ += this.m_CurrentPageData.MaxHP * this.m_CurrentPageData.CurrentHPGain;
               }
               if(this.m_CurrentPageData.SelectedItemHPGain > 0)
               {
                  _loc4_ += this.m_CurrentPageData.MaxHP * this.m_CurrentPageData.SelectedItemHPGain;
               }
               if(this.m_CurrentPageData.CurrentHPGain == 0 && this.m_CurrentPageData.SelectedItemHPGain == 0)
               {
                  _loc4_ = 0;
               }
               this.Info_mc.HPMeter.SetMeter(this.m_CurrentPageData.CurrentHP,Math.min(_loc4_,this.m_CurrentPageData.MaxHP),this.m_CurrentPageData.MaxHP);
               break;
            default:
               this.Info_mc.gotoAndStop("InvPage_Misc");
         }
         TextFieldEx.setTextAutoSize(this.Info_mc.Weight_tf,TextFieldEx.TEXTAUTOSZ_SHRINK);
         TextFieldEx.setTextAutoSize(this.Info_mc.Caps_tf,TextFieldEx.TEXTAUTOSZ_SHRINK);
         if(this.m_CurrentPageData.CurrentWeight >= this.m_CurrentPageData.AbsoluteWeightLimit)
         {
            this.Info_mc.Weight_tf.text = "$AbsoluteWeightLimitDisplay";
            GlobalFunc.SetText(this.Info_mc.Weight_tf,this.Info_mc.Weight_tf.text.replace("{weight}",Math.floor(this.m_CurrentPageData.CurrentWeight).toString()));
         }
         else
         {
            GlobalFunc.SetText(this.Info_mc.Weight_tf,Math.floor(this.m_CurrentPageData.CurrentWeight) + "/" + Math.floor(this.m_CurrentPageData.MaxWeight),false);
         }
         if(this.m_CurrentPageData.CapsCount >= this.m_MaxDisplayCaps)
         {
            GlobalFunc.SetText(this.Info_mc.Caps_tf,this.m_MaxDisplayText,false);
         }
         else
         {
            GlobalFunc.SetText(this.Info_mc.Caps_tf,this.m_CurrentPageData.CapsCount,false);
         }
      }
      
      private function SetDataRadioPageDisplay() : void
      {
         this.Info_mc.gotoAndStop("DataPage");
         GlobalFunc.SetText(this.Info_mc.Date_tf,this.m_CurrentPageData.DateMonth + "." + this.m_CurrentPageData.DateDay + "." + this.m_CurrentPageData.DateYear,false);
         var _loc1_:uint = uint(this.m_CurrentPageData.TimeHour);
         var _loc2_:uint = uint(this.m_CurrentPageData.TimeMin);
         var _loc3_:uint = _loc1_ % 12;
         if(_loc3_ == 0)
         {
            _loc3_ = 12;
         }
         GlobalFunc.SetText(this.Info_mc.Time_tf,_loc3_ + ":" + (_loc2_ < 10 ? "0" + _loc2_ : _loc2_.toString()) + " " + (_loc1_ < 12 ? "AM" : "PM"),false);
         if(this.m_CurrentPageIndex == NewPipBoyShared.RADIO_PAGE || this.m_CurrentPageIndex == NewPipBoyShared.DATA_PAGE)
         {
            GlobalFunc.SetText(this.Info_mc.Location_tf,this.m_CurrentPageData.CurrLocationName,false);
         }
         else
         {
            GlobalFunc.SetText(this.Info_mc.Location_tf," ",false);
         }
      }
   }
}

