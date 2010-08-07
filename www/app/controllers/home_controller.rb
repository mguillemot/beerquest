class HomeController < ApplicationController
	def play
		@required_version = (params[:id].to_i <= 2) ? "0.5" : "0.4"
		@mode = "solo"
		@server_url = url_for(:controller => 'scores', :action => 'postscore')
		@token = "test"
		@opponent = {
						:id => 123,
						:name => "Hop Onent",
						:title => "Le Moche",
						:level => 15,
						:total_beers => 67890,
						:total_caps => 666666,
						:avatar => "http://static.ak.fbcdn.net/rsrc.php/z5HB7/hash/ecyu2wwn.gif"
		}.to_json
		@bar = {
						:name => "Chez Robert",
						:location => "Roubaix - France",
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
							:total_beers => 0,
							:total_caps => 0,
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
							:total_beers => 0,
							:total_caps => 0,
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
