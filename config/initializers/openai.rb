require "openai"

OPENAI_CLIENT = OpenAI::Client.new(access_token: ENV["OPENAI_ACCESS_TOKEN"])
