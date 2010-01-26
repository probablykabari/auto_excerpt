describe "an HTML stripper", :shared => true do
  
  before(:all) do
    @html = "foo < BAR> <><a href=\"www.beer.com\">xyzzy</a>>><br /><p><br/><p><br///><p></><br ///><p></br><p></ br> <cheeky"
    
  end
  it "should strip html tags" do
    AutoExcerpt.new(@html, {:strip_html => true}).should == "foo  xyzzy "
  end
  
  # cheeky keeper
  it "should allow given tags" do
    AutoExcerpt.new(@html, {:strip_html => true, :allowed_tags => %w(bar br ) }).should == "foo < BAR> xyzzy<br /><br/><br///><br ///></br></ br> " 
  end

  it "should treat unclosed tags at the end of the document as tags to be safe" do
    AutoExcerpt.new(@html, {:strip_html => true, :allowed_tags => %w(cheeky monkey) }).should == "foo  xyzzy <cheeky"
    AutoExcerpt.new("pass< cheeky", {:strip_html => true, :allowed_tags => %w(cheeky) }).should == "pass< cheeky"
    AutoExcerpt.new("pass< cheeky ", {:strip_html => true, :allowed_tags => %w(cheeky) }).should == "pass< cheeky"
    AutoExcerpt.new("pass< cheeky  ", {:strip_html => true, :allowed_tags => %w(cheeky) }).should == "pass< cheeky"
  end

  it "should treat quotes, less thans and shashes as tag word terminators to be conservative" do
    q_test_html = "pass<img'foo' >"
    dbq_test_html = "pass<img\"foo\""
    lt_test_html = "pass<img<foo\" "
    AutoExcerpt.new(q_test_html, {:strip_html => true, :allowed_tags => %w(img) }).should == q_test_html
    AutoExcerpt.new(dbq_test_html, {:strip_html => true, :allowed_tags => %w(img) }).should == dbq_test_html
    AutoExcerpt.new(lt_test_html, {:strip_html => true, :allowed_tags => %w(img) }).should == "pass<img" # treats foo as new tag
  end

  it "should know the difference between a tag called a and one called alpha" do
    difference_test = "passed<alpha> the test"
    AutoExcerpt.new(difference_test, {:strip_html => true, :allowed_tags => %w(a) }).should == "passed the test"
    AutoExcerpt.new(difference_test, {:strip_html => true, :allowed_tags => %w(alpha) }).should == "passed<alpha> the test</alpha>"
  end
  
end