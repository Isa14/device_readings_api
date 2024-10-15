# frozen_string_literal: true

# Class instance variables to store device data
class DeviceDataStore
  @device_readings = {}
  @cumulative_counts = {}
  @latest_readings = {}

  class << self
    attr_accessor :device_readings, :cumulative_counts, :latest_readings

    # Initialize the data store if not already initialized
    def initialize_data_store
      @device_readings ||= {}
      @cumulative_counts ||= {}
      @initialize_data_store ||= {}
    end

    # Process a single reading
    def process_reading(device_id, reading)
      return if duplicate_reading?(device_id, reading[:timestamp])

      store_reading(device_id, reading)
      update_cumulative_count(device_id, reading[:count])
      update_latest_timestamp(device_id, reading[:timestamp])
    end

    # Check if the reading is a duplicate
    def duplicate_reading?(device_id, timestamp)
      device_readings[device_id].any? { |r| r[:timestamp] == timestamp }
    end

    # Store a new reading
    def store_reading(device_id, reading)
      device_readings[device_id] << { timestamp: reading[:timestamp], count: reading[:count] }
    end

    # Update the cumulative count for the device
    def update_cumulative_count(device_id, count)
      cumulative_counts[device_id] += count
    end

    # Update the latest reading timestamp for the device
    def update_latest_timestamp(device_id, timestamp)
      if latest_readings[device_id].nil? || timestamp > latest_readings[device_id][:timestamp]
        latest_readings[device_id] = { timestamp: }
      end
    end
  end

  # Make sure to call initialize when the class is first loaded
  initialize_data_store
end
