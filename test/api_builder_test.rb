require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../lib/highrise/api_builder'

class ApiBuilderTest < ActiveSupport::TestCase

  context "create_api" do
    should "construct module with appropriate highrise classes" do
      new_highrise_module = Highrise::APIBuilder.create_api("api_key", "subdomain", false)
      assert_equal "Highrise_SubdomainHighrisehqCom", new_highrise_module.to_s
      assert_equal "Highrise_SubdomainHighrisehqCom::Person", new_highrise_module::Person.to_s
      assert_equal "Highrise_SubdomainHighrisehqCom::Address", new_highrise_module::Address.to_s
      assert_equal "Highrise_SubdomainHighrisehqCom::Company", new_highrise_module::Company.to_s
    end
  end
  
  context "site" do
    should "be https if third parameter specifies" do
      new_highrise_module = Highrise::APIBuilder.create_api("api_key", "subdomain", true)
      assert_equal URI::HTTPS, new_highrise_module::Base.site.class
    end

    should "not be https if third parameter specifies" do
      new_highrise_module = Highrise::APIBuilder.create_api("api_key", "subdomain", false)
      assert_equal URI::HTTP, new_highrise_module::Base.site.class
    end
  end
  
  context "find_all_companies_since" do
    should "delegate to company" do
      highrise_module = Highrise::APIBuilder.create_api("api_key", "subdomain", false)
      highrise_module::Company.expects(:find_all_across_pages).with(:params => {:since =>:timestamp}).returns :companies
      assert_equal :companies, highrise_module.find_all_companies_since(:timestamp)
    end
  end

  context "find_all_people_since" do
    should "delegate to person" do
      highrise_module = Highrise::APIBuilder.create_api("api_key", "subdomain", false)
      highrise_module::Person.expects(:find_all_across_pages).with(:params => {:since =>:timestamp}).returns :people
      assert_equal :people, highrise_module.find_all_people_since(:timestamp)
    end
  end

  context "find_all_companies" do
    should "delegate to company" do
      highrise_module = Highrise::APIBuilder.create_api("api_key", "subdomain", false)
      highrise_module::Company.expects(:find_all_across_pages).returns :companies
      assert_equal :companies, highrise_module.find_all_companies
    end
  end

  context "find_all_people" do
    should "delegate to person" do
      highrise_module = Highrise::APIBuilder.create_api("api_key", "subdomain", false)
      highrise_module::Person.expects(:find_all_across_pages).returns :people
      assert_equal :people, highrise_module.find_all_people
    end
  end

end
