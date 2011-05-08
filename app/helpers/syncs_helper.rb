module SyncsHelper
  def get_all_clients
    Dir.glob("#{Rails.root}/config/oauth/*.yml").collect do |config_filename|
      client_name = config_filename.scan(/(\w+).yml/).to_s
      client_config = YAML.load_file(config_filename)[Rails.env]
      authorized = client_config['access_token'] && client_config['access_secret']
      { :name => client_name, :authorized => authorized }
    end
  end
end
