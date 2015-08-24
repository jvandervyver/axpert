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

  #-----------------------------
  # Device protocol ID
  PROTOCOL_ID = OP.new('QPI') { |r| r.data[3..-1] }

  #-----------------------------
  # Device serial number
  SERIAL_NUMBER = OP.new('QID') { |r| r.data[1..-1] }

  #-----------------------------
  # Main CPU Firmware version
  MAIN_CPU_FIRMWARE = OP.new('QVFW') do |r|
    r.data[8..-1].split('.').map { |s| s.chars.map { |c| c.to_i(16).to_s }.flatten.join }.join('.')
  end

  #-----------------------------
  # Other CPU Firmware version
  OTHER_CPU_FIRMWARE = OP.new('QVFW2') do |r|
    r.data[8..-1].split('.').map { |s| s.chars.map { |c| c.to_i(16).to_s }.flatten.join }.join('.')
  end

  #-----------------------------
  # Device rating information
  DEVICE_RATING = OP.new('QPIRI') do |r|
    r = r.data[1..-1].split(' ').map { |s| Float(s) }
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
      battery_type: ['Absorbent Glass Mat (AGM)', 'Flooded Cell', 'User defined'][r[12]],
      maximum_ac_charge_current: r[13].to_i,
      maximum_charge_current: r[14].to_i,
      input_voltage_sensitivity: ['Appliance mode', 'UPS mode'][r[15]],
      output_source_priority: ['Utility first', 'Solar first', 'Solar -> Battery -> Utility'][r[16]],
      charger_source_priority: ['Utility first', 'Solar first', 'Solar & Utility', 'Solar only'][r[17]],
      maximum_parallel_units: r[18].to_i,
      device_type: (['Grid tie', 'Off-Grid'] + ['']*8 + ['Hybrid'])[r[19]],
      device_topology: ['Transformerless', 'Transformer'][r[20]],
      output_mode: ['Single device', 'Parallel device', 'Phase 1 of 3', 'Phase 2 of 3', 'Phase 3 of 3'][r[21]],
      battery_redischarge_voltage: r[22],
      pv_parallel_ok: ['Only one unit need report OK', 'All units must report OK'][r[23]],
      pv_power_balance: ['Charge current limited', 'Charge current + load current'][r[24]] }
  end

  #-----------------------------
  # Device flags
  DEVICE_FLAGS = OP.new('QFLAG') do |r|
    r = r.data[1..-1].chars.map { |s| ('E' == s.upcase) }
    { silence_buzzer: r[0],
      utility_bypass_on_overload: r[1],
      power_saving_mode: r[2]
      lcd_timeout_escape_to_default_page: r[3],
      overload_restart: r[4],
      overtemperature_restart: r[5],
      lcd_backlight: r[6],
      alarm_on_primary_source_loss: r[7],
      record_fault_code: r[8] }.freeze
  end

  # Device mode
  DEVICE_MODE = OP.new('QMOD') do |r|
    {'P' => 'Power on',
     'S' => 'Standby',
     'L' => 'Line',
     'B' => 'Battery',
     'F' => 'Fault'}[r.data[1..-1].upcase].freeze
  end

  # Device warning status
  DEVICE_WARNING_STATUS = OP.new('QPIWS') do |r|
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
  end
end
