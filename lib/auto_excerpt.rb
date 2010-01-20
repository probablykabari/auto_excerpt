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
  VERSION = '0.6'
  
  DEFAULTS = {
     :characters => 0,
     :words => 0,
     :sentences => 0, 
     :paragraphs => 0,
     :skip_characters => 0,
     :skip_words => 0,
     :skip_sentences => 0,
     :skip_paragraphs => 0,
     :ending => '...',
     :strip_html => false, #:allowed_tags => [],
     :strip_breaks_tabs => false,
     :strip_paragraphs => false
  }.freeze
  
  # TODO add and allowwed tags option
  HTMLTAGS = /<(.|\n)+?>/
  PUNCTUATION_MARKS = /\!\s|\.\s|\?\s/
  NO_CLOSE = %w( br hr img input ) # tags that do not have opposite closing tags

  # @param [String] text The text to be excerpted
  # @param [Hash] settings The settings for creating the excerpt
  # @option settings [Integer] :characters (0)
  # 
  # 
  def initialize(text, settings = {})
    @settings = DEFAULTS.dup.merge(settings)
    
    # make our copy
    @body = text.dup.strip
    @excerpt = ""
    @body.gsub!(HTMLTAGS, "") if @settings[:strip_html]
    @body.clean! if @settings[:strip_breaks_tabs]
    # TODO replace this with better regex
    @body.replace(@body.gsub(/<(\/|)p>/,'')) if @settings[:strip_paragraphs]
    # @charcount = @body.gsub(HTMLTAGS, "").length
    @charcount = @body.length
    @wordcount = @body.gsub(HTMLTAGS, "").scan(/\w+/).size
    @sencount  = @body.split(PUNCTUATION_MARKS).size
    @pghcount  = @body.split("</p>").size
    @settings[:characters] = 150 if @settings.values_at(:characters, :words, :sentences, :paragraphs).all?{|val| val.zero?  }
    
    create_excerpt
    super(@excerpt)
  end
      
  
  protected
  attr_reader :charcount, :wordcount, :sencount, :pghcount
  attr_accessor :settings, :body, :excerpt
  
 # close html tags
 # TODO make this work with new strip_html method. Improve regex
  def close_tags(text)
    tagstoclose = ""
    tags = []
    opentags = text.scan( /<(([A-Z]|[a-z]).*?)(( )|(>))/is ).transpose[0] || []
    opentags.reverse!
    closedtags = text.scan(/<\/(([A-Z]|[a-z]).*?)(( )|(>))/is).transpose[0] || []
  
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
    
    text << (@settings[:ending] || "") + tagstoclose
    @excerpt = text
  end
    
  def create_excerpt #:nodoc:
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
  def characters
    return non_excerpted_text if @charcount < @settings[:characters]
    text = @body[@settings[:skip_characters]...@settings[:characters]].split(" ")
    text.pop if text.length > 1
    text = text.join(" ")
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
    # text.last.replace(text.last.rstrip.concat(@settings.delete(:ending)))
    text = text.join("</p>")
    close_tags(text)
  end
  
  # Removes HTML tags from a string. Allows you to specify some tags to be kept.
  # @see http://codesnippets.joyent.com/posts/show/1354#comment-293
  # def strip_html(html)    
  #   reg = if @settings[:allowed_tags].any?
  #     Regexp.new(
  #       %(<(?!(\\s|\\/)*(#{
  #         @settings[:allowed_tags].map {|tag| Regexp.escape( tag )}.join( "|" )
  #       })( |>|\\/|'|"|<|\\s*\\z))[^>]*(>+|\\s*\\z)),
  #       Regexp::IGNORECASE | Regexp::MULTILINE, 'u'
  #     )
  #   else
  #     /<[^>]*(>+|\s*\z)/m
  #   end
  #   html.gsub(reg,'')
  # end
end