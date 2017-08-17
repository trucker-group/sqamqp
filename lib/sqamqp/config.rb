module Sqamqp
 class Config
   attr_accessor :log_file, :log_level

   def options
    res = {}
    res[:log_file] = log_file if log_file
    res[:log_level] = log_level if log_level
    res
   end
 end
end