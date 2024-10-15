# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Devices API' do
  let(:valid_device_id) { '36d5658a-6908-479e-887e-a949ec199272' }
  let(:invalid_device_id) { '00000000-0000-0000-0000-000000000000' }

  let(:valid_readings) do
    [
      { timestamp: '2021-09-29T16:08:15+01:00', count: 2 },
      { timestamp: '2021-09-29T16:09:15+01:00', count: 15 }
    ]
  end

  let(:valid_readings_2) do
    [
      { timestamp: '2021-09-29T16:20:14+01:00', count: 5 }
    ]
  end

  let(:duplicate_readings) do
    [
      { timestamp: '2021-09-29T16:08:15+01:00', count: 2 },
      { timestamp: '2021-09-29T16:08:15+01:00', count: 2 } # Duplicate timestamp
    ]
  end

  let(:invalid_payload) { { readings: [{ count: 2 }] } } # Missing timestamp and device id

  # Clear the in-memory data store before each test
  before do
    DeviceDataStore.device_readings.clear
    DeviceDataStore.cumulative_counts.clear
    DeviceDataStore.latest_readings.clear
  end

  describe 'POST /api/v1/devices' do
    subject do
      post '/api/v1/devices', params: params.to_json,
                              headers: { 'Content-Type': 'application/json' }
      response
    end

    context 'with valid params' do
      context 'with no reading duplicates' do
        let(:params) { { id: valid_device_id, readings: valid_readings } }

        it { is_expected.to have_http_status :no_content }

        it 'creates readings for the device' do
          device_data = DeviceDataStore.device_readings
          expect(device_data.size).to eq(0)

          subject

          # Validate the readings have been added
          device_data = DeviceDataStore.device_readings[valid_device_id]
          expect(device_data.size).to eq(2)
          expect(device_data.first[:timestamp]).to eq(valid_readings.first[:timestamp])
          expect(device_data.last[:count]).to eq(valid_readings.last[:count])

          post '/api/v1/devices',
               params: { id: valid_device_id, readings: valid_readings_2 }.to_json,
               headers: { 'Content-Type': 'application/json' }

          # Validate new readings to be added in the second POST request
          device_data = DeviceDataStore.device_readings[valid_device_id]
          expect(device_data.size).to eq(3)
        end
      end

      context 'with reading duplicates' do
        let(:params) { { id: valid_device_id, readings: duplicate_readings } }

        it { is_expected.to have_http_status :no_content }

        it 'ignores duplicate readings based on timestamp' do
          device_data = DeviceDataStore.device_readings
          expect(device_data.size).to eq(0)

          subject

          # Validate only one unique reading was added
          device_data = DeviceDataStore.device_readings[valid_device_id]
          expect(device_data.size).to eq(1)
          expect(device_data.first[:timestamp]).to eq(duplicate_readings.first[:timestamp])
        end
      end
    end

    context 'with invalid params' do
      context 'when id is missing' do
        let(:params) { { readings: valid_readings } }

        it { is_expected.to have_http_status :bad_request }

        it 'returns error message and does not add new readings' do
          expect(JSON.parse(subject.body)['error']).to eq('Invalid request data')

          # Validate no readings were added
          device_data = DeviceDataStore.device_readings
          expect(device_data.size).to eq(0)
        end
      end

      context 'readings are malformed' do
        let(:params) { { id: valid_device_id, readings: invalid_payload } }

        it { is_expected.to have_http_status :bad_request }

        it 'returns error message and does not add new readings' do
          expect(JSON.parse(subject.body)['error']).to eq('Invalid request data')

          # Validate no readings were added
          device_data = DeviceDataStore.device_readings
          expect(device_data.size).to eq(0)
        end
      end
    end
  end

  describe 'GET /api/v1/devices/:id/latest' do
    before do
      allow(DeviceDataStore).to receive(:device_readings).and_return(
        { valid_device_id => valid_readings }
      )
      allow(DeviceDataStore).to receive(:latest_readings).and_return(
        { valid_device_id => { timestamp: latest_timestamp } }
      )
    end

    let(:latest_timestamp) { '2021-09-29T16:09:15+01:00' }

    subject do
      get "/api/v1/devices/#{device_id}/latest"
      response
    end

    context 'when the device ID exists' do
      let(:device_id) { valid_device_id }

      it { is_expected.to have_http_status :ok }

      it 'returns the latest reading timestamp' do
        expect(JSON.parse(subject.body)['latest_timestamp']).to eq(latest_timestamp)
      end
    end

    context 'when the device ID does not exist' do
      let(:device_id) { invalid_device_id }

      it { is_expected.to have_http_status :not_found }

      it 'returns error message' do
        expect(JSON.parse(subject.body)['error']).to eq('Device not found')
      end
    end
  end

  describe 'GET /api/v1/devices/:id/cumulative' do
    before do
      allow(DeviceDataStore).to receive(:device_readings).and_return({ valid_device_id => valid_readings })
      allow(DeviceDataStore).to receive(:cumulative_counts).and_return({ valid_device_id => 17 })
    end

    let(:cumulative_count) { 17 }

    subject do
      get "/api/v1/devices/#{device_id}/cumulative"
      response
    end

    context 'when the device ID exists' do
      let(:device_id) { valid_device_id }

      it { is_expected.to have_http_status :ok }

      it 'returns the cumulative count for the device' do
        expect(JSON.parse(subject.body)['cumulative_count']).to eq(cumulative_count)
      end
    end

    context 'when the device ID does not exist' do
      let(:device_id) { invalid_device_id }

      it { is_expected.to have_http_status :not_found }

      it 'returns error message' do
        expect(JSON.parse(subject.body)['error']).to eq('Device not found')
      end
    end
  end
end
