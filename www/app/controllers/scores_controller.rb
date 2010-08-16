class ScoresController < ApplicationController

	protect_from_forgery :except => :postscore

	def start
		replay = Replay.find_by_token_and_token_use_time_and_ip(params[:token], nil, request.remote_ip)
		result = {}
		if replay
			replay.seed = rand(2147483647)
			replay.token_use_time = DateTime.now
			begin
				replay.save!
				result[:replay_id] = replay.id
				result[:seed] = replay.seed
				result[:ok] = true
			rescue ActiveRecord::ActiveRecordError
				logger.error "Could not mark token #{params[:token]} as used"
				result[:ok] = false
			end
		else
			logger.error "Token #{params[:token]} invalid for IP #{request.remote_ip}"
			result[:ok] = false
		end
		render :text => result.to_json
	end

	def getscores
		me = nil
		me = params[:id].to_i if params[:id]
		@bar = Bar.find(1) # TODO paramétrize
		scores = @bar.high_scores(me)
		render :text => scores.to_json
	end

	def postscore
		replay = Replay.find_by_token params[:token]
		params.each do |k, v|
			if replay.attributes.key?(k) && v != "NaN"
				replay[k] = v
			end
		end
		replay.update_count += 1
		replay.account_id = params[:id].to_i
		replay.user_agent = request.env["HTTP_USER_AGENT"]
		replay.save!

		@bar = Bar.find(1) # TODO paramétrize
		barship = @bar.barships.find_by_account_id(replay.account_id)
		unless barship
			barship = @bar.barships.build(:account_id => replay.account_id)
		end
		barship.total_beers += replay.score
		if replay.score > barship.max_beers
			barship.max_beers = replay.score
		end
		barship.save!

		render :text => "OK"
	end

end
