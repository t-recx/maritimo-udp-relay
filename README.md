# UdpRelay

This application receives data via-UDP annotates each message with the sender's IP and relays those annotated messages to a destination.

## Requirements

- Ruby
- [Bundler](https://bundler.io/)

## Configuration

Configuration is done via environment variables.

| Name                      | Description                         |
| ------------------------- | ----------------------------------- |
| RELAY_LISTEN_PORT         | Listening port                      |
| RELAY_DESTINATION_ADDRESS | Destination address                 |
| RELAY_DESTINATION_PORT    | Destination port                    |
| RELAY_SOURCE_ID           | Source ID (optional)                |
| RELAY_CONNECTION_TYPE     | Listening connection type (TCP/UDP) |

## Running

Inside the station directory, install any missing gem dependencies using:

    $ bundle install

And then run the application using:

    $ bundle exec exe/relay

## Tests

To run the tests execute the following command from the root of the station application directory:

    $ bundle exec rake test

## Linting/Formating code

To automatically lint and format code execute the following command from the root of the station application directory:

    $ bundle exec standardrb --fix
