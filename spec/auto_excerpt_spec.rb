require File.expand_path(File.dirname(__FILE__) + "/spec_helper")
require File.join(File.dirname(__FILE__), "shared_strip_tags")

# I definitely need more tests
describe AutoExcerpt do
  include AutoExcerptHelpers
  
  before(:all) do
    @html = "foo < BAR> <><a href=\"www.beer.com\">xyzzy</a>>><br /><p><br/><p><br///><p></><br ///><p></br><p></ br> <cheeky"
  end
  
 it "should limit characters" do
   text = html_excerpt({:characters => 5})
   stripped_text(text).length.should eql(5)
   
   text = heavy_excerpt({:characters => 5})
   stripped_text(text).length.should eql(5)
 end
 
 it "should default to 150 characters" do
   text = html_excerpt
   text.length.should be_close(150, 4)
 end
 
 it "should limit words" do
   text = html_excerpt({:words => 5})
   stripped_text(text).split(" ").length.should eql(5)
   
   text = heavy_excerpt({:words => 5})
   stripped_text(text).split(" ").length.should eql(5)
   
 end
 
 it "should limit sentences" do
   text = html_excerpt({:sentences => 3})
   stripped_text(text).split(AutoExcerpt::PUNCTUATION_MARKS).length.should eql(3)
   
   text = heavy_excerpt({:sentences => 3})
   stripped_text(text).split(AutoExcerpt::PUNCTUATION_MARKS).length.should eql(3)
   
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
 
 it_should_behave_like "an HTML stripper"
end