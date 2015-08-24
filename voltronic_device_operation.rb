##
# A convenient immutable object to encapsulate the logic
# of a Voltronic Device operation consisting of:
# Command, parameter validation and result parser
#
# @author: Johan van der Vyver
class VoltronicDeviceOperation
  require 'voltronic_rs232'
  require 'time'

  ##
  # Create a command
  #
  # Input:
  #   command - The human readable ASCII command, use %{input} where input is expected
  #   valid_values (optional) - A regular expression to validate input when input is required
  #   <block> - A block used to parse the output of the command
  def initialize(command, validation = nil, &blk)
    raise ArgumentError.new("Expected in input block to deal with command result") unless block_given?
    @command = command.to_s.chomp.freeze
    @validation = validation.freeze unless validation.nil?
    @result_parser = blk
    freeze
  end

  ##
  # Issue a command to the device and parse the output result
  def issue_command(serial, arg = nil)
    serial.write(command(arg).bytes)
    parse_result(serial)
  end

  ##
  # Create an VoltronicRS232 object containing a command
  # and optional parameter to execute on the device
  def command(arg = nil)
    cmd = @command.to_s.dup
    if !arg.nil?
      arg = arg.to_s.dup
      raise ArgumentError.new("'#{arg}' is not valid") if (!@validation.nil && (arg =~ @validation).nil?)
      cmd = cmd % {input: arg.to_s}
    end

    ::VoltronicRS232.new(cmd)
  end

  ##
  # Parse the command output returned from the Voltronic device
  def parse_result(result)
    # Parse the result if it is Serial stream
    if result.is_a?(::IO)
      result.read_timeout = -1 # return immediately
      parse = ''
      timeout = Time.now.to_i + 2 # 2 seconds
      while(true)
        ch = result.getc
        if ch.nil?
          sleep 0.1 # 100ms break
          next
        end
        parse += ch
        break if ("\r" == ch)
        raise IOError.new("IO read timeout reached, giving up") if (Time.now.to_i > timeout)
      end
      result = parse
    end

    @result_parser.yield(::VoltronicRS232.new(result))
  rescue StandardError, ScriptError => err
    err = "#{err.class.name.to_s} thrown; #{err.message.to_s}"
    raise "Could not parse the result (#{err})"
  end

  def to_s
    "#{self.class.name.to_s.split('::').last}('#{@command}')"
  end
end