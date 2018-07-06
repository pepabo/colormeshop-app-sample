require 'spec_helper'

describe '/js/disable-right-click.js', type: :request do
  describe 'GET /js/disable-right-click.js' do
    before do
      get '/js/disable-right-click.js'
    end

    it 'JavaScriptを返す' do
      expect(response.status).to eq 200
      expect(response.header['Content-Type']).to eq 'text/javascript; charset=utf-8'
    end
  end
end

