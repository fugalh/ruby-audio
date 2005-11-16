require 'narray'
# TODO: libsamplerate, portaudio
module Audio
  
  # A Sound is a NArray with some audio convenience methods. It should always
  # have the shape (n,m) where n is the number of frames and m is the number of
  # channels. (Even when m=1)
  class Sound < NArray
    # The number of frames
    def frames
      self.shape[0]
    end

    # The number of channels
    def channels
      self.shape[1]
    end

    # Returns a new Sound with the data from channel i
    def channel(i)
      self[true,i]
    end

    # A frame, i.e. an array containing the samples at position i from each
    # channel. For a two-channel sound:
    #   sound.frame(i) #=> [0.42, 0.12]
    #
    # You may prefer to do this the NArray way: s[i,false]
    def frame(i)
      unless (0...frames).include? i
	raise IndexError, "Index out of range"
      end
      self[i,false]
    end

    # For a two-channel sound:
    #   s.set_frame(i,[0.42,0.24])
    #   s.set_frame(i,0.42) #=> s.set_frame(i,[0.42,0.42])
    #
    # You may prefer to do this the NArray way: s[i,false] = val
    def set_frame(i,val)
      self[i,false] = val
    end

    def each_frame
      frames.times do |i|
	yield frame(i)
      end
    end

    # Return a Sound with the channels interleaved.
    #   Sound[[0,1],[2,3]].interleaved #=> Sound[[0,2,1,3]]
    def interleave
      self.transpose(1,0).reshape!(self.size,1)
    end
    alias_method :interleaved, :interleave

    # Fill this Sound's channels with deinterleaved data.
    #   Sound[[0,0],[0,0]].interleaved = NArray[0,2,1,3] #=> Sound[[0,1],[2,3]]
    def interleave=(o)
      self[] = o2.reshape(channels,frames).transpose(1,0)
    end
    alias_method :interleaved=, :interleave=


    # Creates a new Sound with the specified number of channels from the
    # interleaved data in narray. narray should be evenly divisible by
    # channels.
    def self.deinterleave(narray,channels)
      unless narray.size % channels == 0
	raise ArgumentError, "narray not evenly divisible by channels"
      end
      frames = narray.size/channels
      s = Sound.new(narray.typecode,frames,channels)
      s.interleaved = narray
      s
    end

    %w{byte sint int sfloat float}.each do |t|
      eval "def self.#{t}(frames,channels=1); super(frames,channels); end"
    end

    # alias class methods
    class << self
      alias_method :char,   :byte
      alias_method :short,  :sint
      alias_method :long,   :int
      alias_method :double, :float
    end

    # One of [:byte, :sint, :int, :sfloat, :float].
    def type
      [nil,:byte,:sint,:int,:sfloat,:float][typecode]
    end
  end
end
