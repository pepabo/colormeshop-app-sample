require 'spec_helper'

describe '/auth/colormeshop/callback', type: :request do
  describe 'GET /auth/colormeshop/callback' do
    let(:auth_hash) do
      credentials = OmniAuth::AuthHash.new
      credentials.token = 'xxxxxxxxxxxxxxx'

      auth_hash = OmniAuth::AuthHash.new
      auth_hash.uid = 'PA00000001'
      auth_hash.credentials = credentials
      auth_hash
    end

    before do
      OmniAuth.config.mock_auth[:colormeshop] = auth_hash
    end

    it 'トップページにリダイレクトする' do
      VCR.use_cassette('requests/sessions/script_tags') do
        get '/auth/colormeshop/callback', params: { provider: 'colormeshop' }
      end

      expect(response.status).to eq 302
      expect(response.header['Location']).to eq 'http://www.example.com/'
    end

    context '新規ユーザーの場合' do
      it 'ユーザーを作成する' do
        expect {
          VCR.use_cassette('requests/sessions/no_script_tag') do
            get '/auth/colormeshop/callback', params: { provider: 'colormeshop' }
          end
        }.to change(User, :count).from(0).to(1)
      end
    end

    context '登録済みユーザーの場合' do
      let(:user_already_registered) do
        user = User.new(account_id: 'PA00000001', access_token: 'test')
        user.save
        user
      end

      before do
        user_already_registered
        VCR.use_cassette('requests/sessions/script_tags') do
          get '/auth/colormeshop/callback', params: { provider: 'colormeshop' }
        end
      end

      it '既存レコードを利用する' do
        expect(User.count).to eq 1
        expect(User.find_by_account_id('PA00000001').id).to eq user_already_registered.id
      end

      it 'アクセストークンを更新する' do
        expect(User.find_by_account_id('PA00000001').access_token).to eq 'xxxxxxxxxxxxxxx'
      end
    end
  end
end

