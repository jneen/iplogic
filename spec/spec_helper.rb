require File.expand_path(File.join(
  File.dirname(__FILE__),
  '..',
  'lib',
  'ip'
))

Spec::Runner.configure do |config|
  config.include IPLogic
end
