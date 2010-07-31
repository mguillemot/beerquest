class HomeController < ApplicationController
	def index
		@oauth_url = MiniFB.oauth_url(BeerQuest::FB_APP_ID, BeerQuest::FB_BASE_URL + "facebook/opensession", :scope => "email")
	end

	def play
		@required_version = "0.3"
		@mode = "solo"
		@server_url = url_for(:controller => 'scores', :action => 'postscore')
		@token = "test"
		@opponent = {
						:name => "Hop Onent",
						:title => "Le Moche",
						:level => 15,
						:avatar => "http://static.ak.fbcdn.net/rsrc.php/z5HB7/hash/ecyu2wwn.gif"
		}.to_json
		@bar = {
						:name => "Le Salon de Massage",
						:location => "Tôkyô - Japon",
						:banner => "http://erhune.iobb.net/images/banner.jpg",
						:open => "21:00",
						:close => "2:00"
		}.to_json

		begin
			account = Account.find params[:id]
			@full_name = "#{account.first_name} #{account.last_name}"
			@me = {
							:id => params[:id].to_i,
							:name => @full_name,
							:title => account.title,
							:level => account.level,
							:avatar => account.avatar
			}.to_json
			@scores = BetaScore.high_scores(params[:id].to_i).to_json
		rescue ActiveRecord::RecordNotFound
			@full_name = "Anne Onymous"
			@me = {
							:id => 0,
							:name => @full_name,
							:title => "L'Inconnu",
							:level => 0,
							:avatar => "http://static.ak.fbcdn.net/rsrc.php/z5HB7/hash/ecyu2wwn.gif"
			}.to_json
			@scores = BetaScore.high_scores.to_json
		end
	end

	def help
	end

	def privacy
	end

	def tos
	end
end
