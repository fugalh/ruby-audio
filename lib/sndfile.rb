require 'sndfile.so'

module Audio
  # libsndfile[http://www.mega-nerd.com/libsndfile/]
  #
  # = Synopsis
  #   require 'sndfile'
  #   require 'narray'
  #
  #   sf = Audio::Soundfile.open('chunky_bacon.wav')
  #   na = NArray.float(sf.info.frames, sf.info.channels)
  #   sf.read_float(na)
  #   sf.close
  #
  # = Details
  # Refer to the libsndfile api[http://www.mega-nerd.com/libsndfile/api.html].
  #
  # Usage is quite straightforward: drop the +sf_+ prefix, omit the
  # <tt>SNDFILE*</tt> paramter, and use NArray or Numeric instead of (pointer,
  # size) pairs. So, if you have a Soundfile object named +sf+, then
  #   sf_read_float(SNDFILE, float *ptr, sf_count_t items) 
  # becomes
  #   buf = NArray.sfloat(items)
  #   sf.read_float(buf)
  # or
  #   buf = sf.read_float(items)  # creates a new NArray
  #
  # 
  # Exceptions to this pattern are documented below.
  #
  # Constants are accessed as Audio::Soundfile::SF_FORMAT_WAV
  #
  # TODO: s/NArray/Audio::Sound/
  class Soundfile
    # SF_INFO
    attr :info

    # +mode+:: One of <tt>%w{r w rw}</tt>
    # +info+:: Instance of SF_INFO (if nil, it will create a new one)
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

    %w{short int float double}.each do |t|

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

