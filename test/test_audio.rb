require 'test/unit'
require 'audio'

class AudioTest < Test::Unit::TestCase
  include Audio
  def test_channel
    c = Sound.new(:float,10)
    assert_equal :float, c.type
    assert_equal 10, c.size

    c = Sound.char(20)
    assert_equal :byte, c.type
    assert_equal 20, c.size

    c = Sound.short(10)
    assert_equal :sint, c.type
    assert_equal 10, c.size

    c = Sound.long(10)
    assert_equal :int, c.type
    assert_equal 10, c.size

    c = Sound.sfloat(10)
    assert_equal :sfloat, c.type
    assert_equal 10, c.size

    c = Sound.double(10)
    assert_equal :float, c.type
    assert_equal 10, c.size
  end

  def test_sound
    s = Sound.sfloat(10)
    assert_equal 10, s.size
    assert_equal 1, s.channels
    assert_equal :sfloat, s.type
    s.channels.times do |i|
      c = s.channel(i)
      assert_instance_of NArray, c
      assert_equal 10, c.size
    end

    s = Sound.double(10,2)
    assert_equal 2, s.channels
    assert_equal :float, s.type
    assert_equal 10, s.length

    c = s.channel(1)
    assert_instance_of NArray, c
    assert_equal 10, c.size
    assert_nothing_raised do
      c[5] = 0.42
      s[4] = 0.24
      s[3] = [0.24, 0.42]
    end
    assert_equal [0.24, 0.42], s[3].to_a
    assert_equal [0.24, 0.24], s[4].to_a
    assert_not_equal [0.0, 0.42], s[5].to_a

    s.resize!(20)
    assert_equal 20, s.size
    assert_equal [0.24, 0.42], s[3].to_a
    assert_equal [0.24, 0.24], s[4].to_a

    s.resize!(5)
    assert_equal [0.24, 0.24], s[4].to_a

    s.resize!(4)
    assert_raise IndexError do
      s[4]
    end

    s.each_frame do |a|
      assert_instance_of NArray, a
      assert_kind_of Numeric, a[0]
      assert_kind_of Numeric, a[1]
    end
  end
end
