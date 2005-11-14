require 'test/unit'
require 'audio'

class SndfileTest < Test::Unit::TestCase
  include Audio
  def test_channel
    c = Channel.new(5,10)
    assert_equal :float, c.type
    assert_equal 10, c.size

    c = Channel.char(20)
    assert_equal :byte, c.type
    assert_equal 20, c.size

    c = Channel.short(10)
    assert_equal :sint, c.type
    assert_equal 10, c.size

    c = Channel.long(10)
    assert_equal :int, c.type
    assert_equal 10, c.size

    c = Channel.sfloat(10)
    assert_equal :sfloat, c.type
    assert_equal 10, c.size

    c = Channel.double(10)
    assert_equal :float, c.type
    assert_equal 10, c.size
  end

  def test_sound
    s = Sound.new(10)
    assert_equal 10, s.size
    assert_equal 1, s.channels.size
    assert_equal :sfloat, s.type
    assert s.channels.frozen?
    s.channels.each do |c|
      assert_kind_of NArray, c
      assert_instance_of Channel, c
      assert_equal 10, c.size
    end

    s = Sound.new(10,2,:double)
    assert_equal 2, s.channels.size
    assert_equal :float, s.type
    assert_equal 10, s.length

    assert_nothing_raised do
      s.channels[1][5] = 0.42
      s[4] = 0.24
      s[3] = [0.24, 0.42]
    end
    assert_equal [0.24, 0.42], s[3]
    assert_equal [0.24, 0.24], s[4]
    assert_equal [0.0, 0.42], s[5]

    assert_raise TypeError do
      s.channels[0] = nil
    end

    s.resize!(20)
    assert_equal 20, s.size
    assert_equal [0.24, 0.42], s[3]
    assert_equal [0.24, 0.24], s[4]
    assert_equal [0.0, 0.42], s[5]

    s.resize!(6)
    assert_equal [0.0, 0.42], s[5]

    s.resize!(5)
    assert_raise IndexError do
      s[5]
    end

    s.each_frame do |a|
      assert_instance_of Array, a
      assert_kind_of Numeric, a[0]
      assert_kind_of Numeric, a[1]
    end
  end
end
