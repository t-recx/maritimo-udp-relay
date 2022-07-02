require "test_helper"
require "udp_relay"

include UdpRelay

describe Application do
  let(:udp_data_received) { [] }
  let(:udp_socket_factory) do
    lambda {
      @udp_socket ||= FakeUdpSocket.new

      @udp_socket.received = udp_data_received

      @udp_socket
    }
  end
  let(:kernel) { FakeKernel.new }

  let(:listen_port) { 3500 }
  let(:destination_address) { "test.org" }
  let(:destination_port) { 3212 }

  subject { Application.new udp_socket_factory, kernel }

  describe :run do
    it "should create a socket" do
      exercise_run

      _(@udp_socket).wont_be_nil
    end

    it "should bind socket to listen_port" do
      exercise_run

      _(@udp_socket.binded_host).must_equal "0.0.0.0"
      _(@udp_socket.binded_port).must_equal listen_port
    end

    it "should close socket" do
      exercise_run

      _(@udp_socket.closed_called).must_equal true
    end

    describe "when socket returns values" do
      let(:udp_data_received) { [["ONE\nTWO\n", [nil, nil, nil, "230.49.12.3"]], ["A\nB\n", [nil, nil, nil, "174.2.44.1"]]] }

      it "should be received and published with the source's ip address" do
        exercise_run

        _(@udp_socket.sent).must_equal [
          {message: "[230.49.12.3]ONE\n[230.49.12.3]TWO", flags: 0, address: destination_address, port: destination_port},
          {message: "[174.2.44.1]A\n[174.2.44.1]B", flags: 0, address: destination_address, port: destination_port}
        ]
      end
    end
  end

  def exercise_run
    subject.run listen_port, destination_address, destination_port
  end
end

class FakeUdpSocket
  attr_accessor :binded_host, :binded_port, :received, :received_index, :closed_called, :sent

  def initialize
    @received = []
    @sent = []
    @received_index = 0
    @closed_called = false
  end

  def bind(host, port)
    @binded_host = host
    @binded_port = port
  end

  def recvfrom bytes
    return_value = @received[@received_index]

    @received_index += 1

    raise unless return_value

    return_value
  end

  def send message, flags, address, port
    @sent.push({message: message, flags: flags, address: address, port: port})
  end

  def close
    @closed_called = true
  end
end

class FakeKernel
  def puts(pstr = "")
  end
end