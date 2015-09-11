require "net/http"

SCHEDULER.every '1m', :first_in => 0 do |job|
  slugs = ['zendesk', 'zopim-live-chat', 'inbox-by-zendesk']
  slugs.each do |slug|
    # Total Downloads
    url = "http://api.wordpress.org/plugins/info/1.0/" + slug + ".json"
    uri = URI(url)

    res = Net::HTTP.get_response(uri)
    response = JSON.parse res.body

    send_event('downloads-' + slug, {value: response["downloaded"]})
  end
end
