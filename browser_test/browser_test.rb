#
# This is a small Sinatra app to test that the html created by the excerpt
# is valid. It was the easiest way to test if all the tags
# were really closed or not.
#
require "rubygems"
require "sinatra"
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. lib auto_excerpt]))

set_option(:port,8030)

HTML_BLOCK = %Q{
<p>Alright&hellip;ok&hellip;that title is a bold faced lie. I don&rsquo;t give a damn about <acronym title="Cascading Style Sheets">CSS</acronym> validation! Being a designer for a living, you have to know when to ditch some of these &lsquo;web 2.0&rsquo; type fads. When you&rsquo;re building a new site it&rsquo;s great to use the validation tool <a href="http://jigsaw.w3.org/css-validator/">found here</a> to review your style sheets and get rid of any errors, especially ones that may be giving you a couple layout problems. After that, the validation service doesn&rsquo;t mean about how good your <span class="caps">CSS</span> is, or how special you are, or how valid your stuff is. It is <strong>not</strong> at all the same as validating your <acronym title="hypertext markup language">HTML</acronym> or <acronym title="extensible hypertext markup language">XHTML</acronym>; style sheets don&rsquo;t have DOCTYPE&rsquo;s. </p>

	<p>So all those hacks which you will definitely need t use, and those special CSS3 properties you want to start using now will give you errors. These errors don&rsquo;t mean your <span class="caps">CSS</span> is flawed, or that it won&rsquo;t work, they are just arbitrary errors thrown out because there isn&rsquo;t a solid example for the validation service to run against other than the CSS2 property list.  </p>

	<p>Use the validation tool on your basic style sheets if your having a hard time figuring out what may be causing an issue. At this stage in development they are helpful tools for just that. By no means should you be running them as the final judge on your styles, or checking everyone else&rsquo;s sites to &lsquo;see if it validates&rsquo; so you can feel all professional, or posting the &lsquo;valid CSS&rsquo; emblem at the bottom of your web pages like it&rsquo;s a flag on the moon.</p>
}

get '/' do
  erb <<-HTML
    <h3>180 characters</h3>
    <%= AutoExcerpt.new(HTML_BLOCK, {:characters => 180}) %>
    <h3>80 Words</h3>
    <%= AutoExcerpt.new(HTML_BLOCK, {:words => 80}) %>
    <h3>3 Sentences</h3>
    <%= AutoExcerpt.new(HTML_BLOCK, {:sentences => 3}) %>
    <h3>2 Paragraphs</h3>
    <%= AutoExcerpt.new(HTML_BLOCK, {:paragraphs => 2}) %>
    <h3>No Paragraphs</h3>
    <%= AutoExcerpt.new(HTML_BLOCK, {:characters => 5000, :strip_paras => true}) %>
  HTML
end

use_in_file_templates!

__END__

## layout

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>

	<title>Testing AutoExcerpt Class</title>

</head>

<body>
  <%= yield %>
</body>
</html>
