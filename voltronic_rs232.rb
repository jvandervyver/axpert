##
# Simple immutable object representing the Voltronic RS232 protocol
#
# @author: Johan van der Vyver
class VoltronicRS232
  ##
  # The human readable command to be sent to the device
  attr_reader :data

  ##
  # The calculated CRC for the data
  attr_reader :crc

  ##
  # The encoded data that will be transmitted over the wire
  # Format: <DATA><CRC><CR>
  attr_reader :bytes

  def initialize(data) #:nodoc:
    data = data.to_s
    parse_test = data.encode(Encoding.find('ASCII'), {invalid: :replace, undef: :replace, replace: ''})
    data = ((data == parse_test) ? data.chomp : data.chars[0..-4].join)
    @crc = calculate_crc(data.bytes.to_a).map { |b| b.chr }.join.freeze
    @data = data.dup.freeze
    @bytes = "#{@data}#{@crc}\r".freeze
    self.freeze
  end

  def to_s #:nodoc:
    "#{self.class.name.to_s.split('::').last}(data: '#{data}')"
  end

  def inspect #:nodoc:
    to_s
  end

  def ==(other) #:nodoc:
    return true if self.equal?(other)
    return false if other.nil?
    return false unless other.respond_to?(:bytes)
    (self.bytes == other.bytes)
  end

  private

  # CRC calculation source: http://forums.aeva.asn.au/pip4048ms-inverter_topic4332_post53760.html#53760
  def calculate_crc(pin) #:nodoc:
    crc, da = 0, 0
    for index in 0..(pin.length-1)
      da = byte(byte(crc >> 8) >> 4)
      crc = short(short(crc << 4) ^ CRC_TABLE[byte(da ^ byte(pin[index] >> 4))])
      da = byte(byte(crc >> 8) >> 4)
      crc = short(short(crc << 4) ^ CRC_TABLE[byte(da ^ byte(pin[index] & 0x0f))])
    end

    crc_low, crc_high = byte(crc & 0x00FF), byte(crc >> 8)
    crc_low = short(crc_low + 1) if CRC_MOD.include?(crc_low)
    crc_high = short(crc_high + 1) if CRC_MOD.include?(crc_high)
    crc = short(short(crc_high << 8) | crc_low)
    [byte(short(crc >> 8) & 0xff), byte(crc & 0xff)]
  end

  def byte(input) #:nodoc:
    (input & 255)
  end

  def short(input) #:nodoc:
    (input & 65535)
  end

  CRC_TABLE = [0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50a5, 0x60c6, 0x70e7,
               0x8108, 0x9129, 0xa14a, 0xb16b, 0xc18c, 0xd1ad, 0xe1ce, 0xf1ef].freeze #:nodoc:

  CRC_MOD = [0x28, 0x0d, 0x0a].freeze #:nodoc:
end
