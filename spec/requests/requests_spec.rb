require 'rails_helper'

RSpec.describe 'Accounts API', type: :request do
  let(:user) { User.create!(name: 'John Doe', email: 'john@example.com') }
  let(:headers) { { 'User-ID' => user.id.to_s } }
  
  describe 'POST /accounts' do
    it 'creates a new account for user' do
      post '/accounts', headers: headers
      
      expect(response).to have_http_status(:created)
      expect(user.reload.active_account).to be_present
      expect(user.active_account.balance).to eq(0)
    end
    
    it 'prevents creating multiple accounts' do
      user.create_account!(account_type: 'checking', balance: 0, status: 'active')
      
      post '/accounts', headers: headers
      
      expect(response).to have_http_status(:conflict)
      expect(JSON.parse(response.body)['error']).to include('already has an active account')
    end
  end
  
  describe 'POST /accounts/:id/deposit' do
    let(:account) { user.create_account!(account_type: 'checking', balance: 100, status: 'active') }
    
    it 'successfully deposits money' do
      post "/accounts/#{account.id}/deposit", 
           params: { amount: 50 }, 
           headers: headers
      
      expect(response).to have_http_status(:ok)
      expect(account.reload.balance).to eq(150)
      expect(JSON.parse(response.body)['new_balance'].to_f).to eq(150.0)
    end
    
    it 'rejects negative deposits' do
      post "/accounts/#{account.id}/deposit", 
           params: { amount: -50 }, 
           headers: headers
      
      expect(response).to have_http_status(:unprocessable_entity)
      expect(account.reload.balance).to eq(100)
    end
  end
  
  describe 'POST /accounts/:id/withdraw' do
    let(:account) { user.create_account!(account_type: 'checking', balance: 100, status: 'active') }
    
    it 'successfully withdraws money' do
      post "/accounts/#{account.id}/withdraw", 
           params: { amount: 30 }, 
           headers: headers
      
      expect(response).to have_http_status(:ok)
      expect(account.reload.balance).to eq(70)
    end
    
    it 'rejects overdraft attempts' do
      post "/accounts/#{account.id}/withdraw", 
           params: { amount: 150 }, 
           headers: headers
      
      expect(response).to have_http_status(:unprocessable_entity)
      expect(account.reload.balance).to eq(100)
    end
  end
end