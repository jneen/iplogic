module IPLogic
  VERSION = '0.1.0'

  LIB = File.expand_path(File.dirname(__FILE__))
end

Dir.glob(File.join(LIB, '**', '*.rb')).each do |f|
  require f
end
