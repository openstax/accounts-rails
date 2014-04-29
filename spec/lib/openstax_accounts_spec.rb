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

    it 'makes api call to application_user create' do
      Api::ApplicationUsersController.last_action = nil
      Api::ApplicationUsersController.last_params = nil
      Accounts.application_users_create(user)
      expect(Api::ApplicationUsersController.last_action).to eq :create
      expect(Api::ApplicationUsersController.last_params).not_to be_nil
    end

    it 'makes api call to application_user index' do
      Api::ApplicationUsersController.last_action = nil
      Api::ApplicationUsersController.last_params = nil
      Accounts.application_users_index('sth')
      expect(Api::ApplicationUsersController.last_action).to eq :index
      expect(Api::ApplicationUsersController.last_params).to include :q => 'sth'
    end

    it 'makes api call to application_user updates' do
      Api::ApplicationUsersController.last_action = nil
      Api::ApplicationUsersController.last_params = nil
      Accounts.application_users_updates
      expect(Api::ApplicationUsersController.last_action).to eq :updates
      expect(Api::ApplicationUsersController.last_params).not_to be_nil
    end

    it 'makes api call to application_user updated' do
      Api::ApplicationUsersController.last_action = nil
      Api::ApplicationUsersController.last_params = nil
      Accounts.application_users_updated({1 => 1})
      expect(Api::ApplicationUsersController.last_action).to eq :updated
      expect(Api::ApplicationUsersController.last_params[:application_users]).to include '1' => '1'
    end
  end
end