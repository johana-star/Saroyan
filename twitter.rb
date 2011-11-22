require "rubygems"
require "twitter"
require 'sinatra'
require 'time'
require 'yaml'

before do
  headers "Content-Type" => "text/html; charset=utf-8"
end

def authenticate

    #TODO: Ensure that yaml based obfuscation combined with a selective gitignore is the right way to keep this secret.
    #Resources: YML, Git IRCs? Twitter?

    # See also: http://blog.innovativethought.net/2009/01/02/making-configuration-files-with-yaml-revised/ — On configuring YML
  
  Twitter.configure do |c|
    config = YAML.load(File.read("config.yml"))[:twitter]
    c.consumer_key       = config[:consumer_key]
    c.consumer_secret    = config[:consumer_secret]
    c.oauth_token        = config[:oauth_token]
    c.oauth_token_secret = config[:oauth_token_secret]
  end
  @client = Twitter::Client.new
end

get '/no_tweets' do
  
  @title = "Twitter - No Tweets"
  erb :no_tweets
end

get %r{/([[:digit:]])} do |page|
  @title = "Twitter"
  authenticate
  page = "#{page}".to_i
  @tweets = @client.home_timeline(:count => 100, :page => page)
  if @tweets != []
    @current_time = Time.now
    @first_time = Time.parse(@tweets.first.created_at)
    @last_time = Time.parse(@tweets.last.created_at)
    erb :index
  else
    redirect ('/no_tweets')  
  end
end

get '/:name' do |name|
  @name = "#{name}"
  @user = Twitter.user(@name)
  authenticate
  @friends_ids = Twitter.friend_ids(@name).ids
  @friends_info = Array.new
  @friends = Array.new
  until @friends_ids == []
    ids = @friends_ids.shift(100)
    @friends_info << Twitter.users(ids)
  end
  @friends_info.flatten!
  @friends_info.each { |friend| @friends << [friend.statuses_count / ((Time.now - Time.parse(friend.created_at))/86400), friend.screen_name] }
  @friends.sort!.reverse!
  sum = 0
  @friends.each{|a| sum += a[0]}
  @average = sum / @friends.size
  erb :friendly
end

get '/*' do
  @splats = params[:splat]
  erb :four_oh_four
end

__END__

@@ layout
<html>
  <head>
    <title><%= @title %></title>
    <style>
      body { margin: 40px; font: 20px helvetica;}
      #nav { margin: 16px; font: 16px helvetica;}
      .username { font-weight: bold; color:blue;}
      .tweet { }
      .timestamp { font-style: italic; font-size: 85%; color: gray;}
    </style>
  </head>
  <body>
    <%= yield %>
  </body>
  
  <div id="nav">Empty NAV
	</div>
</html>

@@ index
  <%= ((@current_time - @first_time)/3600).round %> hours ago to <%= ((@current_time - @last_time)/3600).round %> hours ago.
  <% @tweets.each do |tweet| %>
    <p>
    <span class="username"><%= tweet.user.screen_name %></span>
    <span class="tweet"><%= tweet.text %></span>
    <span class="timestamp"><%= tweet.created_at %></span>
    </p>
  <% end %>
  
@@ no_tweets
<p>Sorry, there are no tweets there.</p>

@@ four_oh_four

<big>404</big>
<% @splats.each do |s| %>
  <p>
  <span><%= s %> wasn't found.</span>
  </p>
<% end %>

@@ friendly

<p><%= @name %> follows <%= @friends.count %> users who average <%= @average.round(2) %> tweets per day. They tweet <%= (@user.statuses_count/ ((Time.now - Time.parse(@user.created_at))/86400)).round(2) %></p> times a day.
  <table>
    <tr><th>Tweets per day</th><th>Username</th></tr>
    <% @friends.each do |f| %>
    <tr><td><%= f.first.round(2) %></td><td><a href="http://localhost:9393/<%= f.last %>">@<%= f.last %></a></td></tr>
    <% end %>
  </table>