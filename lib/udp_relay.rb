# frozen_string_literal: true

require_relative "udp_relay/version"
require_relative "udp_relay/application"

module UdpRelay
  class Error < StandardError; end

  class << self
    def application
      @application ||= UdpRelay::Application.new
    end
  end
end
