# return unless ENV["OPENAI_ACCESS_TOKEN"].present?

# OpenAI.configure do |config|
#   config.access_token = ENV["OPENAI_ACCESS_TOKEN"]
# end
OpenAI.api_key = ENV["OPENAI_ACCESS_TOKEN"]
