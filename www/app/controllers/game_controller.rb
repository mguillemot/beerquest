class GameController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def start
    replay = Replay.first(:token => params[:token], :token_use_time => nil, :ip => request.remote_ip)
    result = {:ok => false}
    if replay
      #replay.seed = rand(2**31-1) # TODO réactiver
      replay.seed           = 1234
      replay.token_use_time = DateTime.now
      replay.save
      if replay.mode == 'vs'
        replay.challenge.accept! params[:raise]
      end
      result[:replay_id]    = replay.id
      result[:seed]         = replay.seed
      result[:ok]           = true
    else
      logger.error "Token #{params[:token]} invalid for IP #{request.remote_ip}"
    end
    render :text => result.to_json
  end

  def postscore
    replay = Replay.first(:token => params[:token], :ip => request.remote_ip, :game_over => false)
    if replay
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
      replay.game_over    = false # TODO filtrer les attributs reçus de tte manière
      replay.update_count += 1
      replay.user_agent   = request.env["HTTP_USER_AGENT"]
      unless replay.save
        logger.error "Impossible to save replay!"
        replay.errors.each do |e|
          logger.error "ERROR: #{e}"
        end
      end
      render :text => "OK"
    else
      logger.error "Token #{params[:token]} invalid for IP #{request.remote_ip}"
      render :text => "KO"
    end
  end

  def end
    replay = Replay.first(:token => params[:token], :ip => request.remote_ip, :game_over => false)
    result = {:valid => false, :personalHigh => false, :barHigh => false}
    if replay
      result[:valid]      = true
      logger.debug "Found replay #{replay.id} with token #{params[:token]}"
      # TODO check validité de la partie
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
      replay.user_agent   = request.env["HTTP_USER_AGENT"]
      replay.game_over    = true
      if replay.mode == 'solo'
        personal_best = replay.account.best_score_weekly_in_bar(replay.bar)
        bar_best      = replay.bar.weekly_high_score
        replay.save
        logger.info "Solo replay #{replay.id} ended with success with score #{replay.score}"

        # Check for personal high score
        logger.info "Your best weekly score in this bar was #{personal_best}"
        if replay.score > personal_best
          logger.info "New personal record!"
          result[:personalHigh] = true
        end

        # Check for bar high score
        logger.info "General best weekly score in this bar was #{bar_best}"
        if replay.score > bar_best
          logger.info "New bar record!"
          result[:barHigh] = true
        end
      elsif replay.mode == 'vs'
        replay.save
        logger.info "Replay #{replay.id} ended with success with score #{replay.score}"

        # Update corresponding challenge
        replay.challenge.end!(replay.score)
        if replay.challenge.status == 'won'
          logger.info "Challenge #{replay.challenge.id} won and counter-challenge created!"
        else
          logger.info "Challenge #{replay.challenge.id} lost!"
        end
      end

    else
      logger.error "Token #{params[:token]} invalid for IP #{request.remote_ip}"
    end
    render :text => result.to_json
  end

  def message
    replay = Replay.first(:token => params[:token], :ip => request.remote_ip, :game_over => true, :message => nil)
    if replay
      replay.message = params[:message]
      replay.save
      render :text => "OK"
    else
      render :text => "KO"
    end
  end

end
