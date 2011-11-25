require "rubygems"
require "twitter"
require 'sinatra'
require 'time'
require 'yaml'

# TODO Cleanup Twitter.rb
# TODO Create basic nav
# TODO Fix "Internal Server Error"

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
    @first_time = Time.parse(@tweets.first.created_at.to_s)
    @last_time = Time.parse(@tweets.last.created_at.to_s)
    erb :index
  else
    redirect ('/no_tweets')  
  end
end

get '/:name' do |name|
  @name = "#{name}"
  @user = Twitter.user(@name)
  @user_time_existed = (Time.now - Time.parse(@user.created_at.to_s))
  @user_tweet_average = (@user.statuses_count / (@user_time_existed/86400)).round(2)
  authenticate
  @friends_ids = Twitter.friend_ids(@name).ids
  @friends_info = Array.new
  @friends = Array.new
  until @friends_ids.empty?
    ids = @friends_ids.shift(100)
    @friends_info << Twitter.users(ids)
  end
  @friends_info.flatten!
  @friends_info.each do |friend| 
  @friends << [friend.statuses_count / ((Time.now - Time.parse(friend.created_at.to_s))/86400), friend.screen_name]
  end
  @friends.sort!.reverse!
  sum = 0
  @friends.each{|a| sum += a[0]}
  @average = sum / @friends.size
  erb :friendly
end

get '/' do
  erb :main
end

get '/*' do
  @splats = params[:splat]
  erb :four_oh_four
end