require 'rake'
require 'rake/testtask'

task :spec do
  spec_files = FileList.new('./spec/**/*_spec.rb')
  switch_spec_files = spec_files.map { |x| "-r#{x}" }.join(' ')
  sh "ruby -I./lib -r ./spec/spec_helper #{switch_spec_files} -e Minitest::Unit.autorun"
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
