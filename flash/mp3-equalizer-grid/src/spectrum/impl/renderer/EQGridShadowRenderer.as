package spectrum.impl.renderer
{
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Loader;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.net.URLRequest;
	
	import spectrum.base.renderer.SpectrumRendererBase;
	import spectrum.common.GravityDroppedAmplitudeAndTop;
	import spectrum.iface.renderer.ISpectrumRenderer;

	public class EQGridShadowRenderer extends SpectrumRendererBase implements ISpectrumRenderer
	{	
		// Measurements.
		private var eq_measurement_height     :Number = 0.0;
		private var eq_measurement_leftOffset :Number = 0.0;
		private var eq_measurement_topOffset  :Number = 0.0;
		private var eq_measurement_width      :Number = 0.0;
		
		private var shadow_measurement_maxHeight :Number = 0.0;
		private var shadow_measurement_maxWidth  :Number = 0.0;
		
		private var all_measurement_centerY   : Number = 0.0;
		private var all_measurement_centerX   : Number = 0.0;
		private var all_measurement_height    : Number = 0.0;
		private var all_measurement_width     : Number = 0.0;
				
		// Settings.
		private var accelerationOfGravityAmplitude :Number = 0.0319;
		private var accelerationOfGravityTops      :Number = 0.005;
		private var eqColorsArray                  :Array  = null;
		private var eqGridNumColumns               :uint   = 16; 
		
		// Gradient Setup - Background.
		private var fillType     :String = GradientType.LINEAR;
		private var matrix       :Matrix = new Matrix();
		private var spreadMethod:String = SpreadMethod.REFLECT;
		
		// Visualization Shapes.
		/*Visualization Container */
		private var vizualizationContainer :Sprite = new Sprite();
		/*background*/
		private var background          :Shape = new Shape();
		/* Logo */
		private var logo:Bitmap               = null;
		private var logoOriginalWidth :Number = 0.0;
		private var logoOriginalHeight:Number = 0.0;
		
		/*main EQ*/
		private var mainEqContainer     :Sprite = new Sprite();
		private var mainEqShapeArray    :Array = null;
		private var mainEqTopShapesArray:Array = null;
		/*shadow EQ*/
		private var shadowEqContainer     :Sprite = new Sprite();
		private var shadowEqShapeArray    :Array  = null;
		private var shadowEqTopShapesArray:Array = null;
		private var shadowThetaDegrees    :Number = 125.0;
		private var shadowThetaRadians    :Number = 125.0 / 180.0 * Math.PI;
		private var shadowFocalLen        :Number = 0.0;
		
		// State
		private var hasResizedOnce                   :Boolean = false;
		private var rotationActualX                  :Number  = 0.0;
		private var rotationActualY                  :Number  = 0.0;
		private var rotationTargetX                  :Number  = 0.0;
		private var rotationTargetY                  :Number  = 0.0;
		private var previousTotalHeight              :Number  = 0.0; 
		private var previousTotalWidth               :Number  = 0.0;
		private var isResizeing                      :Boolean = true;
		private var lastEqValuesArray                :Array   = null;
		private var lastEqTopsArray                  :Array   = null;
		private var gravityAccelerationValuesAmounts :Array   = null;
		private var gravityAccelerationTopsAmounts   :Array   = null;
		private var shouldRenderEqChange             :Boolean = true;
		
		// Constructor.
		public function EQGridShadowRenderer(settingsObject:Object)
		{
			super(settingsObject);
			
			this.initializeWithSettings(settingsObject);

			this.addChild(this.background);
			this.addChild(this.vizualizationContainer);
			this.vizualizationContainer.addChild(this.mainEqContainer);
			this.vizualizationContainer.addChild(this.shadowEqContainer);
			
			this.addEventListener(MouseEvent.MOUSE_MOVE, this.reactToMouseLocation);
		}
		
		// Methods.
		
		private function initializeWithSettings(settingsObject:Object):void
		{
			// Init the settings object with Defauts or overrides.
			this.settingsObject["backgroundGridAlpha"]      = this.settingsObject["backgroundGridAlpha"]     ?this.settingsObject["backgroundGridAlpha"]     :0.9;
			this.settingsObject["backgroundGridColor"]      = this.settingsObject["backgroundGridColor"]     ?this.settingsObject["backgroundGridColor"]     :0x000000;
			
			this.settingsObject["eqBlockCornerRadii"] = (this.settingsObject["eqBlockCornerRadii"]) ?this.settingsObject["eqBlockCornerRadii"]  : 8.0;

			this.settingsObject["eqPercentHeight"] = (this.settingsObject["eqPercentHeight"]) ?this.settingsObject["eqPercentHeight"]  : 0.50;
			this.settingsObject["eqPercentWidth"]  = (this.settingsObject["eqPercentWidth"] ) ?this.settingsObject["eqPercentWidth"]   : 0.75;
			
			this.settingsObject["shadowPercentMaxHeight"] = (this.settingsObject["shadowPercentMaxHeight"]) ?this.settingsObject["shadowPercentMaxHeight"] : 0.40;
			this.settingsObject["shadowPercentMaxWidth"]  = (this.settingsObject["shadowPercentMaxWidth"] ) ?this.settingsObject["shadowPercentMaxWidth"]  : 0.95;
			
			this.settingsObject["eqPercentOfLeftoverForTopOffset"]  = (this.settingsObject["eqPercentOfLeftoverForTopOffset"] ) ?this.settingsObject["eqPercentOfLeftoverForTopOffset"]  : 0.50;
			
			this.settingsObject["eqBackgroundAlphasArray"] = this.commaSeparatedStringToNumberArray(this.settingsObject["eqBackgroundAlphasArray"]); 
			this.settingsObject["eqBackgroundColorsArray"] = this.commaSeparatedStringToNumberArray(this.settingsObject["eqBackgroundColorsArray"]); 
			this.settingsObject["eqBackgroundRatiosArray"] = this.commaSeparatedStringToNumberArray(this.settingsObject["eqBackgroundRatiosArray"]); 
			
			this.settingsObject["eqBackgroundAlphasArray"] = (this.settingsObject["eqBackgroundAlphasArray"] && this.settingsObject["eqBackgroundAlphasArray"].length>1) ?this.settingsObject["eqBackgroundAlphasArray"] : [1.0, 1.0];
			this.settingsObject["eqBackgroundColorsArray"] = (this.settingsObject["eqBackgroundColorsArray"] && this.settingsObject["eqBackgroundColorsArray"].length>1) ?this.settingsObject["eqBackgroundColorsArray"] : [0x000000, 0x000000];	
			this.settingsObject["eqBackgroundRatiosArray"] = (this.settingsObject["eqBackgroundRatiosArray"] && this.settingsObject["eqBackgroundRatiosArray"].length>1) ?this.settingsObject["eqBackgroundRatiosArray"] : [0, 127];	
			
			this.settingsObject["eqBackgroundCornerRadii"] = this.settingsObject["eqBackgroundCornerRadii"] ?this.settingsObject["eqBackgroundCornerRadii"] :8.0;

			this.settingsObject["eqGridTopsColor"]     = this.settingsObject["eqGridTopsColor"]     ? this.settingsObject["eqGridTopsColor"]     : 0xAC2975;
			this.settingsObject["eqGridTopsGlowColor"] = this.settingsObject["eqGridTopsGlowColor"] ? this.settingsObject["eqGridTopsGlowColor"] : 0xAC2975;
			
			this.settingsObject["eqGridColorArray"] = this.commaSeparatedStringToNumberArray(this.settingsObject["eqGridColorArray"]); 
			this.settingsObject["eqGridColorArray"] = (this.settingsObject["eqGridColorArray"] && this.settingsObject["eqGridColorArray"].length>1) ?this.settingsObject["eqGridColorArray"] 
				:[0xFF6600,0xF77500,0xF07D00,0xEC8400,0xE78C00,0xE29400,0xDD9B00,0xD7A200,0xD4AA00,0xC2A106,0xAE9709,0x99900D,0x888512,0x888416,0x61741B,0x61741B,0x4F6B20,0x3C6324,0x295929,0x17502D];	
			
			this.settingsObject["logoImageAlpha"]    = this.settingsObject["logoImageAlpha"]    ? this.settingsObject["logoImageAlpha"]    : 0.7;
			this.settingsObject["logoImageLocation"] = this.settingsObject["logoImageLocation"] ? this.settingsObject["logoImageLocation"] : "http://207.38.199.219:8080/kali-ma-web/images/logos/kalima-logo-black-glow-blue.png";
			
			this.settingsObject["percentSpaceHeight"]       = this.settingsObject["percentSpaceHeight"]      ?this.settingsObject["percentSpaceHeight"]      :0.1;
			this.settingsObject["percentSpaceWidth"]        = this.settingsObject["percentSpaceWidth"]       ?this.settingsObject["percentSpaceWidth"]       :0.1;
		
			// Load the logo.
			this.loadLogoBitmap();
			
			// Use the settings to set up other things.
			this.eqColorsArray = this.settingsObject["eqGridColorArray"];
			
			// EQ Shape array init.
			this.mainEqShapeArray       = new Array(this.eqGridNumColumns);
			this.shadowEqShapeArray     = new Array(this.eqGridNumColumns);
			this.mainEqTopShapesArray   = new Array(this.eqGridNumColumns);
			this.shadowEqTopShapesArray = new Array(this.eqGridNumColumns);

			for( var i:int=0; i<this.eqGridNumColumns; ++i )
			{
				for( var j:int=0; j<this.eqColorsArray.length; ++j )
				{
					if( j == 0 )
					{
						this.mainEqTopShapesArray[i]   = new Array(this.eqColorsArray.length);
						this.shadowEqTopShapesArray[i] = new Array(this.eqColorsArray.length);
						
						this.mainEqShapeArray[i]   = new Array(this.eqColorsArray.length);
						this.shadowEqShapeArray[i] = new Array(this.eqColorsArray.length);
					}
					
					var mainGridTopItem :Shape = new Shape();
					this.mainEqTopShapesArray[i][j] = mainGridTopItem;
					this.mainEqContainer.addChild(mainGridTopItem);
					
					var shadowGridTopItem :Shape = new Shape();
					this.shadowEqTopShapesArray[i][j] = shadowGridTopItem;
					this.shadowEqContainer.addChild(shadowGridTopItem);
					
					var mainGridItem :Shape = new Shape();
					this.mainEqShapeArray[i][j] = mainGridItem;
					this.mainEqContainer.addChild(mainGridItem);
					
					var shadowGridItem :Shape = new Shape();
					this.shadowEqShapeArray[i][j] = shadowGridItem;
					this.shadowEqContainer.addChild(shadowGridItem);
				}
			}
			
		}
		
		public function resize (newWidth:Number, newHeight:Number):void
		{
			this.isResizeing = true;
			
			this.resize_measurements(newWidth, newHeight);
			
			this.resize_eq(newWidth, newHeight);
			
			this.isResizeing = false;
			
			this.hasResizedOnce = true;
		}
		
		private function resize_measurements(newWidth:Number, newHeight:Number):void
		{
			this.all_measurement_width  = newWidth;
			this.all_measurement_height = newHeight;
			
			this.eq_measurement_height     = newHeight*this.settingsObject["eqPercentHeight"];
			this.eq_measurement_width      = newWidth*this.settingsObject["eqPercentWidth"];
			this.eq_measurement_leftOffset = ((newWidth-this.eq_measurement_width) / 2.0);
			
			this.shadow_measurement_maxHeight = newHeight*this.settingsObject["shadowPercentMaxHeight"];
			this.shadow_measurement_maxWidth  = newWidth*this.settingsObject["shadowPercentMaxWidth"];
			
			this.eq_measurement_topOffset = (newHeight-(this.eq_measurement_height+this.shadow_measurement_maxHeight)) * this.settingsObject["eqPercentOfLeftoverForTopOffset"];
			
			this.all_measurement_centerX = newWidth / 2.0;
			this.all_measurement_centerY = this.eq_measurement_topOffset + this.eq_measurement_height;
			
			var z :Number = eq_measurement_height*Math.sin(Math.PI-this.shadowThetaRadians);
			var v :Number = this.eq_measurement_height*Math.cos(Math.PI-this.shadowThetaRadians);
			
			var flenShadowHeight:Number = (z*this.shadow_measurement_maxHeight)/(this.shadow_measurement_maxHeight-v);
			
			var flenShadowWidth:Number = z/(1-((this.eq_measurement_width/2.0)/(this.shadow_measurement_maxWidth/2.0)));
			
			this.shadowFocalLen = Math.max(flenShadowHeight, flenShadowWidth);
		}
		
		private function resize_eq(newWidth:Number, newHeight:Number):void
		{
			this.vizualizationContainer.transform.perspectiveProjection = new PerspectiveProjection();
			this.vizualizationContainer.transform.perspectiveProjection.projectionCenter = new Point(this.all_measurement_centerX, this.all_measurement_centerY); 
			this.vizualizationContainer.transform.perspectiveProjection.focalLength = this.shadowFocalLen;
			
			// Position the Logo
			this.resizeLogoMaintainAspectMaximizeInBoundingBox();
			
			// Make the background gradient.
			this.matrix.createGradientBox(newWidth, newHeight, Math.PI / 2.0, 0, 0);
			this.background.graphics.clear();
			this.background.graphics.beginGradientFill(fillType
													  ,this.settingsObject["eqBackgroundColorsArray"]
													  ,this.settingsObject["eqBackgroundAlphasArray"]
													  ,this.settingsObject["eqBackgroundRatiosArray"], matrix, spreadMethod);
			
			this.background.graphics.drawRoundRect(0,0,newWidth,newHeight,this.settingsObject["eqBackgroundCornerRadii"]);
			this.background.graphics.endFill();
			
			// Set up the EQ containers.
			/* Main Grid */
			this.mainEqContainer.graphics.clear();
			this.mainEqContainer.x = this.eq_measurement_leftOffset
			this.mainEqContainer.y = this.eq_measurement_topOffset;
			this.mainEqContainer.z = 0.0;
			/* Shadow Grid */
			this.shadowEqContainer.graphics.clear();
			this.shadowEqContainer.transform.matrix3D = new Matrix3D();
			this.shadowEqContainer.filters = [new BlurFilter(8.0,8.0)];
			this.shadowEqContainer.alpha = .31;
			this.shadowEqContainer.x = this.eq_measurement_leftOffset
			this.shadowEqContainer.y = this.eq_measurement_topOffset;
			this.shadowEqContainer.z = 0.0; // Workaround.
			this.shadowEqContainer.transform.matrix3D.appendRotation(this.shadowThetaDegrees, Vector3D.X_AXIS, new Vector3D(this.all_measurement_centerX,this.all_measurement_centerY,0.0));
			this.shadowEqContainer.transform.perspectiveProjection = new PerspectiveProjection();
			this.shadowEqContainer.transform.perspectiveProjection.projectionCenter = new Point(this.all_measurement_centerX, this.all_measurement_centerY); 
			this.shadowEqContainer.transform.perspectiveProjection.focalLength = this.shadowFocalLen;
			
			// EQ grid Item width and Height.
			var eqBarSegmentHeight :Number = this.eq_measurement_height * Number(1.0-this.settingsObject["percentSpaceHeight"]) / Number(this.eqColorsArray.length);
			var eqBarSegmentWidth  :Number = this.eq_measurement_width  * Number(1.0-this.settingsObject["percentSpaceWidth"])  / Number(this.eqGridNumColumns);
			
			// Spacer Width and Height.
			var eqSpaceSegmentHeight :Number = this.eq_measurement_height * Number(this.settingsObject["percentSpaceHeight"]) / Number(this.eqColorsArray.length);
			var eqSpaceSegmentWidth  :Number = this.eq_measurement_width  * Number(this.settingsObject["percentSpaceWidth"])  / Number(this.eqGridNumColumns+1);
			
			// Space and EQ total Heights and Widths.
			var gridItemHeight :Number = eqBarSegmentHeight+eqSpaceSegmentHeight;
			var gridItemWidth  :Number = eqBarSegmentWidth +eqSpaceSegmentWidth;
			
			var backgroundGridColor :uint   = this.settingsObject["backgroundGridColor"];
			var backgroundGridAlpha :Number = this.settingsObject["backgroundGridAlpha"];
			
			// Tops Glow Filter
			var glowFilterArray:Array = [new GlowFilter(this.settingsObject["eqGridTopsGlowColor"],0.7,eqBarSegmentWidth/3.0,eqBarSegmentWidth/3.0)];
			
			for( var i:int=0; i<this.eqGridNumColumns; ++i )
			{
				for( var j:int=0; j<this.eqColorsArray.length; ++j )
				{
					this.mainEqContainer.graphics.beginFill(backgroundGridColor, backgroundGridAlpha);
					this.mainEqContainer.graphics.drawRoundRect((gridItemWidth*i)+eqSpaceSegmentWidth,gridItemHeight*j,eqBarSegmentWidth,eqBarSegmentHeight,this.settingsObject["eqBlockCornerRadii"]);
					this.mainEqContainer.graphics.endFill();
					
					this.shadowEqContainer.graphics.beginFill(backgroundGridColor, backgroundGridAlpha);
					this.shadowEqContainer.graphics.drawRoundRect((gridItemWidth*i)+eqSpaceSegmentWidth,gridItemHeight*j,eqBarSegmentWidth,eqBarSegmentHeight,this.settingsObject["eqBlockCornerRadii"]);
					this.shadowEqContainer.graphics.endFill();
					
					this.mainEqTopShapesArray[i][j].graphics.clear();
					this.mainEqTopShapesArray[i][j].x = (gridItemWidth*i)+eqSpaceSegmentWidth;
					this.mainEqTopShapesArray[i][j].y = gridItemHeight*j;
					this.mainEqTopShapesArray[i][j].graphics.beginFill(this.settingsObject["eqGridTopsColor"]);
					this.mainEqTopShapesArray[i][j].graphics.drawRoundRect(0,0,eqBarSegmentWidth,eqBarSegmentHeight,this.settingsObject["eqBlockCornerRadii"]);
					this.mainEqTopShapesArray[i][j].graphics.endFill();
					this.mainEqTopShapesArray[i][j].filters = glowFilterArray;
					
					this.shadowEqTopShapesArray[i][j].graphics.clear();
					this.shadowEqTopShapesArray[i][j].x = (gridItemWidth*i)+eqSpaceSegmentWidth;
					this.shadowEqTopShapesArray[i][j].y = gridItemHeight*j;
					this.shadowEqTopShapesArray[i][j].graphics.beginFill(this.settingsObject["eqGridTopsColor"]);
					this.shadowEqTopShapesArray[i][j].graphics.drawRoundRect(0,0,eqBarSegmentWidth,eqBarSegmentHeight,this.settingsObject["eqBlockCornerRadii"]);
					this.shadowEqTopShapesArray[i][j].graphics.endFill();
					this.shadowEqTopShapesArray[i][j].filters = glowFilterArray;
					
					this.mainEqShapeArray[i][j].graphics.clear();
					this.mainEqShapeArray[i][j].x = (gridItemWidth*i)+eqSpaceSegmentWidth;
					this.mainEqShapeArray[i][j].y = gridItemHeight*j;
					this.mainEqShapeArray[i][j].graphics.beginFill(this.eqColorsArray[j]);
					this.mainEqShapeArray[i][j].graphics.drawRoundRect(0,0,eqBarSegmentWidth,eqBarSegmentHeight,this.settingsObject["eqBlockCornerRadii"]);
					this.mainEqShapeArray[i][j].graphics.endFill();
					
					this.shadowEqShapeArray[i][j].graphics.clear();
					this.shadowEqShapeArray[i][j].x = (gridItemWidth*i)+eqSpaceSegmentWidth;
					this.shadowEqShapeArray[i][j].y = gridItemHeight*j;
					this.shadowEqShapeArray[i][j].graphics.beginFill(this.eqColorsArray[j]);
					this.shadowEqShapeArray[i][j].graphics.drawRoundRect(0,0,eqBarSegmentWidth,eqBarSegmentHeight,this.settingsObject["eqBlockCornerRadii"]);
					this.shadowEqShapeArray[i][j].graphics.endFill();
				}
			}
		}
		
	    private var scanDirectionBoolean:Boolean = true;
		
		public function render(spectrumArray:Array):void
		{				
			if( this.isResizeing )
			{
				return;
			}
						
			if (spectrumArray == null)
			{
				this.lastEqValuesArray = null;
				this.lastEqTopsArray   = null;
				
				return;
			}
			
			this.rotateTowardsTargetIfNeeded();
			
			var gravityDroppedAmplitudeAndTop:GravityDroppedAmplitudeAndTop = null;
			
			var i          :int = 0;
			var j          :int = 0;
			var cutoffIndex:int = 0;
			
			if (scanDirectionBoolean)
			{
				for (i=0; (i<spectrumArray.length)&&(i<this.mainEqShapeArray.length); ++i)
				{	
					gravityDroppedAmplitudeAndTop = this.gravityDropSpectrumAmplitudeAndTop(spectrumArray,i);
					
					cutoffIndex = this.computeBarCutoffIndex(this.eqColorsArray.length,gravityDroppedAmplitudeAndTop.amplitude,i);
					
					for (j=cutoffIndex+1; j<this.eqColorsArray.length; ++j)
					{
						mainEqShapeArray[i][j].visible   = true;
						shadowEqShapeArray[i][j].visible = true;
						
						mainEqTopShapesArray[i][j].visible   = false;
						shadowEqTopShapesArray[i][j].visible = false;
					}
					for (j=0; j<=cutoffIndex; ++j)
					{
						mainEqShapeArray[i][j].visible   = false;
						shadowEqShapeArray[i][j].visible = false;
						
						mainEqTopShapesArray[i][j].visible   = false;
						shadowEqTopShapesArray[i][j].visible = false;
					}
					
					cutoffIndex = this.computeBarCutoffIndex(this.eqColorsArray.length,gravityDroppedAmplitudeAndTop.top,i);
					
					mainEqTopShapesArray[i][cutoffIndex].visible   = true;
					shadowEqTopShapesArray[i][cutoffIndex].visible = true;
				}
				
				scanDirectionBoolean = false;
			}
			else
			{
				for (i=mainEqShapeArray.length-1; i >= 0; --i)
				{	
					gravityDroppedAmplitudeAndTop = this.gravityDropSpectrumAmplitudeAndTop(spectrumArray,i);
					
					cutoffIndex = this.computeBarCutoffIndex(this.eqColorsArray.length,gravityDroppedAmplitudeAndTop.amplitude,i);
					
					for (j=cutoffIndex+1; j<this.eqColorsArray.length; ++j)
					{
						mainEqShapeArray[i][j].visible   = true;
						shadowEqShapeArray[i][j].visible = true;
						
						mainEqTopShapesArray[i][j].visible   = false;
						shadowEqTopShapesArray[i][j].visible = false;
					}
					for (j=0; j<=cutoffIndex; ++j )
					{
						mainEqTopShapesArray[i][j].visible   = false;
						shadowEqTopShapesArray[i][j].visible = false;
						
						mainEqShapeArray[i][j].visible   = false;
						shadowEqShapeArray[i][j].visible = false;
					}
					
					cutoffIndex = this.computeBarCutoffIndex(this.eqColorsArray.length,gravityDroppedAmplitudeAndTop.top,i);
					
					mainEqTopShapesArray[i][cutoffIndex].visible   = true;
					shadowEqTopShapesArray[i][cutoffIndex].visible = true;
				}
				
				scanDirectionBoolean = true;
			}
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
		
		private function computeBarCutoffIndex(numBlocks:Number, freqAmplitude:Number, i:int):int
		{	
			freqAmplitude = Math.min(1.0, freqAmplitude);
			
			var cutoffIndex:int = Math.round((numBlocks-1)*freqAmplitude);
			
			return numBlocks-1-cutoffIndex; // Flip because we are upside down.
		}
		
		private function commaSeparatedStringToNumberArray (commaString:String):Array
		{
			if (commaString==null || commaString.length==0)
			{
				return new Array();
			}
			
			var numberArray:Array = commaString.split(",");
			
			for (var i:uint=0; i<numberArray.length; ++i)
			{
				numberArray[i] = Number(numberArray[i]);
			}
			
			return numberArray;
		}
		
		private function resizeLogoMaintainAspectMaximizeInBoundingBox () : void
		{	
			if (this.logo == null)
				return;
			
			var perspectiveThetaHeight:Number = Math.atan(this.all_measurement_centerY/this.shadowFocalLen);
			var perspectiveThetaWidth:Number = Math.atan(this.all_measurement_centerX/this.shadowFocalLen);

			var zHeight :Number = this.shadowFocalLen*(Math.pow(Math.sin(perspectiveThetaHeight),2.0));
			var zWidth  :Number = this.shadowFocalLen*(Math.pow(Math.sin(perspectiveThetaWidth),2.0));

			var z :Number = Math.min(zHeight, zWidth);
			
			var topLogoMin        :Number = (z*(this.all_measurement_centerY)) / this.shadowFocalLen;
			var botLogoMax        :Number = (z*(this.all_measurement_centerY - this.eq_measurement_topOffset) / this.shadowFocalLen) + this.eq_measurement_topOffset;
			var logoMaxHeight     :Number = botLogoMax - topLogoMin;
			var logoAdjustedHeight:Number = logoMaxHeight * 0.8;
			
			var logoMaxWidth     :Number = ((this.shadowFocalLen-z)*this.all_measurement_width)/this.shadowFocalLen;
			var leftLogoMin      :Number = (this.all_measurement_width-logoMaxWidth) / 2.0;
			var logoAdjustedWidth:Number = logoMaxWidth * 0.8;
			
			var boundingWidth :Number = logoAdjustedWidth;
			var boundingHeight:Number = logoAdjustedHeight;
			
			var widthRatio :Number = boundingWidth  / this.logoOriginalWidth;
			var heightRatio:Number = boundingHeight / this.logoOriginalHeight;
			
			var aspectMultiplier:Number = Math.min(widthRatio, heightRatio);
			
			var maximizedWidth :Number = this.logoOriginalWidth  * aspectMultiplier;
			var maximizedHeight:Number = this.logoOriginalHeight * aspectMultiplier;
			
			this.logo.height = maximizedHeight;
			this.logo.width  = maximizedWidth;
			
			var offsetLeft:Number = (boundingWidth  - maximizedWidth ) / 2.0;
			var offsetTop :Number = (boundingHeight - maximizedHeight) / 2.0;
			
			this.logo.x = offsetLeft + logoMaxWidth  * 0.1 + leftLogoMin;
			this.logo.y = offsetTop  + logoMaxHeight * 0.1 + topLogoMin;
			this.logo.z = -z;
		}
		
		private function loadLogoBitmap () : void
		{
			var imageLoader:Loader = new Loader();
			imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.loadLogoImageComplete);
			imageLoader.load(new URLRequest(this.settingsObject["logoImageLocation"]));
		}
	
		/*
		** Event Handlers
		*/
			
		private function loadLogoImageComplete (e:Event) : void
		{
			this.logo = new Bitmap(e.target.loader.contentLoaderInfo.content.bitmapData,PixelSnapping.NEVER,true);
			this.logoOriginalHeight = this.logo.height;
			this.logoOriginalWidth  = this.logo.width;
			
			this.logo.alpha = this.settingsObject["logoImageAlpha"];
			
			this.vizualizationContainer.addChild(this.logo);
			
			if (this.hasResizedOnce)
			{
				this.resizeLogoMaintainAspectMaximizeInBoundingBox();
			}
		}
			
		private function loadLogoImageProgress (pe:ProgressEvent) : void
		{
			
		}
		
		private function reactToMouseLocation (me:MouseEvent) : void
		{
			this.rotationTargetY = ((this.all_measurement_width -me.stageX) / this.all_measurement_width  * 45.0) - 22.5;
			this.rotationTargetX = ((me.stageY) / this.all_measurement_height * 45.0) - 22.5;
			
			this.rotateTowardsTargetIfNeeded();
		}
		private function rotateTowardsTargetIfNeeded () : void
		{
			var shouldRotate:Boolean = false;
			
			if (this.rotationActualX <= this.rotationTargetX-0.001)
			{
				shouldRotate = true;
				this.rotationActualX = Math.min(this.rotationTargetX,(this.rotationActualX+1.0));
			}
			else if (this.rotationActualX >= this.rotationTargetX+0.001)
			{
				shouldRotate = true;
				this.rotationActualX = Math.max(this.rotationTargetX,(this.rotationActualX-1.0));
			}
			
			if (this.rotationActualY <= this.rotationTargetY-0.001)
			{
				shouldRotate = true;
				this.rotationActualY = Math.min(this.rotationTargetY,(this.rotationActualY+1.0));
			}
			else if (this.rotationActualY >= this.rotationTargetY+0.001)
			{
				shouldRotate = true;
				this.rotationActualY = Math.max(this.rotationTargetY,(this.rotationActualY-1.0));
			}
			
			if (shouldRotate)
			{
				this.vizualizationContainer.transform.matrix3D = new Matrix3D();
				this.vizualizationContainer.z = 0.0; // Workaround.
				this.vizualizationContainer.transform.matrix3D.appendRotation(this.rotationActualX, Vector3D.X_AXIS, new Vector3D(this.all_measurement_centerX,this.all_measurement_centerY,0.0));
				this.vizualizationContainer.transform.matrix3D.appendRotation(this.rotationActualY, Vector3D.Y_AXIS, new Vector3D(this.all_measurement_centerX,this.all_measurement_centerY,0.0));
				this.vizualizationContainer.transform.perspectiveProjection = new PerspectiveProjection();
				this.vizualizationContainer.transform.perspectiveProjection.projectionCenter = new Point(this.all_measurement_centerX, this.all_measurement_centerY); 
				this.vizualizationContainer.transform.perspectiveProjection.focalLength = this.shadowFocalLen;
			}
		}
	}
}


