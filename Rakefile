require 'rake'
require 'rake/testtask'

# begin
task :spec do
  sh "rspec -I spec/ spec/*_spec.rb"
end

#   require 'rspec/rake'
#   Spec::Rake::SpecTask.new('spec') do |t|
#     t.spec_files = FileList['spec/**/*_spec.rb']
#     t.ruby_opts = ["-r spec/spec_helper.rb"]
#   end

  task :default => [:spec]
# rescue LoadError
#   #pass.  rspec is not required
# end
