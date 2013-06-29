require 'sinatra'
require 'nokogiri'
require 'open-uri'
require 'meta-spotify'
require 'json'

set :protection, except: :ip_spoofing

get '/' do
  erb :index
end


post '/8ts' do
	username = params[:username]
	url = "http://8tracks.com/users/" + username + "/favorite_tracks?per_page=1000"
	# http://8tracks.com/users/aliamin/favorite_tracks?per_page=1000
	# 8tracks.com/users/mahesh427/favorite_tracks
	html = Nokogiri::HTML(open(url))
	tracks = []
	html.css('.track_info').each do |i|
		tracks << i.text
	end
	uris = []
	tracks.each do |track|
		result = MetaSpotify::Track.search(track)
		uris << result[:tracks][0].uri.gsub("spotify:track:","") if (result.count > 0) rescue nil
	end
	# https://embed.spotify.com/?uri=spotify:trackset:cggaurav:0Qw7qGuXlVBZLcfoQ17yZn,5tu9ExlYqrlSk1MjAMTr2O,67Hna13dNDkZvBpTXRIaOJ&theme=white&view=coverart
	src = 'https://embed.spotify.com/?uri=spotify:trackset:'
	src += username.to_s
	src += ":"
	src += uris.compact.join(",")
	src += '&theme=white&view=coverart'
	return {'src' => src}.to_json
end