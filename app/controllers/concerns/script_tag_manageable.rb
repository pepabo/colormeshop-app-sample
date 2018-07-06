module ScriptTagManageable
  extend ActiveSupport::Concern

  private

  def api_client(token)
    ColorMeShop.configure do |config|
      config.access_token = token
    end

    ColorMeShop::ScriptApi.new
  end

  def script_has_been_registered?(token)
    response = api_client(token).get_script_tags

    response[:script_tags].size > 0
  end

  def register_script_tag_if_needed(token)
    return if script_has_been_registered?(token)

    script_tag = ColorMeShop::ScriptTag.new({ src: Settings.script_tag.src, display_scope: 'shop' })
    api_client(token).create_script_tag(script_tag)
  end

  def delete_script_tag_if_needed(token)
    return unless script_has_been_registered?(token)

    api = api_client(token)
    response = api.get_script_tags

    response[:script_tags].each do |script|
      api.delete_script_tag(script[:id])
    end
  end
end
