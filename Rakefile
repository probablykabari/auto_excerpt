require "spec/rake/spectask"

task :default => :spec

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "auto_excerpt"
    gemspec.summary = "Create excerpts from html formatted text."
    gemspec.description = "Create excerpts from html formatted text. HTML tags are automatically closed."
    gemspec.email = "kabari@gmail.com"
    gemspec.homepage = "http://github.com/kabari/auto_excerpt"
    gemspec.authors = ["Kabari Hendrick"]
    
    gemspec.add_development_dependency "rspec", ">= 1.2.9"
    gemspec.add_development_dependency "yard", ">= 0"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end


desc "spec"
Spec::Rake::SpecTask.new do |t|
  t.libs << "spec"
  t.spec_files = FileList['spec/**/*_spec.rb']
end


begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yard do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
