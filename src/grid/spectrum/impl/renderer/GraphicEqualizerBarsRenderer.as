package spectrum.impl.renderer
{
	import flash.display.Shape;
	import flash.display.Sprite;
	
	import spectrum.base.renderer.SpectrumRendererBase;
	import spectrum.common.GravityDroppedAmplitudeAndTop;
	import spectrum.iface.renderer.ISpectrumRenderer;

	public class GraphicEqualizerBarsRenderer extends SpectrumRendererBase implements ISpectrumRenderer
	{
		private var barsShapeArray  :Array  = null;
		private var barWidth        :Number = 0;
		private var spaceWidth      :Number = 0;
		private var sprite          :Sprite = null;
		private var topsShapeArray  :Array  = null;
		
		// Constants.
		private var accelerationOfGravityAmplitude :Number = 0.0259;
		private var accelerationOfGravityTops      :Number = 0.007;
		
		// State.
		private var lastEqValuesArray                :Array   = null;
		private var lastEqTopsArray                  :Array   = null;
		private var gravityAccelerationValuesAmounts :Array   = null;
		private var gravityAccelerationTopsAmounts   :Array   = null;
		private var tops_height_measurement          :Number  = 0.0;
		
		// Resize with Tween.
		private var isPositiveChange:Boolean = false;
		private var newHeight       :Number  = 1.0;
		private var newWidth        :Number  = 1.0;
		private var totalHeight     :Number  = 27.0;
		private var totalWidth      :Number  = 1.0;
		private var tweenHeightDiff :Number  = 0.0;
		private var tweenWidthDiff  :Number  = 0.0;
		
		private var tweenRate:Number = 9.0;
		
		public function GraphicEqualizerBarsRenderer(sprite:Sprite, settingsObject:Object)
		{
			this.sprite = sprite;
			
			super(settingsObject);
			
			this.initializeSettingsObject(settingsObject);
		}
		
		private function initializeSettingsObject(settingsObject:Object):void
		{
			this.settingsObject = settingsObject;
			
			this.settingsObject["eqBarsColor"]         = this.settingsObject["eqBarsColor"]        ?this.settingsObject["eqBarsColor"]        :0xC3E897;
			this.settingsObject["eqTopsColor"]         = this.settingsObject["eqTopsColor"]        ?this.settingsObject["eqTopsColor"]        :0x68ecde;
			this.settingsObject["eqTopsHeightPercent"] = this.settingsObject["eqTopsHeightPercent"]?this.settingsObject["eqTopsHeightPercent"]:0.05;
		}
		
		private var scanDirectionBoolean:Boolean = false;
		
		public function render(spectrumArray:Array):void
		{	
			if( spectrumArray == null )
				return;
			
			// Tween
			if (this.totalHeight != this.newHeight)
			{
				this.tweenHeightDiff = this.newHeight - this.totalHeight;
				
				this.isPositiveChange = (this.tweenHeightDiff > 0);
				this.tweenHeightDiff = Math.abs(this.tweenHeightDiff);
				
				if (this.tweenHeightDiff > this.tweenRate)
				{
					this.tweenHeightDiff = this.tweenRate;
				}
				
				this.totalHeight = this.isPositiveChange ? (this.totalHeight+this.tweenHeightDiff) : (this.totalHeight-this.tweenHeightDiff);
			}
			if (this.totalWidth != this.newWidth)
			{
				this.tweenWidthDiff = this.newWidth - this.totalWidth;
				
				this.isPositiveChange = (this.tweenWidthDiff > 0);
				this.tweenWidthDiff = Math.abs(this.tweenWidthDiff);
				
				if (this.tweenWidthDiff > this.tweenRate)
				{
					this.tweenWidthDiff = this.tweenRate;
				}
				
				this.totalWidth = this.isPositiveChange ? (this.totalWidth+this.tweenWidthDiff) : (this.totalWidth-this.tweenWidthDiff);
			}

			if( this.barsShapeArray == null )
			{
				this.barsShapeArray = new Array(spectrumArray.length);
			}
			if( this.topsShapeArray == null )
			{
				this.topsShapeArray = new Array(spectrumArray.length);
			}
			
			
			
			this.barWidth   = (this.totalWidth*0.6)/spectrumArray.length;
			this.spaceWidth = (this.totalWidth*0.4)/(spectrumArray.length+1);
			
			var i:int = 0;
			var gravityDroppedAmplitudeAndTop:GravityDroppedAmplitudeAndTop = null;
			
			if (this.scanDirectionBoolean)
			{
				for (i=0; i<spectrumArray.length; ++i)
				{	
					if( barsShapeArray[i] == null )
					{
						barsShapeArray[i] = new Shape();
						barsShapeArray[i].alpha = .5;
						this.sprite.addChild(barsShapeArray[i]);
					}
					if( this.topsShapeArray[i] == null )
					{
						topsShapeArray[i] = new Shape();
						topsShapeArray[i].alpha = .5;
						this.sprite.addChild(topsShapeArray[i]);
					}
					
					gravityDroppedAmplitudeAndTop = this.gravityDropSpectrumAmplitudeAndTop (spectrumArray, i);
					
					barsShapeArray[i].x = (i+1)*this.spaceWidth + i*this.barWidth;
					barsShapeArray[i].y = 0;
					
					barsShapeArray[i].graphics.clear();
					barsShapeArray[i].graphics.beginFill(this.settingsObject["eqBarsColor"]);
					barsShapeArray[i].graphics.drawRect(0,this.newHeight,this.barWidth,(-1*(this.totalHeight)*gravityDroppedAmplitudeAndTop.amplitude));
					barsShapeArray[i].graphics.endFill();
					
					topsShapeArray[i].x = (i+1)*this.spaceWidth + i*this.barWidth;
					topsShapeArray[i].y = this.newHeight-(this.newHeight*gravityDroppedAmplitudeAndTop.top);
					
					topsShapeArray[i].graphics.clear();
					topsShapeArray[i].graphics.beginFill(this.settingsObject["eqTopsColor"]);
					topsShapeArray[i].graphics.drawRect(0,0,this.barWidth,Math.min(this.tops_height_measurement,this.newHeight-topsShapeArray[i].y));
					topsShapeArray[i].graphics.endFill();
				}
				
				this.scanDirectionBoolean = false;
			}
			else
			{
				for (i=spectrumArray.length-1; i>=0; --i)
				{	
					if( barsShapeArray[i] == null )
					{
						barsShapeArray[i] = new Shape();
						barsShapeArray[i].alpha = .5;
						this.sprite.addChild(barsShapeArray[i]);
					}
					if( this.topsShapeArray[i] == null )
					{
						topsShapeArray[i] = new Shape();
						topsShapeArray[i].alpha = .5;
						this.sprite.addChild(topsShapeArray[i]);
					}
					
					gravityDroppedAmplitudeAndTop = this.gravityDropSpectrumAmplitudeAndTop (spectrumArray, i);
					
					barsShapeArray[i].x = (i+1)*this.spaceWidth + i*this.barWidth;
					barsShapeArray[i].y = 0;
					
					barsShapeArray[i].graphics.clear();
					barsShapeArray[i].graphics.beginFill(this.settingsObject["eqBarsColor"]);
					barsShapeArray[i].graphics.drawRect(0,this.newHeight,this.barWidth,(-1*(this.totalHeight)*gravityDroppedAmplitudeAndTop.amplitude));
					barsShapeArray[i].graphics.endFill();
					
					topsShapeArray[i].x = (i+1)*this.spaceWidth + i*this.barWidth;
					topsShapeArray[i].y = this.newHeight-(this.newHeight*gravityDroppedAmplitudeAndTop.top);
					
					topsShapeArray[i].graphics.clear();
					topsShapeArray[i].graphics.beginFill(this.settingsObject["eqTopsColor"]);
					topsShapeArray[i].graphics.drawRect(0,0,this.barWidth,Math.min(this.tops_height_measurement,this.newHeight-topsShapeArray[i].y));
					topsShapeArray[i].graphics.endFill();
				}
				
				this.scanDirectionBoolean = true;
			}
		}
		
		public function resize (newWidth:Number, newHeight:Number):void
		{
			this.newWidth  = newWidth;
			this.newHeight = newHeight;
			
			this.tops_height_measurement = newHeight * this.settingsObject["eqTopsHeightPercent"];
		}
		
		private function gravityDropSpectrumAmplitudeAndTop (spectrumArray:Array, spectrumIndex:int):GravityDroppedAmplitudeAndTop
		{
			var currentAmplitude:Number = spectrumArray[spectrumIndex];
			
			if (this.lastEqValuesArray == null)
				this.lastEqValuesArray = spectrumArray.concat();
			
			if (this.lastEqTopsArray == null)
				this.lastEqTopsArray = spectrumArray.concat();
			
			var previousAmplitude:Number = this.lastEqValuesArray[spectrumIndex];
			var previousTop      :Number = this.lastEqTopsArray  [spectrumIndex];
			
			if (this.gravityAccelerationValuesAmounts == null)
				this.zeroGravityAccelerationValues(spectrumArray);
			
			if (this.gravityAccelerationTopsAmounts == null)
				this.zeroGravityAccelerationTops(spectrumArray);
			
			var gravityDroppedAmplitudeAndTop:GravityDroppedAmplitudeAndTop = new GravityDroppedAmplitudeAndTop(currentAmplitude,currentAmplitude);
			
			if (currentAmplitude >= previousAmplitude)
				this.gravityAccelerationValuesAmounts[spectrumIndex] = 0;
			
			if (currentAmplitude >= previousTop)
				this.gravityAccelerationTopsAmounts[spectrumIndex] = 0;
			
			++this.gravityAccelerationValuesAmounts[spectrumIndex];
			++this.gravityAccelerationTopsAmounts  [spectrumIndex];
			
			gravityDroppedAmplitudeAndTop.amplitude = Math.max(currentAmplitude, (previousAmplitude-(this.accelerationOfGravityAmplitude*this.gravityAccelerationValuesAmounts[spectrumIndex])));
			gravityDroppedAmplitudeAndTop.top       = Math.max(currentAmplitude, (previousTop      -(this.accelerationOfGravityTops     *this.gravityAccelerationTopsAmounts  [spectrumIndex])));
			
			this.lastEqValuesArray[spectrumIndex] = gravityDroppedAmplitudeAndTop.amplitude;
			this.lastEqTopsArray  [spectrumIndex] = gravityDroppedAmplitudeAndTop.top;
			
			return gravityDroppedAmplitudeAndTop;
		}
		
		private function zeroGravityAccelerationValues (spectrumArray:Array):void
		{
			if (this.gravityAccelerationValuesAmounts == null)
				this.gravityAccelerationValuesAmounts = new Array(spectrumArray.length);
			
			for (var i:int=0; i<this.gravityAccelerationValuesAmounts.length; ++i)
			{
				this.gravityAccelerationValuesAmounts[i] = 0;
			}
		}
		
		private function zeroGravityAccelerationTops (spectrumArray:Array):void
		{
			if (this.gravityAccelerationTopsAmounts == null)
				this.gravityAccelerationTopsAmounts = new Array(spectrumArray.length);
			
			for (var i:int=0; i<this.gravityAccelerationTopsAmounts.length; ++i)
			{
				this.gravityAccelerationTopsAmounts[i] = 0;
			}
		}
	}
}