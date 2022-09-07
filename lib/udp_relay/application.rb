require "socket"

module UdpRelay
  class Application
    def initialize(udp_socket_factory = nil, kernel = nil)
      @udp_socket_factory = udp_socket_factory || (-> { UDPSocket.new })
      @kernel = kernel || Kernel
    end

    def run(listen_port, destination_address, destination_port, source_id)
      @kernel.puts "Creating UDP socket to listen for packets"
      socket = @udp_socket_factory.call

      @kernel.puts "Binding socket to #{listen_port}"
      socket.bind("0.0.0.0", listen_port)

      begin
        loop do
          text, sender = socket.recvfrom(1024 * 16)

          message = text.split("\n").map { |sentence| get_message(sender, sentence, source_id) }.join("\n") + "\n"

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

    def get_message sender, sentence, source_id
      if !source_id.nil?
        if sentence.chars.count { |x| x == "\\" } >= 2
          # already has block

          if sentence.include? "s:"
            # replace
            tokens = sentence.split("s:", 2)
            rest_of_sentence = tokens[1].partition(/[,*]/).drop(1).join

            return "[#{sender[3]}]#{tokens[0]}s:#{source_id}#{rest_of_sentence}"
          else
            # introduce inside block
            tokens = sentence.split("\\")
            existing_block_contents = tokens[1]
            rest_of_sentence = tokens[2]

            return "[#{sender[3]}]\\s:#{source_id},#{existing_block_contents}\\#{rest_of_sentence}"
          end
        else
          # introduce new block with s:
          return "[#{sender[3]}]\\s:#{source_id}*00\\#{sentence}"
        end
      end

      "[#{sender[3]}]#{sentence}"
    end
  end
end
