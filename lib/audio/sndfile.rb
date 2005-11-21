require 'audio'
require 'sndfile.so'

module Audio
  # libsndfile[http://www.mega-nerd.com/libsndfile/]
  #
  # = Synopsis
  #   require 'audio/sndfile'
  #   require 'narray'
  #
  #   sf = Audio::Soundfile.open('chunky_bacon.wav')
  #   na = Audio::Sound.float(sf.frames, sf.channels)
  #   sf.read_float(na)
  #   sf.close
  #
  # = Details
  # Refer to the libsndfile api[http://www.mega-nerd.com/libsndfile/api.html].
  #
  # Usage is quite straightforward: drop the +sf_+ prefix, omit the
  # <tt>SNDFILE*</tt> paramter, and use Sound or Numeric instead of
  # (pointer, size) pairs. So, if you have a Soundfile object named +sf+, then
  #   sf_read_float(SNDFILE, float *ptr, sf_count_t items) 
  # becomes
  #   buf = Sound.float(items)
  #   sf.read_float(buf)
  # or
  #   buf = sf.read_float(items)  # creates a new Sound
  # 
  # Exceptions to this pattern are documented below.
  #
  # Constants are accessed as <tt>Soundfile::SF_FORMAT_WAV</tt>
  class Soundfile
    # SF_INFO
    attr :info
    attr_reader :mode

    # mode:: One of %w{r w rw}
    # info:: Instance of SF_INFO or nil
    def initialize(path, mode='r', info=nil)
      if info.nil?
	info = SF_INFO.new
      end
      
      modes = {:r => SFM_READ, :w => SFM_WRITE, :rw => SFM_RDWR}
      unless Numeric === mode
	mode = modes[mode.to_sym]
      end
      unless [SFM_READ, SFM_WRITE, SFM_RDWR].include? mode
	raise ArgumentError, "Invalid mode" 
      end

      sf = Sndfile.sf_open(path.to_s, mode, info)
      @sf = sf
      @info = info
      @mode = modes.invert[mode]
      if block_given?
	yield self
	self.close
      end
    end

    class << self
      alias_method :open, :new
    end

    def frames
      @info.frames
    end
    def samplerate
      @info.samplerate
    end
    def channels
      @info.channels
    end
    def format
      @info.format
    end
    def sections
      @info.sections
    end
    def seekable
      @info.seekable
    end

    # The following are equivalent: 
    #   sf_format_check(info) /* C */
    #   sf.format_check       # ruby
    def format_check
      Sndfile.sf_format_check(@info)
    end

    TYPES = [nil,:char,:short,:int,:float,:double] #:nodoc:

    # Automagic read method. Type is autodetected.
    def read(na)
      sym = "read_#{TYPES[na.typecode]}".to_sym
      self.send sym, na
    end

    # Automagic write method. Type is autodetected.
    def write(na)
      sym = "write_#{TYPES[na.typecode]}".to_sym
      self.send sym, na
    end

    %w{read readf}.each do |r|
      %w{short int float double}.each do |t|
	tc = TYPES.index(t.to_sym)
	c = ', channels' if r == 'readf'
	cmd = "#{r}_#{t}"
	eval <<-EOF
	  def #{cmd}(arg)
	    if Numeric === arg
	      na = NArray.new(#{tc}, arg#{c})
	      n = Sndfile.sf_#{cmd}(@sf, na)
	      Sound.deinterleave(na, channels)
	    else
	      na = arg
	      n = Sndfile.sf_#{cmd}(@sf, na)
	      na.deinterleave!(channels)
	      n
	    end
	  end
	EOF
      end
    end

    %w{write writef}.each do |w|
      %w{short int float double}.each do |t|
	cmd = "#{w}_#{t}"
	eval <<-EOF
	  def #{cmd}(sound)
	    Sndfile.sf_#{cmd}(sound.interleave)
	  end
	EOF
      end
    end

    def method_missing(name, *args) #:nodoc:
      begin
	Sndfile.send "sf_#{name}".to_sym, @sf, *args
      rescue NameError
	super
      end
    end

    def self.const_missing(sym) #:nodoc:
      begin
	Sndfile.const_get(sym)
      rescue NameError
	super
      end
    end
  end
end

