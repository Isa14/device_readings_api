# frozen_string_literal: true

# app/controllers/concerns/device_data.rb
module DeviceData
  extend ActiveSupport::Concern

  included do
    before_action :initialize_device_data
  end

  def device_readings
    ::DeviceDataStore.device_readings
  end

  def cumulative_counts
    ::DeviceDataStore.cumulative_counts
  end

  def latest_readings
    ::DeviceDataStore.latest_readings
  end

  private

  def initialize_device_data
    ::DeviceDataStore.initialize_data_store
  end
end
