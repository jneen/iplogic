module IPLogic
  VERSION = '0.1.0'

  LIB = File.expand_path(File.dirname(__FILE__))
end

require File.join(IPLogic::LIB, 'core_ext')
require File.join(IPLogic::LIB, 'ip_logic', 'ip')
require File.join(IPLogic::LIB, 'ip_logic', 'cidr')
