class String
  def clean # remove all double-spaces, tabs, and new lines from string
    strip.gsub(/\s{2,}|[\n\r\t]/, ' ')
  end
  
  def clean! # ditto, but replaces the original string
    replace(clean)
  end
end

# TODO allow for default options to be set.
class AutoExcerpt < String  
  DEFAULTS = {
     :characters => 0,
     :words => 0,
     :sentences => 0, 
     :paragraphs => 0,
     # :skip_characters => 0,
     :skip_words => 0,
     :skip_sentences => 0,
     :skip_paragraphs => 0,
     :ending => '...',
     :strip_html => false, :allowed_tags => [],
     :strip_breaks_tabs => false,
     :strip_paragraphs => false
  }
  
  # TODO add and allowwed tags option
  PUNCTUATION_MARKS = /\!\s|\.\s|\?\s/
  NO_CLOSE = %w( br hr img input ) # tags that do not have opposite closing tags
  OPENING_TAG = /<([a-z0-9]{1,})\b[^>]*>/im
  CLOSING_TAG = /<\/([a-z0-9]{1,})>/im
  
  # @param [String] text The text to be excerpted
  # @param [Hash] settings The settings for creating the excerpt
  # @option settings [Integer] :characters (0) The number of characters to limit the html by
  # @option settings [Integer] :words (0) The number of words to limit the html by
  # @option settings [Integer] :sentences (0) The number of sentences to limit the html by
  # @option settings [Integer] :paragraphs (0) The number of paragraphs to limit the html by
  # @option settings [Integer] :skip_characters (0) The number of characters to skip from the start of the html
  # @option settings [Integer] :skip_words (0) The number of words to skip from the start of the html
  # @option settings [Integer] :skip_sentences (0) The number of sentences to skip from the start of the html
  # @option settings [Integer] :skip_paragraphs (0) The number of paragraphs to skip from the start of the html
  # @option settings [String] :ending ('...') A string added to the end of the excerpt
  # @option settings [Boolean] :strip_html (false) Strip all HTML from the text before creating the excerpt
  # @option settings [Boolean] :strip_paragraphs (false) Strip all <p> tags from the HTML before creating the excerpt
  def initialize(text, settings = {})
    @settings = Marshal.load(Marshal.dump(DEFAULTS)).merge(settings)
    
    # make our copy
    @body = text.dup.strip
    @excerpt = ""
    
    if @settings[:strip_html]
      (@settings[:allowed_tags] << "p") if @settings[:paragraphs] > 0 # don't stip P tags if that is the limiter
      @body = strip_html(@body) 
    end
    @body = @body.clean if @settings[:strip_breaks_tabs]
    # TODO replace this with better regex
    @body.replace(@body.gsub(/<(\/|)p>/,'')) if @settings[:strip_paragraphs]
    @charcount = strip_html(@body).length
    @wordcount = strip_html(@body).scan(/\w+/).size
    @sencount  = @body.split(PUNCTUATION_MARKS).size
    @pghcount  = @body.split("</p>").size
    @settings[:characters] = 150 if @settings.values_at(:characters, :words, :sentences, :paragraphs).all?{|val| val.zero? || val.nil?  }
    
    create_excerpt
    super(@excerpt)
  end
      
  
  protected
  
  attr_reader :charcount, :wordcount, :sencount, :pghcount
  attr_accessor :settings, :body, :excerpt
  
 # close html tags
 # TODO make this work with new strip_html method. Improve regex
  def close_tags(text)
    # Don't bother closing tags if html is stripped since there are no tags.
    if @settings[:strip_html] && @settings[:allowed_tags].empty?
      tagstoclose = nil
    else
      tagstoclose = ""
      tags = []
      # /<(([A-Z]|[a-z]).*?)(( )|(>))/is
      # /<\/(([A-Z]|[a-z]).*?)(( )|(>))/is
      opentags = text.scan(OPENING_TAG).transpose[0] || []
      opentags.reverse!
      closedtags = text.scan(CLOSING_TAG).transpose[0] || []
  
      opentags.each do |ot|
        if closedtags.include?(ot)
          closedtags.delete_at(closedtags.index(ot))
        else
          tags << ot
        end
      end
    
      tags.each do |tag|
        tagstoclose << "</#{tag.strip.downcase}>" unless NO_CLOSE.include?(tag)
      end      
    end
    
    @excerpt = [text, @settings[:ending], tagstoclose].compact.join
  end
    
  def create_excerpt
    return characters unless @settings[:characters].zero?
    return words      unless @settings[:words].zero?
    return sentences  unless @settings[:sentences].zero?
    return paragraphs unless @settings[:paragraphs].zero?  
  end

  def non_excerpted_text
    @settings[:ending] = nil
    close_tags(@body)
  end

  # limit by characters
  # @todo make this work with skip characters
  def characters
    return non_excerpted_text if @charcount < @settings[:characters]
    text = ""
    html_count = char_count = 0
    start_end_tags = /#{Regexp.union(/(<[a-z0-9]{1,}\b[^>]*>)/,/(<\/[a-z0-9]{1,}>)/)}/io
    @body.split(start_end_tags).each do |piece|
      if piece =~ start_end_tags
        html_count += piece.length
      else
        chars_left = @settings[:characters] - char_count
        char_count += piece[0...chars_left].length
      end
      break if (char_count >= @settings[:characters])
    end 
    text = @body[0...(html_count+char_count)]
    close_tags(text)
  end
  
  # limit by words
  def words
    return non_excerpted_text if @wordcount < @settings[:words]
     text = @body.split(" ").slice(@settings[:skip_words], @settings[:words]).join(" ")
     close_tags(text)
  end

  # limit by sentences
  def sentences
    return non_excerpted_text if @sencount < @settings[:sentences]
    text = @body.split(PUNCTUATION_MARKS).slice(@settings[:skip_sentences], @settings[:sentences]).join(". ")
    close_tags(text)
  end

  # limit by paragraphs
  def paragraphs
    return non_excerpted_text if @pghcount < @settings[:paragraphs]
    text = @body.split("</p>").slice(@settings[:skip_paragraphs], @settings[:paragraphs])
    @settings[:ending] = nil
    text = text.join("</p>")
    close_tags(text)
  end
  
  # Removes HTML tags from a string. Allows you to specify some tags to be kept.
  # @see http://codesnippets.joyent.com/posts/show/1354#comment-293
  def strip_html(html)
    allowed = @settings[:allowed_tags]
    reg = if allowed.any?
      Regexp.new(
        %(<(?!(\\s|\\/)*(#{
          allowed.map {|tag| Regexp.escape( tag )}.join( "|" )
        })( |>|\\/|'|"|<|\\s*\\z))[^>]*(>+|\\s*\\z)),
        Regexp::IGNORECASE | Regexp::MULTILINE, 'u'
      )
    else
      /<[^>]*(>+|\s*\z)/m
    end
     @stripped_html ||= html.gsub(reg,'')
  end
end