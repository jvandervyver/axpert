##
# A list of constants used by the Axpert devices with a convenient parser
#
# @author: Johan van der Vyver
module AxpertConstants
  def self.lookup_hash(type, values) # :nodoc:
    type = type.to_s.strip.freeze
    values.values.each(&:freeze)
    lookup = Hash.new do |_, k|
      if lookup.has_key?(k.to_s)
        lookup[k.to_s]
      elsif (k.is_a?(Numeric) && (k.to_i == k) && (lookup.values.count > k))
        lookup.values[k]
      elsif lookup.values.include?(k)
        k
      else
        raise ::AxpertConstants::UnknownConstant.new("Unknown #{type} '#{k}'")
      end
    end
    lookup.instance_eval <<-RUBY_CODE
      def key(input) # :nodoc: 
        parse = super(self[input]) rescue nil
        parse = (super(input.to_s.to_sym) rescue nil) if parse.nil?
        parse = (super(input) rescue nil) if parse.nil?
        return parse unless parse.nil?
        raise ::AxpertConstants::UnknownConstant.new("Could not find the #{type} constant '\#{input}' in \#{self.values}")
      end
    RUBY_CODE
    lookup.merge!(values).freeze
  end

  ##
  # The type of batteries connected to the device
  # Used to determine the float, bulk charging, re-charge and re-discharge voltage ranges
  #
  #    :agm # => Absorbent Glass Mat (AGM)
  #    :flooded # => Flooded Cell
  #    :user # => User defined
  BATTERY_TYPE = lookup_hash('battery type', {'0' => :agm, '1' => :flooded, '2' => :user})

  ##
  # The current device mode
  #
  #    :power # => Power on
  #    :standby # => Standby
  #    :line # => Line
  #    :battery # => Battery
  #    :fault # => Fault
  DEVICE_MODE = lookup_hash('device mode', {'P' => :power, 'S' => :standby, 'L' => :line, 'B' => :battery, 'F' => :fault})

  ##
  # The input voltage is monitored to determine if it is within an acceptable range
  # The sensitivity determines when the unit switches output mode to/from Utility
  #
  #    :appliance # => Appliance mode sensitivity (see manual for ranges)
  #    :ups # => UPS mode sensitivity (see manual for ranges)
  INPUT_VOLTAGE_SENSITIVITY = lookup_hash('input voltage sensitivity', {'0' => :appliance, '1' => :ups})

  ##
  # Device output priority
  #
  #    :utility # => Prefer utility as first output power source
  #    :solar # => Prefer solar as first output power source
  #    :sbu # => Prefer solar first, then battery and utility last as output power source
  OUTPUT_SOURCE_PRIORITY = lookup_hash('output source priority', {'0' => :utility, '1' => :solar, '2' => :sbu})

  ##
  # Battery charger source priority
  #
  #    :utility_first # => Charge batteries from utility first
  #    :solar:first # => Charge batteries from solar first,
  #    :solar_and_utility # => Charge batteries from solar & utility
  #    :solar_only # => Charge batteries from solar only
  CHARGER_SOURCE_PRIORITY = lookup_hash('charger source priority', {'0' => :utility_first, '1' => :solar_first, '2' => :solar_and_utility, '3' => :solar_only})

  ##
  # The type of device
  #
  #    :grid_tie # => Grid tie device
  #    :off_grid # => Off-Grid device
  #    :hybrid # =>Hybrid device
  DEVICE_TYPE = lookup_hash('device type', {'00' => :grid_tie, '01' => :off_grid, '10' => :hybrid})

  ##
  # The internal device topology
  # NOTE: All models make use of a transformer in Inverter mode
  #
  #    :transformerless # => The device output does not pass through an isolation transformer
  #    :transformer # => The device output does pass through an isolation transformer
  DEVICE_TOPOLOGY = lookup_hash('device topology', {'0' => :transformerless, '1' => :transformer})

  ##
  # The current output mode of the device
  #
  #    :single # => The device is running in single mode, single phase output
  #    :parallel # => The device is running in parallel mode (allow multiple units in parallel), single phase output
  #    :phase1 # => The device is running in parallel mode, 3 phase output, set to phase 1 of 3
  #    :phase2 # => The device is running in parallel mode, 3 phase output, set to phase 2 of 3
  #    :phase3 # => The device is running in parallel mode, 3 phase output, set to phase 3 of 3
  OUTPUT_MODE = lookup_hash('output mode', {'0' => :single, '1' => :parallel, '2' => :phase1, '3' => :phase2, '4' => :phase3})

  ##
  # Only applicable to units running in Parallel!
  # The required mode for the PV to report OK on the inverter in parallel mode
  #
  #    :one # => Only one unit needs to report PV is OK
  #    :all # => All units must report that PV is OK
  PV_PARALLEL_OK_MODE = lookup_hash('PV parallel mode', {'0' => :one, '1' => :all})

  ##
  # The PV power balance mode setting
  #
  #    :charge # => PV output is limited to battery charge current
  #    :charge_and_load # => PV output will attempt to use enough power for charging the battery and enough to supply the connected load
  PV_POWER_BALANCE_MODE = lookup_hash('PV power balance mode', {'0' => :charge, '1' => :charge_and_load})

  ##
  # Possible fault codes returned by the device
  FAULT_CODE = lookup_hash('fault code',
   { '00' => 'No faults',
     '01' => 'Fan is locked',
     '02' => 'Over temperature',
     '03' => 'Battery voltage is too high',
     '04' => 'Battery voltage is too low',
     '05' => 'Output short circuited/Over temperature',
     '06' => 'Output voltage is too high',
     '07' => 'Overload time out',
     '08' => 'Bus voltage is too high',
     '09' => 'Bus soft start failed',
     '11' => 'Main relay failed',
     '51' => 'Inverter over current',
     '52' => 'Bus soft start failed',
     '53' => 'Inverter soft start failed',
     '54' => 'Self-test failed',
     '55' => 'Inverter over voltage on DC output',
     '56' => 'Battery connection is open',
     '57' => 'Current sensor failed',
     '58' => 'Output voltage is too low',
     '60' => 'Inverter negative power',
     '71' => 'Parallel version different',
     '71' => 'Output circuit failed',
     '80' => 'CAN communication failed',
     '81' => 'Parallel host line lost',
     '82' => 'Parallel synchronized signal lost',
     '83' => 'Parallel battery voltage is detected as different',
     '84' => 'Parallel line voltage or frequency is detected as different',
     '85' => 'Parallel line input current unbalanced',
     '86' => 'Parallel output setting is different' })

  class UnknownConstant < RuntimeError; end # :nodoc:
end