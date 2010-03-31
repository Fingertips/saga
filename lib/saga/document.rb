require 'active_support/ordered_hash'

module Saga
  class Document
    attr_accessor :title, :introduction, :authors, :stories, :definitions
    
    def initialize
      @title        = ''
      @introduction = []
      @authors      = []
      @stories      = ActiveSupport::OrderedHash.new
      @definitions  = ActiveSupport::OrderedHash.new
    end
  end
end