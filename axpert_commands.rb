##
# A list of known commands
#
# Commands implemented as constants
# Each command includes the actual command to be executed and a parser for the results of the command
#
# Commands source: http://forums.aeva.asn.au/uploads/293/HS_MS_MSX_RS232_Protocol_20140822_after_current_upgrade.pdf
#
# @author: Johan van der Vyver
module AxpertCommands
  require 'voltronic_device_operation'
  OP = ::VoltronicDeviceOperation # :nodoc

  ##
  # Device protocol ID
  #
  # Returns:
  #    # An Integer specifying the protocol ID
  #    30 # Example
  PROTOCOL_ID = OP.new(command: 'QPI', parser: lambda { |r| Integer(r.data[3..-1]) })

  ##
  # Device serial number
  #
  # Returns:
  #    # A String specifying the device serial number
  #    "XXXXXXXXXXXXXX" # Example
  SERIAL_NUMBER = OP.new(command: 'QID', parser: lambda { |r| r.data[1..-1] })

  ##
  # Main CPU Firmware version
  #
  # Returns:
  #    # A String representing the CPU Firmware as a hexidecimal number
  #    "124004.10" # Example
  MAIN_CPU_FIRMWARE = OP.new(command: 'QVFW', parser: lambda do |r|
    r.data[8..-1].split('.').map { |s| s.chars.map { |c| c.to_i(16).to_s }.flatten.join }.join('.')
  end)

  ##
  # Other CPU Firmware version
  #
  # Returns:
  #    # A String representing the CPU Firmware as a hexidecimal number
  #    "124004.10" # Example
  OTHER_CPU_FIRMWARE = OP.new(command: 'QVFW2', parser: lambda do |r|
    r.data[8..-1].split('.').map { |s| s.chars.map { |c| c.to_i(16).to_s }.flatten.join }.join('.')
  end)

  ##
  # Device rating information
  #
  # Returns:
  #    # A Hash containing device rating information
  #    { grid_voltage: 230.5, grid_current: 11.2, .. }
  DEVICE_RATING = OP.new(command: 'QPIRI', parser: lambda do |r|
    r = r.data[1..-1].split(' ').map { |s| s = Float(s); (s%1==0) ? s.to_i : s }
    { grid_voltage: r[0],
      grid_current: r[1],
      output_voltage: r[2],
      output_frequency: r[3],
      output_current: r[4],
      output_va: r[5],
      output_watts: r[6],
      battery_voltage: r[7],
      battery_recharge_voltage: r[8],
      battery_under_voltage: r[9],
      battery_bulk_charge_voltage: r[10],
      battery_float_charge_voltage: r[11],
      # Absorbent Glass Mat (AGM), Flooded Cell, User defined
      battery_type: [:agm, :flooded, :user][r[12]],
      maximum_ac_charge_current: r[13],
      maximum_charge_current: r[14],
      # Appliance mode, UPS mode
      input_voltage_sensitivity: [:appliance, :ups][r[15]],
      # Utility first, Solar first, Solar -> Battery -> Utility (SBU in manual)
      output_source_priority: [:utility, :solar, :sbu][r[16]],
      # Utility first, Solar first, Solar & Utility, Solar only
      charger_source_priority: [:utility_first, :solar_first, :solar_and_utility, :solar_only][r[17]],
      maximum_parallel_units: r[18],
      # Grid tie, Off-Grid, Hybrid
      device_type: ([:grid_tie, :off_grid] + ['']*8 + [:hybrid])[r[19]],
      # Transformerless, Transformer
      device_topology: [:transformerless, :transformer][r[20]],
      # Single device, Parallel device, Phase 1 of 3, Phase 2 of 3, Phase 3 of 3
      output_mode: [:single, :parallel, :phase1, :phase2, :phase3][r[21]],
      battery_redischarge_voltage: r[22],
      # Only one unit need report OK, All units must report OK
      pv_parallel_ok: [:one, :all][r[23]],
      # Charge current limited,  Charge current + load current
      pv_power_balance: [:charge, :charge_and_load][r[24]], }
  end)


  ##
  # Device flags
  #
  # Returns:
  #    # A Hash containing device flag status as booleans
  #    {enable_buzzer: true/false, nable_bypass_to_utility_on_overload: true/false, ... }
  DEVICE_FLAGS = OP.new(command: 'QFLAG', parser: lambda do |r|
    r = r.data[1..-1].chars.map { |s| ('E' == s.upcase) }
    { enable_buzzer: r[0],
      enable_bypass_to_utility_on_overload: r[1],
      enable_power_saving: r[2],
      enable_lcd_timeout_escape_to_default_page: r[3],
      enable_overload_restart: r[4],
      enable_over_temperature_restart: r[5],
      enable_lcd_backlight: r[6],
      enable_primary_source_interrupt_alarm: r[7],
      enable_fault_code_recording: r[8], }
  end)

  # Device mode
  #
  # Returns:
  #    # The device mode as a Symbol
  #    :power #=> Power on mode
  #    :standby #=> Standby mode
  #    :line #=> Line mode
  #    :battery #=> Battery mode
  #    :fault #=> Fault mode
  DEVICE_MODE = OP.new(command: 'QMOD', parser: lambda do |r|
    { 'P' => :power, # Power on
      'S' => :standby,
      'L' => :line,
      'B' => :battery,
      'F' => :fault, }[r.data[1..-1].upcase].freeze
  end)

  # Device warning status
  DEVICE_WARNING_STATUS = OP.new(command: 'QPIWS', parser: lambda do |r|
    r = r.data[1..-1].downcase.scan(/[a-z][0-9][0-9]?/)
    r.map do |code|
      case code
        when 'a0'
        when 'a1'
        when 'a2'
        when 'a3'
        when 'a4'
        when 'a5'
        when 'a6'
        when 'a7'
        when 'a8'
        when 'a9'
        when 'a10'
        when 'a11'
        when 'a12'
        when 'a13'
        when 'a14'
        when 'a15'
        when 'a16'
        when 'a17'
        when 'a18'
        when 'a19'
        when 'a20'
        when 'a21'
        when 'a22'
        when 'a23'
        when 'a24'
        when 'a25'
        when 'a26'
        when 'a27'
        when 'a28'
        when 'a29'
        when 'a30'
        else
          raise "Unknown code #{code}"
      end
    end
  end)

  ##
  # The device default settings
  #
  # Returns:
  #    # A Hash containing device defaults
  #    { grid_voltage: 230.5, grid_current: 11.2, .. }
  DEFAULT_SETTINGS = OP.new(command: 'QDI', parser: lambda do |r|
    r = r.data[1..-1].split(' ').map { |s| s = Float(s); (s%1==0) ? s.to_i : s }
    { output_voltage: r[0],
      output_frequency: r[1],
      maximum_ac_charge_current: r[2],
      battery_under_voltage: r[3],
      battery_float_charge_voltage: r[4],
      battery_bulk_charge_voltage: r[5],
      battery_recharge_voltage: r[6],
      maximum_charge_current: r[7],
      # Appliance mode, UPS mode
      input_voltage_sensitivity: [:appliance, :ups][r[8]],
      # Utility first, Solar first, Solar -> Battery -> Utility (SBU in manual)
      output_source_priority: [:utility, :solar, :sbu][r[9]],
      # Utility first, Solar first, Solar & Utility, Solar only
      charger_source_priority: [:utility_first, :solar_first, :solar_and_utility, :solar_only][r[10]],
      # Absorbent Glass Mat (AGM), Flooded Cell, User defined
      battery_type: [:agm, :flooded, :user][r[11]],
      enable_buzzer: (0 == r[12]),
      enable_power_saving: (0 == r[13]),
      enable_overload_restart: (0 == r[14]),
      enable_over_temperature_restart: (0 == r[15]),
      enable_lcd_backlight:  (0 == r[16]),
      enable_primary_source_interrupt_alarm: (0 == r[17]),
      enable_fault_code_recording: (0 == r[18]),
      enable_bypass_to_utility_on_overload: (0 == r[19]),
      enable_lcd_timeout_escape_to_default_page: (0 == r[20]),
      # Single device, Parallel device, Phase 1 of 3, Phase 2 of 3, Phase 3 of 3
      output_mode: [:single, :parallel, :phase1, :phase2, :phase3][r[21]],
      battery_redischarge_voltage: r[22],
      # Only one unit need report OK, All units must report OK
      pv_parallel_ok: [:one, :all][r[23]],
      # Charge current limited,  Charge current + load current
      pv_power_balance: [:charge, :charge_and_load][r[24]], }
  end)

  ##
  # Has device undergone DSP bootstrap
  #
  # Returns:
  #    # A Boolean indicating if the device has undergone DSP bootstrap
  #    true # Example
  DSP_BOOTSTRAP_STATUS = OP.new(command: 'QBOOT', parser: lambda { |r| (r.data == '(1') })

  ##
  # Device parallel output mode status
  #
  # Returns:
  #    # A Symbol indicating the current device output mode
  #    :single # => Single device
  #    :parallel # => Parallel device
  #    :phase1 # => Phase 1 of 3
  #    :phase2 # => Phase 2 of 3
  #    :phase3 # => Phase 3 of 3
  PARALLEL_OUTPUT_STATUS = OP.new(command: 'QOPM', parser: lambda { |r| [:single, :parallel, :phase1, :phase2, :phase3][Integer(r.data[1..-1])] })

  ##
  # Reset device to factory defaults
  #
  # Returns:
  #    # A Boolean indicating if the device has reset to defaults succesfully
  #    true # Example
  RESET_TO_DEFAULT = OP.new(command: 'PF', error_on_nak: false, parser: lambda { |r| (r.data == '(ACK') })

  ##
  # Set device output frequency
  #
  # Input:
  #    50 # => Any integer is accepted, consult manual for valid values
  #
  # Returns:
  #    # A Boolean indicating if the frequency was set succesfully
  #    true # Example
  SET_OUTPUT_FREQUENCY = OP.new(command: lambda { |input| "F#{Integer(input).to_s}" }, error_on_nak: false, parser: lambda { |r| (r.data == '(ACK') })

  ##
  # Set device output source priority
  #
  # Input:
  #    :utility # => Utility first
  #    :solar # => Solar first
  #    :sbu # => Solar -> Battery -> Utility (SBU in manual)
  #
  # Returns:
  #    # A Boolean indicating if the output priority was set succesfully
  #    true # Example
  SET_OUTPUT_PRIORITY = OP.new(command: lambda do |input|
    "POP#{case input
            when :utility
              '00'
            when :solar
              '01'
            when :sbu
              '02'
            else
              raise ::ArgumentError.new("Unexpected value #{input}, valid inputs: [:utility, :solar, :sbu]")
          end}"
  end, error_on_nak: false, parser: lambda { |r| (r.data == '(ACK') })

  ##
  # Set battery re-charge voltage
  #
  # Input:
  #    24.3 # => Any float is accepted, consult manual for valid values
  #
  # Returns:
  #    # A Boolean indicating if the recharge voltage was successfully set
  #    true # Example
  SET_BATTERY_RECHARGE_VOLTAGE = OP.new(command: lambda { |input| "PBCV#{Float(input).to_s}" }, error_on_nak: false, parser: lambda { |r| (r.data == '(ACK') })

  ##
  # Set battery re-discharge voltage
  #
  # Input:
  #    24.3 # => Any float is accepted, consult manual for valid values
  #
  # Returns:
  #    # A Boolean indicating if the re-discharge voltage was successfully set
  #    true # Example
  SET_BATTERY_REDISCHARGE_VOLTAGE = OP.new(command: lambda { |input| "PBDV#{Float(input).to_s}" }, error_on_nak: false, parser: lambda { |r| (r.data == '(ACK') })

  ##
  # Set device charger priority
  #
  # Input:
  #    # (REQUIRED) Parameter 0 => mode - The input mode
  #    :utility_first # => Utility first
  #    :solar_first # => Solar first
  #    :solar_and_utility # => Solar & Utility
  #    :solar_only # => Solar only
  #
  #    # (OPTIONAL) Parameter 1 => parallel_machine_number (Parallel mode only)
  #    5 # => Do not pass in this value unless the device is running in parallel mode
  #
  # Returns:
  #    # A Boolean indicating if the device charger priority was set successfully
  #    true # Example
  SET_DEVICE_CHARGER_PRIORITY = OP.new(command: lambda do |mode, parallel_machine_number = nil|
    "#{(parallel_machine_number.nil? ? 'PCP' : "PPCP#{Integer(parallel_machine_number).to_s}")}#{case mode
            when :utility_first
              '00'
            when :solar_first
              '01'
            when :solar_and_utility
              '02'
            when :solar_only
              '03'
            else
              raise ::ArgumentError.new("Unexpected value #{mode}, valid inputs: [:utility_first, :solar_first, :solar_and_utility, :solar_only]")
          end}"
  end, error_on_nak: false, parser: lambda { |r| (r.data == '(ACK') })

  ##
  # Set device input voltage sensitivity
  #
  # Input:
  #    :appliance # => Appliance mode
  #    :ups # => UPS mode
  #
  # Returns:
  #    # A Boolean indicating if the device input voltage sensitivity was set successfully
  #    true # Example
  SET_INPUT_VOLTAGE_SENSITIVITY = OP.new(command: lambda do |input|
    "PGR#{case input
            when :appliance
              '00'
            when :ups
              '01'
            else
              raise ::ArgumentError.new("Unexpected value #{input}, valid inputs: [:appliance, :ups]")
          end}"
  end, error_on_nak: false, parser: lambda { |r| (r.data == '(ACK') })

  ##
  # Set battery type
  #
  # Input:
  #    :agm # => Absorbent Glass Mat (AGM)
  #    :flooded # => Flooded Cell
  #    :user # => User defined
  #
  # Returns:
  #    # A Boolean indicating if the device battery type was set successfully
  #    true # Example
  SET_BATTERY_TYPE = OP.new(command: lambda do |input|
    "POP#{case input
            when :agm
              '00'
            when :flooded
              '01'
            when :user
              '02'
            else
              raise ::ArgumentError.new("Unexpected value #{input}, valid inputs: [:agm, :flooded, :user]")
          end}"
  end, error_on_nak: false, parser: lambda { |r| (r.data == '(ACK') })

  ##
  # Set device battery cut-off voltage
  #
  # Input:
  #    22.1 # => Any float is accepted, consult manual for valid values
  #
  # Returns:
  #    # A Boolean indicating if the battery cut-off voltage was successfully set
  #    true # Example
  SET_BATTERY_CUTOFF_VOLTAGE = OP.new(command: lambda { |input| "PSDV#{Float(input).to_s}" }, error_on_nak: false, parser: lambda { |r| (r.data == '(ACK') })

  ##
  # Set device battery constant charging voltage
  #
  # Input:
  #    28.3 # => Any float is accepted, consult manual for valid values
  #
  # Returns:
  #    # A Boolean indicating if the battery constant charging voltage was successfully set
  #    true # Example
  SET_BATTERY_CONSTANT_CHARGING_VOLTAGE = OP.new(command: lambda { |input| "PCVV#{Float(input).to_s}" }, error_on_nak: false, parser: lambda { |r| (r.data == '(ACK') })

  ##
  # Set device battery float charging voltage
  #
  # Input:
  #    26.5 # => Any float is accepted, consult manual for valid values
  #
  # Returns:
  #    # A Boolean indicating if the battery float charging was successfully set
  #    true # Example
  SET_BATTERY_FLOAT_CHARGING_VOLTAGE = OP.new(command: lambda { |input| "PBFT#{Float(input).to_s}" }, error_on_nak: false, parser: lambda { |r| (r.data == '(ACK') })

  ##
  # Set parallel PV OK condition
  #
  # Input:
  #    :one # => Only one unit needs to report OK
  #    :all # => All units must report OK
  #
  # Returns:
  #    # A Boolean indicating if the parallel PV OK condition was set successfully
  #    true # Example
  SET_PARALLEL_PV_OK_CONDITION = OP.new(command: lambda do |input|
    "PSPB#{case input
            when :one
              '0'
            when :all
              '1'
            else
              raise ::ArgumentError.new("Unexpected value #{input}, valid inputs: [:one, :all]")
          end}"
  end, error_on_nak: false, parser: lambda { |r| (r.data == '(ACK') })

  ##
  # Set PV power balance mode
  #
  # Input:
  #    :charge # => Charge current limited, solar will not draw more than is required to charge
  #    :charge_and_load # =>  Charge current + load current, solar will draw enough for charge and load (up to max of solar)
  #
  # Returns:
  #    # A Boolean indicating if the PV power balance mode was set successfully
  #    true # Example
  SET_PV_POWER_BALANCE = OP.new(command: lambda do |input|
    "PSPB#{case input
            when :charge
              '0'
            when :charge_and_load
              '1'
            else
              raise ::ArgumentError.new("Unexpected value #{input}, valid inputs: [:charge, :charge_and_load]")
          end}"
  end, error_on_nak: false, parser: lambda { |r| (r.data == '(ACK') })

  ##
  # Set the maximum charging current
  #
  # Input:
  #    # (REQUIRED) Parameter 0 => Charge current 
  #    30  # => Any integer is accepted, consult manual for valid values
  #
  #    # (OPTIONAL) Parameter 1 => parallel_machine_number (Parallel mode only)
  #    5 # => Do not pass in this value unless the device is running in parallel mode
  #
  # Returns:
  #    # A Boolean indicating if the maximum charging current was set successfully
  #    true # Example
  SET_MAXIMUM_CHARGING_CURRENT = OP.new(command: lambda do |current, parallel_machine_number = 0|
    current = Integer(current)
    "#{((current >= 100) ? 'MNCHGC' : 'MCHGC')}#{Integer(parallel_machine_number).to_s}#{current.to_s}"
  end, error_on_nak: false, parser: lambda { |r| (r.data == '(ACK') })

  #
  # Set the maximum charging current for utility
  #
  # Input:
  #    # (REQUIRED) Parameter 0 => Charge current 
  #    30  # => Any integer is accepted, consult manual for valid values
  #
  #    # (OPTIONAL) Parameter 1 => parallel_machine_number (Parallel mode only)
  #    5 # => Do not pass in this value unless the device is running in parallel mode
  #
  # Returns:
  #    # A Boolean indicating if the maximum charging current for utility was set successfully
  #    true # Example
  SET_MAXIMUM_UTILITY_CHARGING_CURRENT = OP.new(command: lambda do |current, parallel_machine_number = 0|
    "MUCHGC#{Integer(parallel_machine_number).to_s}#{Integer(current).to_s}"
  end, error_on_nak: false, parser: lambda { |r| (r.data == '(ACK') })

  ##
  # Set the parallel output mode (or single mode)
  #
  # Input:
  #    # (REQUIRED) Parameter 0 => mode - The input mode
  #    :single # => Single device
  #    :parallel # => Parallel device
  #    :phase1 # => Phase 1 of 3
  #    :phase2 # => Phase 2 of 3
  #    :phase3 # => Phase 3 of 3
  #
  #    # (OPTIONAL) Parameter 1 => parallel_machine_number (Parallel mode only)
  #    5 # => Do not pass in this value unless the device is running in parallel mode
  #
  # Returns:
  #    # A Boolean indicating if the parallel output mode was set successfully
  #    true # Example
  SET_PARALLEL_OUTPUT_MODE = OP.new(command: lambda do |mode, parallel_machine_number = 0|
    "#{(:single == mode) ? 'POPM00' : "POPM#{Integer(parallel_machine_number).to_s}#{case mode
            when :parallel
              '1'
            when :phase1
              '2'
            when :phase2
              '3'
            when :phase3
              '4'
            else
              raise ::ArgumentError.new("Unexpected value #{mode}, valid inputs: [:single, :parallel, :phase1, :phase2, :phase3]")
          end}"}"
  end, error_on_nak: false, parser: lambda { |r| (r.data == '(ACK') })
end
