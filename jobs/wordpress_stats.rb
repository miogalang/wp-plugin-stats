require "net/http"
require "time"

SCHEDULER.every '5m', :first_in => 0 do |job|
  slugs = ['zendesk', 'zopim-live-chat', 'inbox-by-zendesk']

  slugs.each do |slug|
    # Total Downloads
    uri = URI("http://api.wordpress.org/plugins/info/1.0/" + slug + ".json")
    res = Net::HTTP.get_response(uri)
    response = JSON.parse res.body
    totalDownloads = response["downloaded"]

    send_event('downloads-' + slug, current: totalDownloads)

    # Version Stats
    uri = URI("https://api.wordpress.org/stats/plugin/1.0/" + slug)
    res = Net::HTTP.get_response(uri)
    response = JSON.parse res.body

    if !response.empty?
      versionsData = []
      response.each do |version, percentage|
        downloadCount = percentage * totalDownloads / 100
        versionsData << {label: version, value: downloadCount.round(0)}
      end
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
      timestamp = Time.parse(date).to_i
      downloadsData << {x: timestamp, y: downloadsCount.to_i}
    end

    series = [
      {
        name: "Daily Downloads",
        data: downloadsData
      }
    ]
    send_event("daily-downloads-" + slug, series: series, displayedValue: sum/30)
  end
end
