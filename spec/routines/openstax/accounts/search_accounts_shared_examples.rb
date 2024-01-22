require 'spec_helper'

RSpec.shared_examples 'search accounts' do

  let!(:account_1) do
    FactoryBot.create :openstax_accounts_account, first_name: 'John',
                                                  last_name: 'Stravinsky',
                                                  username: 'jstrav'
  end
  let!(:account_2) do
    FactoryBot.create :openstax_accounts_account, first_name: 'Mary',
                                                  last_name: 'Mighty',
                                                  full_name: 'Mary Mighty',
                                                  username: 'mary'
  end
  let!(:account_3) do
    FactoryBot.create :openstax_accounts_account, first_name: 'John',
                                                  last_name: 'Stead',
                                                  username: 'jstead'
  end

  let!(:account_4) do
    FactoryBot.create :openstax_accounts_account, first_name: 'Bob',
                                                  last_name: 'JST',
                                                  username: 'bigbear'
  end

  it 'should match based on username' do
    outcome = described_class.call('username:jstra').outputs.items
    expect(outcome).to eq [account_1]
  end

  it 'should ignore leading wildcards on username searches' do
    outcome = described_class.call('username:%rav').outputs.items
    expect(outcome).to eq []
  end

  it 'should match based on one first name' do
    outcome = described_class.call('first_name:"John"').outputs.items
    expect(outcome).to eq [account_3, account_1]
  end

  it 'should match based on one full name' do
    outcome = described_class.call('full_name:"Mary Mighty"').outputs.items
    expect(outcome).to eq [account_2]
  end

  it 'should match based on id (openstax_uid)' do
    outcome = described_class.call("id:#{account_3.openstax_uid}").outputs.items
    expect(outcome).to eq [account_3]
  end

  it 'should match based on uuid' do
    outcome = described_class.call("uuid:#{account_3.uuid}").outputs.items
    expect(outcome).to eq [account_3]
  end

  it 'should match based on support_identifier' do
    outcome = described_class.call(
      "support_identifier:#{account_3.support_identifier}"
    ).outputs.items
    expect(outcome).to eq [account_3]
  end

  it 'should return all results if the query is empty' do
    outcome = described_class.call('').outputs.items
    expect(outcome).to eq [account_4, account_3, account_1, account_2]
  end

  it 'should match any field when no prefix given' do
    outcome = described_class.call('jst').outputs.items
    expect(outcome).to eq [account_4, account_3, account_1]
  end

  it 'should match any field when no prefix given and intersect when prefix given' do
    outcome = described_class.call('jst username:jst').outputs.items
    expect(outcome).to eq [account_3, account_1]
  end

  it 'shouldn\'t allow users to add their own wildcards' do
    outcome = described_class.call("username:'%ar'").outputs.items
    expect(outcome).to eq []
  end

  it 'should gather comma-separated unprefixed search terms' do
    outcome = described_class.call('john,mighty').outputs.items
    expect(outcome).to eq [account_3, account_1, account_2]
  end

  it 'should not gather space-separated unprefixed search terms' do
    outcome = described_class.call('john mighty').outputs.items
    expect(outcome).to eq []
  end

  context 'pagination and sorting' do

    let!(:billy_accounts) do
      (0..45).to_a.map do |ii|
        FactoryBot.create :openstax_accounts_account,
                           first_name: "Billy#{ii.to_s.rjust(2, '0')}",
                           last_name: "Bob_#{(45-ii).to_s.rjust(2,'0')}",
                           username: "billy_#{ii.to_s.rjust(2, '0')}"
      end
    end

    it 'should return the first page of values by default when requested' do
      outcome = described_class.call('username:billy', per_page: 20).outputs.items
      expect(outcome.length).to eq 20
      expect(outcome[0]).to eq OpenStax::Accounts::Account.find_by!(username: 'billy_00')
      expect(outcome[19]).to eq OpenStax::Accounts::Account.find_by!(username: 'billy_19')
    end

    it 'should return the second page when requested' do
      outcome = described_class.call('username:billy', page: 2, per_page: 20).outputs.items
      expect(outcome.length).to eq 20
      expect(outcome[0]).to eq OpenStax::Accounts::Account.find_by!(username: 'billy_20')
      expect(outcome[19]).to eq OpenStax::Accounts::Account.find_by!(username: 'billy_39')
    end

    it 'should return the incomplete 3rd page when requested' do
      outcome = described_class.call('username:billy', page: 3, per_page: 20).outputs.items
      expect(outcome.length).to eq 6
      expect(outcome[5]).to eq OpenStax::Accounts::Account.find_by!(username: 'billy_45')
    end

  end

  context 'sorting' do

    let!(:bob_brown) do
      FactoryBot.create :openstax_accounts_account, first_name: 'Bob',
                                                    last_name: 'Brown',
                                                    username: 'foo_bb'
    end
    let!(:bob_jones) do
      FactoryBot.create :openstax_accounts_account, first_name: 'Bob',
                                                    last_name: 'Jones',
                                                    username: 'foo_bj'
    end
    let!(:tim_jones) do
      FactoryBot.create :openstax_accounts_account, first_name: 'Tim',
                                                    last_name: 'Jones',
                                                    username: 'foo_tj'
    end

    it 'should allow sort by multiple fields in different directions' do
      outcome = described_class.call(
        'username:foo', order_by: 'first_name, last_name DESC'
      ).outputs.items
      expect(outcome).to eq [bob_jones, bob_brown, tim_jones]

      outcome = described_class.call(
        'username:foo', order_by: 'first_name, last_name ASC'
      ).outputs.items
      expect(outcome).to eq [bob_brown, bob_jones, tim_jones]
    end

  end

end
