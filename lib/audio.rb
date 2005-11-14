require 'narray'
# TODO: lots of testing, libsndfile, libsamplerate, portaudio
module Audio
  
  # Construct with one of:
  #   Sound.new(:sfloat,len,channels=1)
  #   Sound.byte(len,channels=1)
  #   Sound.sint(len,channels=1)   # short int
  #   Sound.int(len,channels=1)
  #   Sound.sfloat(len,channels=1) # single-precision float
  #   Sound.float(len,channels=1)  # double-precision float
  #
  # See also the NArray documentation.
  #
  # Data is stored interleaved in narray, as an NArray (obviously). Get and set
  # frames with [] and []=, get the raw data via narray. Get only one channel
  # (as a new NArray) with channel.
  class Sound
    # The actual data. Channels are interleaved.
    attr_reader :narray
    # number of channels
    attr_reader :channels

    # type:: one of [:byte,:sint,:int,:sfloat,:float].  See NArray
    #        documentation.  In particular, notice that :float means double
    #        precision float.
    # len:: length in frames
    # channels:: Number of channels
    def initialize(type,len,channels=1)
      raise ArgumentError, "Too few channels" unless channels > 0

      typecode = case type.to_sym
      when :byte,  :char   : 1
      when :sint,  :short  : 2
      when :int,   :long   : 3
      when :sfloat         : 4
      when :float, :double : 5
      else
	raise ArgumentError, "Invalid type"
      end

      @channels = channels
      @narray = NArray.new(typecode, @channels * len)
      @mask = NArray.byte(@narray.size).indgen
      @mask %= @channels
    end

    # The number of frames
    def size
      @narray.size / @channels
    end
    alias_method :length, :size

    # Returns a new NArray with the data from channel i
    def channel(i)
      unless (0...@channels).include? i
	raise IndexError, "Channel index out of range" 
      end
      @narray[@mask.eq(i)]
    end

    # One of [:byte, :sint, :int, :sfloat, :float].
    def type
      [nil,:byte,:sint,:int,:sfloat,:float][@narray.typecode]
    end

    # A frame, i.e. an array containing the samples at position i from each
    # channel. For a two-channel sound:
    #   sound[i] #=> [0.42, 0.12]
    def [](i)
      unless (0...size).include? i
	raise IndexError, "Index out of range"
      end
      j = 2*i
      @narray[j..j+@channels-1]
    end
    alias_method :frame, :[]

    # For a two-channel sound: 
    # 	sound[i] = [0.2, 0.24]
    # 	sound[i] = 0.42 #=> sound[i] = [0.42, 0.42]
    def []=(i,val)
      if Numeric === val
	val = Array.new(@channels,val)
      end
      raise ArgumentError, "Value must be Array or Numeric" unless Array === val
      raise ArgumentError, "Expected Array of size #{@channels}" unless val.size == @channels

      j = 2*i
      @narray[j..j+@channels-1] = val
    end
    alias_method :frame=, :[]=

    def each_frame
      self.size.times do |i|
	yield self[i]
      end
    end
    alias_method :each, :each_frame
    include Enumerable

    def resize!(newlen)
      oldlen = size
      if newlen > oldlen
	old = @narray
	@narray = NArray.new(old.typecode,newlen*@channels)
	@narray[0...oldlen*@channels] = old
      else
	@narray = @narray[0...newlen*@channels]
      end
      size
    end

    def self.byte(len, channels=1)
      self.new(:byte,len,channels)
    end
    def self.sint(len, channels=1)
      self.new(:sint,len,channels)
    end
    def self.int(len, channels=1)
      self.new(:int,len,channels)
    end
    def self.sfloat(len, channels=1)
      self.new(:sfloat,len,channels)
    end
    def self.float(len, channels=1)
      self.new(:float,len,channels)
    end

    # alias class methods
    class << self
      alias_method :char,   :byte
      alias_method :short,  :sint
      alias_method :long,   :int
      alias_method :double, :float
    end
  end

end
