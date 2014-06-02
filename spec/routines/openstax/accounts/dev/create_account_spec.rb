require 'spec_helper'

module OpenStax
  module Accounts
    module Dev

      describe CreateUser do

        it 'creates users' do

          expect(User.where(username: 'bob').first).to be_nil

          outputs = CreateUser.call(username: 'bob', last_name: 'jones').outputs

          expect(outputs[:user]).not_to be_nil
          expect(outputs[:user].username).to eq 'bob'
          expect(outputs[:user].last_name).to eq 'jones'
          expect(User.where(username: 'bob').first).to eq outputs[:user]

        end

      end

    end
  end
end
