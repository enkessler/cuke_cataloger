module CukeCataloger

  # Some helper methods used during testing
  module HelperMethods

    # A handy place to stick things when global variables are needed but without using global variables
    def self.test_storage
      @test_storage ||= {}
    end

  end
end
