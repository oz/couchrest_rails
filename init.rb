require 'couch_rest_rails'
require 'validatable'
require 'spec/rails/matchers/couch_document_validations'

config.gem 'oz-couchrest', :lib => 'couchrest', :source => 'http://gems.github.com'
config.gem 'validatable'
config.gem 'json'
