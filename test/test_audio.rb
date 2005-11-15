require 'test/unit'
require 'audio'

class AudioTest < Test::Unit::TestCase
  include Audio
  def test_sound
    %w{byte sint int sfloat float}.each do |t|
      eval "s = Sound.#{t}(10); assert_equal :#{t}, s.type"
    end
    s = Sound.float(6).indgen!
    assert_equal [6,1], s.shape
    assert_equal 1, s.channels
    assert_equal 6, s.frames
    s.reshape!(3,2)
    assert_equal 2, s.channels
    assert_equal 3, s.frames
    assert_equal [[0.0,3.0,1.0,4.0,2.0,5.0]], s.interleave.to_a
    assert_equal 6, s.size

    s = Sound.char(10); assert_equal :byte, s.type
    s = Sound.short(10); assert_equal :sint, s.type
    s = Sound.long(10); assert_equal :int, s.type
    s = Sound.double(10); assert_equal :float, s.type

    s = Sound.sfloat(10)
    assert_equal 10, s.size
    assert_equal 10, s.frames
    assert_equal 1, s.channels
    assert_equal :sfloat, s.type
    assert_kind_of NArray, s
    s.channels.times do |i|
      c = s.channel(i)
      assert_kind_of NArray, c
      assert_instance_of Sound, c
      assert_equal 10, c.size
    end

    s = Sound.double(10,2)
    assert_equal 2, s.channels
    assert_equal :float, s.type
    assert_equal 10, s.frames

    c = s.channel(1)
    assert_instance_of Sound, c
    assert_equal 10, c.size

    s.each_frame do |a|
      assert_instance_of Sound, a
      assert_kind_of Numeric, a[0]
      assert_kind_of Numeric, a[1]
    end
  end
end
