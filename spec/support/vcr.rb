require 'vcr'

module Helper
  def sanitize_body(body)
    body = JSON.parse(body) unless body.is_a?(Hash)
    Hash[
      body.map { |key, val|
        [key, sanitize_json(val, %w(state id).include?(key))]
      }
    ]
  rescue
    body
  end
  module_function :sanitize_body

  def sanitize_json(json, do_not_filter = false)
    if json.is_a?(Hash)
      sanitize_body(json)
    elsif json.is_a?(Array)
      json.map { |value| sanitize_json(value) }
    elsif do_not_filter || !json.is_a?(String)
      json
    else
      'filtered'
    end
  end
  module_function :sanitize_json
end

VCR.configure do |vcr|
  vcr.allow_http_connections_when_no_cassette = false
  vcr.cassette_library_dir = File.join(File.dirname(__FILE__), '..', 'vcr')
  vcr.configure_rspec_metadata!
  vcr.hook_into :excon

  vcr.before_record do |interaction|
    interaction.request.headers.delete('Cookie')
    interaction.request.headers.delete('Authorization')

    interaction.response.headers.delete('Set-Cookie')
    interaction.response.body =
      Helper.sanitize_body(interaction.response.body).to_json
  end
end
