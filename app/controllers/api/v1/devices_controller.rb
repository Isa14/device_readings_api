# frozen_string_literal: true

module Api
  module V1
    class DevicesController < ApplicationController
      include DeviceData

      before_action :validate_device_presence, only: %i[latest cumulative]

      # POST /api/v1/devices
      def create
        if valid_device_params?

          # Initialize the array for the device if it doesn't exist
          device_readings[device_id] ||= []
          cumulative_counts[device_id] ||= 0

          device_params[:readings].each do |reading|
            process_reading(reading)
          end

          head :no_content
        else
          render json: { error: 'Invalid request data' }, status: :bad_request
        end
      end

      # GET /api/v1/devices/:id/latest
      def latest
        latest_reading = latest_readings[device_id]

        render json: { latest_timestamp: latest_reading[:timestamp] }
      end

      # GET /api/v1/devices/:id/cumulative
      def cumulative
        total_count = cumulative_counts[device_id]

        render json: { cumulative_count: total_count }
      end

      private

      def device_params
        params.permit(:id, readings: %i[count timestamp])
      end

      def device_id
        @device_id ||= device_params[:id]
      end

      def process_reading(reading)
        return if duplicate_reading?(reading[:timestamp])

        DeviceDataStore.process_reading(device_id, reading)
      end

      def duplicate_reading?(timestamp)
        device_readings[device_id].any? { |r| r[:timestamp] == timestamp }
      end

      def valid_device_params?
        required_params_present? && readings_format_valid?
      end

      def required_params_present?
        device_params[:id].present? && device_params[:readings].present?
      end

      def readings_format_valid?
        device_params[:readings].is_a?(Array) && device_params[:readings].all? do |reading|
          reading[:timestamp].present? && reading[:count].present?
        end
      end

      def validate_device_presence
        return if device_readings[device_id].present?

        render json: { error: 'Device not found' }, status: :not_found
      end
    end
  end
end
