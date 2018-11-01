Rails.application.config.middleware.use OmniAuth::Builder do
  provider :colormeshop, ENV['COLORMESHOP_CLIENT_ID'], ENV['COLORMESHOP_CLIENT_SECRET'], { scope: 'read_script_tags write_script_tags' }
end

OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}
