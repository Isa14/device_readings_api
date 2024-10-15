# Device Readings API

This is a web API that handles device readings, stores them in-memory, and provides functionalities to return the latest reading's timestamp and the cumulative count of readings for a specific device.

## Instructions on how to build and start the web API locally

### Prerequisites

- Ruby version 3.x.x
- Rails version 7.x.x
- Bundler installed (`gem install bundler`)

### Steps

1. Install dependencies:
    ```bash
    bundle install
    ```

2. Start the Rails server:
    ```bash
    bundle exec rails server
    ```

3. The API will be accessible at `http://localhost:3000`.

### Running tests

    ```bash
    bundle exec rspec .
    ```

## API Documentation

The following endpoints are available in the API:

### 1. Create a Device Reading

- **Endpoint**: `POST /api/v1/devices`
- **Description**: Creates readings for a device and stores them in-memory.
- **Parameters**:
  - `id`: (string, required) The UUID of the device.
  - `readings`: (array, required) An array of reading objects with the following attributes:
    - `timestamp`: (string, ISO-8601, required) The timestamp when the reading was taken.
    - `count`: (integer, required) The count value recorded for this reading.
    
- **Example Request**:
    ```json
    {
      "id": "36d5658a-6908-479e-887e-a949ec199272",
      "readings": [
        {
          "timestamp": "2021-09-29T16:08:15+01:00",
          "count": 2
        },
        {
          "timestamp": "2021-09-29T16:09:15+01:00",
          "count": 15
        }
      ]
    }
    ```
- **Response**:
    - `204 No Content` if the request is valid.
    - `400 Bad Request` if the request data is invalid.


### 2. Get the Latest Reading Timestamp

- **Endpoint**: `GET /api/v1/devices/:id/latest`
- **Description**: Returns the latest reading timestamp for the specified device.
- **Parameters**:
  - `id`: (string, required) The UUID of the device.

- **Example Response**:
    ```json
    {
      "latest_timestamp": "2021-09-29T16:09:15+01:00"
    }
    ```

### 3. Get the Cumulative Count

- **Endpoint**: `GET /api/v1/devices/:id/cumulative`
- **Description**: Returns the cumulative count of all readings for the specified device.
- **Parameters**:
  - `id`: (string, required) The UUID of the device.

- **Example Response**:
    ```json
    {
      "cumulative_count": 17
    }
    ```

## Project Structure

- **app/controllers**: Contains the main controller `devices_controller.rb` that handles the logic for device readings.
- **app/controllers/concerns**: Includes the `device_data.rb` concern, which manages the interaction with the `DeviceDataStore`.
- **lib**: Contains the `DeviceDataStore` class, which acts as the in-memory data store for the devices, and centralizes and manages shared data across the application.
- **config/routes.rb**: Defines the API endpoints and maps them to the controller actions.
- **spec/**: Contains the integration tests for each API endpoint.
  
### Key files:
- `app/controllers/api/v1/devices_controller.rb`: Handles the `create`, `latest`, and `cumulative` actions.
- `app/controllers/concerns/device_data.rb`: A concern to manage the device data storage.
- `lib/device_data_store.rb`: The class responsible for storing the device data in-memory.
- `spec/requests/api/v1/devices_spec.rb`


## Improvements and Optimizations

Given more time, I would consider implementing the following improvements:

- **Concurrency**: Use atomic operations when storing the data to ensure consistency. For example, using Redis as the in-memory store.
- **Validation and Error Handling**: Add more validations to the payloads (for example, timestamp format) and enhance error handling to return more specific error messages.
- **Test Coverage**: Add unit tests to device data store class.
- **API Documentation**: Use tools like Swagger to provide interactive API documentation.

Wanted to mention that since I'm using a class variable, the data will be stored in memory until the server is restarted. For production, you would use Redis or another caching mechanism for in-memory storage, but for the purpose of this exercise, this approach works fine.
