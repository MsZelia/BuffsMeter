package
{
   import Shared.GlobalFunc;
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol50")]
   public class BB_DMGDRWidget extends MovieClip
   {
      
      public static const NUM_ICON_FRAMES:uint = 13;
      
      public var Icon_mc:MovieClip;
      
      private const ENTRY_SPACING:uint = 10;
      
      private const MAX_WIDTH:Number = 365;
      
      private const SMALLER_SCALE:Number = 0.88;
      
      public function BB_DMGDRWidget()
      {
         super();
         this.Icon_mc.scaleX = 0.85;
         this.Icon_mc.scaleY = 0.85;
      }
      
      public function redraw(param1:Boolean, param2:Array) : *
      {
         var _loc4_:BB_DMGDRWidget_Entry = null;
         var _loc5_:Vector.<BB_DMGDRWidget_Entry> = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:Number = NaN;
         while(this.numChildren > 1)
         {
            this.removeChildAt(this.numChildren - 1);
         }
         this.Icon_mc.gotoAndStop(param1 ? "Weapon" : "Armor");
         var _loc3_:Number = 0;
         if(!param2 || param2.length == 0)
         {
            _loc4_ = new BB_DMGDRWidget_Entry();
            _loc3_ = this.AddEntry(_loc4_,param1,{
               "type":1,
               "value":0
            },_loc3_);
         }
         else
         {
            _loc5_ = new Vector.<BB_DMGDRWidget_Entry>();
            _loc6_ = int(param2.length - 1);
            while(_loc6_ >= 0)
            {
               if(param2[_loc6_].value > 0)
               {
                  _loc4_ = new BB_DMGDRWidget_Entry();
                  _loc3_ = this.AddEntry(_loc4_,param1,param2[_loc6_],_loc3_);
                  _loc5_.push(_loc4_);
               }
               _loc6_--;
            }
            _loc6_ = 0;
            this.Icon_mc.x = 0;
            while(width > this.MAX_WIDTH && _loc6_ < _loc5_.length)
            {
               if(_loc6_ > 0)
               {
                  _loc3_ = _loc5_[_loc6_].x;
                  _loc5_[_loc6_].x = _loc5_[_loc6_ - 1].x;
                  _loc5_[_loc6_].visible = false;
               }
               else
               {
                  _loc3_ = _loc5_[_loc6_].x;
                  _loc5_[_loc6_].truncate();
                  _loc5_[_loc6_].x = _loc3_;
                  _loc8_ = _loc5_[_loc6_].leftX;
                  _loc3_ += _loc8_ - this.ENTRY_SPACING;
               }
               _loc7_ = _loc6_ + 1;
               while(_loc7_ < _loc5_.length)
               {
                  _loc5_[_loc7_].x = _loc3_;
                  _loc3_ += _loc5_[_loc7_].leftX - this.ENTRY_SPACING;
                  _loc7_++;
               }
               _loc6_++;
            }
            this.Icon_mc.x = _loc3_ - this.ENTRY_SPACING * 2;
         }
      }
      
      private function AddEntry(param1:BB_DMGDRWidget_Entry, param2:Boolean, param3:Object, param4:Number) : Number
      {
         if(param3.type + GlobalFunc.NUM_DAMAGE_TYPES <= NUM_ICON_FRAMES)
         {
            param1.redraw(param2,param3.type,param3.value);
            this.addChild(param1);
            param1.x = param4;
            return param4 + param1.leftX - this.ENTRY_SPACING;
         }
         return param4;
      }
   }
}

