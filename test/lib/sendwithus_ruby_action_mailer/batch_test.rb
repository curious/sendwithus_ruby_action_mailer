require_relative '../../test_helper'

describe SendWithUsMailer do
  class FirstMailer < SendWithUsMailer::Base
    def send_an_email; end
  end

  class SecondMailer < SendWithUsMailer::Base
    def send_an_email; end
  end

  describe "#batch_deliver" do
    it "is a recognized method" do
      SendWithUsMailer.must_respond_to :batch_deliver
    end

    it "calls send_emails on the Api" do
      mailers = [FirstMailer.send_an_email, SecondMailer.send_an_email]
      SendWithUs::Api.any_instance.expects(:send_emails).once
      SendWithUsMailer.batch_deliver(mailers)
    end

    it "calls send_emails with an array of mail_params" do
      first = FirstMailer.send_an_email
      second = SecondMailer.send_an_email

      first_params = { foo: "foo" }
      second_params = { foo: "bar" }

      first.stubs(:mail_params).returns(first_params)
      second.stubs(:mail_params).returns(second_params)

      SendWithUs::Api.any_instance.expects(:send_emails).with([first_params, second_params])
      SendWithUsMailer.batch_deliver([first, second])
    end
  end
end
