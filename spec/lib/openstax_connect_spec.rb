module OpenStax
  describe Connect do
    let!(:user) { OpenStax::Connect::User.create(username: 'some_user',
                                                 openstax_uid: 1,
                                                 access_token: 'secret') }

    it 'makes api calls' do
      expect(Api::DummyController.last_action).to be_nil
      expect(Api::DummyController.last_params).to be_nil
      Connect.api_call(:post, 'dummy', :access_token => user.access_token,
                                       :params => {:test => true})
      expect(Api::DummyController.last_action).to eq :dummy
      expect(Api::DummyController.last_params).to include 'test' => 'true'
    end

    it 'makes api call to create application_user' do
      expect(Api::ApplicationUsersController.last_action).to be_nil
      expect(Api::ApplicationUsersController.last_params).to be_nil
      Connect.create_application_user(user)
      expect(Api::ApplicationUsersController.last_action).to eq :create
      expect(Api::ApplicationUsersController.last_params).not_to be_nil
    end
  end
end