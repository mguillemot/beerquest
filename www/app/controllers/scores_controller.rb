class ScoresController < ApplicationController

  protect_from_forgery :except => :postscore

  def start
    replay = Replay.first(:token => params[:token], :token_use_time => nil, :ip => request.remote_ip)
    result = {}
    if replay
      replay.seed = rand(2**31-1)
      replay.token_use_time = DateTime.now
      if replay.save
        result[:replay_id] = replay.id
        result[:seed] = replay.seed
        result[:ok] = true
      else
        logger.error "Could not mark token #{params[:token]} as used"
        result[:ok] = false
      end
    else
      logger.error "Token #{params[:token]} invalid for IP #{request.remote_ip}"
      result[:ok] = false
    end
    render :text => result.to_json
  end

  def postscore
    replay = Replay.first(:token => params[:token])
    logger.debug "Found replay #{replay.id} with token #{params[:token]}"
    params.each do |k, v|
      logger.debug "Received: #{k} => #{v}"
      if v != "NaN"
        begin
          if k[0..3] == 'avg_'
            v = v.to_f.round(3)
          end
          replay.attribute_set(k, v)
        rescue NoMethodError
          logger.warn "No attribute #{k}"
        end
      end
    end
    replay.update_count += 1
    replay.user_agent = request.env["HTTP_USER_AGENT"]
    unless replay.save
      logger.error "Impossible to save replay!"
      replay.errors.each do |e|
        logger.error "ERROR: #{e}"
      end
    end

#    barship = replay.bar.barships.find_by_account_id(replay.account_id)
#    unless barship
#      barship = replay.bar.barships.build(:account_id => replay.account_id)
#    end
#    barship.total_beers += replay.score
#    if replay.score > barship.max_beers
#      barship.max_beers = replay.score
#    end
#    barship.save!

    render :text => "OK"
  end

end
