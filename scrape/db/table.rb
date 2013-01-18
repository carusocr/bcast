#Class for writing methods for interacting with our table

require 'yaml'
require 'active_record'

config = YAML.load_file(File.expand_path("../config.yml", __FILE__))

ActiveRecord::Base.establish_connection(
   "adapter" => config['dev']['adapter'],
   "database" => File.expand_path("../"+config['dev']['database'], __FILE__),
   "timeout" => config['dev']['timeout'],
)

class ScolaRecord < ActiveRecord::Base

end
