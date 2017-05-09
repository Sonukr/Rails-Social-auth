# Rails-Social-auth
Login system using rails with local and Facebook, GitHub integration.

#  Features!

  - Login using local auth
  - Login using omniauth-facebook
  - Login using omniauth-github
  
### Tech

Rails-Social-auth uses a number of open source projects to work properly:

* [Bootstrap](http://getbootstrap.com/)
* [Devise](https://github.com/plataformatec/devise)
* [omniauth-github](https://github.com/intridea/omniauth-github) 
* [omniauth-facebook](https://github.com/mkdynamic/omniauth-facebook)

### local setup
 - Clone this repo
 - Run ```bundle install```
 - Run ``` rake db:migrate```
 - Run ``` rails s```
 - [open your app here](https://localhost:3000)



### Steps to create this app from scratch

I am assuming you have all the prerequirments installed like Rails, sql etc, run the following command in terminal.

```sh
$ mkdir Social-auth
$ rails new social-auth
$ cd social-auth
$ rails s


```
Here the above commands will create a rails project.

- 1- It will create a directory
- 2- It will create a new rails app using rails generator
- 3- Go inside of that directory
- 4- Run rails server

You can check your rails app is running on 3000 port [open it here](https://localhost:3000)

Open your project in any editor of your choice.
Open gemfile and add the following gem.

```
 gem 'devise'
 gem 'omniauth-facebook'
 gem 'omniauth-github'
```
And run the following  command

```
$ bundle install
```

After this, create all the app on facebook,github using their developer console.

now come back into rails app and create a scaffolding for a default route.

```
$ rails g scaffold contact name:string number:text 
```
Next, migrate the db (I am using sqllite)
```
rake db:migrate
```
let's add devise authentication, run the following command 

```
$ rails g devise:install
$ rails g devise user
$ rails g devise:views
$ rake db:migrate
$ rails g migration add_social_to_users provider:string uid:string gender:string
```
#### Now configure the devise
open up the following file 
```
config/environments/development.rb
```
and add this line before end keyword

```
 config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
```
 Open up app/views/layouts/application.html.erb and add the following code before <%= yield %> 

```
<% if notice %>
  <p class="alert alert-success"><%= notice %></p>
<% end %>
<% if alert %>
  <p class="alert alert-danger"><%= alert %></p>
<% end %>
```

Now you can check working login at  http://localhost:3000/users/sign_up 

Let's add the login/signup link in navbar in app/views/layouts/application.html.erb 

```
<% if user_signed_in? %>
  Logged in as <strong><%= current_user.email %></strong>.
  <%= link_to 'Edit profile', edit_user_registration_path, :class => 'navbar-link' %> |
  <%= link_to "Logout", destroy_user_session_path, method: :delete, :class => 'navbar-link'  %>
<% else %>
  <%= link_to "Sign up", new_user_registration_path, :class => 'navbar-link'  %> |
  <%= link_to "Login", new_user_session_path, :class => 'navbar-link'  %>
<% end %>
```

#### Configure social auth using omniauth

open app/controllers/application_controller.rb and add the following lines before end -

```
before_action :authenticate_user!
before_action :configure_permitted_parameters, if: :devise_controller?
 
protected
def configure_permitted_parameters
 devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :email, :password, :password_confirmation])
end
```

Next, open config/initializers/devise.rb. and goto line No : 254 and add the code below -

```
//Github
config.omniauth :github, 'APP_ID', 'APP_SECRET',
scope: 'user,public_repo', callback_url: "http://localhost:3000/users/auth/github/callback"


//Facebook
config.omniauth :facebook, "APP_ID", "APP_SECRET",
callback_url: "http://localhost:3000/users/auth/facebook/callback"

```
You can read more about scope at omniauth website.

### Create a omniauth callback controller and configure user model and routes. [343b0ec1fa ](https://github.com/Sonukr/Rails-Social-auth/commit/343b0ec1fa)

- create a fine with name " omniauth_callbacks_controller.rb " in controller folder and add the below code in that file -

```
class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def github
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "github") if is_navigational_format?
    else
      session["devise.github_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def failure
    redirect_to root_path
  end
end
```

- open app/models/user.rb file and add the following code before end -

```
 :omniauthable, :omniauth_providers => [:facebook, :github]
	def self.from_omniauth(auth)
	  where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
	    user.email = auth.info.email
	    user.password = Devise.friendly_token[0,20]
	    name = auth.info.name.split(' ')
	    user.first_name =  name.first  # assuming the user model has a name
	    user.last_name =  name.last  # assuming the user model has a name
	    #user.image = auth.info.image # assuming the user model has an image
	    # If you are using confirmable and the provider(s) you use validate emails,
	    # uncomment the line below to skip the confirmation emails.
	    # user.skip_confirmation!
	  end
	end
```



- open the  config/routes.rb and make the foollowing changes

```
 devise_for :users (remove this line and add the below line )
 devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }
```

- To make the entire application authenticatble on / . add the default route in routes.rb file, just add the below line.

```
root to: "contacts#index"
```

- Let's give the links for signin using Facebook, Github
	- open app/views/layouts/application.html.erb 
	- add the following code below signup link

	```
	<%= link_to "Sign in with facebook", user_facebook_omniauth_authorize_path, :class => 'navbar-link'  %> |
  <%= link_to "Sign in with github", user_github_omniauth_authorize_path, :class => 'navbar-link'  %>
	 
	```
	
That's It... :)
 Now you have a working Login system with local and Social auth. 
 
 Happy Coding...!
	


