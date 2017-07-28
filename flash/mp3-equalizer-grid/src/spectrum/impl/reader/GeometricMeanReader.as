package spectrum.impl.reader
{
	import flash.media.SoundMixer;
	import flash.utils.ByteArray;
	
	import spectrum.base.reader.SpectrumReaderBase;
	import spectrum.iface.reader.ISpectrumReader;
	
	public class GeometricMeanReader extends SpectrumReaderBase implements ISpectrumReader
	{
		private var bytes          :ByteArray  = null;
		private var bucketMarkers  :Array      = null;
		private var numBuckets     :Number     = 16;
		private var zeroArray      :Array      = null;
		
		private var SPECTRUM_LENGTH  :Number = 512;
		private var CHANNEL_LENGTH   :Number = 256;
		private var logChannelLength :Number = 8; // log(256)/log(2) = 8 // log base 2 of 256.
		
		public function GeometricMeanReader(settingsObject:Object)
		{
			super(settingsObject);
			
			// Init our butcket widths and spectrum bytes.
			this.bytes         = new ByteArray();
			this.bucketMarkers = this.getBucketMarkers(this.numBuckets);
			
			// Init an array of zeros for a quick clone.
			this.zeroArray = new Array(numBuckets);
			for( var i:uint=0; i<numBuckets; ++i )
			{
				zeroArray[i] = 0;
			}
		}
		
		private function getBucketMarkers( numBuckets:int ):Array
		{			
			var logBucketWidth:Number = this.logChannelLength / numBuckets;
		
			var computedBucketMarkers:Array = new Array(numBuckets-1);
			
			for( var i:uint=1; i<numBuckets; ++i )
			{
				// Hearing is logarithmic. 2^x = frequency (spectrum index).
				computedBucketMarkers[i-1] = Math.round(Math.pow(2,(i*logBucketWidth)));
			}
			
			return computedBucketMarkers;
		}
		
		public function read():Array
		{
			var result:Array;
			
			try 
			{
				SoundMixer.computeSpectrum(bytes, true, 0); // Compute the FFT with sampled at 44.1kHz.
								
				result = byMaximumValues(bytes);
			} 
			catch( e:Error )
			{
				trace("error in GeometricMeanReader.read()");
				trace(e.getStackTrace());
			}
			
			return result;
		}
				
		private function byMaximumValues(computedSpectrum:ByteArray):Array
		{
			var byMax:Array = this.zeroArray.concat(); // shallow clone.
			
			var bucketSpectrumIndexStart:int = 0;
			
			// Left Channel
			for( var bucket:uint=0; bucket<this.numBuckets; ++bucket )
			{
				var bucketSpectrumIndexEnd:uint = bucket==(this.numBuckets-1)?CHANNEL_LENGTH:this.bucketMarkers[bucket];
				
				for( ; bucketSpectrumIndexStart<bucketSpectrumIndexEnd; ++bucketSpectrumIndexStart )
				{
					byMax[bucket] = Math.max(Math.min(1.0,computedSpectrum.readFloat()), byMax[bucket]);
				}
			}
			
			// Right Channel.
			for( bucket=0; bucket<this.numBuckets; ++bucket )
			{
				bucketSpectrumIndexEnd = bucket==(this.numBuckets-1)?this.SPECTRUM_LENGTH:(this.bucketMarkers[bucket]+this.CHANNEL_LENGTH);
				
				for( ; bucketSpectrumIndexStart<bucketSpectrumIndexEnd; ++bucketSpectrumIndexStart )
				{
					var value:Number = Math.max(Math.min(1.0,computedSpectrum.readFloat()), byMax[bucket]);
										
					byMax[bucket] = value;
				}
			}
			
			return byMax;
		}
	}
}