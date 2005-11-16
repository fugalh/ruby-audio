require 'sndfile.so'
require 'delegate'

# The Sndfile module provides access to libsndfile. All functionality at
# http://www.mega-nerd.com/libsndfile/api.html is provided as module methods.
# SNDFILE is an opaque type, as it is in libsndfile. However, the
# Sndfile::Soundfile class is provided to give a more object-oriented
# interface.
#
# *Note*: sf_{read,write}* take an NArray instead of a buffer pointer and
# length. The length is derived from the size of the NArray. The same holds
# true for the Sndfile::Soundfile versions of these calls.
module Sndfile
  class Soundfile
    # SF_INFO
    attr :info

    # You probably want to use Soundfile.open
    def initialize(sf, info)
      @sf, @info = sf, info
    end

    # mode:: Element of %w{r w rw}
    # info:: Instance of SF_INFO (if nil, it will create a new one)
    def self.open(path, mode='r', info=nil)
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
      self.new(sf,info)
    end

    # The following are equivalent: 
    #   sound.format_check
    #   Sndfile.sf_format_check(sound.info)
    def format_check
      Sndfile.sf_format_check(@info)
    end

    # All the sf_* methods that take a SNDFILE* as the first argument are
    # available with the sf_ prefix removed, and the SNDFILE* parameter
    # omitted. For example, 
    #   Sndfile.sf_perror(sf,...) 
    # becomes 
    #   sound.perror(...)
    def method_missing(name, *args)
      begin
	Sndfile.send "sf_"+name, @sf, *args
      rescue NameError
	super
      end
    end
  end
end

