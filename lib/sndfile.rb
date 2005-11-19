require 'sndfile.so'

module Audio
  # libsndfile[http://www.mega-nerd.com/libsndfile/]
  #
  # = Synopsis
  #   require 'sndfile'
  #   require 'narray'
  #
  #   sf = Audio::Soundfile.open('chunky_bacon.wav')
  #   na = Audio::Sound.float(sf.info.frames, sf.info.channels)
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
  #
  # TODO read/write functions with Sound objects.
  class Soundfile
    # SF_INFO
    attr :info

    # mode:: One of %w{r w rw}
    # info:: Instance of SF_INFO or nil
    def initialize(path, mode='r', info=nil)
      if info.nil?
	info = SF_INFO.new
      end
      
      unless Numeric === mode
	modes = {:r => SFM_READ, :w => SFM_WRITE, :rw => SFM_RDWR}
	mode = modes[mode.to_sym]
      end
      unless [SFM_READ, SFM_WRITE, SFM_RDWR].include? mode
	raise ArgumentError, "Invalid mode" 
      end

      sf = Sndfile.sf_open(path.to_s, mode, info)
      @sf = sf
      @info = info
      if block_given?
	yield self
	self.close
      end
    end

    class << self
      alias_method :open, :new
    end

    # The following are equivalent: 
    #   sf_format_check(info) /* C */
    #   sf.format_check       # ruby
    def format_check
      Sndfile.sf_format_check(@info)
    end

    # Automagic read method. Type is autodetected.
    def read(na)
      sym = "read_#{Sound::TYPES[na.typecode]}".to_sym
      self.send sym, na
    end

    # Automagic write method. Type is autodetected.
    def write(na)
      sym = "write_#{Sound::TYPES[na.typecode]}".to_sym
      self.send sym, na
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

