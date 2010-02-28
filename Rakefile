require "spec/rake/spectask"

task :default => :spec

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "auto_excerpt"
    gemspec.summary = "Validly shorten HTML formatted text."
    gemspec.description = "Create excerpts from html formatted text. HTML tags are automatically closed and html is kept valid."
    gemspec.email = "kabari@gmail.com"
    gemspec.homepage = "http://kabari.github.com/auto_excerpt"
    gemspec.authors = ["Kabari Hendrick"]
    
    gemspec.add_development_dependency "rspec", ">= 1.2.9"
    gemspec.add_development_dependency "yard", ">= 0"
    gem.files = FileList["lib/**/*.rb",
                         "README.textile",
                         "LICENSE",
                         "VERSION",
                         "CHANGELOG"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end


desc "spec"
Spec::Rake::SpecTask.new do |t|
  t.libs << "spec"
  t.spec_files = FileList['spec/*_spec.rb']
end


begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.files   = ['lib/**/*.rb', 'README.textile', 'CHANGELOG', 'LICENSE']
    t.options = ['--any', '--extra', '--opts']
  end
rescue LoadError
  task :yard do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
