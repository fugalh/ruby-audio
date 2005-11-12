require 'narray'
# TODO: lots of testing, libsndfile, libsamplerate, portaudio
module Audio
  
  # A Sound consists of one or more Channel objects of the same type and
  # length. It provides an interface for working on Channels together. For
  # monophonic work you probably want to deal with a Channel directly.
  class Sound
    # An array of channels
    attr_reader :channels

    # type:: one of [:byte,:sint,:int,:sfloat,:float].  See Channel.  
    #        In particular, notice that :float means double precision float.
    def initialize(len,num_channels=1,type=:sfloat)
      raise ArgumentError, "Too few channels" unless num_channels > 0

      typecode = case type.to_sym
      when :byte,  :char   : 1
      when :sint,  :short  : 2
      when :int,   :long   : 3
      when :sfloat         : 4
      when :float, :double : 5
      else
	raise ArgumentError, "Invalid type"
      end

      @channels = Array.new(num_channels) do
	Channel.new(typecode,len)
      end.freeze
    end

    # Number of samples in each channel.
    def size
      @channels[0].size
    end
    alias_method :length, :size

    # One of :byte, :sint, :int, :sfloat, :float. (See Channel)
    def type
      @channels[0].type
    end

    # A frame, i.e. an array containing the samples at position i from each
    # channel. For a two-channel sound:
    #   sound[i] #=> [0.42, 0.12]
    def [](i)
      @channels.map {|c| c[i]}
    end
    alias_method :frame, :[]

    # For a two-channel sound: 
    # 	sound[i] = [0.2, 0.24]
    # 	sound[i] = 0.42 #=> sound[i] = [0.42, 0.42]
    def []=(i,values)
      if Numeric === values
	values = Array.new(@channels.size,values)
      end
      unless Array === values and values.size == @channels.size
	raise ArgumentError, 'values' 
      end
      @channels.each_with_index do |c,j|
	c[i] = values[j]
      end
      self[i]
    end
    alias_method :frame=, :[]=

    include Enumerable
    def each_frame
      self.size.times do |i|
	yield self[i]
      end
    end
    alias_method :each, :each_frame

    # Resize the sound, padding with 0s or truncating. *Warning*: this replaces
    # the channels, it does not modify them. So any outside references you may
    # have to the channels are orphans.
    def resize(newlen)
      oldlen = self.size
      if newlen > oldlen
	@channels = @channels.map do |c| 
	  c2 = Channel.new(c.typecode,newlen)
	  c2[0...oldlen] = c
	  c2
	end.freeze
      else
	@channels = @channels.map do |c|
	  c[0...newlen]
	end.freeze
      end
      self.size
    end
  end

  # Adapted from the NArray documentation:
  #   Channel.new(typecode, size)	create new Channel. initialize with 0.
  #
  #   Channel.byte(size)		1 byte unsigned integer
  #   Channel.sint(size)		2 byte signed integer
  #   Channel.int(size)			4 byte signed integer
  #   Channel.sfloat(size)		single precision float
  #   Channel.float(size)		double precision float 
  #
  # Channel is a light subclass of NArray. Create one as above. Remember that
  # not everything you can do with NArray makes sense for a Channel, e.g.  more
  # than one dimension probably doesn't make much sense. However, you're free
  # to do whatever evil you want, just don't come crying to me...
  class Channel < NArray
    # One of [:byte,:sint,:int,:sfloat,:float].
    def type
      [:byte,:sint,:int,:sfloat,:float][self.typecode]
    end

    # alias class methods
    class << Channel
      alias_method :char,   :byte
      alias_method :short,  :sint
      alias_method :long,   :int
      alias_method :double, :float
    end
  end
end
