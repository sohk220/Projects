# See http://docs.opscode.com/config_rb_knife.html for more information on knife configuration options

current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "sohk220"
client_key               "#{current_dir}/sohk220.pem"
validation_client_name   "cnn_nyc_test-validator"
validation_key           "#{current_dir}/cnn_nyc_test-validator.pem"
chef_server_url          "https://api.opscode.com/organizations/cnn_nyc_test"
cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
cookbook_path            ["#{current_dir}/../cookbooks"]
