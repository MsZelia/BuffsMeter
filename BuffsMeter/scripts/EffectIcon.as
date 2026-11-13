package
{
   import Shared.GlobalFunc;
   import flash.display.*;
   import flash.filters.*;
   import flash.text.*;
   import scaleform.gfx.*;
   
   public class EffectIcon extends MovieClip
   {
      
      public var Duration_tf:TextField;
      
      public var Text_tf:TextField;
      
      public var ImageHolder:MovieClip = new MovieClip();
      
      public var Image:ImageFixture;
      
      private var loadedImageLocation:String = "";
      
      public function EffectIcon()
      {
         super();
         this.init();
      }
      
      private function get config() : Object
      {
         return BuffsMeterConfig.get();
      }
      
      private function init() : void
      {
         addChild(this.ImageHolder);
         this.Image = initImage();
         this.Text_tf = initTextfield("effect");
         this.Duration_tf = initTextfield("1h 0m");
         this.Duration_tf.y += 20;
         this.imageScale = 0.5;
      }
      
      private function initImage() : ImageFixture
      {
         var img:ImageFixture = new ImageFixture();
         img.visible = true;
         ImageHolder.addChild(img);
         return img;
      }
      
      private function initTextfield(text:String = "") : TextField
      {
         var tf:TextField = new TextField();
         tf.text = text;
         tf.x = 16;
         tf.y = 30;
         tf.width = 0;
         TextFieldEx.setTextAutoSize(tf,TextFieldEx.TEXTAUTOSZ_SHRINK);
         tf.autoSize = "center";
         tf.wordWrap = false;
         tf.multiline = false;
         var textFormat:TextFormat = new TextFormat("$MAIN_Font",18,GlobalFunc.COLOR_TEXT_HEADER);
         textFormat.align = "center";
         tf.defaultTextFormat = textFormat;
         tf.setTextFormat(textFormat);
         tf.filters = [new DropShadowFilter(2,45,0,1,1,1,1,BitmapFilterQuality.HIGH)];
         tf.visible = true;
         addChild(tf);
         return tf;
      }
      
      private function getImageLocation(imageName:String) : String
      {
         return "Textures/BuffsMeter/" + imageName + ".dds";
      }
      
      public function set imageScale(value:Number) : void
      {
         this.ImageHolder.scaleX = value;
         this.ImageHolder.scaleY = value;
      }
      
      public function setImage(imageName:String) : void
      {
         if(this.loadedImageLocation == imageName)
         {
            return;
         }
         this.loadedImageLocation = imageName;
         this.Image.LoadExternal(this.getImageLocation(imageName),GlobalFunc.STORE_IMAGE_TEXTURE_BUFFER);
      }
      
      public function setData(text:String, duration:String, textColor:uint, durationColor:uint) : void
      {
         this.Text_tf.text = text;
         this.Duration_tf.text = duration;
         this.Text_tf.textColor = textColor;
         this.Duration_tf.textColor = durationColor;
      }
      
      public function applyConfig() : void
      {
         applyTextfieldConfig(this.Duration_tf,config.iconsWidget.duration);
         applyTextfieldConfig(this.Text_tf,config.iconsWidget.text);
      }
      
      private function applyTextfieldConfig(tf:TextField, cnf:Object) : void
      {
         tf.y = cnf.y;
         tf.x = 16 + cnf.x;
         tf.width = 0;
         tf.autoSize = cnf.align;
         var format:TextFormat = new TextFormat();
         format.align = cnf.align;
         format.size = cnf.size;
         format.font = cnf.font;
         tf.defaultTextFormat = format;
         tf.setTextFormat(format);
      }
   }
}

