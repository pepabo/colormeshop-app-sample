class TopController < ApplicationController
  include ScriptTagManageable

  def show
    if request.query_parameters['hmac'].present?
      unless validate_query(request.query_parameters)
        render plain: 'リクエストに誤りがあるため処理を中断しました。お手数ですが再度、カラーミーショップ管理画面よりアクセスをお願いいたします。', status: 403
        return
      end

      session['user'] = current_user(request.query_parameters['account_id'])
      redirect_to :root
      return
    end

    redirect_to '/auth/colormeshop' and return unless session['user']

    begin
      @script_has_been_registered = script_has_been_registered?(current_user(session['user']['account_id']).access_token)
    rescue ColorMeShop::ApiError => e
      # 401 Unauthorized
      # トークンが無効(例: アプリをアンインストールした)なので認可ページにリダイレクトする
      redirect_to '/auth/colormeshop' and return if e.code == 401

      raise e
    end

  rescue ActiveRecord::RecordNotFound => e
    redirect_to '/auth/colormeshop'
  end

  def update
    unless session['user']
      render plain: 'セッションの有効期限が切れたため処理を中断しました。お手数ですが再度、カラーミーショップ管理画面よりアクセスをお願いいたします。', status: 401
      return
    end

    case submitted_parameters['state']
    when 'on'
      register_script_tag_if_needed(current_user(session['user']['account_id']).access_token)
    when 'off'
      delete_script_tag_if_needed(current_user(session['user']['account_id']).access_token)
    else
      render status: 422, file: 'public/422.html'
      return
    end

    flash[:updated] = true
    redirect_to action: :show
  end

  private

  def current_user(account_id)
    User.find_by!(account_id: account_id)
  end

  def submitted_parameters
    params.require(:script_tag).permit(:state)
  end

  def validate_query(query)
    return false unless validate_hmac(query)
    return false unless (query['timestamp'].to_i + 10) >= Time.now.to_i

    true
  end

  def validate_hmac(query)
    hmac = query['hmac']
    digest = calculated_hmac(query.select { |k, _| k != 'hmac' })

    ActiveSupport::SecurityUtils.secure_compare(digest, hmac)
  end

  def calculated_hmac(query)
    # カラーミーショップは昇順でソートしたパラメータからHMAC値を作っている
    query_string = URI.escape(query.sort.collect { |k, v| "#{k}=#{v}" }.join('&'))
    digest = OpenSSL::Digest.new('sha512')

    OpenSSL::HMAC.hexdigest(digest, ENV['COLORMESHOP_CLIENT_SECRET'], query_string)
  end
end
