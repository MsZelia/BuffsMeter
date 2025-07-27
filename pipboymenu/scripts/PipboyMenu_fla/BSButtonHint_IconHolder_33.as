package PipboyMenu_fla
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol11")]
   public dynamic class BSButtonHint_IconHolder_33 extends MovieClip
   {
      
      public var IconAnimInstance:MovieClip;
      
      public function BSButtonHint_IconHolder_33()
      {
         super();
         addFrameScript(0,this.frame1,30,this.frame31);
      }
      
      internal function frame1() : *
      {
         stop();
      }
      
      internal function frame31() : *
      {
         gotoAndPlay("Flashing");
      }
   }
}

