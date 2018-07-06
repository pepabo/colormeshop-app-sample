require 'spec_helper'

describe '/', type: :request do
  describe 'トップページ' do
    let(:current_timestamp) { Time.now.to_i }

    context 'セッションにユーザー情報が無い場合' do
      before do
        get '/'
      end

      it 'アプリの認可ページにリダイレクトする' do
        expect(response.status).to eq 302
        expect(response.header['Location']).to eq 'http://www.example.com/auth/colormeshop'
      end
    end

    context 'セッションにユーザー情報がある場合' do
      let(:user) { create(:user) }

      before do
        sign_in_as(user)
        VCR.use_cassette('requests/top/script_tags') do
          get '/'
        end
      end

      it 'トップページを表示する' do
        expect(response.status).to eq 200
      end

      context 'アプリをアンインストールしたユーザーがアクセスしてきた場合' do
        before do
          sign_in_as(user)
          VCR.use_cassette('requests/top/unauthrized') do
            get '/'
          end
        end

        it 'アプリの認可ページにリダイレクトする' do
          expect(response.status).to eq 302
          expect(response.header['Location']).to eq 'http://www.example.com/auth/colormeshop'
        end
      end
    end

    context 'HMACが不正だった場合' do
      before do
        allow(ENV).to receive(:[]).with('COLORMESHOP_CLIENT_SECRET').and_return('test')
        get '/', params: { account_id: 'PA00000001', timestamp: current_timestamp, hmac: 'foo' }
      end

      it '403を返す' do
        expect(response.status).to eq 403
      end
    end

    context 'タイムスタンプが古い場合' do
      before do
        allow(ENV).to receive(:[]).with('COLORMESHOP_CLIENT_SECRET').and_return('colormeshop_client_secret')
        hmac = TopController.new.send(:calculated_hmac, [account_id: 'PA00000001', timestamp: 1000000000])
        get '/', params: { account_id: 'PA00000001', timestamp: 1000000000, hmac: hmac }
      end

      it '403を返す' do
        expect(response.status).to eq 403
      end
    end

    context 'HMACが正しい場合' do
      before do
        allow(ENV).to receive(:[]).with('COLORMESHOP_CLIENT_SECRET').and_return('colormeshop_client_secret')
      end

      context 'アプリのDBにユーザーが存在する場合' do
        let(:user) { create(:user) }

        before do
          hmac = TopController.new.send(:calculated_hmac, { 'account_id' => user.account_id, 'timestamp' => current_timestamp })

          VCR.use_cassette('requests/top/script_tags') do
            get '/', params: { account_id: user.account_id, timestamp: current_timestamp, hmac: hmac }
          end
        end

        it 'トップページにリダイレクトする' do
          expect(response.status).to eq 302
          expect(response.header['Location']).to eq 'http://www.example.com/'
        end
      end

      context 'アプリのDBにユーザーが存在しない場合' do
        before do
          account_id = 'PA00000002'
          hmac = TopController.new.send(:calculated_hmac, { 'account_id' => account_id, 'timestamp' => current_timestamp })

          VCR.use_cassette('requests/top/script_tags') do
            get '/', params: { account_id: account_id, timestamp: current_timestamp, hmac: hmac }
          end
        end

        it 'アプリの認可ページにリダイレクトする' do
          expect(response.status).to eq 302
          expect(response.header['Location']).to eq 'http://www.example.com/auth/colormeshop'
        end
      end
    end
  end

  describe '更新' do
    context '正常に終了した場合' do
      let(:user) { create(:user) }

      before do
        sign_in_as(user)
        VCR.use_cassette('requests/top/script_tags') do
          put '/', params: { script_tag: { state: 'on' } }
        end
      end

      it 'トップページにリダイレクトする' do
        expect(response.status).to eq 302
        expect(response.header['Location']).to eq 'http://www.example.com/'
      end
    end

    context 'セッションにユーザー情報が無い場合' do
      before do
        put '/', params: { script_tag: { state: 'on' } }
      end

      it '401を返す' do
        expect(response.status).to eq 401
      end
    end
  end
end

