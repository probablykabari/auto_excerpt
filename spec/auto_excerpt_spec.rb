require File.expand_path(File.dirname(__FILE__) + "/spec_helper")
require File.join(File.dirname(__FILE__), *%w[shared strip_html_spec])

# I definitely need more tests
describe AutoExcerpt do

  it { should respond_to(:new) }

  it "should return a string" do
    AutoExcerpt.new("foo bar").should be_instance_of(String)
  end

  describe "via bash" do
    before(:all) do
      @script = File.expand_path(File.join(File.dirname(__FILE__), *%w[.. bin auto_excerpt]))
      @html = AutoExcerptHelpers::HEAVY_HTML_BLOCK
      @file_path = File.join(File.dirname(__FILE__), *%w[test_file.html])
      File.open(@file_path, 'w'){|f| f.write(@html) }
    end

    after(:all) do
      FileUtils.rm(@file_path)
    end

    AutoExcerpt::Parser::DEFAULTS.each_pair{ |k,v|
      v = v.is_a?(Array) ? %w(p br span) : v
      o = {k => v}
      it "passes options correctly: '#{o.inspect}'" do
        `#{@script} #{convert_options(o)} #{@file_path}`.chomp.should == AutoExcerpt.new(@html, o)
      end
    }

    it "blows up when no STRING or FILE is passed" do
      system("#{@script} --words 10 'this is a string' &> /dev/null").should be(true)
      system("#{@script} --words 10 &> /dev/null").should be(false)
    end

    def dashed(str)
      str.gsub('_','-')
    end

    def convert_options(opts)
      opt_string = ""
      opts.each_pair do |key,val|
        v = case val
        when Array; val.join(','); break
        when TrueClass,FalseClass; nil; break
        else val.to_s
        end

        opt_string << "--#{dashed(key.to_s)} "
        (opt_string << v) if v
        opt_string << ' '
      end
      opt_string
    end
  end
end

describe AutoExcerpt::Parser do
  it "should limit characters" do
   text = html_excerpt({:characters => 5, :ending => nil})
   stripped_text(text).length.should eql(5)

   text = heavy_excerpt({:characters => 7, :ending => nil})
   stripped_text(text).length.should eql(7)
  end

  it "should default to 150 characters" do
   text = html_excerpt(:ending => nil)
   stripped_text(text).length.should be_close(150, 7)
  end

  it "does not include html tags or entities in character count" do
    AutoExcerpt::Parser.new("<h1>Hello World!</h1>", {:characters => 5, :ending => nil}).parse.should == "<h1>Hello</h1>"
    AutoExcerpt::Parser.new("<h1>Copyright &copy; 2010</h1>", {:characters => 11, :ending => nil}).parse.should == "<h1>Copyright &copy;</h1>"
  end

  it "should not cutoff in the middle of a word" do
    AutoExcerpt::Parser.new("<h1>Hello World!</h1>", {:characters => 4, :ending => nil}).parse.should == "<h1>Hello</h1>"
    AutoExcerpt::Parser.new("<h1>Hello World!</h1>", {:characters => 7, :ending => nil}).parse.should == "<h1>Hello World</h1>"
  end

  it "should limit words" do
   text = html_excerpt({:words => 5})
   stripped_text(text).split(" ").length.should eql(5)

   text = heavy_excerpt({:words => 5})
   stripped_text(text).split(" ").length.should eql(5)

  end

  it "should limit sentences" do
   text = html_excerpt({:sentences => 3})
   text.should == %{<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur...</p>}

   text = heavy_excerpt({:sentences => 3})
   text.should == %{<p>Alright&hellip;ok&hellip;that title is a bold faced lie. I don&rsquo;t give a damn about <acronym title="Cascading Style Sheets">CSS</acronym> validation. Being a designer for a living, you have to know when to ditch some of these &lsquo;web 2.0&rsquo; type fads...</p>}
  end

  it "should limit paragraphs" do
   text = html_excerpt({:paragraphs => 1})
   stripped_text(text).split("</p>").length.should eql(1)
  end

  it "should not include the :ending when limited by paragraph" do
   text = html_excerpt({:paragraphs => 1})
   stripped_text(text).split("</p>").last[-3..-1].should_not == '...'
  end

  it "should close the effin B tag" do
   t = %{
     <strong>
     left a greeting on Kroogi page of <a href="http://localhost:3000/user/sasha/" frwrd_type="user" title="sasha">sasha</a>
     </strong>
     crap
     <br />
     <br />crap<b>dddd
     <a href="/activity/read_and_frwd/1251?type=comment">(Open)</a>
   }
   text = AutoExcerpt::Parser.new(t,{:characters => 270}).parse
   text.match(/(<(\/|)b>)/).captures.length.should eql(2)
  end

  describe "when stripping HTML" do

    it_should_behave_like "an HTML stripper"

    it "should not strip P tags if :paragraphs option is set" do
      AutoExcerpt::Parser.new("<p>this is a paragraph.</p><p>this is also a paragraph.</p>",{:paragraphs => 1, :strip_html => true}).parse.should eql("<p>this is a paragraph.</p>")
    end
  end
end

