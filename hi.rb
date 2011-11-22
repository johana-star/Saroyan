require 'sinatra'

before do
  headers "Content-Type" => "text/html; charset=utf-8"
end

get '/' do
  @title = "Temperatures"
  erb :index
end

get '/fahrenheit' do
  @title = "Fahrenheit"
  erb :fahrenheit
end

post '/fahrenheit' do
  @title = "Fahrenheit"
  @temp = params[:fahrenheit].to_i.round(2)
  @celsius = ((@temp - 32.0)*(5.0/9.0)).round(2)
  @kelvin = ((@temp + 459.67)*(5.0/9.0)).round(2)
  erb :post_fahrenheit
end

get '/celsius' do
  @title = "Celsius"
  erb :celsius
end

post '/celsius' do
  @title = "Celsius"
  @temp = params[:celsius].to_i.round(2)
  @fahrenheit = (@temp * 1.8 + 32.0).round(2)
  @kelvin = (@temp + 273.15).round(2)
  erb :post_celsius
end

get '/kelvin' do
  @title = "Kelvin"
  erb :kelvin
end

post '/kelvin' do
  @title = "Kelvin"
  @temp = params[:kelvin].to_i.round(2)
  @celsius = (@temp - 273.15).round(2)
  @fahrenheit = (@temp * 1.8 - 459.67).round(2)
  erb :post_kelvin
end

__END__

@@ layout
<html>
  <head>
    <title><%= @title %></title>
    <style>
      body { margin: 40px; font: 20px/24px helvetica;}
      #nav { margin: 16px; font: 16px/20px helvetica;}
    </style>
  </head>
  <body>
    <%= yield %>
  </body>
  
  <div id="nav">
		<a href="/fahrenheit">Fahrenheit</a> | <a href="/celsius">Celsius</a> | <a href="/kelvin">Kelvin</a>
	</div>
</html>

@@ index
<p><big><strong>Please select a temperature scale to convert from below.</strong></big></p>

@@ fahrenheit
<form action"/fahrenheit" method="post" id="ad" enctype="multipart/form-data">
  <p>
	  <label>Fahrenheit:</label><br />
	  <input type="text" name="fahrenheit" id="temperature">
  </p>
  <p>
	  <input type="submit">
  </p>
</form>

@@ celsius
<form action"/celsius" method="post" id="ad" enctype="multipart/form-data">
  <p>
	  <label>Celsius:</label><br />
	  <input type="text" name="celsius" id="temperature">
  </p>
  <p>
	  <input type="submit">
  </p>
</form>

@@ kelvin
<form action"/kelvin" method="post" id="ad" enctype="multipart/form-data">
  <p>
	  <label>Kelvin:</label><br />
	  <input type="text" name="kelvin" id="temperature">
  </p>
  <p>
	  <input type="submit">
  </p>
</form>

@@ post_fahrenheit
<p>You entered in a temperature of <%= @temp %> degrees Fahrenheit.</p>
<p>This is the equivelant of <%= @celsius %> degrees Celsius and <%= @kelvin %> degrees kelvin.</p>

@@ post_celsius
<p>You entered in a temperature of <%= @temp %> degrees Celsius.</p>
<p>This is the equivelant of <%= @fahrenheit %> degrees Fahrenheit and <%= @kelvin %> degrees kelvin.</p>

@@ post_kelvin
<p>You entered in a temperature of <%= @temp %> degrees Kelvin.</p>
<p>This is the equivelant of <%= @celsius %> degrees Celsius and <%= @fahrenheit %> degrees Fahrenheit.</p>