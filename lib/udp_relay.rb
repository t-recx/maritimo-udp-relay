# frozen_string_literal: true

require_relative "udp_relay/version"
require_relative "udp_relay/application"
require_relative "udp_relay/application_tcp"

module UdpRelay
  class Error < StandardError; end

  class << self
    def application
      @application ||= UdpRelay::Application.new
    end

    def application_tcp
      @application_tcp ||= UdpRelay::ApplicationTCP.new
    end
  end
end
