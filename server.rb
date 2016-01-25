module Forum

	class Server < Sinatra::Base

    enable :sessions
    set :method_override, true 
    
      if ENV["RACK_ENV"] == 'production'
        uri = URI.parse(ENV['DATABASE_URL'])
        @@db = PG.connect(uri.hostname, uri.port, nil, nil, uri.path[1..-1], uri.user, uri.password)
      else
        raise 'I SHOULD NOT HAPPEN'
        @@db = PG.connect(dbname: "heartbeat_forum")
      end

      def db
        @@db
      end
     
      def current_user
        if session["user_id"]
          @user ||= @@db.exec_params(<<-SQL, [session["user_id"]]).first
            SELECT * FROM users WHERE id = $1
          SQL
        else
          # THE USER IS NOT LOGGED IN
          {}
        end
      end

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
      erb :mainpage1
    end

    get "/signup" do
      erb :signup
    end

    post "/signup" do

      encrypted_password = BCrypt::Password.create(params[:password])

      users = @@db.exec_params(<<-SQL, [params[:name],encrypted_password]) 
        INSERT INTO users (name, password) VALUES ($1, $2) RETURNING id;
      SQL

      session["user_id"] = users.first["id"]

      @signed_up = true

      erb :signup
    end

     get "/login" do 
      erb :login 
    end

    post "/login" do  
      @user = @@db.exec_params("SELECT * FROM users WHERE name = $1", [params[:name]]).first
        if @user
          if BCrypt::Password.new(@user["password"]) == params[:password]
            session["user_id"] = @user["id"]
            redirect "/"
          else
            @error = "Invalid Password"
            erb :login
          end
        else
          @error = "Invalid Username"
          erb :login
        end
    end

    get "/logout" do
      session.clear
      redirect "/"
    end

    delete "/logout" do
      session.clear
      redirect "/"
    end

    get "/:topic/posts/:counter/:id" do 
      @topic = params[:topic]
      post_id = params[:id].to_i
      @post = @@db.exec_params(
          "SELECT * FROM posts WHERE id= '#{post_id}'"
          ).first
      
      @post_comments = @@db.exec_params(
          "SELECT * FROM comments WHERE post_id = '#{post_id}'"
          )
      @user= @@db.exec_params(
          "select users.name from users
          join posts
          on users.id = posts.user_id
          where posts.id = '#{post_id}'"
          ).first
      erb :show_post
    end


    get "/:topic/posts/new" do 
      @topic = params[:topic]
      erb :new_post
    end

    post "/:topic/posts/new" do 
       
      title = params[:title]
      today_date = params[:today_date]
      message = params[:message]
      current_user_id = @@db.exec_params(
        "select id from users where name = '#{current_user["name"]}'"
        ).first["id"]
      topic = @@db.exec_params(
        "SELECT id FROM topics WHERE name = '#{params[:topic]}'"
        ).first["id"]

      @@db.exec_params(
        "INSERT INTO posts (title,today_date,message,topic_id,user_id) VALUES ($1, $2, $3,$4,$5)",
          [title,today_date,message,topic,current_user_id]
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


    get "/:topic/post/:id/newreply" do
        @topic = params[:topic]
        @id = params[:id]
        @title = @@db.exec_params(
        "SELECT title FROM posts WHERE id = '#{@id}'"
        ).first["title"]
        erb :new_reply

    end

    post "/:topic/post/:id/newreply" do

      @reply_submitted = true
      title = params[:title]
      today_date = params[:today_date]
      message = params[:message]
      post = @@db.exec_params(
        "SELECT id FROM posts WHERE id = '#{params[:id]}'"
        )

      @@db.exec_params(
        "INSERT INTO comments (title,today_date,message,post_id) VALUES ($1, $2, $3,$4)",
          [title,today_date,message,post.first["id"]]
        )
      erb :new_reply
    end

    # post "/login" do
    #   users = @@db.exec_params(
    # "INSERT INTO users (name,password) VALUES ($1,$2), [params[:name],params[:password]"
    # )
    # end

  end
end
