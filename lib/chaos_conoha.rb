require "optparse"
require "conoha_api"
require "slack-ruby-client"
require "chaos_conoha/version"

module ChaosConoha
  class Runner
    COMMANDS = [
      :create,
      :stop,
      :restart,
      :delete
    ]

    def initialize(args)
      parse!(args.dup)
    rescue => e
      puts e.message
      puts e.backtrace.join("\n")
      puts ""
      puts parser
      exit 1
    end

    def parser
      @parser ||= begin
                    parser = OptionParser.new
                    parser.banner = 'Usage: chaos_conoha -l LOGIN_NAME -p PASSWORD -t TENANT_ID -i https://example.com -s SLACK_TOKEN -c CHANNEL_TO_POST'

                    parser.on('-l', '--login LOGIN')   { |login| options[:login] = login }
                    parser.on('-p', '--password PASS') { |pass|  options[:password] = pass }
                    parser.on('-t', '--tenant-id TENANT') { |tenant_id| options[:tenant_id] = tenant_id }
                    parser.on('-i', '--identity-api-host HOST') { |host| options[:api_endpoint] = host }
                    parser.on('-s', '--slack-token TOKEN') { |token| options[:slack_token] = token }
                    parser.on('-c', '--slack-channel CHANNEL') { |channel| options[:slack_channel] = channel }
                    parser
                  end
    end

    def parse!(args)
      parser.parse!(args)
    rescue => e
      puts e.message
      puts parser
      exit 1
    end

    def run!
      res = __send__(COMMANDS.sample)
      slack.chat_postMessage(channel: options[:slack_channel], text: res, as_user: true)
    rescue => e
      puts e.message
      puts e.backtrace.join("\n")
      puts ""
      puts parser
      exit 1
    end

    def conoha
      @conoha ||= ConohaApi::Client.new(options)
    end

    def slack
      @slack ||= begin
                   Slack.configure do |config|
                     config.token = options[:slack_token]
                   end
                   Slack::Web::Client.new
                 end
    end

    def options
      @options ||= {}
    end

    def create
      image = conoha.images_detail.images.sample
      flavor = conoha.flavors_detail.flavors.sample
      conoha.add_server(image.id, flavor.id)
      "CPUが#{flavor.vcpus}個の、メモリが#{flavor.ram}Mのインスタンスに、#{image.name}を入れて作っておいたよ！\n感謝してね！"
    end

    def stop
      machine = conoha.servers_detail.servers.select { |s| s.status == "ACTIVE" }.sample
      conoha.stop_server(machine.id)
      "ごめんっ、コンセントに足引っ掛けて#{machine.metadata.instance_name_tag}っていうマシン止めちゃった！"
    end

    def restart
      machine = conoha.servers_detail.servers.select { |s| s.status == "ACTIVE" }.sample
      conoha.reboot_server(machine.id, 'HARD')
      "なんか、#{machine.metadata.instance_name_tag}っていうマシンから変な音してたから、再起動しといたよっ！ えへん！"
    end

    def delete
      machine = conoha.servers_detail.servers.select { |s| s.status == "ACTIVE" }.sample
      conoha.delete_server(machine.id)
      "#{machine.metadata.instance_name_tag}っていうマシン、なんか使ってなかったっぽいから消しといたよ！"
    end
  end
end
