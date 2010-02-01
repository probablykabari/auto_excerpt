require "auto_excerpt/parser"

module AutoExcerpt
  def self.new(text, options = {})
    parser = Parser.new(text, options)
    parser.parse
  end
end