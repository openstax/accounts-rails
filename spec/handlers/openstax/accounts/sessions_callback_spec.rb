require 'spec_helper'

module OpenStax
  module Accounts

    describe SessionsCallback do

      context "faculty_status" do
        it "should deal with faculty status it doesn't know (e.g. if Accounts updated but this repo not)" do
          result = described_class.handle(request: mock_omniauth_request(faculty_status: "howdy_ho"))
          expect(result.outputs.account).to be_no_faculty_info
        end

        it "should deal with faculty status that is not present" do
          request = mock_omniauth_request()
          remove_faculty_status!(request)
          result = described_class.handle(request: request)
          expect(result.outputs.account).to be_no_faculty_info
        end
      end

    end

  end
end
