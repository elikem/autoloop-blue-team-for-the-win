require 'twilio-ruby'

class Fogbugz
  def initialize(command)
    @command = command
    @token = Figaro.env.fb_token
    @uri = Figaro.env.fb_uri
  end

  def run
    HTTParty.get(@command)
  end

  class << self
    def get_cases
      uri = "#{Figaro.env.fb_uri}/api.asp?token=#{Figaro.env.fb_token}&cmd=search&q=opened:today&cols=dtOpened,ixBug,sTitle"
      response = self.new(uri).run

      Crack::XML.parse(response.body)['response']['cases']['case']
    end

    def most_recent_case(fogbugz_cases = nil)
      case_numbers = []
      cases = fogbugz_cases ||= get_cases

      unless cases.nil?
        cases.each do |c|
          case_numbers << c['ixBug'].to_i
        end

        cases[case_numbers.each_with_index.max[1]]
      end
    end

    def cases_to_milestone(fogbugz_cases = nil)
      cases = fogbugz_cases ||= get_cases

      unless cases.nil?
        100000 - most_recent_case(cases)['ixBug'].to_i
      end
    end

    def create_milestone_case
      uri = "#{Figaro.env.fb_uri}/api.asp?token=#{Figaro.env.fb_token}&cmd=new"
      fogbugz_cases = get_cases
      case_count = cases_to_milestone(fogbugz_cases)

      if case_count == 1
        puts Fogbugz.new(uri).run
      else
        puts "#{case_count.nil? ? 'Unknown cases' : case_count } to milestone"
        twilio.api.account.messages.create(from: "#{Figaro.env.twilio_phone_number}", to: '+13216956446', body: "#{case_count.nil? ? 'Unknown cases' : case_count } cases to milestone")
      end
    end

    def twilio
      Twilio::REST::Client.new Figaro.env.twilio_account_sid, Figaro.env.twilio_auth_token
    end

    def create_new_case
      uri = "#{Figaro.env.fb_uri}/api.asp?token=#{Figaro.env.fb_token}&cmd=new"
      puts Fogbugz.new(uri).run
    end
  end
end