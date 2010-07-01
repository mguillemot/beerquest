class AccountsController < ApplicationController
	def index
		render :text => 'toto=tutu&titi=tonton'
	end
end
