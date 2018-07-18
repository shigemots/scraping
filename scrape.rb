
require 'open-uri'
require 'nokogiri'
require 'csv'
require 'pp'


CSV.open("scrape.csv", "w") do |csv|

  start_number = 685515
  get_count = 199
  end_number = start_number + get_count
  pp "#{get_count + 1}ページ分みてくるわぁ〜＼＼\٩(๑`^´๑)۶//／／"

  for path in start_number..end_number do
    url = "https://techplay.jp/event/#{path}/"
    begin
      _html = open(url)
    rescue OpenURI::HTTPError, Errno::ECONNRESET, Errno::ETIMEDOUT
      pp "ID:#{path} ページないらしい..."
      sleep 1
      next
    end

    doc = Nokogiri::HTML(_html)
    title = doc.css('div.title-heading').inner_text
    hizuke = doc.at_css('div.event-day')
    time = doc.at_css('div.event-time')
    venue = doc.css('div.event-venue').search('div.event-info-item').inner_text
    info = doc.at('div.event-info-item')

    unless info.nil?
      info_text = info.text()
      hizuke_text = hizuke.text()
      date = hizuke_text.delete("(月)").delete("(火)").delete("(水)").delete("(木)").delete("(金)").delete("(土)").delete("(日)")
      #pp info_text.strip()

      if   info_text.include?("／")
        apply, total = info_text.delete("人").delete("定員").split("／")

        csv << [path, url, title.strip(), date, time, venue, apply.strip(), total.strip()]

      elsif  info_text.include?("定員")
        apply = " "
        total =   info_text.delete("定員").delete("人").delete("connpass").delete("Doorkeeper").delete("ATND").delete("Peatix").delete("ストアカ")

        csv << [path, url, title.strip(), date, time, venue, apply.strip(), total.strip()]

      else
        apply =   info_text.delete("人").delete("connpass").delete("Doorkeeper").delete("ATND").delete("Peatix").delete("ストアカ")
        total = " "

        csv << [path, url, title.strip(), date, time, venue, apply.strip(), total.strip()]

      end

    end
    pp "ID:#{path} いけたで(*ﾟ▽ﾟ)ﾉ！"
    sleep 1

  end
  pp "終わったから scrape.csv をスプレッドシートにインポートしてな(*ﾟ∀ﾟ*)"
end

