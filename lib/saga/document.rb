module Saga
  class Document
    attr_accessor :title, :introduction, :authors, :stories, :definitions
    
    def initialize
      @title        = ''
      @introduction = []
      @authors      = []
      @stories      = {}
      @definitions  = {}
    end
  end
end