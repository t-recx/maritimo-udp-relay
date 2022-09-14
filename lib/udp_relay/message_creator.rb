module UdpRelay
  class MessageCreator
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
