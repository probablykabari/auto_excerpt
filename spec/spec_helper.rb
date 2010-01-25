require "rubygems"
require "spec"
require File.join(File.dirname(__FILE__), *%w[.. lib auto_excerpt])

module AutoExcerptHelpers
  def html_excerpt(opts = {})
   AutoExcerpt.new(HTML_BLOCK, opts)
  end

  def normal_excerpt(opts = {})
   AutoExcerpt.new(NORMAL_TEXT, opts)
  end

  def heavy_excerpt(opts = {})
   AutoExcerpt.new(HEAVY_HTML_BLOCK, opts)
  end

  def stripped_text(t)
   t.gsub(/<[^>]*(>+|\s*\z)/m, "")
  end
  
  CRAP_HTML = "foo < BAR> <><a href=\"www.beer.com\">xyzzy</a>>><br /><p><br/><p><br///><p></><br ///><p></br><p></ br> <cheeky"
  
  MORE_CRAP_HTML = ""
  
  NORMAL_TEXT = %{Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
    
    Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
    }
    
  HTML_BLOCK = <<-HTML
  <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor <strong>incididunt</strong> ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
  </p>
  
  <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
  </p>
  HTML
 
  HEAVY_HTML_BLOCK = %Q{
  <p>Alright&hellip;ok&hellip;that title is a bold faced lie. I don&rsquo;t give a damn about <acronym title="Cascading Style Sheets">CSS</acronym> validation! Being a designer for a living, you have to know when to ditch some of these &lsquo;web 2.0&rsquo; type fads. When you&rsquo;re building a new site it&rsquo;s great to use the validation tool <a href="http://jigsaw.w3.org/css-validator/">found here</a> to review your style sheets and get rid of any errors, especially ones that may be giving you a couple layout problems. After that, the validation service doesn&rsquo;t mean about how good your <span class="caps">CSS</span> is, or how special you are, or how valid your stuff is. It is <strong>not</strong> at all the same as validating your <acronym title="hypertext markup language">HTML</acronym> or <acronym title="extensible hypertext markup language">XHTML</acronym>; style sheets don&rsquo;t have DOCTYPE&rsquo;s. </p>

  	<p>So all those hacks which you will definitely need t use, and those special CSS3 properties you want to start using now will give you errors. These errors don&rsquo;t mean your <span class="caps">CSS</span> is flawed, or that it won&rsquo;t work, they are just arbitrary errors thrown out because there isn&rsquo;t a solid example for the validation service to run against other than the CSS2 property list.  </p>

  	<p>Use the validation tool on your basic style sheets if your having a hard time figuring out what may be causing an issue. At this stage in development they are helpful tools for just that. By no means should you be running them as the final judge on your styles, or checking everyone else&rsquo;s sites to &lsquo;see if it validates&rsquo; so you can feel all professional, or posting the &lsquo;valid CSS&rsquo; emblem at the bottom of your web pages like it&rsquo;s a flag on the moon.</p>
  }
end

Spec::Runner.configure do |config|
  config.include AutoExcerptHelpers
end
