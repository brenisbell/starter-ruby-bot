require 'slack-ruby-client'
require 'logging'

logger = Logging.logger(STDOUT)
logger.level = :debug

Slack.configure do |config|
  config.token = ENV['SLACK_TOKEN']
  if not config.token
    logger.fatal('Missing ENV[SLACK_TOKEN]! Exiting program')
    exit
  end
end

client = Slack::RealTime::Client.new

# listen for hello (connection) event - https://api.slack.com/events/hello
client.on :hello do
  logger.debug("Connected '#{client.self['name']}' to '#{client.team['name']}' team at https://#{client.team['domain']}.slack.com.")
end

# listen for channel_joined event - https://api.slack.com/events/channel_joined
client.on :channel_joined do |data|
  if joiner_is_bot?(client, data)
    client.message channel: data['channel']['id'], text: "Thanks for the invite! I don\'t do much yet, but #{help}"
    logger.debug("#{client.self['name']} joined channel #{data['channel']['id']}")
  else
    logger.debug("Someone far less important than #{client.self['name']} joined #{data['channel']['id']}")
  end
end

# listen for message event - https://api.slack.com/events/message
client.on :message do |data|

  case data['text']
  when 'shit', 'fuck', 'dick', 'balls', 'damn', 'mother fucker', 'tits', 'turd', 'pussy', 'fuck you', 'fuck that' then
    client.typing channel: data['channel']
    client.message channel: data['channel'], text: "Hehe I like that <@#{data['user']}>."
    logger.debug("<@#{data['user']}> said hi")

    if direct_message?(data)
      client.message channel: data['channel'], text: "you silly."
      logger.debug("And it was a direct message")
    end

  when 'attachment', 'bot attachment', ':taco:', 'oops', 'yay!' then
    # attachment messages require using web_client
    client.web_client.chat_postMessage(post_message_payload(data))
    logger.debug("Attachment message posted")

  when 'Sorry, you can only give tacos to other people on your team.' then
    # attachment messages require using web_client
    client.web_client.chat_postMessage(post_message_payload2(data))
    logger.debug("sellse")
    
  when '*Tomato and Onion Leaderboard*' then
    # attachment messages require using web_client
    client.web_client.chat_postMessage(post_message_payload3(data))
    logger.debug("leaderboard")
    
  when 'lol' then
    # attachment messages require using web_client
    client.web_client.chat_postMessage(post_message_payload4(data))
    logger.debug("lol")
    
  when 'ha' then
    client.typing channel: data['channel']
    client.message channel: data['channel'], text: "#funnynotfunny"
    logger.debug("<@#{data['user']}> ha")
    
  when bot_mentioned(client)
    client.message channel: data['channel'], text: 'You really do care about me. :heart:'
    logger.debug("Bot mentioned in channel #{data['channel']}")

  when 'bot help', 'help' then
    client.message channel: data['channel'], text: help
    logger.debug("A call for help")

  when /^bot/ then
    client.message channel: data['channel'], text: "Sorry <@#{data['user']}>, I don\'t understand. \n#{help}"
    logger.debug("Unknown command")
  end
end

def direct_message?(data)
  # direct message channles start with a 'D'
  data['channel'][0] == 'D'
end

def bot_mentioned(client)
  # match on any instances of `<@bot_id>` in the message
  /\<\@#{client.self['id']}\>+/
end

def joiner_is_bot?(client, data)
 /^\<\@#{client.self['id']}\>/.match data['channel']['latest']['text']
end

def help
  %Q(I will respond to the following messages: \n
      `bot hi` for a simple message.\n
      `bot attachment` to see a Slack attachment message.\n
      `@<your bot\'s name>` to demonstrate detecting a mention.\n
      `bot help` to see this again.)
end

def post_message_payload(data)
  main_msg = 'feed toddlers tacos'
  {
    channel: data['channel'],
      as_user: true,
      attachments: [
        {
          fallback: main_msg,
          image_url: 'http://i.imgur.com/mg8SjSt.jpg',
          title_link: 'dang',
          text: main_msg,
          color: '#7CD197'
        }
      ]
  }
end

def post_message_payload2(data)
  main_msg = '...'
  {
    channel: data['channel'],
      as_user: true,
      attachments: [
        {
          fallback: main_msg,
          image_url: 'http://i.giphy.com/3o7qE5fLZwYjgY2iSQ.gif',
          title_link: 'dang',
          text: main_msg,
          color: '#527BE7'
        }
      ]
  }
end

def post_message_payload3(data)
  main_msg = '...'
  {
    channel: data['channel'],
      as_user: true,
      attachments: [
        {
          fallback: main_msg,
          image_url: 'http://i.giphy.com/l396IsyYn5NUCLcOc.gif',
          title_link: 'dang',
          text: main_msg,
          color: '#527BE7'
        }
      ]
  }
end

def post_message_payload3(data)
  main_msg = '...'
  {
    channel: data['channel'],
      as_user: true,
      attachments: [
        {
          fallback: main_msg,
          image_url: 'http://i.giphy.com/3oEjHKO4CODwxBV5sY.gif',
          title_link: 'dang',
          text: main_msg,
          color: '#527BE7'
        }
      ]
  }
end

client.start!
