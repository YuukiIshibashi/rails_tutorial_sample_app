class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    # @relationship = current_user.relationships.build(params[:followed_id])
    # if @relationship.save
    #   flash[:success] = "フォローしました"
    # else
    # end
    
    # user = User.find(params[:followed_id])
    # current_user.follow(user)
    # redirect_to user

    @user = User.find(params[:followed_id])
    current_user.follow(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.turbo_stream
    end
  end

  def destroy
    # relationship = Relationship.find(params[:id])
    # relationship.destroy

    # user = Relationship.find(params[:id]).followed
    # current_user.unfollow(user)
    # redirect_to user, status: :see_other

    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
    respond_to do |format|
      format.html { redirect_to @user, status: :see_other }
      format.turbo_stream
    end
  end
end
