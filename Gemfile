# require 'rake/dsl_definition'

source :rubygems
# source 'http://gems.github.com'
# source 'http://gemcutter.org'

gem 'rails', '3.2.8'

group :assets do
  gem 'sass-rails', '~> 3.2.0'
  gem 'coffee-rails', '~> 3.2.0'
  gem 'uglifier'
end

group :production, :stage do
  gem 'mysql2' #, '0.2.18'
end

group :development do 
  gem 'mongrel', '>= 1.2.0.pre2'
end

# gem 'iwyg_be'
gem 'airbrake'
gem 'eventmachine', '1.0.0.beta.2'
gem 'thin'
gem 'therubyracer', :platform => :ruby
gem 'execjs'
gem 'geokit'
gem 'hpricot'
gem 'redis'
gem 'sqlite3-ruby'
gem 'inherited_resources'
gem 'has_scope'
gem 'squeel'
gem 'ransack'
gem 'routing-filter', '0.3.0'
gem 'friendly_id', '4.0'
gem 'paper_trail'
gem 'json_pure', '1.6.1'   
gem 'jquery-rails' #, '>= 1.0.12'
gem 'rails3-jquery-autocomplete'
gem 'formtastic' #, '2.1.0.beta1'
gem 'client_side_validations'
gem 'client_side_validations-formtastic'
gem 'nested_form'
gem 'devise', '< 2.1' # , :git => 'git://github.com/plataformatec/devise.git'
gem 'cancan'
gem 'devise_rpx_connectable'
gem 'geocoder'
gem 'gmaps4rails', '1.4.5'
gem 'ajaxful_rating', '2.2.8.2'
gem 'acts-as-taggable-on', '~> 2.2.2'
gem 'paperclip'
#gem 'meta_search'
gem 'will_paginate', '3.0.3'
gem 'validates_timeliness' #, '2.3.2'
gem 'roadie'
gem 'acts_as_follower'
gem 'acts_as_audited', '~> 2.1.0'
gem 'rails3_acts_as_paranoid'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
end

group :test do
  gem 'mysql2' #, '0.2.18'
  gem 'capybara', '1.1.4'
	gem 'launchy'
	gem 'guard'  
	gem 'guard-rspec'
	gem 'populator'
  gem 'faker'
	gem 'shoulda'  
	gem 'shoulda-matchers'
end

