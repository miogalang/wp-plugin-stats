require "net/http"

SCHEDULER.every '1m', :first_in => 0 do |job|
  slugs = ['zendesk', 'zopim-live-chat', 'inbox-by-zendesk']

  slugs.each do |slug|
    # Total Downloads
    uri = URI("http://api.wordpress.org/plugins/info/1.0/" + slug + ".json")
    res = Net::HTTP.get_response(uri)
    response = JSON.parse res.body
    totalDownloads = response["downloaded"]

    send_event('downloads-' + slug, {value: totalDownloads})

    # Version Stats
    uri = URI("https://api.wordpress.org/stats/plugin/1.0/" + slug)
    res = Net::HTTP.get_response(uri)
    response = JSON.parse res.body

    puts slug
    if !response.empty?
      versionsData = []
      response.each do |version, percentage|
        downloadCount = percentage * totalDownloads / 100
        versionsData << {label: version, value: downloadCount.round(0)}
      end
      puts versionsData
      send_event("version-downloads-" + slug, items: versionsData)
    end

    # Download Stats
    uri = URI("https://api.wordpress.org/stats/plugin/1.0/downloads.php?limit=30&slug=" + slug)
    res = Net::HTTP.get_response(uri)
    response = JSON.parse res.body
    downloadsData = []
    sum = 0
    response.each_with_index do |(date, downloadsCount), index|
      sum += downloadsCount.to_i
      downloadsData << {x: index, y: downloadsCount}
    end
    send_event("daily-downloads-" + slug, points: downloadsData, displayedValue: sum/30)
  end
end
