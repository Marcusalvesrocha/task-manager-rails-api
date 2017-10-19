require 'rails_helper'

RSpec.describe 'Sessions API', type: :request do
	before { host! 'api.taskmanager.dev' }
	let!(:user) { create(:user) }
  let(:auth_data) { user.create_new_auth_token }
  let(:headers) do
  	{
  		'Accept' => 'application/vnd.taskmanager.v2',
  		'Content-Type' => Mime[:json].to_s,
      'uid' => auth_data['uid'],
      'client' => auth_data['client'],
      'access-token' => auth_data['access-token']
  	}
	end

	describe 'POST /auth/sign_in' do
	  before do
	  	post '/auth/sign_in', params: credentials.to_json, headers: headers
	  end

	  context 'when the credentials are correct' do
	  	let(:credentials) { { email: user.email, password: '123123' } }

	  	it 'return status code 200' do
	  		expect(response).to have_http_status(200)
	  	end

	  	it 'return the authentication data in the headers' do
	  		expect(response.headers).to have_key('access-token')
	  		expect(response.headers).to have_key('uid')
	  		expect(response.headers).to have_key('client')
	  	end
	  end

	  context 'when the credentials are incorrect' do
	  	let(:credentials) { { email: user.email, password: 'invalid' } }

	  	it 'return status code 401' do
	  		expect(response).to have_http_status(401)
	  	end

	  	it 'return the json data for errors' do
	  		expect(json_body).to have_key(:errors)
	  	end
	  end
	end

	describe 'DELETE /auth/sign_out' do
	  let(:auth_token) { user.auth_token }

	  before do
	  	delete '/auth/sign_out', params: {}, headers: headers
	  end

	  it 'return status code 200' do
	  	expect(response).to have_http_status(200)
	  end

	  it 'changes the user auth token' do
	  	user.reload
	  	expect( user.valid_token?(auth_data['access-token'], auth_data['client']) ).to eq(false)
	  	expect( user ).not_to be_valid_token(auth_data['access-token'], auth_data['client'])
	  end
	end

end