#Class for writing methods for interacting with our table

require 'yaml'
require 'active_record'

config = YAML.load_file(File.expand_path("../config.yaml", __FILE__))

ActiveRecord::Base.establish_connection(
   "adapter" => config['dev']['adapter'],
   "database" => config['dev']['database'],
   "timeout" => config['dev']['timeout'],
)

class ScolaRecord < ActiveRecord::Base

end
