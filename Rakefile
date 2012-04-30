require 'rake'
require 'rake/testtask'

task :spec do
  sh "bundle exec rspec -I spec/ spec/*_spec.rb"
end

task :doc do
  sh "bundle exec yard"
end

task :default => [:spec]

CLEAN = %w(
  *.gem
  **/*.rbc
).map(&Dir.method(:glob)).flatten

task :clean do
  sh "rm -f", *CLEAN
end
