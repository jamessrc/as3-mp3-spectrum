package player.impl
{
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.media.ID3Info;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import player.event.PlayerEvent;
	
	import spectrum.iface.visualization.ISpectrumVisualization;
	import spectrum.impl.visualization.LimeGreenTraslucentGaphicEqualizerBarsVisualization;
	
	public class SweetPlayer extends Sprite
	{
		// Settings.
		private var settingsObject:Object = null;
		
		// The Main Sprite.
		private var songPlayerContainerSprite :Sprite = new Sprite();
		
		// Play Pause Button. //
		private var playPauseContainerSprite         :Sprite = new Sprite();
		//private var playPauseHoverShape              :Shape  = new Shape();
		private var pauseSymbolShape                 :Shape  = new Shape();  
		private var pauseSymbolHoverShape            :Shape  = new Shape();  
		private var playSymbolShape                  :Shape  = new Shape();
		private var playSymbolHoverShape             :Shape  = new Shape();
		private var playPauseHoverGlowFilter         :GlowFilter = null;
		private var playPauseClearCoverSprite        :Sprite = new Sprite();
		
		// The Visualization //
		private var visualizationContainerSprite     :Sprite     = new Sprite();
		
		// Text //
		[Embed(source="../../resources/fonts/vermin_vibes_redux.ttf", 
        	fontName = "verminVibesRedux", 
    		mimeType = "application/x-font", 
    		fontStyle="normal", 
    		unicodeRange="U+0020-U+0040,U+0041-U+005A,U+005B-U+0060,U+0061-U+007A,U+007B-U+007E", 
    		advancedAntiAliasing="true", 
    		embedAsCFF="false")]
		private var verimVibesReduxFont:Class;
		
		[Embed(source="../../resources/fonts/dom_casual_italic.ttf", 
        	fontName = "domCasualItalic", 
    		mimeType = "application/x-font", 
    		fontStyle="normal", 
    		unicodeRange="U+0020-U+0040,U+0041-U+005A,U+005B-U+0060,U+0061-U+007A,U+007B-U+007E", 
    		advancedAntiAliasing="true", 
    		embedAsCFF="false")]
		private var domCasualFont:Class;
		
		[Embed(source="../../resources/fonts/reenie_beanie.ttf", 
        	fontName = "reenieBeanie", 
    		mimeType = "application/x-font", 
    		fontStyle="normal", 
    		unicodeRange="U+0020-U+0040,U+0041-U+005A,U+005B-U+0060,U+0061-U+007A,U+007B-U+007E", 
    		advancedAntiAliasing="true", 
    		embedAsCFF="false")]
		private var reenieBeanieFont:Class;
		
		[Embed(source="../../resources/fonts/good_times.ttf", 
        	fontName = "goodTimes", 
    		mimeType = "application/x-font", 
    		fontStyle="normal", 
    		unicodeRange="U+0020-U+0040,U+0041-U+005A,U+005B-U+0060,U+0061-U+007A,U+007B-U+007E", 
    		advancedAntiAliasing="true", 
    		embedAsCFF="false")]
		private var goodTimesFont:Class;
		
		[Embed(source="../../resources/fonts/olivers_barney.ttf", 
        	fontName = "oliversBarney", 
    		mimeType = "application/x-font", 
    		fontStyle="normal", 
    		unicodeRange="U+0020-U+0040,U+0041-U+005A,U+005B-U+0060,U+0061-U+007A,U+007B-U+007E", 
    		advancedAntiAliasing="true", 
    		embedAsCFF="false")]
		private var oliversBarnyFont:Class;
		
		[Embed(source="../../resources/fonts/meridian.ttf", 
        	fontName = "meridian", 
    		mimeType = "application/x-font", 
    		fontStyle="normal", 
    		unicodeRange="U+0020-U+0040,U+0041-U+005A,U+005B-U+0060,U+0061-U+007A,U+007B-U+007E", 
    		advancedAntiAliasing="true", 
    		embedAsCFF="false")]
		private var meridianFont:Class;
				
		private var timePositionIndicatorTextBox    :TextField  = new TextField();
		private var timePositionIndicatorTextFormat :TextFormat = new TextFormat();
		
		private var albumArtistTextField :TextField = new TextField();
		private var albumNameTextField   :TextField = new TextField();
		private var albumSongTextField   :TextField = new TextField();
		
		// The Time Position Indicator. //
		private var timePositionIndicatorContainerSprite :Sprite  = new Sprite();
		private var timePositionIndicatorNormalShape     :Shape   = new Shape();
		private var timePositionIndicatorHoverShape      :Shape   = new Shape();
		private var timePositionIndicatorMasksShape      :Shape   = new Shape();
		
		// Time position background lightup gradient. //
		private var fillType     :String = GradientType.LINEAR;
		private var colorsNormal :Array = null;
		private var colorsHover  :Array = null;
		private var alphas       :Array = [0, 0.9];
		private var ratios       :Array = [0, 255];
		private var matrix       :Matrix = new Matrix();
		private var spreadMethod:String = SpreadMethod.REFLECT;
		
		// Volume Dial.
		private var volumeDialContainerSprite           :Sprite     = new Sprite();
		private var volumeDialTickersGlowFilter         :GlowFilter = null;
		private var volumeDialTickersShape              :Shape      = new Shape();
		private var volumeDialTickersHoverShape         :Shape      = new Shape();
		private var volumeDialTickersMaskShape          :Shape      = new Shape();
		private var volumeDialBackgoundTickerShape      :Shape      = new Shape();
		private var volumeDialSpeakerShape              :Shape      = new Shape();
		private var volumeDialClearCoverSprite          :Sprite     = new Sprite();
		
		// Volume control level indicator.
		private var volumeLevelIndicatorShape :Shape = new Shape();
		
		// The visualization object. //
		private var visualization:ISpectrumVisualization = null;
		
		// Sound. //
		private var sound            :Sound          = null;
		private var soundChannel     :SoundChannel   = null;
		private var soundTrans       :SoundTransform = null;
		
		// Constants. //
		private var maxProgressPercentPerFrame    :Number  = 0.0027; // 0.27% per frame. //WE SHOULD CHECK THE FRAME RATE HERE.
		private var playerHeightPercent           :Number  = 0.7;
		
		private var volumeTickerWidthPlusMinusRad :Number  = Math.PI/24.0;
		private var volumeTickerIncrementRad      :Number  = Math.PI/12.0;
		private var volumeRadSpan                 :Number  = Math.PI*5.0/3.0;
		private var volumeMinRad                  :Number  = Math.PI/6.0;
		private var volumeMaxRad                  :Number  = Math.PI*2-volumeMinRad;
		
		// Positions and Sizes. //		
		private var left_playPauseBackGround       :Number = 0;
		private var left_playPauseContainer        :Number = 0;
		private var right_playPauseContainer       :Number = 0;
		private var right_playPauseBackground      :Number = 0;
		
		private var left_visualizationBackground   :Number = 0;
		private var left_visualizationContainer    :Number = 0;
		private var right_visualizationContainer   :Number = 0;
		private var right_visualizationBackground  :Number = 0;
		
		private var left_volumeDialBackground      :Number = 0;
		private var right_volumeDialBackground     :Number = 0;
		
		private var top_background                 :Number = 0;
		private var top_container                  :Number = 0;
		private var bottom_container               :Number = 0;
		private var bottom_background              :Number = 0;
		
		private var width_playPauseBackground      :Number = 0;
		private var width_playPauseContainer       :Number = 0;
		private var width_visualizationBackground  :Number = 0;
		private var width_visualizationContainer   :Number = 0;
		private var width_volumeDialBackground     :Number = 0;
		private var height_background              :Number = 0;
		private var height_background_1d2          :Number = 0;
		private var height_container               :Number = 0;
		
		private var textHeight :Number = 0;
		
		private var measure_container_1d5  :Number = 0;
		private var measure_container_1d10 :Number = 0;
		private var measure_container_1d25 :Number = 0;
		private var measure_container_1d50 :Number = 0;
		private var measure_container_1d2  :Number = 0;
		private var measure_container_1d3  :Number = 0;
		private var measure_container_1d6  :Number = 0;
		private var measure_container_1d30 :Number = 0;
		private var measure_container_1d15 :Number = 0;
		private var measure_container_2d15 :Number = 0;
		
		private var progress_visualizationContainer:Number = 0;
		
		private var border_outside  :Number    = 1.0;
		private var border_0p25     :Number    = 0.5;
		private var border_0p5      :Number    = 1.0;
		private var border_1p0      :Number    = 2.0;
		private var border_1p5      :Number    = 3.0;
		private var border_2p0      :Number    = 4.0;
		private var border_4p0      :Number    = 8.0;
		
		// States. //
		private var isPlaying                    :Boolean = true;
		private var isHoveringPlayPause          :Boolean = false;
		private var downloadIsComplete           :Boolean = false;
		private var audioPositionMillis          :Number  = 0;
		private var downloadProgress             :Number  = 0.001;
		private var displayedProgress            :Number  = 0.001;
		private var soundLengthEstimated         :Number  = 0;
		/* Time Position */
		private var timePositionPercent          :Number  = 0;
		private var timePositionMouseIsDown      :Boolean = false;
		private var timePositionStateWasPlaying  :Boolean = false;
		private var timePositionX                :Number  = 0;
		/* Volume */
		private var volumeLevelPercent           :Number  = 0.75;
		private var volumeLevelMouseIsDown       :Boolean = false;
		private var volumeLevelStartMouseX       :Number  = 0;
		private var volumeLevelX                 :Number  = 0;
		
		public function SweetPlayer(settingsObject:Object)
		{	
			try
			{			
				this.initializeSettingsObject(settingsObject);
				
				this.colorsNormal = [this.settingsObject["timeIndGradientNormalColor"],this.settingsObject["timeIndGradientNormalColor"]];
				this.colorsHover  = [this.settingsObject["timeIndGradientHoverColor"],this.settingsObject["timeIndGradientHoverColor"]];
				
				
				// Add the spectrum Visualization as a child.
				visualization = new LimeGreenTraslucentGaphicEqualizerBarsVisualization(this.visualizationContainerSprite,this.settingsObject);
				
				
				// VISUALIZATION SRTUCTURE.
				this.songPlayerContainerSprite.addChild(this.visualizationContainerSprite);
				this.songPlayerContainerSprite.addChild(this.timePositionIndicatorTextBox);
				this.songPlayerContainerSprite.addChild(this.albumArtistTextField);
				this.songPlayerContainerSprite.addChild(this.albumNameTextField);
				this.songPlayerContainerSprite.addChild(this.albumSongTextField);
				
				// TIME POSITION INDICATOR STRUCTURE.
				this.songPlayerContainerSprite.addChild(this.timePositionIndicatorContainerSprite);
				this.timePositionIndicatorContainerSprite.addChild(this.timePositionIndicatorNormalShape);
				this.timePositionIndicatorContainerSprite.addChild(this.timePositionIndicatorHoverShape);
				
				// TIME POSITION INDICATOR MASK.
				this.songPlayerContainerSprite.addChild(this.timePositionIndicatorMasksShape);
				
				// PLAY PAUSE STRUCTURE.
				this.songPlayerContainerSprite.addChild(this.playPauseContainerSprite);
				this.playPauseContainerSprite.addChild(this.playSymbolShape);
				this.playPauseContainerSprite.addChild(this.playSymbolHoverShape);
				this.playPauseContainerSprite.addChild(this.pauseSymbolShape);
				this.playPauseContainerSprite.addChild(this.pauseSymbolHoverShape);
				this.playPauseContainerSprite.addChild(this.playPauseClearCoverSprite);
				
				this.playPauseClearCoverSprite.buttonMode = true;
				
				// VOLUME DIAL STRUCTURE.
				this.songPlayerContainerSprite.addChild(this.volumeDialContainerSprite);
				this.volumeDialContainerSprite.addChild(this.volumeDialBackgoundTickerShape);
				this.volumeDialContainerSprite.addChild(this.volumeDialTickersMaskShape);
				this.volumeDialContainerSprite.addChild(this.volumeDialTickersShape);
				this.volumeDialContainerSprite.addChild(this.volumeDialTickersHoverShape);
				this.volumeDialContainerSprite.addChild(this.volumeDialSpeakerShape);
				this.volumeDialContainerSprite.addChild(this.volumeDialClearCoverSprite);
				
				// States.
				this.playSymbolShape.visible     = !this.isPlaying;
				this.pauseSymbolShape.visible    =  this.isPlaying;
				this.playSymbolHoverShape.visible  = false;
				this.pauseSymbolHoverShape.visible = false;
				
				this.timePositionIndicatorNormalShape.visible = true;
				this.timePositionIndicatorHoverShape.visible  = false;
				
				// Add it all to this SWF movie.
				this.addChild(this.songPlayerContainerSprite);
			}
			catch( e:Error )
			{
				trace("CAUGHT ERROR IN SWEET PLAYER.");
				trace(e);
			}
		}
		
		public function startSweetPlayer():void
		{
			this.sound = new Sound();
			this.sound.load(new URLRequest(this.settingsObject["songUrl"]));
			
			sound.addEventListener(ProgressEvent.PROGRESS, onDownloadProgress);
			sound.addEventListener(Event.ID3             , this.onID3        );
			sound.addEventListener(Event.COMPLETE        , onDownloadComplete);
			
			this.soundTrans = new SoundTransform(this.volumeLevelPercent, 0);
			
			
			// Start playback of the sound with
			this.soundChannel = sound.play(0, 0, this.soundTrans);
			
			// Reset the player Size when the containing div resizes.
			//this.addEventListener(Event.RESIZE, onResize);
			
			// Add the play/pause eventListener.
			this.playPauseClearCoverSprite.addEventListener(MouseEvent.CLICK     , this.onPlayPauseClick    );
			this.playPauseClearCoverSprite.addEventListener(MouseEvent.MOUSE_OVER, this.onPlayPauseMouseOver);
			this.playPauseClearCoverSprite.addEventListener(MouseEvent.MOUSE_OUT , this.onPlayPauseMouseOut );
			
			// Time Position Event Listeners.
			this.timePositionIndicatorContainerSprite.addEventListener(MouseEvent.MOUSE_OVER, this.onTimePositionMouseOver );
			this.timePositionIndicatorContainerSprite.addEventListener(MouseEvent.MOUSE_OUT,  this.onTimePositionMouseOut  );  
			this.timePositionIndicatorContainerSprite.addEventListener(MouseEvent.MOUSE_MOVE, this.onTimePositionMouseMove );
			this.timePositionIndicatorContainerSprite.addEventListener(MouseEvent.MOUSE_DOWN, this.onTimePositionMouseDown );
			this.timePositionIndicatorContainerSprite.addEventListener(MouseEvent.MOUSE_UP,   this.onTimePositionMouseUp   );
			
			// Volume Control Listeners.
			this.volumeDialClearCoverSprite.addEventListener(MouseEvent.MOUSE_OVER, this.onVolumeLevelMouseOver );
			this.volumeDialClearCoverSprite.addEventListener(MouseEvent.MOUSE_OUT,  this.onVolumeLevelMouseOut  );  
			this.volumeDialClearCoverSprite.addEventListener(MouseEvent.MOUSE_MOVE, this.onVolumeLevelMouseMove );
			this.volumeDialClearCoverSprite.addEventListener(MouseEvent.MOUSE_DOWN, this.onVolumeLevelMouseDown );
			this.volumeDialClearCoverSprite.addEventListener(MouseEvent.MOUSE_UP,   this.onVolumeLevelMouseUp   );
			
			// listeners for volume control and time indicator.
			this.stage.addEventListener(MouseEvent.MOUSE_OUT,  this.onMouseOut );
			this.stage.addEventListener(MouseEvent.MOUSE_UP,   this.onMouseUp  );
			this.stage.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove); 
			
			if (this.settingsObject["playAutomatically"] )
			{
				this.play();
			}
			else
			{
				this.pause();
			}
			
			this.updatePlayPauseSymbols();
		}
		
		// TIME POSITION LISTENER.
		
		private function onTimePositionMouseOut(me:MouseEvent):void
		{
			if( !this.timePositionMouseIsDown )
			{
				this.timePositionIndicatorNormalShape.visible = true;
				this.timePositionIndicatorHoverShape.visible  = false;
			}
		}
		
		private function onTimePositionMouseOver(me:MouseEvent):void
		{
			if( !volumeLevelMouseIsDown )
			{
				this.timePositionIndicatorHoverShape.visible  = true;
				this.timePositionIndicatorNormalShape.visible = false; 
			}
		}
		
		private function onTimePositionMouseDown(me:MouseEvent):void
		{	
			this.timePositionMouseIsDown      = true;
			this.timePositionStateWasPlaying  = this.isPlaying;
		}
		
		private function onTimePositionMouseUp(me:MouseEvent=null):void
		{
			if( this.timePositionMouseIsDown )
			{
				if( this.timePositionStateWasPlaying )
				{
					this.soundChannel.stop();
					this.play();
				}
				else
				{
					this.play();
					this.pause();
				}
				
				this.timePositionMouseIsDown = false;
				
				this.timePositionIndicatorContainerSprite.z = 0;
			}
		}
		
		private function onTimePositionMouseMove(me:MouseEvent):void
		{
			if( timePositionMouseIsDown )
			{
				this.moveTimeToPosition(me.stageX);
			}
		}
		
		private function moveTimeToPosition (stagex:Number) : void
		{
			stagex = Math.max(this.left_visualizationContainer, Math.min(stagex, this.left_visualizationContainer+this.progress_visualizationContainer));
			
			var truex    :Number = stagex - this.left_visualizationContainer;
			var positionx:Number = truex - this.measure_container_1d10;
			
			this.timePositionIndicatorHoverShape.x  = positionx
			this.timePositionIndicatorNormalShape.x = positionx;
			
			this.timePositionX       = positionx;
			this.timePositionPercent = this.safeDivide(truex,this.width_visualizationContainer);
			
			this.audioPositionMillis = Math.min(this.soundLength,Math.max(0,this.timePositionPercent*(this.soundLength)));
			
			this.timePositionIndicatorTextBox.text = this.minutesSecondsStringFromMillis(this.audioPositionMillis);
		}
		
		// VOLUME CONTROL LISTENERS.
		
		private function volumeRadiansFromLocation(x:Number, y:Number):Number
		{
			var radians:Number = 0.0;
			
			x = x-this.height_background_1d2;
			y = y-this.height_background_1d2;
			
			radians = Math.atan2(x,y); // x and y coords swaped to match as3 rotation.
			
			// Adjust the return from atan2.
			if( radians < 0.0 )
				radians += 2*Math.PI;
			
			// Bound the radians to our control dial.
			radians = Math.min(this.volumeMaxRad, radians);
			radians = Math.max(this.volumeMinRad, radians);
			
			return radians;
		}
		
		private function volumeLevelFromRadians(radians:Number):Number
		{
			radians = radians - this.volumeMinRad;
			
			return 1 - radians/(this.volumeRadSpan);
		}
		
		private function volumeRadiansFromLevel(level:Number):Number
		{
			return this.volumeMinRad + (1-level)*this.volumeRadSpan;
		}
		
		private function drawVolumeDialTickersMaskWithRadians(volumeLevelRads:Number):void
		{
			// draw the volume ticker mask.
			this.volumeDialTickersMaskShape.graphics.clear();
			this.volumeDialTickersMaskShape.graphics.beginFill(0x000000);
			
			for( var rad:Number=2*Math.PI; rad>volumeLevelRads; rad-=this.volumeTickerIncrementRad )
			{
				this.volumeDialTickersMaskShape.graphics.lineTo(this.height_background_1d2*Math.sin(rad), this.height_background_1d2*Math.cos(rad));
			}
			
			this.volumeDialTickersMaskShape.graphics.lineTo(this.height_background_1d2*Math.sin(volumeLevelRads), this.height_background_1d2*Math.cos(volumeLevelRads));
			
			this.volumeDialTickersMaskShape.graphics.lineTo(0,0);
		}
		
		
		private function onVolumeLevelMouseOut(me:MouseEvent):void
		{
			if( !this.volumeLevelMouseIsDown )
			{
				this.onVolumeLevelMouseUp();
			}
			
			this.volumeDialTickersShape.visible = true;
			this.volumeDialTickersShape.mask    = this.volumeDialTickersMaskShape;
			
			this.volumeDialTickersHoverShape.visible = false;
		}
		
		private function onVolumeLevelMouseOver(me:MouseEvent):void
		{
			if( !timePositionMouseIsDown )
			{
				this.volumeDialTickersHoverShape.visible = true;
				this.volumeDialTickersHoverShape.mask    = this.volumeDialTickersMaskShape;
				
				this.volumeDialTickersShape.visible      = false;
			}
		}
		
		private function onVolumeLevelMouseDown(me:MouseEvent):void
		{
			this.adjustVolumeWithLocation(me.localX, me.localY);
			
			this.volumeLevelMouseIsDown = true;
		}
		
		private function onVolumeLevelMouseUp(me:MouseEvent=null):void
		{
			if( this.volumeLevelMouseIsDown )
			{
				this.volumeLevelMouseIsDown = false;
			}
		}
		
		private function onVolumeLevelMouseMove(me:MouseEvent):void
		{
			if( this.volumeLevelMouseIsDown )
			{
				this.adjustVolumeWithLocation(me.localX, me.localY);
			}
		}
		
		private function adjustVolumeWithLocation(x:Number, y:Number):void
		{
			var radians:Number      = this.volumeRadiansFromLocation(x, y);
			this.volumeLevelPercent = this.volumeLevelFromRadians(radians);
						
			this.soundTrans.volume           = this.volumeLevelPercent;
			this.soundChannel.soundTransform = this.soundTrans;
			
			this.drawVolumeDialTickersMaskWithRadians(radians);
		}
		
		// LISTENERS FOR VOLUME AND TIME POSITION
		
		public function onMouseUp(me:MouseEvent):void
		{			
			if( this.timePositionMouseIsDown )
			{
				this.onTimePositionMouseUp();
			}
		}
		
		public function onMouseDown (me:MouseEvent):void
		{			
			if (!this.mouseIsOutsideOfProgress(me.stageX, me.stageY))
			{
				this.timePositionMouseIsDown      = true;
				this.timePositionStateWasPlaying  = this.isPlaying;
				
				this.moveTimeToPosition(me.stageX);
			}
		}
		
		public function onMouseMove(me:MouseEvent):void
		{			
			if( this.timePositionMouseIsDown )
			{
				this.onTimePositionMouseMove(me);
				
				if( this.mouseIsOutsideOfProgress(me.stageX, me.stageY) )
				{
					this.timePositionIndicatorNormalShape.visible = true;
					this.timePositionIndicatorHoverShape.visible  = false;
					
					this.onTimePositionMouseUp();
				}
			}
		}
		
		public function onMouseOut(me:MouseEvent):void
		{	
			if( this.timePositionMouseIsDown )
			{	
				if( this.mouseIsOutsideOfProgress(me.stageX, me.stageY) )
				{
					this.timePositionIndicatorNormalShape.visible = true;
					this.timePositionIndicatorHoverShape.visible  = false;
					
					this.onTimePositionMouseUp();
				}
			}
			else if( this.volumeLevelMouseIsDown )
			{
				if( this.mouseIsOutsideOfContainer(me.stageX, me.stageY) )
				{	
					this.onVolumeLevelMouseUp();
				}
			}
		}
		
		private function mouseIsOutsideOfProgress(x:Number, y:Number):Boolean
		{				
			var localPoint:Point = this.parent.globalToLocal(new Point(x,y));
						
			if(	localPoint.x > (this.left_visualizationContainer+this.progress_visualizationContainer)
				||  localPoint.x < this.left_visualizationContainer 
				||  localPoint.y > this.bottom_background 
				||  localPoint.y < this.top_background )
			{
				return true;
			}
			
			return false;
		}
		
		private function mouseIsOutsideOfContainer(x:Number, y:Number):Boolean
		{
			var localPoint:Point = this.parent.globalToLocal(new Point(x,y));

			if(	localPoint.x < this.left_volumeDialBackground
				||  localPoint.x > this.right_volumeDialBackground 
				||  localPoint.y > this.bottom_background 
				||  localPoint.y < this.top_background )
			{
				return true;
			}
			
			return false;
		}
		
		private function onPlayPauseMouseOut(me:MouseEvent):void
		{
			this.isHoveringPlayPause = false;
			
			this.playSymbolShape.visible       = false;
			this.playSymbolHoverShape.visible  = false;
			this.pauseSymbolShape.visible      = false;
			this.pauseSymbolHoverShape.visible = false;
			
			if (this.isPlaying)
			{
				this.pauseSymbolShape.visible = true;
			}
			else
			{
				this.playSymbolShape.visible = true;
			}
		}
		
		private function onPlayPauseMouseOver(me:MouseEvent):void
		{
			this.isHoveringPlayPause = true;
			
			this.playSymbolShape.visible       = false;
			this.playSymbolHoverShape.visible  = false;
			this.pauseSymbolShape.visible      = false;
			this.pauseSymbolHoverShape.visible = false;
		
			if (this.isPlaying)
			{				
				this.pauseSymbolHoverShape.visible = true;
			}
			else
			{
				this.playSymbolHoverShape.visible = true;
			}
		}
		
		private function onPlayPauseClick(e:MouseEvent):void
		{
			if( isPlaying )
			{
				this.pause();
			}
			else
			{
				this.play();
			}
			
			this.updatePlayPauseSymbols();
		}
		
		private function updatePlayPauseSymbols():void
		{
			this.playSymbolShape.visible       = (!this.isPlaying && !this.isHoveringPlayPause);
			this.playSymbolHoverShape.visible  = (!this.isPlaying &&  this.isHoveringPlayPause);
			this.pauseSymbolShape.visible      = ( this.isPlaying && !this.isHoveringPlayPause);
			this.pauseSymbolHoverShape.visible = ( this.isPlaying &&  this.isHoveringPlayPause);
		}
		
		private function pause():void
		{
			this.audioPositionMillis = this.soundChannel.position;
			this.soundChannel.stop();
			
			this.isPlaying = false;
			
			this.dispatchEvent(new PlayerEvent(PlayerEvent.ON_PAUSE));
		}
		
		private function play():void
		{
			this.soundChannel = this.sound.play(this.audioPositionMillis,0,this.soundTrans);
			
			this.isPlaying = true;
			
			this.dispatchEvent(new PlayerEvent(PlayerEvent.ON_PLAY));
		}
		
		private function onDownloadProgress(pe:ProgressEvent):void
		{	
			this.downloadProgress = (pe.bytesLoaded/pe.bytesTotal);
			
			this.soundLengthEstimated = pe.bytesTotal * this.sound.length / pe.bytesLoaded;  
		}
		
		private function onID3(e:Event):void
		{
			var songInfo:ID3Info = ID3Info(sound.id3)
			
			if ((this.settingsObject["albumArtistText"]==null) && (songInfo.artist!=null))
			{
				this.settingsObject["albumArtistText"] = songInfo.artist;
				this.albumArtistTextField.text         = this.settingsObject["albumArtistText"];
			}
			if ((this.settingsObject["albumNameText"]==null) && (songInfo.album!=null))
			{
				this.settingsObject["albumNameText"] = songInfo.album;
				this.albumArtistTextField.text       = this.settingsObject["albumNameText"];

			}
			if ((this.settingsObject["albumSongText"]==null) && (songInfo.songName!=null))
			{
				this.settingsObject["albumSongText"] = songInfo.songName;
				this.albumArtistTextField.text       = this.settingsObject["albumSongText"];
			} 
		}
		
		private function onDownloadComplete(e:Event):void
		{
			this.downloadIsComplete = true;
		}
		
		public function onEnterFrame(e:Event=null):void
		{		
			this.renderDownloadProgress();
			
			if (!this.isPlaying)
				return;
			
			this.visualization.readAndRender();
			
			this.renderTrackPosition();
		}
		
		private function renderTrackPosition():void
		{	
			if( this.timePositionMouseIsDown )
				return;
			
			this.timePositionPercent = this.safeDivide(this.soundChannel.position,this.soundLength);
			this.timePositionX       = this.width_visualizationContainer*this.timePositionPercent;
			
			this.timePositionIndicatorHoverShape.x  = this.timePositionX-this.measure_container_1d10;
			this.timePositionIndicatorNormalShape.x = this.timePositionX-this.measure_container_1d10;
			
			this.timePositionIndicatorTextBox.text = this.minutesSecondsStringFromMillis(this.soundChannel.position);
		}
		
		private function renderDownloadProgress():void
		{
			if( this.displayedProgress < this.downloadProgress )
			{
				this.displayedProgress += Math.min(this.maxProgressPercentPerFrame, (this.downloadProgress-this.displayedProgress));
				
				this.progress_visualizationContainer = this.width_visualizationContainer*this.displayedProgress;
				
				this.visualizationContainerSprite.graphics.clear();
				
				this.visualizationContainerSprite.graphics.beginFill(this.settingsObject["visualizationContainerColor"], this.settingsObject["visualizationContainerAlpha"]);
				this.visualizationContainerSprite.graphics.drawRoundRect(0,0,this.progress_visualizationContainer,this.height_container,this.settingsObject["cornerRadii"]);
				this.visualizationContainerSprite.graphics.endFill();
				
				this.visualization.resize(this.progress_visualizationContainer,this.height_container);
				
				this.timePositionIndicatorMasksShape.graphics.clear();
				this.timePositionIndicatorMasksShape.graphics.beginFill(this.settingsObject["visualizationContainerColor"]);
				this.timePositionIndicatorMasksShape.graphics.drawRoundRect(0,0,this.progress_visualizationContainer,this.height_container,this.settingsObject["cornerRadii"]);
				this.timePositionIndicatorMasksShape.graphics.endFill();
			}
		}
		
		private function initializeSettingsObject(settingsObject:Object):void
		{
			this.settingsObject = settingsObject;
			
			this.settingsObject["albumAttributesTextColor"]         = this.settingsObject["albumAttributesTextColor"]         ?this.settingsObject["albumAttributesTextColor"]         :0xAC2975;
			this.settingsObject["albumArtistText"]                  = this.settingsObject["albumArtistText"]                  ?this.settingsObject["albumArtistText"]                  :null;
			this.settingsObject["albumNameText"]                    = this.settingsObject["albumNameText"]                    ?this.settingsObject["albumNameText"]                    :null;
			this.settingsObject["albumSongText"]                    = this.settingsObject["albumSongText"]                    ?this.settingsObject["albumSongText"]                    :null;
			this.settingsObject["borderWidthIsPercent"]             = this.settingsObject["borderWidthIsPercent"]             ?this.settingsObject["borderWidthIsPercent"]             :true;
			this.settingsObject["borderWidthPercentOrValue"]        = this.settingsObject["borderWidthPercentOrValue"]        ?this.settingsObject["borderWidthPercentOrValue"]        :0.027;
			this.settingsObject["cornerRadii"]                      = this.settingsObject["cornerRadii"]                      ?this.settingsObject["cornerRadii"]                      :0.0;
			this.settingsObject["mainBackgroundColor"]              = this.settingsObject["mainBackgroundColor"]              ?this.settingsObject["mainBackgroundColor"]              :0x1B1B1B;
			this.settingsObject["songPlayerBackgroundAlpha"]        = this.settingsObject["songPlayerBackgroundAlpha"]        ?this.settingsObject["songPlayerBackgroundAlpha"]        :0.5;
			this.settingsObject["songPlayerBackgroundColor"]        = this.settingsObject["songPlayerBackgroundColor"]        ?this.settingsObject["songPlayerBackgroundColor"]        :0xC3E897;
			this.settingsObject["songPlayerOutsideBorderAlpha"]     = this.settingsObject["songPlayerOutsideBorderAlpha"]     ?this.settingsObject["songPlayerOutsideBorderAlpha"]     :0.5;
			this.settingsObject["songPlayerOutsideBorderColor"]     = this.settingsObject["songPlayerOutsideBorderColor"]     ?this.settingsObject["songPlayerOutsideBorderColor"]     :0x000000;
			this.settingsObject["songPlayerOutsideBorderThickness"] = this.settingsObject["songPlayerOutsideBorderThickness"] ?this.settingsObject["songPlayerOutsideBorderThickness"] :1.0;
			this.settingsObject["componentsBackgroundAlpha"]        = this.settingsObject["componentsBackgroundAlpha"]        ?this.settingsObject["componentsBackgroundAlpha"]        :0.5;
			this.settingsObject["componentsBackgroundColor"]        = this.settingsObject["componentsBackgroundColor"]        ?this.settingsObject["componentsBackgroundColor"]        :0x1B1B1B;
			this.settingsObject["playPauseHoverColor"]              = this.settingsObject["playPauseHoverColor"]              ?this.settingsObject["playPauseHoverColor"]              :0x000000;
			this.settingsObject["playPauseNormalColor"]             = this.settingsObject["playPauseNormalColor"]             ?this.settingsObject["playPauseNormalColor"]             :0x1B1B1B;
			this.settingsObject["playPauseSymbolColor"]             = this.settingsObject["playPauseSymbolColor"]             ?this.settingsObject["playPauseSymbolColor"]             :0xC3E897;
			this.settingsObject["playPauseGlowAlpha"]               = this.settingsObject["playPauseGlowAlpha"]               ?this.settingsObject["playPauseGlowAlpha"]               :1.0;
			this.settingsObject["playPauseGlowColor"]               = this.settingsObject["playPauseGlowColor"]               ?this.settingsObject["playPauseGlowColor"]               :0xAC2975;
			this.settingsObject["songUrl"]                          = this.settingsObject["songUrl"]                          ?this.settingsObject["songUrl"]                          :"http://207.38.199.219:8080/kali-ma-web/audio/theBoyAndTheMoon.mp3";
			this.settingsObject["fontFamily"]                       = this.settingsObject["fontFamily"]                       ?this.settingsObject["fontFamily"]                       :"verminVibesRedux";
			this.settingsObject["fontSizeScale"]                    = this.settingsObject["fontSizeScale"]                    ?this.settingsObject["fontSizeScale"]                    :1.0;
			this.settingsObject["textHeightPercent"]                = this.settingsObject["textHeightPercent"]                ?this.settingsObject["textHeightPercent"]                :0.27;
			this.settingsObject["timeIndNormalColor"]               = this.settingsObject["timeIndNormalColor"]               ?this.settingsObject["timeIndNormalColor"]               :0x1B1B1B;
			this.settingsObject["timeIndHoverColor"]                = this.settingsObject["timeIndHoverColor"]                ?this.settingsObject["timeIndHoverColor"]                :0xAC2975;
			this.settingsObject["timeIndGradientNormalColor"]       = this.settingsObject["timeIndGradientNormalColor"]       ?this.settingsObject["timeIndGradientNormalColor"]       :0xAC2975;
			this.settingsObject["timeIndGradientHoverColor"]        = this.settingsObject["timeIndGradientHoverColor"]        ?this.settingsObject["timeIndGradientHoverColor"]        :0xAC2975;
			this.settingsObject["timeIndTextColor"]                 = this.settingsObject["timeIndTextColor"]                 ?this.settingsObject["timeIndTextColor"]                 :0xAC2975;
			this.settingsObject["timeTotalTextColor"]               = this.settingsObject["timeTotalTextColor"]               ?this.settingsObject["timeTotalTextColor"]               :0xC3E897;
			this.settingsObject["visualizationUnderColor"]          = this.settingsObject["visualizationUnderColor"]          ?this.settingsObject["visualizationUnderColor"]          :0x434343;
			this.settingsObject["visualizationUnderAlpha"]          = this.settingsObject["visualizationUnderAlpha"]          ?this.settingsObject["visualizationUnderAlpha"]          :0.7;
			this.settingsObject["visualizationContainerColor"]      = this.settingsObject["visualizationContainerColor"]      ?this.settingsObject["visualizationContainerColor"]      :0x1B1B1B;
			this.settingsObject["visualizationContainerAlpha"]      = this.settingsObject["visualizationContainerAlpha"]      ?this.settingsObject["visualizationContainerAlpha"]      :0.7;
			this.settingsObject["volumeSpeakerColor"]               = this.settingsObject["volumeSpeakerColor"]               ?this.settingsObject["volumeSpeakerColor"]               :0x1B1B1B;
			this.settingsObject["volumeLevelBackgroundIndAlpha"]    = this.settingsObject["volumeLevelBackgroundIndAlpha"]    ?this.settingsObject["volumeLevelBackgroundIndAlpha"]    :0.3;
			this.settingsObject["volumeLevelBackgroundIndColor"]    = this.settingsObject["volumeLevelBackgroundIndColor"]    ?this.settingsObject["volumeLevelBackgroundIndColor"]    :0xC3E897;
			this.settingsObject["volumeLevelIndColor"]              = this.settingsObject["volumeLevelIndColor"]              ?this.settingsObject["volumeLevelIndColor"]              :0xC3E897;
			this.settingsObject["volumeLevelIndHoverColor"]         = this.settingsObject["volumeLevelIndHoverColor"]         ?this.settingsObject["volumeLevelIndHoverColor"]         :0x000000;
			this.settingsObject["volumeTickersGlowAlpha"]           = this.settingsObject["volumeTickersGlowAlpha"]           ?this.settingsObject["volumeTickersGlowAlpha"]           :0.5;
			this.settingsObject["volumeTickersGlowColor"]           = this.settingsObject["volumeTickersGlowColor"]           ?this.settingsObject["volumeTickersGlowColor"]           :0xC3E897;
		}
		
		public function onResize(e:Event=null):void
		{	
		}
		
		public function resize (newWidth:Number, newHeight:Number):void
		{
			this.graphics.clear();
			this.graphics.beginFill(0xffffff, 0.0);
			this.graphics.drawRect(0,0,width,height);
			this.graphics.endFill();
			
			// Set up sizes and Positions.
			this.resize_constants(newWidth, newHeight);
			
			// Render the main container Box.
			this.resize_songPlayer(newWidth, newHeight);
			
			// Render the toolbar dropdown.
			this.resize_toolbarDropdown(newWidth, newHeight);
			
			// Render the playPause button.
			this.resize_playPauseButton(newWidth, newHeight);
			
			// Render the Visualization box.
			this.resize_visualizationBox(newWidth, newHeight);
			
			// Render Time Position indicator.
			this.resize_timePositionIndicator(newWidth, newHeight);
			
			// Render the volume indicator.
			this.resize_volumeControl(newWidth, newHeight);
			
			this.renderTrackPosition();
		}
		
		private function resize_constants(newWidth:int, newHeight:int):void
		{
			this.border_outside  = this.settingsObject["songPlayerOutsideBorderThickness"];
			this.border_1p0      = this.settingsObject["borderWidthIsPercent"]==true?Math.min(newHeight,newWidth)*Number(this.settingsObject["borderWidthPercentOrValue"]):Number(this.settingsObject["borderWidthPercentOrValue"]);
			this.border_0p25     = this.border_1p0/4.0;
			this.border_0p5      = this.border_1p0/2.0;
			this.border_1p5      = this.border_1p0+this.border_0p5;
			this.border_2p0      = this.border_1p0+this.border_1p0;
			this.border_4p0      = this.border_2p0+this.border_2p0;
						
			this.top_background                  = this.border_1p0+this.border_outside;
			this.top_container                   = this.border_2p0+this.border_outside;
			this.bottom_container                = (newHeight)-this.border_2p0-this.border_outside;
			this.bottom_background               = (newHeight)-this.border_1p0-this.border_outside;
			
			this.height_background               = this.bottom_background-this.top_background;
			this.height_container                = this.bottom_container -this.top_container;
			this.height_background_1d2           = this.height_background/2.0;
			this.width_playPauseBackground       = this.height_background;
			this.width_playPauseContainer        = this.height_container;
			
			this.textHeight =  Number(this.settingsObject["textHeightPercent"]) * this.height_container;
			
			this.left_playPauseBackGround        = this.border_1p0+this.border_outside;
			this.left_playPauseContainer         = this.border_2p0+this.border_outside;
			this.right_playPauseContainer        = this.left_playPauseContainer +this.width_playPauseContainer;
			this.right_playPauseBackground       = this.left_playPauseBackGround+this.width_playPauseBackground;
			
			this.left_visualizationBackground    = this.right_playPauseBackground+this.border_1p0;
			this.left_visualizationContainer     = this.left_visualizationBackground+this.border_1p0;
			this.right_visualizationContainer    = newWidth-this.border_2p0-this.height_background-this.border_1p0-this.border_outside;
			this.right_visualizationBackground   = this.right_visualizationContainer+this.border_1p0;
			
			this.width_visualizationBackground   = this.right_visualizationBackground-this.left_visualizationBackground;
			this.width_visualizationContainer    = this.right_visualizationContainer -this.left_visualizationContainer;
			
			this.left_volumeDialBackground  = this.right_visualizationBackground+this.border_1p0;
			this.right_volumeDialBackground = newWidth-this.border_1p0-this.border_outside;
			this.width_volumeDialBackground = this.right_volumeDialBackground-this.left_volumeDialBackground;
			
			this.measure_container_1d5  = this.width_playPauseContainer/5.0;
			this.measure_container_1d10 = this.width_playPauseContainer/10.0;
			this.measure_container_1d25 = this.width_playPauseContainer/25.0;
			this.measure_container_1d50 = this.width_playPauseContainer/50.0;
			this.measure_container_1d2  = this.width_playPauseContainer/2.0;
			this.measure_container_1d3  = this.width_playPauseContainer/3.0;
			this.measure_container_1d6  = this.width_playPauseContainer/6.0;
			this.measure_container_1d30 = this.width_playPauseContainer/30.0;
			this.measure_container_1d15 = this.width_playPauseContainer/15.0;
			this.measure_container_2d15 = this.width_playPauseContainer/7.5;
			
			this.progress_visualizationContainer    = this.displayedProgress*this.width_visualizationContainer;
		}
		
		private function resize_songPlayer(newWidth:int, newHeight:int):void
		{
			this.songPlayerContainerSprite.x = 0;
			this.songPlayerContainerSprite.y = 0;
			
			this.songPlayerContainerSprite.graphics.clear();
			
			this.songPlayerContainerSprite.graphics.beginFill(this.settingsObject["songPlayerOutsideBorderColor"], this.settingsObject["songPlayerOutsideBorderAlpha"]);
			this.songPlayerContainerSprite.graphics.drawRoundRect(0,0,newWidth,newHeight,this.settingsObject["cornerRadii"]);
			this.songPlayerContainerSprite.graphics.endFill();
			
			this.songPlayerContainerSprite.graphics.beginFill(this.settingsObject["songPlayerBackgroundColor"], this.settingsObject["songPlayerBackgroundAlpha"]);
			this.songPlayerContainerSprite.graphics.drawRoundRect(this.border_outside,this.border_outside,newWidth-(this.border_outside*2),newHeight-(this.border_outside*2),this.settingsObject["cornerRadii"]);
			this.songPlayerContainerSprite.graphics.endFill();
			
			// play pause background.
			this.songPlayerContainerSprite.graphics.beginFill(this.settingsObject["componentsBackgroundColor"], this.settingsObject["componentsBackgroundAlpha"]);
			this.songPlayerContainerSprite.graphics.drawRoundRect(this.border_1p0+this.border_outside,this.border_1p0+this.border_outside,this.height_background,this.height_background,this.settingsObject["cornerRadii"]);
			this.songPlayerContainerSprite.graphics.endFill();
			
			// visualization background.
			this.songPlayerContainerSprite.graphics.beginFill(this.settingsObject["componentsBackgroundColor"], this.settingsObject["componentsBackgroundAlpha"]);
			this.songPlayerContainerSprite.graphics.drawRoundRect(this.left_visualizationBackground,this.top_background,this.width_visualizationBackground,this.height_background,this.settingsObject["cornerRadii"]);
			this.songPlayerContainerSprite.graphics.endFill();
			
			this.songPlayerContainerSprite.graphics.beginFill(this.settingsObject["visualizationUnderColor"], this.settingsObject["visualizationUnderAlpha"]);
			this.songPlayerContainerSprite.graphics.drawRoundRect(this.left_visualizationContainer,this.top_container,this.width_visualizationContainer,this.height_container,this.settingsObject["cornerRadii"]);
			this.songPlayerContainerSprite.graphics.endFill();
		}
		
		private function resize_toolbarDropdown(newWidth:int, newHeight:int):void
		{	
			this.volumeDialTickersGlowFilter = new GlowFilter(this.settingsObject["volumeTickersGlowColor"],this.settingsObject["volumeTickersGlowAlpha"],this.measure_container_1d5,this.measure_container_1d5);
			
			this.volumeDialContainerSprite.x = this.left_volumeDialBackground;
			this.volumeDialContainerSprite.y = this.top_background;
			
			this.volumeDialContainerSprite.graphics.clear();
			this.volumeDialContainerSprite.graphics.beginFill(this.settingsObject["componentsBackgroundColor"], this.settingsObject["componentsBackgroundAlpha"]);
			this.volumeDialContainerSprite.graphics.drawRoundRect(0,0,this.width_volumeDialBackground,this.height_background,this.settingsObject["cornerRadii"]);
			this.volumeDialContainerSprite.graphics.endFill();
			
			this.volumeDialClearCoverSprite.graphics.clear();
			this.volumeDialClearCoverSprite.graphics.beginFill(0x000000,0.0);
			this.volumeDialClearCoverSprite.graphics.drawRoundRect(0,0,this.width_volumeDialBackground,this.height_background,this.settingsObject["cornerRadii"]);
			this.volumeDialClearCoverSprite.graphics.endFill();
			
			this.volumeDialSpeakerShape.x = this.height_background_1d2;
			this.volumeDialSpeakerShape.y = this.height_background_1d2;
			
			this.volumeDialSpeakerShape.graphics.clear();
			this.volumeDialSpeakerShape.graphics.beginFill(this.settingsObject["volumeSpeakerColor"]);
			this.volumeDialSpeakerShape.graphics.lineStyle(this.border_0p5,this.settingsObject["volumeTickersGlowColor"]);

			this.volumeDialSpeakerShape.graphics.moveTo(this.measure_container_1d15-this.measure_container_1d6,0);
			this.volumeDialSpeakerShape.graphics.lineTo(this.measure_container_1d6-this.measure_container_1d15,this.measure_container_1d6);
			this.volumeDialSpeakerShape.graphics.lineTo(this.measure_container_1d6-this.measure_container_1d15,-this.measure_container_1d6);
			this.volumeDialSpeakerShape.graphics.lineTo(this.measure_container_1d15-this.measure_container_1d6,0);
			this.volumeDialSpeakerShape.graphics.endFill();
			
			this.volumeDialSpeakerShape.graphics.lineStyle(this.border_0p5,this.settingsObject["volumeTickersGlowColor"]);
			this.volumeDialSpeakerShape.graphics.beginFill(this.settingsObject["volumeSpeakerColor"]);
			this.volumeDialSpeakerShape.graphics.drawRect(this.measure_container_1d15-this.measure_container_1d6,-this.measure_container_1d15,this.measure_container_1d15,this.measure_container_2d15);
			
			this.volumeDialSpeakerShape.filters = [this.volumeDialTickersGlowFilter];
			
			this.volumeDialBackgoundTickerShape.x = this.width_volumeDialBackground/2;
			this.volumeDialBackgoundTickerShape.y = this.height_background/2;
			
			var startVolumeTickRad :Number = 0.0;
			var endVolumeTickRad   :Number = 0.0;
			var rad                :Number = 0.0;
			
			var startTickHypotenuse :Number = this.height_background_1d2*0.6;
			var endTickHypotenuse   :Number = this.height_background_1d2*0.9;
			
			this.volumeDialBackgoundTickerShape.graphics.clear();
			this.volumeDialBackgoundTickerShape.graphics.beginFill(this.settingsObject["volumeLevelBackgroundIndColor"], this.settingsObject["volumeLevelBackgroundIndAlpha"]);
			
			for( var i:Number=21; i >=3; --i )
			{
				rad                = i * this.volumeTickerIncrementRad;
				startVolumeTickRad = rad-this.volumeTickerWidthPlusMinusRad;
				endVolumeTickRad   = rad+this.volumeTickerWidthPlusMinusRad;
				
				this.volumeDialBackgoundTickerShape.graphics.moveTo(startTickHypotenuse*Math.sin(startVolumeTickRad),startTickHypotenuse*Math.cos(startVolumeTickRad));
				this.volumeDialBackgoundTickerShape.graphics.lineTo(endTickHypotenuse*Math.sin(startVolumeTickRad),endTickHypotenuse*Math.cos(startVolumeTickRad));
				this.volumeDialBackgoundTickerShape.graphics.lineTo(endTickHypotenuse*Math.sin(endVolumeTickRad),endTickHypotenuse*Math.cos(endVolumeTickRad));
				this.volumeDialBackgoundTickerShape.graphics.lineTo(startTickHypotenuse*Math.sin(endVolumeTickRad),startTickHypotenuse*Math.cos(endVolumeTickRad));
				this.volumeDialBackgoundTickerShape.graphics.lineTo(startTickHypotenuse*Math.sin(startVolumeTickRad),startTickHypotenuse*Math.cos(startVolumeTickRad));
			}
			
			this.volumeDialTickersMaskShape.x = this.volumeDialTickersMaskShape.y = this.height_background_1d2;
			
			this.volumeDialTickersShape.mask = this.volumeDialTickersMaskShape;
			this.drawVolumeDialTickersMaskWithRadians(this.volumeRadiansFromLevel(this.volumeLevelPercent));			
			
			this.volumeDialTickersShape.x = this.height_background_1d2;
			this.volumeDialTickersShape.y = this.height_background_1d2;
			
			this.volumeDialTickersShape.graphics.clear();
			
			this.volumeDialTickersHoverShape.x = this.height_background_1d2;
			this.volumeDialTickersHoverShape.y = this.height_background_1d2;
			
			this.volumeDialTickersHoverShape.graphics.clear();
			this.volumeDialTickersHoverShape.visible = false;
			this.volumeDialTickersHoverShape.filters = [this.volumeDialTickersGlowFilter];
			
			for( i=21; i>=3; --i )
			{
				this.volumeDialTickersShape.graphics.beginFill(this.settingsObject["volumeLevelIndColor"], 1-(i-1)/24.0);
				
				rad                = i * this.volumeTickerIncrementRad;
				startVolumeTickRad = rad-this.volumeTickerWidthPlusMinusRad;
				endVolumeTickRad   = rad+this.volumeTickerWidthPlusMinusRad;
				
				this.volumeDialTickersShape.graphics.moveTo(startTickHypotenuse*Math.sin(startVolumeTickRad),startTickHypotenuse*Math.cos(startVolumeTickRad));
				this.volumeDialTickersShape.graphics.lineTo(endTickHypotenuse*Math.sin(startVolumeTickRad),endTickHypotenuse*Math.cos(startVolumeTickRad));
				this.volumeDialTickersShape.graphics.lineTo(endTickHypotenuse*Math.sin(endVolumeTickRad),endTickHypotenuse*Math.cos(endVolumeTickRad));
				this.volumeDialTickersShape.graphics.lineTo(startTickHypotenuse*Math.sin(endVolumeTickRad),startTickHypotenuse*Math.cos(endVolumeTickRad));
				this.volumeDialTickersShape.graphics.lineTo(startTickHypotenuse*Math.sin(startVolumeTickRad),startTickHypotenuse*Math.cos(startVolumeTickRad));
			
				this.volumeDialTickersHoverShape.graphics.beginFill(this.settingsObject["volumeLevelIndHoverColor"], 1-(i-1)/24.0);
				
				this.volumeDialTickersHoverShape.graphics.moveTo(startTickHypotenuse*Math.sin(startVolumeTickRad),startTickHypotenuse*Math.cos(startVolumeTickRad));
				this.volumeDialTickersHoverShape.graphics.lineTo(endTickHypotenuse*Math.sin(startVolumeTickRad),endTickHypotenuse*Math.cos(startVolumeTickRad));
				this.volumeDialTickersHoverShape.graphics.lineTo(endTickHypotenuse*Math.sin(endVolumeTickRad),endTickHypotenuse*Math.cos(endVolumeTickRad));
				this.volumeDialTickersHoverShape.graphics.lineTo(startTickHypotenuse*Math.sin(endVolumeTickRad),startTickHypotenuse*Math.cos(endVolumeTickRad));
				this.volumeDialTickersHoverShape.graphics.lineTo(startTickHypotenuse*Math.sin(startVolumeTickRad),startTickHypotenuse*Math.cos(startVolumeTickRad));
			}
		}
		
		private function resize_playPauseButton(newWidth:int, newHeight:int):void
		{	
			this.playPauseClearCoverSprite.x = this.left_playPauseBackGround;
			this.playPauseClearCoverSprite.y = this.top_container;
			this.playPauseClearCoverSprite.alpha = 0.0;
			this.playPauseClearCoverSprite.graphics.clear();
			this.playPauseClearCoverSprite.graphics.beginFill(0x000000);
			this.playPauseClearCoverSprite.graphics.drawRoundRect(0,0,this.width_playPauseContainer,this.height_container,this.settingsObject["cornerRadii"]);
			this.playPauseClearCoverSprite.graphics.endFill();
			
			this.playSymbolShape.x = this.left_playPauseContainer;
			this.playSymbolShape.y = this.top_container;
			this.playSymbolShape.graphics.clear();
			this.playSymbolShape.graphics.lineStyle(this.border_0p5,this.settingsObject["componentsBackgroundColor"]);
			this.playSymbolShape.graphics.beginFill(this.settingsObject["playPauseSymbolColor"]);
			this.playSymbolShape.graphics.moveTo((this.width_playPauseContainer*0.25),(this.height_container*0.20)); 
			this.playSymbolShape.graphics.lineTo((this.width_playPauseContainer*0.25),(this.height_container*0.80));
			this.playSymbolShape.graphics.lineTo((this.width_playPauseContainer*0.80),(this.height_container*0.5));
			this.playSymbolShape.graphics.lineTo((this.width_playPauseContainer*0.25),(this.height_container*0.20));
			this.playSymbolShape.graphics.endFill();
			
			this.playPauseHoverGlowFilter = new GlowFilter(this.settingsObject["playPauseGlowColor"],this.settingsObject["playPauseGlowAlpha"],this.measure_container_1d2,this.measure_container_1d2, 2); 
			
			this.playSymbolHoverShape.x = this.left_playPauseContainer;
			this.playSymbolHoverShape.y = this.top_container;
			this.playSymbolHoverShape.graphics.clear();
			this.playSymbolHoverShape.graphics.beginFill(this.settingsObject["playPauseHoverColor"]);
			this.playSymbolHoverShape.graphics.moveTo((this.width_playPauseContainer*0.25),(this.height_container*0.20)); 
			this.playSymbolHoverShape.graphics.lineTo((this.width_playPauseContainer*0.25),(this.height_container*0.80));
			this.playSymbolHoverShape.graphics.lineTo((this.width_playPauseContainer*0.80),(this.height_container*0.5));
			this.playSymbolHoverShape.graphics.lineTo((this.width_playPauseContainer*0.25),(this.height_container*0.20));
			this.playSymbolHoverShape.graphics.endFill();
			this.playSymbolHoverShape.filters = [this.playPauseHoverGlowFilter];
			
			this.pauseSymbolShape.x = this.left_playPauseContainer;
			this.pauseSymbolShape.y = this.top_container;
			this.pauseSymbolShape.graphics.clear();
			this.pauseSymbolShape.graphics.lineStyle(this.border_0p5,this.settingsObject["componentsBackgroundColor"]);
			this.pauseSymbolShape.graphics.beginFill(this.settingsObject["playPauseSymbolColor"]);
			this.pauseSymbolShape.graphics.drawRect(this.measure_container_1d5  ,this.measure_container_1d5,this.measure_container_1d5,this.measure_container_1d5*3);
			this.pauseSymbolShape.graphics.drawRect(this.measure_container_1d5*3,this.measure_container_1d5,this.measure_container_1d5,this.measure_container_1d5*3);
			this.pauseSymbolShape.graphics.endFill();
			
			this.pauseSymbolHoverShape.x = this.left_playPauseContainer;
			this.pauseSymbolHoverShape.y = this.top_container;
			this.pauseSymbolHoverShape.graphics.clear();
			this.pauseSymbolHoverShape.graphics.beginFill(this.settingsObject["playPauseHoverColor"]);
			this.pauseSymbolHoverShape.graphics.drawRect(this.measure_container_1d5  ,this.measure_container_1d5,this.measure_container_1d5,this.measure_container_1d5*3);
			this.pauseSymbolHoverShape.graphics.drawRect(this.measure_container_1d5*3,this.measure_container_1d5,this.measure_container_1d5,this.measure_container_1d5*3);
			this.pauseSymbolHoverShape.graphics.endFill();
			this.pauseSymbolHoverShape.filters = [this.playPauseHoverGlowFilter];
		}
		
		private function resize_visualizationBox(newWidth:int, newHeight:int):void
		{			
			this.progress_visualizationContainer = this.downloadProgress*this.width_visualizationContainer;
			
			// visualization container.
			this.visualizationContainerSprite.x = this.left_visualizationContainer;
			this.visualizationContainerSprite.y = this.top_container;
			this.visualizationContainerSprite.graphics.clear();
			this.visualizationContainerSprite.graphics.beginFill(this.settingsObject["visualizationContainerColor"], this.settingsObject["visualizationContainerAlpha"]);
			this.visualizationContainerSprite.graphics.drawRoundRect(0,0,this.progress_visualizationContainer,this.height_container,this.settingsObject["cornerRadii"]);
			this.visualizationContainerSprite.graphics.endFill();
			
			this.visualization.resize(this.progress_visualizationContainer,this.height_container);
			
			// Time Position Indicator Symbol
			this.timePositionIndicatorMasksShape.x = this.left_visualizationContainer;
			this.timePositionIndicatorMasksShape.y = this.top_container;
			this.timePositionIndicatorMasksShape.graphics.clear();
			this.timePositionIndicatorMasksShape.graphics.beginFill(this.settingsObject["timePositionIndNormalColor"]);
			this.timePositionIndicatorMasksShape.graphics.drawRoundRect(0,0,this.downloadProgress*this.width_visualizationContainer,this.height_container,this.settingsObject["cornerRadii"]);
			this.timePositionIndicatorMasksShape.graphics.endFill();
			
			this.timePositionIndicatorContainerSprite.mask = this.timePositionIndicatorMasksShape;
			
			// Time Position Indicator Text
			this.timePositionIndicatorTextFormat.font = this.settingsObject['fontFamily'];
			this.timePositionIndicatorTextFormat.size = this.textHeight * this.settingsObject['fontSizeScale'];
			this.timePositionIndicatorTextFormat.align = 'right';
			this.timePositionIndicatorTextFormat.italic = true;
			
			var dropShadowFilter:DropShadowFilter = new DropShadowFilter();
			if (this.settingsObject['albumAttributesTextShadowColor']) 
			{
				dropShadowFilter.color = this.settingsObject['albumAttributesTextShadowColor'];
			}
			
			var dropShadowFilterArray:Array = [dropShadowFilter];
			
			this.timePositionIndicatorTextBox.x                 = this.right_visualizationContainer - this.height_container - this.border_4p0;
			this.timePositionIndicatorTextBox.y                 = this.top_container + this.border_2p0;
			this.timePositionIndicatorTextBox.height            = this.textHeight;
			this.timePositionIndicatorTextBox.width             = this.height_container
			this.timePositionIndicatorTextBox.textColor         = this.settingsObject["timeIndTextColor"];
			this.timePositionIndicatorTextBox.setTextFormat(this.timePositionIndicatorTextFormat);
			this.timePositionIndicatorTextBox.defaultTextFormat = this.timePositionIndicatorTextFormat;
		    this.timePositionIndicatorTextBox.embedFonts        = true	
			this.timePositionIndicatorTextBox.filters           = dropShadowFilterArray;	
				
			this.timePositionIndicatorTextBox.text = this.minutesSecondsStringFromMillis(this.soundChannel.position);
			
			// Song Attributes Text.
			this.timePositionIndicatorTextFormat.align = "center";
			
			this.albumArtistTextField.x                 = this.left_visualizationContainer;
			this.albumArtistTextField.y                 = this.height_background_1d2 - (this.textHeight*1.0);
			this.albumArtistTextField.width             = this.width_visualizationBackground;
			this.albumArtistTextField.height            = this.textHeight;
			this.albumArtistTextField.textColor         = this.settingsObject["albumAttributesTextColor"];
			this.albumArtistTextField.setTextFormat(this.timePositionIndicatorTextFormat);
			this.albumArtistTextField.defaultTextFormat = this.timePositionIndicatorTextFormat;
			this.albumArtistTextField.embedFonts        = true;
			this.albumArtistTextField.text              = this.settingsObject["albumArtistText"]==null ? "" : this.settingsObject["albumArtistText"];	
			this.albumArtistTextField.filters           = dropShadowFilterArray;
			
			this.albumSongTextField.x                 = this.left_visualizationContainer;
			this.albumSongTextField.y                 = this.height_background_1d2
			this.albumSongTextField.width             = this.width_visualizationBackground;
			this.albumSongTextField.height            = this.textHeight;
			this.albumSongTextField.textColor         = this.settingsObject["albumAttributesTextColor"];
			this.albumSongTextField.setTextFormat(this.timePositionIndicatorTextFormat);
			this.albumSongTextField.defaultTextFormat = this.timePositionIndicatorTextFormat;
			this.albumSongTextField.embedFonts        = true;	
			this.albumSongTextField.text              = this.settingsObject["albumSongText"]==null ? "" : this.settingsObject["albumSongText"];	
			this.albumSongTextField.filters           = dropShadowFilterArray;
			
			this.albumNameTextField.x                 = this.left_visualizationContainer;
			this.albumNameTextField.y                 = this.height_background_1d2 + (this.textHeight*1.0);
			this.albumNameTextField.width             = this.width_visualizationBackground;
			this.albumNameTextField.height            = this.textHeight;
			this.albumNameTextField.textColor         = this.settingsObject["albumAttributesTextColor"];
			this.albumNameTextField.setTextFormat(this.timePositionIndicatorTextFormat);
			this.albumNameTextField.defaultTextFormat = this.timePositionIndicatorTextFormat;
			this.albumNameTextField.embedFonts        = true;	
			this.albumNameTextField.text              = this.settingsObject["albumNameText"]==null ? "" : this.settingsObject["albumNameText"];	
			this.albumNameTextField.filters           = dropShadowFilterArray;
		}
		
		private function resize_timePositionIndicator(newWidth:int, newHeight:int):void
		{
			// Get the percent Played.
			this.timePositionPercent = this.soundChannel.position/this.soundLength;
			this.timePositionX       = this.width_visualizationContainer*this.timePositionPercent;
			
			// Position the Indicator.
			this.timePositionIndicatorContainerSprite.x = this.left_visualizationContainer;
			this.timePositionIndicatorContainerSprite.y = this.top_container;
			
			// Set up the gradient matrix for normal and hover states.
			this.matrix.createGradientBox(this.measure_container_1d10-0.5, this.height_container, 0, 0, 0);
			
			// Draw the background gradient for normal state.
			this.timePositionIndicatorNormalShape.x = timePositionX-this.measure_container_1d10;
			this.timePositionIndicatorNormalShape.y = 0;
			this.timePositionIndicatorNormalShape.graphics.clear();
			this.timePositionIndicatorNormalShape.graphics.beginGradientFill(fillType, colorsNormal, alphas, ratios, matrix, spreadMethod);
			this.timePositionIndicatorNormalShape.graphics.drawRect(0,0,this.measure_container_1d5,this.height_container);
			this.timePositionIndicatorNormalShape.graphics.endFill();
			
			// Draw the top triangle ticker for normal state.
			this.timePositionIndicatorNormalShape.graphics.beginFill(this.settingsObject["timeIndNormalColor"]);
			this.timePositionIndicatorNormalShape.graphics.moveTo(0,0/*(-1*(this.border_0p5/2))*/); 
			this.timePositionIndicatorNormalShape.graphics.lineTo(this.measure_container_1d5,0);
			this.timePositionIndicatorNormalShape.graphics.lineTo((this.measure_container_1d10),(this.measure_container_1d5));
			this.timePositionIndicatorNormalShape.graphics.lineTo(0,0);
			
			// Draw the bottom triangle ticker for normal state.
			this.timePositionIndicatorNormalShape.graphics.beginFill(this.settingsObject["timeIndNormalColor"]);
			this.timePositionIndicatorNormalShape.graphics.moveTo(0,height_container); 
			this.timePositionIndicatorNormalShape.graphics.lineTo(this.measure_container_1d5,this.height_container);
			this.timePositionIndicatorNormalShape.graphics.lineTo(this.measure_container_1d10,(this.height_container-this.measure_container_1d5));
			this.timePositionIndicatorNormalShape.graphics.lineTo(0,this.height_container);
			this.timePositionIndicatorNormalShape.graphics.endFill();
			
			// Draw the background gradient for hover state.
			this.timePositionIndicatorHoverShape.x = timePositionX-this.measure_container_1d10;
			this.timePositionIndicatorHoverShape.y = 0;
			this.timePositionIndicatorHoverShape.graphics.clear();
			this.timePositionIndicatorHoverShape.graphics.beginGradientFill(fillType, colorsHover, alphas, ratios, matrix, spreadMethod);
			this.timePositionIndicatorHoverShape.graphics.drawRect(0,0,this.measure_container_1d5,this.height_container);
			this.timePositionIndicatorHoverShape.graphics.endFill();
			
			// Draw the top triangle ticker for hover state.
			this.timePositionIndicatorHoverShape.graphics.beginFill(this.settingsObject["timeIndHoverColor"]);
			this.timePositionIndicatorHoverShape.graphics.moveTo(0,0/*(-1*(this.border_0p5/2))*/); 
			this.timePositionIndicatorHoverShape.graphics.lineTo(this.measure_container_1d5,0);
			this.timePositionIndicatorHoverShape.graphics.lineTo((this.measure_container_1d10),(this.measure_container_1d5));
			this.timePositionIndicatorHoverShape.graphics.lineTo(0,0);
			
			// Draw the bottom triangle ticker for hover state.
			this.timePositionIndicatorHoverShape.graphics.beginFill(this.settingsObject["timeIndHoverColor"]);
			this.timePositionIndicatorHoverShape.graphics.moveTo(0,height_container); 
			this.timePositionIndicatorHoverShape.graphics.lineTo(this.measure_container_1d5,this.height_container);
			this.timePositionIndicatorHoverShape.graphics.lineTo(this.measure_container_1d10,(this.height_container-this.measure_container_1d5));
			this.timePositionIndicatorHoverShape.graphics.lineTo(0,this.height_container);
		}
		
		private function resize_volumeControl(newWidth:int, newHeight:int):void
		{
		}
		
		private function minutesSecondsStringFromMillis (millis:int) : String
		{
			var seconds:int = (millis / 1000) % 60;
			var minutes:int = millis / 60000;
			
			return new String(minutes+":"+(seconds<10?"0":"")+seconds+"  ");
		}
		
		private function get soundLength():Number
		{
			if( this.downloadIsComplete )
				return this.sound.length;
			
			return this.soundLengthEstimated;
		}
		
		private function safeDivide(numerator:Number, denominator:Number):Number
		{
			if( denominator == 0 )
				return 0;
			
			return numerator/denominator;
		}
	}
}