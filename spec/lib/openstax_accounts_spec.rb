module OpenStax
  describe Accounts do
    let!(:user) { OpenStax::Accounts::User.create(username: 'some_user',
                                                  openstax_uid: 1,
                                                  access_token: 'secret') }

    it 'makes api calls' do
      expect(Api::DummyController.last_action).to be_nil
      expect(Api::DummyController.last_params).to be_nil
      Accounts.api_call(:post, 'dummy', :params => {:test => true})
      expect(Api::DummyController.last_action).to eq :dummy
      expect(Api::DummyController.last_params).to include 'test' => 'true'
    end

    it 'makes api call to create application_user' do
      expect(Api::ApplicationUsersController.last_action).to be_nil
      expect(Api::ApplicationUsersController.last_params).to be_nil
      Accounts.create_application_user(user)
      expect(Api::ApplicationUsersController.last_action).to eq :create
      expect(Api::ApplicationUsersController.last_params).not_to be_nil
    end

    it 'makes api call to user search' do
      expect(Api::UsersController.last_action).to be_nil
      expect(Api::UsersController.last_params).to be_nil
      Accounts.user_search('sth')
      expect(Api::UsersController.last_action).to eq :search
      expect(Api::UsersController.last_params).to include :q => 'sth'
    end
  end
end