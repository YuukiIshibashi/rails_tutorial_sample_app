class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user, only: :destroy

  def create
    @micropost = current_user.microposts.build(micropost_params)
    @micropost.image.attach(params[:micropost][:image])
    if @micropost.save
      flash[:success] = "micropostを投稿しました"
      redirect_to root_path
    else
      @feed_items = current_user.feed.paginate(page: params[:page])
      flash[:danger] = "投稿できませんでした"
      render 'static_pages/home', status: :unprocessable_entity
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    # 直前のURL
    redirect_back_or_to(root_url, status: :see_other)
    # if request.referrer.nil?
    #   redirect_to root_url, status: :see_other
    # else
    #   redirect_to request.referrer, status: :see_other
    #end
  end

  private
    def micropost_params
      params.require(:micropost).permit(:content, :image)
    end

    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url, status: :see_other if @micropost.nil?
    end
end
