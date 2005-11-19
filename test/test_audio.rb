require 'test/unit'
require 'audio'

class AudioTest < Test::Unit::TestCase
  include Audio
  def test_sound
    %w{char short long float double}.each do |t|
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

    s = Sound.byte(10); assert_equal :char, s.type
    s = Sound.sint(10); assert_equal :short, s.type
    s = Sound.int(10); assert_equal :long, s.type
    s = Sound.sfloat(10); assert_equal :float, s.type

    s = Sound.sfloat(10)
    assert_equal 10, s.size
    assert_equal 10, s.frames
    assert_equal 1, s.channels
    assert_equal :float, s.type
    assert_kind_of NArray, s
    s.channels.times do |i|
      c = s.channel(i)
      assert_kind_of NArray, c
      assert_instance_of Sound, c
      assert_equal 10, c.size
    end

    s = Sound.double(10,2)
    assert_equal 2, s.channels
    assert_equal 10, s.frames

    c = s.channel(1)
    assert_instance_of Sound, c
    assert_equal 10, c.size

    s.each_frame do |a|
      assert_instance_of Sound, a
      assert_kind_of Numeric, a[0]
      assert_kind_of Numeric, a[1]
    end

    # test new
    s = Sound.new(4,10)
    assert_equal [10,1], s.shape
    assert_equal 10, s.size
    assert_equal 4, s.typecode
    assert_equal :float, s.type
    assert_equal 10, s.frames
    assert_equal 1, s.channels

    s = Sound.new(:long,10)
    assert_equal [10,1], s.shape
    assert_equal 10, s.size
    assert_equal 3, s.typecode
    assert_equal :long, s.type
    assert_equal 10, s.frames
    assert_equal 1, s.channels
  end

  def test_interleave
    s = Sound.float(2,2).indgen!
    i = s.interleave
    assert_equal s[0,0], i[0]
    assert_equal s[0,1], i[1]

    s2 = Sound.deinterleave(i,2)
    assert_equal s, s2

    s2.interleave = i
    assert_equal s, s2
  end
end
