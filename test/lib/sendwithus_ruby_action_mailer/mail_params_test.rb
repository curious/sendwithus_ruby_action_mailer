require_relative '../../test_helper'

describe SendWithUsMailer::MailParams do
  include ActiveJob::TestHelper

  subject { SendWithUsMailer::MailParams.new }

  describe "initialization" do
    it "email_data is empty on initialization" do
      subject.email_data.empty?.must_equal true
    end
  end

  describe "#assign" do
    let(:ep) { SendWithUsMailer::MailParams.new }

    it "adds (key,value) pairs to :email_data Hash" do
      ep.assign(:user, {:name => "Dave", :email => "dave@example.com"})
      ep.email_data.must_equal({
        :user => {:name => "Dave", :email => "dave@example.com"}
      })

      ep.assign(:url, "http://test.example.com")
      ep.email_data.must_equal({
        :user => {:name => "Dave", :email => "dave@example.com"},
        :url => "http://test.example.com"
      })
    end

    it "symbolizes the keys" do
      ep.assign("company", "Big Co Inc")
      ep.email_data.has_key?(:company).must_equal true
    end
  end

  describe "#email_id" do
    it "is readable" do
      subject.respond_to?(:email_id).must_equal true
      subject.respond_to?(:email_id=).must_equal false
    end
  end

  describe "#to" do
    it "is readable" do
      subject.respond_to?(:to).must_equal true
      subject.respond_to?(:to=).must_equal false
    end
  end

  describe "#from" do
    it "is readable" do
      subject.respond_to?(:from).must_equal true
      subject.respond_to?(:from=).must_equal false
    end
  end

  describe "#deliver" do
    it "method exists" do
      subject.respond_to?(:deliver).must_equal true
    end

    it "calls the send_with_us gem" do
      subject.merge!(email_id: 'x')
      SendWithUs::Api.any_instance.expects(:send_email)
      subject.deliver
    end

    it "doesn't call the send_with_us gem if mail method is not called" do
      SendWithUs::Api.any_instance.expects(:send_with).never
      subject.deliver
    end
  end

  describe "#deliver_now" do
    it "method exists" do
      subject.respond_to?(:deliver_now).must_equal true
    end

    it "calls the send_with_us gem" do
      subject.merge!(email_id: 'x')
      SendWithUs::Api.any_instance.expects(:send_email)
      subject.deliver_now
    end

    it "doesn't call the send_with_us gem if mail method is not called" do
      SendWithUs::Api.any_instance.expects(:send_with).never
      subject.deliver_now
    end
  end

  describe "#deliver_later" do
    it "method exists" do
      subject.respond_to?(:deliver_later).must_equal true
    end

    it "enqueues the job" do
      subject.merge!(email_id: 'x')
      assert_enqueued_with(job: SendWithUsMailer::Jobs::MailJob) do
        subject.deliver_later
      end
    end

    it "doesn't call the send_with_us gem if no email_id" do
      assert_no_enqueued_jobs do
        subject.deliver_later
      end
    end
  end

  describe "#preview" do
    it "method exists" do
      subject.must_respond_to(:preview)
    end

    describe "when the call is a success" do
      before do
        @response = stub('http', body: 'response body', message: 'success')
        Net::HTTPSuccess.stubs(:===).with(@response).returns(true)
      end

      it "calls the send_with_us gem" do
        SendWithUs::Api.any_instance.expects(:render).once.returns(@response)
        subject.preview
      end

      it "calls the Api::render with email_id, version_name, and email_data" do
        subject.assign(:foo, 'bar')
        subject.merge!(email_id: 'email', version_name: 'version')
        SendWithUs::Api.any_instance.expects(:render)
                       .with('email', 'version', {foo: 'bar'})
                       .returns(@response)
        subject.preview
      end

      it "returns the body" do
        SendWithUs::Api.any_instance.expects(:render).returns(@response)
        subject.preview.must_equal 'response body'
      end
    end

    describe "when the call is a failure" do
      before do
        @response = stub('http', message: 'error message')
        SendWithUs::Api.any_instance.expects(:render).returns(@response)
      end
      it "raises an error" do
        proc { subject.preview }.must_raise(RuntimeError)
      end
    end
  end
end
