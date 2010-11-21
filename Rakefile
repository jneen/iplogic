require 'rake'
require 'rake/testtask'

begin
  require 'spec/rake/spectask'
  Spec::Rake::SpecTask.new('spec') do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.ruby_opts = ["-r spec/spec_helper.rb"]
  end
rescue LoadError
  #pass.  rspec is not required
end
