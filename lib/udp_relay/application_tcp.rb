require "socket"

module UdpRelay
  class ApplicationTCP
    def initialize(tcp_socket_factory = nil, udp_socket_factory = nil, kernel = nil, message_creator = nil)
      @tcp_socket_factory = tcp_socket_factory || (->(port) { TCPServer.new port })
      @udp_socket_factory = udp_socket_factory || (-> { UDPSocket.new })
      @kernel = kernel || Kernel
      @message_creator = message_creator || MessageCreator.new
    end

    def run(listen_port, destination_address, destination_port, source_id)
      @kernel.puts "Creating TCP server to listen for packets"
      tcp_server = @tcp_socket_factory.call(listen_port)
      socket = @udp_socket_factory.call

      begin
        client = tcp_server.accept

        loop do
          text = client.gets

          break if text.nil?

          sender = client.addr

          message = text.split("\n").map { |sentence| @message_creator.get_message(sender, sentence, source_id) }.join("\n") + "\n"

          socket.send message, 0, destination_address, destination_port

          @kernel.puts "Sending message to #{destination_address}:#{destination_port}:"
          @kernel.puts message
        end
      rescue => e
        @kernel.puts "Caught exception: #{e}"
      ensure
        @kernel.puts "Closing socket connection"
        socket.close

        @kernel.puts "Closing client connection"
        client.close
      end
    end
  end
end
