module Forum

	class Server < Sinatra::Base

    # enable :sessions
    set :method_override, true 
    @@db = PG.connect(dbname: "heartbeat_forum")

    get "/" do
      redirect "/mainpage"
    end

    get "/mainpage" do
      @topics = @@db.exec_params(
        "SELECT * FROM topics"
        )
      @posts = @@db.exec_params(
        "SELECT * FROM posts"
        )
      erb :mainpage
    end

    get "/:topic/posts/:counter/:id" do 
      # @topic = params[:topic]
      post_id = params[:id][-1,1].to_i
      @post = @@db.exec_params(
          "SELECT * FROM posts WHERE id= '#{post_id}'"
          )
      
      @post_comments = @@db.exec_params(
          "SELECT * FROM comments WHERE post_id = '#{post_id}'"
          )
      erb :show_post
    end

    get "/login" do 
      erb :login 
    end

    get "/:topic/posts/new" do 
      @topic = params[:topic]
      erb :new_post
    end

    post "/:topic/posts/new" do
      
      title = params[:title]
      today_date = params[:today_date]
      message = params[:message]
      topic = @@db.exec_params(
        "SELECT id FROM topics WHERE name = '#{params[:topic]}'"
        )

      @@db.exec_params(
        "INSERT INTO posts (title,today_date,message,topic_id) VALUES ($1, $2, $3,$4)",
          [title,today_date,message,topic.first["id"]]
        )
      @post_submitted = true
      erb :new_post

    end

    get "/:topic/post/:id/edit" do 
      @topic = params[:topic]
      @id = params[:id]
      @content = @@db.exec_params(
        "SELECT message FROM posts WHERE id = '#{@id}'"
        ).first["message"]
      @title = @@db.exec_params(
        "SELECT title FROM posts WHERE id = '#{@id}'"
        ).first["title"]
      @date = @@db.exec_params(
        "SELECT today_date FROM posts WHERE id = '#{@id}'"
        ).first["today_date"]

      erb :edit_post
    end 

    put "/:topic/post/:id/edit" do 
      @post_edited = true
      id = params["id"]
      title = params["title"]
      message = params["message"]
      date = params["today_date"]
       @@db.exec_params(
        "UPDATE posts 
        SET title= '#{title}',message= '#{message}',today_date = '#{date}'
        WHERE id = '#{id}'"
        )

      erb :edit_post

    end

    get "/:topic/post/:id/delete" do 
      @topic = params[:topic]
      @id = params[:id]
      erb :delete_post
    end


    delete "/:topic/post/:id/delete" do 
      id = params["id"]
      @post_deleted = true
      @@db.exec_params(
      "DELETE FROM posts 
      WHERE id = '#{id}'"
      )
      erb :delete_post
    end

    # post "/login" do
    #   users = @@db.exec_params(
    # "INSERT INTO users (name,password) VALUES ($1,$2), [params[:name],params[:password]"
    # )
    # end

  end
end