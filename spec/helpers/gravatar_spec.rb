require "spec_helper"

class GravatarDummyClass
  include Nanoc::Toolbox::Helpers::Gravatar
end

describe Nanoc::Toolbox::Helpers::Gravatar do
  subject { GravatarDummyClass.new }

  before(:all) do
    @email = 'anouar@adlani.com'
    @avatar = 'avatar/4d076af1db60b16e1ce080505baf821c'
    @secure_host = {
      true => 'https://secure.gratatar.com/' + @avatar,
      false => 'http://gravatar.com/' + @avatar
    }
  end

  it { should respond_to(:gravatar_url) }
  it { should respond_to(:gravatar_image) }


  describe "#subject.gravatar_url" do
    context "when no parameters passed in the options" do
      it "converts an email address to the a gravatar URL" do
        subject.gravatar_url(@email).should == @secure_host[false]
      end

      it "converts an email address to the a secure gravatar URL when requested" do
        subject.gravatar_url(@email, :secure => true).should == @secure_host[true]
      end
      
      it "raise an Argument error when the email is invalid" do
        lambda{subject.gravatar_url('')}.should raise_error(ArgumentError)
        lambda{subject.gravatar_url('a@a.c')}.should raise_error(ArgumentError)
        lambda{subject.gravatar_url('@example.com')}.should raise_error(ArgumentError)
        lambda{subject.gravatar_url('name@name@example.com')}.should raise_error(ArgumentError)
      end
      
      it "strips the additionnal spaces before and after the email" do
        subject.gravatar_url(" \n  #{@email}   \n").should == @secure_host[false]
      end
    end

    context "when parameters passed in the options" do
      it "removes unknown parameters" do
        subject.gravatar_url(@email, :blabl => 'jsdfsdfsd').should == @secure_host[false]
      end

      it "removes empty or nil parameters" do
        subject.gravatar_url(@email, :size => '', :rating => nil).should == @secure_host[false]
      end

      it "should sort the url parameters" do
        subject.gravatar_url(@email, :size => 45, :default_icon => 'monsterid', :rating => 'x').should == @secure_host[false] + '?default_icon=monsterid&rating=x&size=45'
      end

      it "accepts well formed option and render them" do
        subject.gravatar_url(@email, :size => 45, :rating => 'x').should == @secure_host[false] + '?rating=x&size=45'
      end
      
      it "ignores the bad type or the out of rnage parameters" do
        subject.gravatar_url(@email, :size => '45', :rating => 'xssss').should == @secure_host[false] + '?size=45'
      end
    end
  end
  
  describe "#gravatar_image" do
    it "converts an email to an html tag" do
      subject.gravatar_image(@email).should == %[<img src="#{@secure_host[false]}" />]
    end
    
    it "converts an email to an html tag with options for the gravatar" do
      subject.gravatar_image(@email,  :size => 45, :default_icon => 'monsterid', :rating => 'xss').should == %[<img src="#{@secure_host[false]}?default_icon=monsterid&size=45" />]
    end
    
    it "converts an email to an html tag with options for the img tag" do
      subject.gravatar_image(@email,  :height => 10).should == %[<img height="10" src="#{@secure_host[false]}" />]
    end
    
    it "converts an email to an html tag with options for the gravatar and for the img" do
      subject.gravatar_image(@email,  :height => 10, :size => 45, :default_icon => 'monsterid', :rating => 'xss').should == %[<img height="10" src="#{@secure_host[false]}?default_icon=monsterid&size=45" />]
    end
  end
end
