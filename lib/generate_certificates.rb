#!/usr/bin/env ruby
# encoding:UTF-8
require 'rubygems'
require 'json'
require 'dotenv'
require 'action_mailer'
require_relative './certificates.rb'

def build_smtp_options
  {
    address: ENV['SMTP_SERVER'],
    port: ENV['SMTP_PORT'] || '587',
    domain: ENV['SENDER'] && ENV['SENDER'].split('@').last,
    authentication: ENV['AUTHENTICATION'] || 'plain',
    user_name: ENV['SMTP_USERNAME'] || ENV['SENDER'],
    password: ENV['SMTP_PASSWORD']
  }
end

def build_aws_options
  {
    access_key_id: ENV['AWS_ACCESS_KEY_ID'],
    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
    server: ENV['AWS_SERVER']
  }
end

def build_deliveries(options)
  {
    sender: ENV['SENDER'],
    dry_run: options[:dry_run],
    smtp: build_smtp_options,
    aws: build_aws_options
  }
end

def build_map_from(data_folder, options, help)
  {
    filename_pattern: options[:filename_pattern],
    data_folder: data_folder,
    deliveries: build_deliveries(options),
    inkscape_path: ENV['INKSCAPE_PATH'],
    cache_folder_path: options[:cache_folder_path],
    help: help
  }
end

def build_options_from(arguments)
  Dotenv.load
  data_folder = arguments.empty? ? nil : arguments[0]
  option_parser = CertificateOptionParser.new(data_folder || '.')
  options = option_parser.parse!(arguments)
  build_map_from(data_folder, options, option_parser.help)
end

def attendees_from(csv_content)
  parser = CSVParser.new(csv_content)
  parser.to_attributes.map.with_index do |attributes, idx|
    Attendee.new({ id: idx + 1 }.merge(attributes))
  end
end

def generator_from(svg_content, configuration)
  CertificateGenerator.new(
    svg_content,
    configuration.inkscape_path,
    configuration.cache_folder_path,
    configuration.filename_pattern,
    configuration.font_paths
  )
end

def processor_from(generator, body_template, configuration)
  BulkSenderWorker.new(
    generator,
    configuration.email_sender,
    body_template,
    limit: 0, sleep_time: 0
  )
end

options = build_options_from(ARGV)
begin
  configuration = Configuration.new(options)
  configuration.delivery.install_on(ActionMailer::Base)

  csv_content = File.read(configuration.csv_filepath)
  attendees = attendees_from(csv_content)

  svg_content = File.read(configuration.svg_filepath)
  generator = generator_from(svg_content, configuration)

  body_template = File.read(configuration.body_template_path)
  processor = processor_from(generator, body_template, configuration)

  processor.perform(attendees)
  puts processor.error_messages
rescue ConfigurationError => e
  puts e.message
  exit(1)
end
