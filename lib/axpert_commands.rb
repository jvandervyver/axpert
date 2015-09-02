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
  PROTOCOL_ID = OP.new(command: 'QPI', parser: lambda { |r| Integer(r.data[3..-1], 10) })

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
  #
  MAIN_CPU_FIRMWARE = OP.new(command: 'QVFW', parser: lambda do |r|
    r.data[8..-1].split('.').map { |s| s.chars.map { |c| Integer(c, 16).to_s }.flatten.join }.join('.').upcase
  end)

  ##
  # Other CPU Firmware version
  #
  # Returns:
  #    # A String representing the CPU Firmware as a hexidecimal number
  #    "124004.10" # Example
  OTHER_CPU_FIRMWARE = OP.new(command: 'QVFW2', parser: lambda do |r|
    r.data[8..-1].split('.').map { |s| s.chars.map { |c| Integer(c, 16).to_s }.flatten.join }.join('.').upcase
  end)

  ##
  # Device rating information
  #
  # Returns:
  #    # A Hash containing device rating information
  #    { grid_voltage: 230.5, grid_current: 11.2, .. }
  DEVICE_RATING = OP.new(command: 'QPIRI', parser: lambda do |r|
    r = r.data[1..-1].split(' ')
    { utility_voltage: Float(r[0]),
      utility_current: Float(r[1]),
      output_voltage: Float(r[2]),
      output_frequency: Float(r[3]),
      output_current: Float(r[4]),
      output_va: Integer(r[5], 10),
      output_watts: Integer(r[6], 10),
      battery_voltage: Float(r[7]),
      battery_bulk_charge_voltage: Float(r[8]),
      battery_cutoff_voltage: Float(r[9]),
      battery_bulk_charge_voltage: Float(r[10]),
      battery_float_charge_voltage: Float(r[11]),
      battery_type: ::AxpertConstants::BATTERY_TYPE[r[12]],
      maximum_utility_charge_current: Integer(r[13], 10),
      maximum_charge_current: Integer(r[14], 10),
      input_voltage_sensitivity: CONS::INPUT_VOLTAGE_SENSITIVITY[r[15]],
      output_source_priority: CONS::OUTPUT_SOURCE_PRIORITY[r[16]],
      charger_source_priority: CONS::CHARGER_SOURCE_PRIORITY[r[17]],
      maximum_parallel_units: Integer(r[18], 10),
      device_type: CONS::DEVICE_TYPE[r[19]],
      device_topology: CONS::DEVICE_TOPOLOGY[r[20]],
      output_mode: CONS::OUTPUT_MODE[r[21]],
      battery_float_charge_voltage: Float(r[22]),
      pv_parallel_ok_mode: CONS::PV_PARALLEL_OK_MODE[r[23]],
      pv_power_balance_mode: CONS::PV_POWER_BALANCE_MODE[r[24]] }
  end)


  ##
  # Device flags
  #
  # Returns:
  #    # A Hash containing device flag status as booleans
  #    {enable_buzzer: true/false, nable_bypass_to_utility_on_overload: true/false, ... }
  DEVICE_FLAGS = OP.new(command: 'QFLAG', parser: lambda do |r|
    r = r.data[1..-1]
    lookup = Hash.new { |_, k| raise "The device did not return the status of the flag '#{k}'" }
    r.scan(/[E][a-z]*/).first.to_s[1..-1].to_s.chars.each { |e| lookup[e.upcase] = true }
    r.scan(/[D][a-z]*/).first.to_s[1..-1].to_s.chars.each { |d| lookup[d.upcase] = false }
    { enable_buzzer: lookup['A'],
      enable_bypass_to_utility_on_overload: lookup['B'],
      enable_power_saving: lookup['J'],
      enable_lcd_timeout_escape_to_default_page: lookup['K'],
      enable_overload_restart: lookup['U'],
      enable_over_temperature_restart: lookup['V'],
      enable_lcd_backlight: lookup['X'],
      enable_primary_source_interrupt_alarm:  lookup['Y'],
      enable_fault_code_recording: lookup['Z'] }
  end)

  ##
  # The current device status
  #
  # Returns:
  #    # A Hash containing device status information
  #    { grid_voltage: 230.5, grid_current: 11.2, .. }
  DEVICE_STATUS = OP.new(command: 'QPIGS', parser: lambda do |r|
    r = r.data[1..-1].split(' ')
    status = r[16].chars.map { |c| Boolean(c) }
    { utility_voltage: Float(r[0]),
      utility_frequency: Float(r[1]),
      output_voltage: Float(r[2]),
      output_frequency: Float(r[3]),
      output_va: Integer(r[4], 10),
      output_watts: Integer(r[5], 10),
      output_load_percent: Integer(r[6], 10),
      dc_bus_voltage: Integer(r[7], 10),
      battery_voltage: Float(r[8]),
      battery_charge_current: Float(r[9]),
      battery_capacity_remaining: Integer(r[10], 10),
      inverter_temperature_celsius: Integer(r[11], 10),
      pv_battery_input_current: Integer(r[12], 10),
      pv_input_voltage: Float(r[13]),
      solar_charge_controller_battery_voltage: Float(r[14]),
      battery_discharge_current: Integer(r[15], 10),
      add_sbu_priority_version: status[0],
      configuration_changed: status[1],
      solar_charge_controller_firmware_changed: status[2],
      load_on: status[3],
      battery_voltage_stable: status[4],
      charger_enabled: status[5],
      charging_from_solar_charge_controller: status[6],
      charging_from_utility: status[7] }
  end)

  # Device mode
  #
  # Returns:
  #    # A symbol denoting the device mode
  #    See AxpertConstants::DEVICE_MODE for constants
  DEVICE_MODE = OP.new(command: 'QMOD', parser: lambda { |r| CONS::DEVICE_MODE[r.data[1..-1].upcase] })

  ##
  # Device warning status messages
  #
  # Returns:
  #    # An Array of Hashes
  #    # Each Hash has the format { description: String description, level: :none/:fault/:warning }
  #    # The level is only :none if a reserved error was returned which may signify an update
  #    # of the parser is needed
  #    [{ description: 'Bus voltage is too high', level: :fault}, ..]
  DEVICE_WARNING_STATUS = OP.new(command: 'QPIWS', parser: lambda do |r|
    r = r.data[1..-1].chars.map { |s| Boolean(s) }
    parse = lambda { |desc, lvl = :none| { description: desc, level: lvl } }
    errors = []
    errors << parse.yield('Reserved') if r[0]
    errors << parse.yield('Inverter fault', :fault) if r[1]
    errors << parse.yield('Bus voltage is too high', :fault) if r[2]
    errors << parse.yield('Bus voltage is too low', :fault) if r[3]
    errors << parse.yield('Bus soft start failed ', :fault) if r[4]
    errors << parse.yield('Utility input failure', :warning) if r[5]
    errors << parse.yield('Output short circuited', :warning) if r[6]
    errors << parse.yield('Inverter voltage too low', :fault) if r[7]
    errors << parse.yield('Output voltage is too high', :fault) if r[8]
    errors << parse.yield('Over temperature', (r[1] ? :fault : :warning)) if r[9]
    errors << parse.yield('Fan is locked', (r[1] ? :fault : :warning)) if r[10]
    errors << parse.yield('Battery voltage is too high', (r[1] ? :fault : :warning)) if r[11]
    errors << parse.yield('Battery voltage is too low', 'Fault') if r[12]
    errors << parse.yield('Reserved') if r[13]
    errors << parse.yield('Battery under shutdown', :warning) if r[14]
    errors << parse.yield('Reserved') if r[15]
    errors << parse.yield('Overload', (r[1] ? :fault : :warning)) if r[16]
    errors << parse.yield('EEPROM fault', :warning) if r[17]
    errors << parse.yield('Inverter over current', :fault) if r[18]
    errors << parse.yield('Inverter soft start failed', :fault) if r[19]
    errors << parse.yield('Self test fail', :fault) if r[20]
    errors << parse.yield('Over voltage on DC output of inverter', :fault) if r[21]
    errors << parse.yield('Battery connection is open', :fault) if r[22]
    errors << parse.yield('Current sensor failed ', :fault) if r[23]
    errors << parse.yield('Battery short', :fault) if r[24]
    errors << parse.yield('Power limit', :warning) if r[25]
    errors << parse.yield('PV voltage high', :warning) if r[26]
    errors << parse.yield('MPPT overload fault', :warning) if r[27]
    errors << parse.yield('MPPT overload warning', :warning) if r[28]
    errors << parse.yield('Battery too low to charge', :warning) if r[29]
    errors << parse.yield('Reserved') if r[30]
    errors << parse.yield('Reserved') if r[31]
    errors
  end)

  ##
  # The device default settings
  #
  # Returns:
  #    # A Hash containing device defaults
  #    { grid_voltage: 230.5, grid_current: 11.2, .. }
  DEFAULT_SETTINGS = OP.new(command: 'QDI', parser: lambda do |r|
    r = r.data[1..-1].split(' ')
    { output_voltage: Float(r[0]),
      output_frequency: Float(r[1]),
      maximum_ac_charge_current: Integer(r[2], 10),
      battery_cutoff_voltage: Float(r[3]),
      battery_float_charge_voltage: Float(r[4]),
      battery_bulk_charge_voltage: Float(r[5]),
      battery_bulk_charge_voltage: Float(r[6]),
      maximum_charge_current: Integer(r[7], 10),
      input_voltage_sensitivity: CONS::INPUT_VOLTAGE_SENSITIVITY[r[8]],
      output_source_priority: CONS::OUTPUT_SOURCE_PRIORITY[r[9]],
      charger_source_priority: CONS::CHARGER_SOURCE_PRIORITY[r[10]],
      battery_type: ::AxpertConstants::BATTERY_TYPE[r[11]],
      enable_buzzer: !Boolean(r[12]),
      enable_power_saving: Boolean(r[13]),
      enable_overload_restart: Boolean(r[14]),
      enable_over_temperature_restart: Boolean(r[15]),
      enable_lcd_backlight:  Boolean(r[16]),
      enable_primary_source_interrupt_alarm: Boolean(r[17]),
      enable_fault_code_recording: Boolean(r[18]),
      enable_bypass_to_utility_on_overload: Boolean(r[19]),
      enable_lcd_timeout_escape_to_default_page: Boolean(r[20]),
      output_mode: CONS::OUTPUT_MODE[r[21]],
      battery_float_charge_voltage: Float(r[22]),
      pv_parallel_ok_mode: CONS::PV_PARALLEL_OK_MODE[r[23]],
      pv_power_balance_mode: CONS::PV_POWER_BALANCE_MODE[r[24]] }
  end)

  ##
  # All the possible input values for the charge current setting
  #
  # Returns:
  #    [10, 20, 30] # => Array of Integers, example given
  ACCEPTED_CHARGE_CURRENT_VALUES = OP.new(command: 'QMCHGCR', parser: lambda do |r|
    r.data[1..-1].split(' ').map { |s| Integer(s, 10) }
  end)

  ##
  # All the possible input values for the utility charge current setting
  #
  # Returns:
  #    [10, 20, 30] # => Array of Integers, example given
  ACCEPTED_UTILITY_CHARGE_CURRENT_VALUES = OP.new(command: 'QMUCHGCR', parser: lambda do |r|
    r.data[1..-1].split(' ').map { |s| Integer(s, 10) }
  end)

  ##
  # Has device undergone DSP bootstrap
  #
  # Returns:
  #    # A Boolean indicating if the device has undergone DSP bootstrap
  #    true # Example
  DSP_BOOTSTRAP_STATUS = OP.new(command: 'QBOOT', parser: lambda { |r| Boolean(r.data[1..-1]) })

  ##
  # Device parallel output mode status
  #
  # Returns:
  #    # A symbol denoting the current device parallel output mode
  #    See AxpertConstants::OUTPUT_MODE for constants
  OUTPUT_MODE = OP.new(command: 'QOPM', parser: lambda { |r| CONS::OUTPUT_MODE[r.data[2..-1]] })

  ##
  # Parallel device information
  #
  # Input: (OPTIONAL, default = 0)
  #    # Default of 0 seems to work for single unit mode
  #    2 # => parallel_machine_number (Parallel mode only)
  #
  # Returns:
  #    # A Hash containing parallel device status information
  #    { grid_voltage: 230.5, grid_current: 11.2, .. }
  PARALLEL_DEVICE_STATUS = OP.new(command: lambda { |i = 0| "QPGS#{Integer(i)}" }, parser: lambda do |r|
    r = r.data[1..-1].split(' ')
    status = r[19].chars.to_a
    { parallel_number_exists: Boolean(r[0]),
      serial_number: r[1],
      device_mode: CONS::DEVICE_MODE[r[2]],
      fault_code: CONS::FAULT_CODE[r[3]],
      utility_voltage: Float(r[4]),
      utility_frequency: Float(r[5]),
      output_voltage: Float(r[6]),
      output_frequency: Float(r[7]),
      output_va: Integer(r[8], 10),
      output_watts: Integer(r[9], 10),
      load_percentage: Integer(r[10], 10),
      battery_voltage: Float(r[11]),
      battery_charge_current: Integer(r[12], 10),
      battery_capacity: Integer(r[13], 10),
      pv_input_voltage: Float(r[14]),
      total_charge_current: Integer(r[15], 10),
      total_output_va:  Integer(r[16], 10),
      total_output_watt:  Integer(r[17], 10),
      total_load_percentage: Integer(r[18], 10),
      solar_charge_controller_enabled: Boolean(status[0]),
      charging_from_utility: Boolean(status[1]),
      charging_from_solar_charge_controller: Boolean(status[2]),
      battery_status: [:normal, :under, :open][Integer("#{status[3]}#{status[4]}", 10)],
      line_status_ok: !Boolean(status[5]),
      load_on: Boolean(status[6]),
      configuration_changed: Boolean(status[7]),
      output_mode:  CONS::OUTPUT_MODE[r[20]],
      charger_source_priority: CONS::CHARGER_SOURCE_PRIORITY[r[21]],
      maximum_charge_current: Integer(r[22], 10),
      device_maximum_charge_current: Integer(r[23], 10),
      pv_input_current: Integer(r[24], 10),
      battery_redischarge_voltage: Integer(r[25], 10) }
  end)

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
  SET_OUTPUT_FREQUENCY = OP.new(command: lambda { |input| "F#{Integer(input).to_s.rjust(2, '0')}" }, error_on_nak: false, parser: lambda { |r| (r.data == '(ACK') })

  ##
  # Set device output source priority
  #
  # Input:
  #    # A symbol donating the output source priority setting
  #    See AxpertConstants::OUTPUT_SOURCE_PRIORITY
  #
  # Returns:
  #    # A Boolean indicating if the output priority was set succesfully
  #    true # Example
  SET_OUTPUT_SOURCE_PRIORITY = OP.new(command: lambda { |i| "POP#{CONS::OUTPUT_SOURCE_PRIORITY.key(i).to_s.rjust(2, '0')}" }, error_on_nak: false, parser: lambda { |r| (r.data == '(ACK') })

  ##
  # Set battery re-charge voltage
  #
  # Input:
  #    24.3 # => Any float is accepted, consult manual for valid values
  #
  # Returns:
  #    # A Boolean indicating if the recharge voltage was successfully set
  #    true # Example
  SET_BATTERY_RECHARGE_VOLTAGE = OP.new(command: lambda { |input| "PBCV#{Float(input).to_s.rjust(4, '0')}" }, error_on_nak: false, parser: lambda { |r| (r.data == '(ACK') })

  ##
  # Set battery re-discharge voltage
  #
  # Input:
  #    24.3 # => Any float is accepted, consult manual for valid values
  #
  # Returns:
  #    # A Boolean indicating if the re-discharge voltage was successfully set
  #    true # Example
  SET_BATTERY_REDISCHARGE_VOLTAGE = OP.new(command: lambda { |input| "PBDV#{Float(input).to_s.rjust(4, '0')}" }, error_on_nak: false, parser: lambda { |r| (r.data == '(ACK') })

  ##
  # Set device charger priority
  #
  # Input:
  #    # (REQUIRED) Parameter 0 => A symbol donating the charger source priority
  #    See AxpertConstants::CHARGER_SOURCE_PRIORITY
  #
  #    # (OPTIONAL) Parameter 1 => parallel_machine_number (Parallel mode only)
  #    5 # => Do not pass in this value unless the device is running in parallel mode
  #
  # Returns:
  #    # A Boolean indicating if the device charger priority was set successfully
  #    true # Example
  SET_CHARGER_SOURCE_PRIORITY = OP.new(command: lambda do |mode, parallel_machine_number = nil|
    if parallel_machine_number.nil?
      "PPCP#{Integer(parallel_machine_number).to_s}#{CONS::CHARGER_SOURCE_PRIORITY.key(mode).to_s.rjust(2, '0')}"
    else
      "PCP#{CONS::CHARGER_SOURCE_PRIORITY.key(mode).to_s.rjust(2, '0')}"
    end
  end, error_on_nak: false, parser: lambda { |r| (r.data == '(ACK') })

  ##
  # Set device input voltage sensitivity
  #
  # Input:
  #    # A symbol denoting the input voltage sensitivity
  #    See AxpertConstants::INPUT_VOLTAGE_SENSITIVITY
  #
  # Returns:
  #    # A Boolean indicating if the device input voltage sensitivity was set successfully
  #    true # Example
  SET_INPUT_VOLTAGE_SENSITIVITY = OP.new(command: lambda { |i| "PGR#{CONS::INPUT_VOLTAGE_SENSITIVITY.key(i).to_s.rjust(2, '0')}" }, error_on_nak: false, parser: lambda { |r| (r.data == '(ACK') })

  ##
  # Set battery type
  #
  # Input:
  #    # A symbol denoting the battery type
  #    See AxpertConstants::BATTERY_TYPE
  #
  # Returns:
  #    # A Boolean indicating if the device battery type was set successfully
  #    true # Example
  SET_BATTERY_TYPE = OP.new(command: lambda { |i| "PBT#{CONS::BATTERY_TYPE.key(i).to_s.rjust(2, '0')}" }, error_on_nak: false, parser: lambda { |r| (r.data == '(ACK') })

  ##
  # Set device battery cut-off voltage
  #
  # Input:
  #    22.1 # => Any float is accepted, consult manual for valid values
  #
  # Returns:
  #    # A Boolean indicating if the battery cut-off voltage was successfully set
  #    true # Example
  SET_BATTERY_CUTOFF_VOLTAGE = OP.new(command: lambda { |input| "PSDV#{Float(input).to_s.rjust(4, '0')}" }, error_on_nak: false, parser: lambda { |r| (r.data == '(ACK') })

  ##
  # Set device battery constant charging voltage
  #
  # Input:
  #    28.3 # => Any float is accepted, consult manual for valid values
  #
  # Returns:
  #    # A Boolean indicating if the battery constant charging voltage was successfully set
  #    true # Example
  SET_BATTERY_CONSTANT_CHARGING_VOLTAGE = OP.new(command: lambda { |input| "PCVV#{Float(input).to_s.rjust(4, '0')}" }, error_on_nak: false, parser: lambda { |r| (r.data == '(ACK') })

  ##
  # Set device battery float charging voltage
  #
  # Input:
  #    26.5 # => Any float is accepted, consult manual for valid values
  #
  # Returns:
  #    # A Boolean indicating if the battery float charging was successfully set
  #    true # Example
  SET_BATTERY_FLOAT_CHARGING_VOLTAGE = OP.new(command: lambda { |input| "PBFT#{Float(input).to_s.rjust(4, '0')}" }, error_on_nak: false, parser: lambda { |r| (r.data == '(ACK') })

  ##
  # Set parallel PV OK condition
  #
  # Input:
  #    # A input symbol donating the PV Parallel OK condition mode setting
  #    See AxpertConstants::PV_PARALLEL_OK_MODE
  #
  # Returns:
  #    # A Boolean indicating if the parallel PV OK condition was set successfully
  #    true # Example
  SET_PV_PARALLEL_OK_MODE = OP.new(command: lambda { |i| "PPVOKC#{CONS::PV_PARALLEL_OK_MODE.key(i).to_s}" }, error_on_nak: false, parser: lambda { |r| (r.data == '(ACK') })

  ##
  # Set PV power balance mode
  #
  # Input:
  #    # A input symbol donating the PV Power balance mode
  #    See AxpertConstants::PV_POWER_BALANCE_MODE
  #
  # Returns:
  #    # A Boolean indicating if the PV power balance mode was set successfully
  #    true # Example
  SET_PV_POWER_BALANCE_MODE = OP.new(command: lambda { |i| "PSPB#{CONS::PV_POWER_BALANCE_MODE.key(i).to_s}" }, error_on_nak: false, parser: lambda { |r| (r.data == '(ACK') })

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
    if (current >= 100)
      "MNCHGC#{Integer(parallel_machine_number).to_s}#{current.to_s.rjust(3, '0')}"
    else
      "MCHGC#{Integer(parallel_machine_number).to_s}#{current.to_s.rjust(2, '0')}"
    end
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
    "MUCHGC#{Integer(parallel_machine_number).to_s}#{Integer(current).to_s.rjust(2, '0')}"
  end, error_on_nak: false, parser: lambda { |r| (r.data == '(ACK') })

  ##
  # Set the parallel output mode (or single mode)
  #
  # Input:
  #    # (REQUIRED) Parameter 0 => A input symbol donating output mode
  #    See AxpertConstants::OUTPUT_MODE
  #
  #    # (OPTIONAL) Parameter 1 => parallel_machine_number (Parallel mode only)
  #    5 # => Do not pass in this value unless the device is running in parallel mode
  #
  # Returns:
  #    # A Boolean indicating if the parallel output mode was set successfully
  #    true # Example
  SET_OUTPUT_MODE = OP.new(command: lambda do |mode, parallel_machine_number = 0|
   "POPM#{CONS::OUTPUT_MODE.key(mode)}#{Integer(parallel_machine_number).to_s}"
  end, error_on_nak: false, parser: lambda { |r| (r.data == '(ACK') })

  require 'axpert_constants'
  CONS = ::AxpertConstants # :nodoc:
  send(:remove_const, :OP)
end

# This is hacky but it is really a must for accurate parsing
module ::Kernel # :nodoc:
  def Boolean(input) # :nodoc:
    return true if input.equal?(TrueClass)
    return false if input.equal?(FalseClass)
    parse = input.to_s.chomp.downcase
    return true if ('true' == parse) || ('y' == parse) || ('t' == parse) || (1 == (Integer(parse) rescue nil))
    return false if ('false' == parse) || ('n' == parse) || ('f' == parse) || (0 == (Integer(parse) rescue nil))
    raise
  rescue StandardError, ScriptError
    raise ::ArgumentError.new("invalid value for Boolean(): \"#{input}\"")
  end
end