require 'json'

class FileSystem
  def get(path)
    File.new(path)
  end
end

class Out
  def initialize(args, stdin, stdout, rest_client, file_system)
    @args = args
    @rest_client = rest_client
    @stdin = stdin
    @stdout = stdout
    @file_system = file_system
  end

  def run
    input = @stdin.read
    json = JSON.parse(input)

    app_id = json["source"]["app_id"]
    token = json["source"]["token"]
    path = json["params"]["path"]
    downloadable = json["params"]["downloadable"]

    response = @rest_client.post("https://rink.hockeyapp.net/api/2/apps/#{app_id}/app_versions/upload",
      { :ipa => @file_system.get("#{@args[0]}/#{path}"), :status => downloadable ? 2 : 1 },
      { "X-HockeyAppToken" => token })

    version = JSON.parse(response)
    version_ref = version["id"]

    @stdout.write "{ \"version\": { \"ref\": \"#{version_ref}\" } }"
  end
end
