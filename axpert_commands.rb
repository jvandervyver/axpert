module AxpertCommands
  require 'axpert_command'

  # Device protocol ID
  PROTOCOL_ID = ::AxpertCommand.new('QPI') { |r| r.command.gsub('PI','') }

  # Device serial number
  SERIAL_NUMBER = ::AxpertCommand.new('QID') { |r| r.command }

  # Main CPU Firmware version
  MAIN_CPU_FIRMWARE = ::AxpertCommand.new('QVFW') { |r| r.command.gsub('VERFW:', '').split('.').map { |s| s.chars.map { |c| c.to_i(16).to_s }.flatten.join }.join('.') }

  # Other CPU Firmware version
  OTHER_CPU_FIRMWARE = ::AxpertCommand.new('QVFW2') { |r| r.command.gsub('VERFW2:', '').split('.').map { |s| s.chars.map { |c| c.to_i(16).to_s }.flatten.join }.join('.') }

  # Device rating information
  DEVICE_RATING = ::AxpertCommand.new('QPIRI') do |r|
    r = r.command[1..-1].split(' ')
    { grid_voltage: Float(r[0]),
      grid_current: Float(r[1]),
      output_voltage: Float(r[2]),
      output_frequency: Float(r[3]),
      output_current: Float(r[4]),
      output_va: Integer(r[5]),
      output_watts: Integer(r[6]),
      battery_voltage: Float(r[7]),
      battery_recharge_voltage: Float(r[8]),
      battery_under_voltage: Float(r[9]),
      battery_bulk_charge_voltage: Float(r[10]),
      battery_float_charge_voltage: Float(r[11]),
      battery_type: Integer(r[12]),
      maximum_ac_charge_current: Integer(r[13]),
      maximum_charge_current: Integer(r[14]),
      input_voltage_sensitivity: Integer(r[15]),
      output_source_priority: Integer(r[16]),
      charger_source_priority: Integer(r[17]),
      inverter_type: Integer(r[18]),
      inverter_topology: Integer(r[19]),
      output_mode: Integer(r[20]),
      battery_redischarge_voltage: Float(r[21]),
      pv_parallel_ok: Integer(r[22]),
      pv_power_balance: Integer(r[23]) }
  end
end
