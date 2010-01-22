# Clint: Taken from code example on http://www.themcwongs.com/mcblog/2008/01/handling-multiple-user-authent.html.

require 'active_resource'

module Highrise
  
  module Pagination
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def find_all_across_pages(options = {})
        records = []
        each(options) { |record| records << record }
        records
      end

      def each(options = {})
        options[:params] ||= {}
        options[:params][:n] = 0

        loop do
          if (records = self.find(:all, options)).any?
            records.each { |record| yield record }
            options[:params][:n] += records.size
          else
            break # no people included on that page, thus no more people total
          end
        end
      end
    end
  end

  module PersonMethods; end
  module CompanyMethods; end
  module AddressMethods; end
  module EmailAddressMethods; end
  module InstantMessengerMethods; end
  module PhoneNumberMethods; end
  module WebAddressMethods; end
  
  class APIBuilder
    #
    # Creates a module that serves as an ActiveResource
    # client for the specified user
    #
    
    HighriseDomain = "highrisehq.com"
    
    def self.create_api(api_key, subdomain, use_https)
      url = "#{subdomain}.#{HighriseDomain}"
      protocol = use_https ? "https" : "http"
      @url_base = "#{protocol}://#{api_key}:X@#{url}"
      @module = url.gsub(/[^A-Za-z]/, "_").classify
      class_eval <<-"end_eval",__FILE__, __LINE__
      module ::Highrise_#{@module}
        class Base < ActiveResource::Base
          self.site = "#{@url_base}"
          include Highrise::Pagination
        end
        class Person < Base
          include ::Highrise::PersonMethods
        end
        class Address < Base
          include ::Highrise::AddressMethods
        end
        class Company < Base
          include ::Highrise::CompanyMethods
        end
        class EmailAddress < Base
          include ::Highrise::EmailAddressMethods
        end
        class InstantMessenger < Base
          include ::Highrise::InstantMessengerMethods
        end
        class PhoneNumber < Base
          include ::Highrise::PhoneNumberMethods
        end
        class WebAddress < Base
          include ::Highrise::WebAddressMethods
        end
        class ContactData < Base;end
        # return the module
        
        def self.find_all_companies_since(timestamp)
          Company.find_all_across_pages :params => {:since => timestamp }
        end
        
        def self.find_all_people_since(timestamp)
          Person.find_all_across_pages :params => {:since => timestamp }
        end
        
        def self.find_all_companies
          Company.find_all_across_pages
        end
        
        def self.find_all_people
          Person.find_all_across_pages
        end

        def self.check_connection
          Person.find :first
        end
        
        self
      end
      end_eval
    end
  end
end
