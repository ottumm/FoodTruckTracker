def get_all_phrases text, opts={}
  min = opts[:downto] ? opts[:downto] : 1
  phrases = []
  words = text.split /\s+|\: |-(?:\d|:)*/
  words.length.downto(min) do |len|
    0.upto(words.length - len) do |start|
      phrases.push words.slice(start, len).join " "
    end
  end
  
  phrases
end
