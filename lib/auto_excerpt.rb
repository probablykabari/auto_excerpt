require File.join(File.dirname(__FILE__), *%w[auto_excerpt parser])

module AutoExcerpt
  # @param [String] html A string of html.
  # @param [Hash] optons A hash of options
  # return [String]
  # @see Parser#initialize List of options
  def self.new(html, options = {})
    parser = Parser.new(html, options)
    parser.parse
  end
end