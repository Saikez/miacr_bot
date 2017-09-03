require "./miacr_bot/*"
require "yaml"
require "discordcr"

module MiacrBot
  if ARGV.any?{ |arg| arg == "--live" || arg == "-l" }
    config = YAML.parse(File.read("config/secrets.yml"))["production"]
    puts "\nMia[BOT] is ready to fight!\n\n"
  else
    config = YAML.parse(File.read("config/secrets.yml"))["development"]
    puts "\nMia[BOT] is hitting the training room\n\n"
  end

  begin
    settings = YAML.parse(File.read("config/settings.yml")) || {  } of String => String
  rescue
    puts "No settings.yml found"
    puts "Creating settings.yml"
    settings = {  } of String => String
  end

  PREFIX = "!"

  token = "Bot " + config["token"].to_s
  client_id = config["client_id"].to_s.to_u64

  puts "\nYour bot invite URL is https://discordapp.com/oauth2/authorize?client_id=#{client_id}&scope=bot.\n\n"

  client = Discord::Client.new(token, client_id)

  client.on_message_create do |payload|
    command = payload.content
    case command
    when PREFIX + "help"
      client.create_message(client.create_dm(payload.author.id).id, "Help is on the way!")
    when PREFIX + "about"
      block = "```\nMia[BOT] developed by Saikez\n```"
      client.create_message(payload.channel_id, block)
    when .starts_with? PREFIX + "echo"
      suffix = command.split(" ")[1..-1].join(" ")
      client.create_message(payload.channel_id, suffix)
    when PREFIX + "date"
      client.create_message(payload.channel_id, Time.now.to_s("%D"))
    when PREFIX + "ping"
      m = client.create_message(payload.channel_id, "Pong!")
      time = Time.utc_now - payload.timestamp
      client.edit_message(m.channel_id, m.id, "Pong!\n#{time.total_milliseconds} ms.")
    end
  end
end

client.run
