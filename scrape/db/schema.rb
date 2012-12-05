require 'rubygems'
require 'active_record'
require 'yaml'

config = YAML.load_file("config.yaml")

ActiveRecord::Base.establish_connection(
    "adapter" => config['dev']['adapter'],
    "database" => config['dev']['database'],
    "timeout" => config['dev']['timeout'],
)

begin
  AciveRecord::Schema.drop_table('scola')
rescue
  nil
end

ActiveRecord::Schema.define do  
  create_table "scola",   :force => true do |t|
    t.string "prog_id",      :null => false
    t.string "iso_ln",       :null => false
    t.string "iso_cn",       :null => false
    t.datetime "start_time", :null => false
    t.integer "duration",    :null => false
    t.datetime "f_seen",     :null => false
    t.datetime "l_seen",     :null => false
    t.string "n_lang",       :null => false
    t.string "n_country",    :null => false
    t.integer "channel",     :null => false
    t.string "notes"
  end

end
