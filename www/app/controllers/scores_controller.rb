class ScoresController < ApplicationController

 protect_from_forgery :except => :postscore

	def getscores
		me = nil
		me = params[:id].to_i if params[:id] 
		scores = Replay.high_scores me
		render :text => scores.to_json
	end

	def postscore
		score = Replay.new
		logger.debug score.attributes
		params.each do |k,v|
			if score.attributes.key?(k) && v != "NaN"
				score[k] = v
			end
		end
		score.account_id = params[:id].to_i
		score.user_agent = request.env["HTTP_USER_AGENT"]
		score.save!
		render :text => "OK"
	end

	# GET /scores
	# GET /scores.xml
	def index
		@scores = Score.all

		respond_to do |format|
			format.html # index.html.erb
			format.xml { render :xml => @scores }
		end
	end

	# GET /scores/1
	# GET /scores/1.xml
	def show
		@score = Score.find(params[:id])

		respond_to do |format|
			format.html # show.html.erb
			format.xml { render :xml => @score }
		end
	end

	# GET /scores/new
	# GET /scores/new.xml
	def new
		@score = Score.new

		respond_to do |format|
			format.html # new.html.erb
			format.xml { render :xml => @score }
		end
	end

	# GET /scores/1/edit
	def edit
		@score = Score.find(params[:id])
	end

	# POST /scores
	# POST /scores.xml
	def create
		@score = Score.new(params[:score])

		respond_to do |format|
			if @score.save
				format.html { redirect_to(@score, :notice => 'Score was successfully created.') }
				format.xml { render :xml => @score, :status => :created, :location => @score }
			else
				format.html { render :action => "new" }
				format.xml { render :xml => @score.errors, :status => :unprocessable_entity }
			end
		end
	end

	# PUT /scores/1
	# PUT /scores/1.xml
	def update
		@score = Score.find(params[:id])

		respond_to do |format|
			if @score.update_attributes(params[:score])
				format.html { redirect_to(@score, :notice => 'Score was successfully updated.') }
				format.xml { head :ok }
			else
				format.html { render :action => "edit" }
				format.xml { render :xml => @score.errors, :status => :unprocessable_entity }
			end
		end
	end

	# DELETE /scores/1
	# DELETE /scores/1.xml
	def destroy
		@score = Score.find(params[:id])
		@score.destroy

		respond_to do |format|
			format.html { redirect_to(scores_url) }
			format.xml { head :ok }
		end
	end
end
