require 'test/unit'
require 'sndfile'
require 'narray'

class SndfileTest < Test::Unit::TestCase
  include Sndfile
  TEST_WAV='test/what.wav'

  def setup
    @inf = SF_INFO.new
    @sf = sf_open(TEST_WAV,SFM_RDWR,@inf)
    raise "Couldn't open #{TEST_WAV}: #{sf_strerror(@sf)}" if @sf.nil?
  end
  
  def teardown
    sf_close(@sf)
  end

  def test_enums
    enums = {
      SF_FORMAT_WAV          => 0x010000,     
      SF_FORMAT_AIFF         => 0x020000,     
      SF_FORMAT_AU           => 0x030000,     
      SF_FORMAT_RAW          => 0x040000,     
      SF_FORMAT_PAF          => 0x050000,     
      SF_FORMAT_SVX          => 0x060000,     
      SF_FORMAT_NIST         => 0x070000,     
      SF_FORMAT_VOC          => 0x080000,     
      SF_FORMAT_IRCAM        => 0x0A0000,     
      SF_FORMAT_W64          => 0x0B0000,     
      SF_FORMAT_MAT4         => 0x0C0000,     
      SF_FORMAT_MAT5         => 0x0D0000,     
      SF_FORMAT_PVF          => 0x0E0000,     
      SF_FORMAT_XI           => 0x0F0000,     
      SF_FORMAT_HTK          => 0x100000,     
      SF_FORMAT_SDS          => 0x110000,     
      SF_FORMAT_AVR          => 0x120000,     
      SF_FORMAT_WAVEX        => 0x130000,     
      SF_FORMAT_SD2          => 0x160000,     
      SF_FORMAT_FLAC         => 0x170000,     
      SF_FORMAT_CAF          => 0x180000,     
      SF_FORMAT_PCM_S8       => 0x0001,       
      SF_FORMAT_PCM_16       => 0x0002,       
      SF_FORMAT_PCM_24       => 0x0003,       
      SF_FORMAT_PCM_32       => 0x0004,       
      SF_FORMAT_PCM_U8       => 0x0005,       
      SF_FORMAT_FLOAT        => 0x0006,       
      SF_FORMAT_DOUBLE       => 0x0007,       
      SF_FORMAT_ULAW         => 0x0010,       
      SF_FORMAT_ALAW         => 0x0011,       
      SF_FORMAT_IMA_ADPCM    => 0x0012,       
      SF_FORMAT_MS_ADPCM     => 0x0013,       
      SF_FORMAT_GSM610       => 0x0020,       
      SF_FORMAT_VOX_ADPCM    => 0x0021,       
      SF_FORMAT_G721_32      => 0x0030,       
      SF_FORMAT_G723_24      => 0x0031,       
      SF_FORMAT_G723_40      => 0x0032,       
      SF_FORMAT_DWVW_12      => 0x0040,       
      SF_FORMAT_DWVW_16      => 0x0041,       
      SF_FORMAT_DWVW_24      => 0x0042,       
      SF_FORMAT_DWVW_N       => 0x0043,       
      SF_FORMAT_DPCM_8       => 0x0050,       
      SF_FORMAT_DPCM_16      => 0x0051,       
      SF_ENDIAN_FILE         => 0x00000000,   
      SF_ENDIAN_LITTLE       => 0x10000000,   
      SF_ENDIAN_BIG          => 0x20000000,   
      SF_ENDIAN_CPU          => 0x30000000,   
      SF_FORMAT_SUBMASK      => 0x0000FFFF,
      SF_FORMAT_TYPEMASK     => 0x0FFF0000,
      SF_FORMAT_ENDMASK      => 0x30000000
    }

    enums.each_pair do |k,v|
      assert_equal k,v
    end
    assert_equal SF_ERR_UNSUPPORTED_ENCODING, 4
  end

  def test_info
    assert ! sf_format_check(SF_INFO.new)
    assert @inf.frames > 0
    assert_equal 16000, @inf.samplerate
    assert_equal 1, @inf.channels
    assert_equal SF_FORMAT_WAV|SF_FORMAT_PCM_16, @inf.format
    assert_equal 1, @inf.sections
    #assert_equal true, @inf.seekable
    assert sf_format_check(@inf)
  end

  def test_error
    system 'rm -f bogus.wav'
    s = sf_open('bogus.wav',SFM_READ,SF_INFO.new)
    assert_nil s
    assert_equal SF_ERR_UNRECOGNISED_FORMAT, sf_error(nil)
    sf_close(s)
    assert_equal SF_ERR_NO_ERROR, sf_error(@sf)
    assert_equal 'No Error.', sf_strerror(@sf)
    assert_equal 'Supported file format but unsupported encoding.', 
      sf_error_number(4)
  end

  def test_file
    s = sf_open(TEST_WAV,SFM_READ,SF_INFO.new)
    assert_not_nil s
    assert_equal 0, sf_close(s)
  end

  def test_read
    a = NArray.float(1000)
    sf_read_double(@sf, a)
    assert a.max > 0
  end

  def test_write
    a = NArray.float(1000)
    sf_read_double(@sf, a)
    sf2 = nil
    assert_nothing_raised do
      sf2 = sf_open('bogus.wav',SFM_RDWR, @inf)
      sf_write_double(sf2, a)
    end
    b = NArray.float(1000)
    sf_seek(sf2, 0, SEEK_SET)
    sf_read_double(sf2, b)
    assert a == b
    sf_close(sf2)
    system 'rm -f bogus.wav'
  end

  def test_string
    assert_nil sf_get_string(@sf,SF_STR_COMMENT)
  end

  def test_rubization
    sf = Audio::Soundfile.open(TEST_WAV)
    assert_instance_of Audio::Soundfile, sf
    assert sf.format_check
    assert_equal Audio::Soundfile::SF_FORMAT_WAV, 0x010000
    sf.close

    Audio::Soundfile.open(TEST_WAV) do |sf|
      a = sf.read_float(100)
      assert_instance_of Sound, a
      assert a.size <= 100
      assert_equal sf.channels, a.channels

      n = sf.read(a)
      assert n <= a.size
    end
  end
end
