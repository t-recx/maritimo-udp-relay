require "socket"

module UdpRelay
  class Application
    def initialize(udp_socket_factory = nil, kernel = nil, message_creator = nil)
      @udp_socket_factory = udp_socket_factory || (-> { UDPSocket.new })
      @kernel = kernel || Kernel
      @message_creator = message_creator || MessageCreator.new
    end

    def run(listen_port, destination_address, destination_port, source_id)
      @kernel.puts "Creating UDP socket to listen for packets"
      socket = @udp_socket_factory.call

      @kernel.puts "Binding socket to #{listen_port}"
      socket.bind("0.0.0.0", listen_port)

      begin
        loop do
          text, sender = socket.recvfrom(1024 * 16)

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
      end
    end
  end
end
