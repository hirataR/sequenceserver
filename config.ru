require 'sequenceserver'

SequenceServer::DEFAULT_CONFIG_FILE = ENV.fetch('SEQUENCESERVER_CONFIG_FILE', '~/.sequenceserver.conf').freeze
SequenceServer::DOTDIR = ENV.fetch('SEQUENCESERVER_DOTDIR', File.expand_path('~/.sequenceserver')).freeze

SequenceServer.init
run SequenceServer
