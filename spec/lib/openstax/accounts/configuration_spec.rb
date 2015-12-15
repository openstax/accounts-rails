module OpenStax
  module Accounts
    describe Configuration do

      let!(:config) { Configuration.new.tap {|c| c.openstax_accounts_url = "https://accounts.openstax.org"} }
      let!(:a_fake_request) { OpenStruct.new(url: "http://foo.com") }

      it "returns the default logout redirect when no explicit URL is set" do
        expect(config.logout_redirect_url(a_fake_request)).to eq "https://accounts.openstax.org/logout"
      end

      it "returns an explicitly-set string logout redirect URL when set" do
        config.logout_redirect_url = "blah"
        expect(config.logout_redirect_url(a_fake_request)).to eq "blah"
      end

      it "returns the default URL when Proc logout redirect URL set and returns nil" do
        config.logout_redirect_url = ->(request) { nil }
        expect(config.logout_redirect_url(a_fake_request)).to eq "https://accounts.openstax.org/logout"
      end

      it "returns the Proc URL when Proc logout redirect URL set and returns non-nil" do
        config.logout_redirect_url = ->(request) { "howdy" }
        expect(config.logout_redirect_url(a_fake_request)).to eq "howdy"
      end

      it "says return_to urls not approved when nil" do
        config.return_to_url_approver = ->(url) { true }
        expect(config.is_return_to_url_approved?(nil)).to be_falsy
      end

      it "says return_to urls not approved when approver nil" do
        config.return_to_url_approver = nil
        expect(config.is_return_to_url_approved?("http://www.google.com")).to be_falsy
      end

    end
  end
end
