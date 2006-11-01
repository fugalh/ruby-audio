require 'narray'

# TODO: libsamplerate, portaudio
module Audio
  
  # A Sound is a NArray with some audio convenience methods. It should always
  # have the shape <tt>[frames,channels]</tt>. (Even when m=1)
  #
  # *Notice* for NArray users: because most audio libraries do not agree with
  # NArray on type names, Sound.float has a different meaning than
  # NArray.float. Also, the shape of a new Sound is different than you might
  # expect:
  #   s = Sound.float(10)
  #   n = NArray.float(10)
  #   s.shape			#=> [10,1]
  #   n.shape			#=> [10]
  #   s.typecode		#=> 4
  #   n.typecode		#=> 5
  class Sound < NArray

    # Mapping from typecode to type symbols
    TYPES = [nil,:char,:short,:long,:float,:double]

    # typecode:: Same as NArray, or a member of TYPES
    # frames::   Number of frames
    # channels:: Number of channels
    #
    # Note that the resulting shape is always [frames,channels].
    def self.new(typecode,frames,channels=1)
      case typecode
      when String, Symbol
	typecode = TYPES.index(typecode.to_sym)
      end
      super(typecode,frames,channels)
    end

    # One of TYPES
    def type
      TYPES[typecode]
    end

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
      self[] = o.reshape(channels,frames).transpose(1,0)
      self
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
    def deinterleave(channels)
      self.class.deinterleave(self,channels)
    end
    def deinterleave!(channels)
      s = deinterleave(channels)
      reshape!(*s.shape)
      self[] = s
    end

    %w{char short long float double}.each_with_index do |t,i|
      eval "def self.#{t}(frames,channels=1); self.new(#{i+1},frames,channels); end"
    end

    # alias class methods
    class << self
      alias_method :byte,   :char
      alias_method :sint,   :short
      alias_method :int,    :long
      alias_method :sfloat, :float
    end
  end
end
