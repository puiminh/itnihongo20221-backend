class PostsController < ApplicationController
  before_action :set_post, only: [:show, :update, :destroy]

  # GET /posts
  def index
    @posts = Post.all

    render json: @posts
  end

  # GET /posts/1
  def show
    render json: @post
  end

  # POST /posts
  def create
    authenticate_account!
    @post = Post.new(post_params)
    @post[:user_id] = current_account.id

    if @post.save
      render json: @post, status: :created, location: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /posts/1
  def update
    authenticate_account!
    if current_account.id != @post[:user_id].to_i
      render json: { message: 'Not your post' }, status: :forbidden
      return
    end

    @post[:user_id] = current_account.id

    if @post.update(post_params)
      render json: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1
  def destroy
    authenticate_account!
    puts current_account.role
    if (current_account.id != @post[:user_id].to_i) && current_account.user?
      render json: { message: 'Not your post' }, status: :forbidden
      return
    end
    @post.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def post_params
      params.require(:post).permit(:user_id, :term, :description)
    end
end
