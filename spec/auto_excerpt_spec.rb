require File.expand_path(File.dirname(__FILE__) + "/spec_helper")
require File.join(File.dirname(__FILE__), *%w[shared strip_html_spec])

# I definitely need more tests
describe AutoExcerpt do
  
  it "should limit characters" do
   text = html_excerpt({:characters => 5, :ending => nil})
   stripped_text(text).length.should eql(5)
 
   text = heavy_excerpt({:characters => 5, :ending => nil})
   stripped_text(text).length.should eql(5)
  end

  it "should default to 150 characters" do
   text = html_excerpt(:ending => nil)
   stripped_text(text).length.should eql(150)
  end

  it "does not include html tags in character count" do
    AutoExcerpt.new("<h1>Hello World!</h1>", {:characters => 5, :ending => nil}).should == "<h1>Hello</h1>"
  end
  
  it "should not cutoff in the middle of a word" do
    pending("this does not work yet") do
      AutoExcerpt.new("<h1>Hello World!</h1>", {:characters => 4, :ending => nil}).should == "<h1>Hello</h1>"
    end
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
 
   # text = heavy_excerpt({:sentences => 3})
   # text.should == %{<p>Alright&hellip;ok&hellip;that title is a bold faced lie. I don&rsquo;t give a damn about <acronym title="Cascading Style Sheets">CSS</acronym> validation! Being a designer for a living, you have to know when to ditch some of these &lsquo;web 2.0&rsquo; type fads...</p>} 
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
   text = AutoExcerpt.new(t,{:characters => 270})
   text.match(/(<(\/|)b>)/).captures.length.should eql(2)
  end
  
end

describe AutoExcerpt, "when stripping HTML" do
  
  it_should_behave_like "an HTML stripper"
  
  it "should not strip P tags if :paragraphs option is set" do
    AutoExcerpt.new("<p>this is a paragraph.</p><p>this is also a paragraph.</p>",{:paragraphs => 1, :strip_html => true}).should eql("<p>this is a paragraph.</p>")
  end
end