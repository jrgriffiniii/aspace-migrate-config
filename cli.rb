require 'pry-byebug'
require 'thor'
require 'yaml'

class ASpaceMigrationCLI < Thor
  def self.upstream_locale_file(language = 'en')
    current_path = File.dirname(__FILE__)
    File.join(current_path, 'archivesspace', 'common', 'locales', "#{language}.yml")
  end

  def self.upstream_enum_locale_file(language = 'en')
    current_path = File.dirname(__FILE__)
    File.join(current_path, 'archivesspace', 'common', 'locales', 'enums', "#{language}.yml")
  end

  def self.default_locale(language: 'en', enum: false)
    locale_file = if enum
                    upstream_enum_locale_file(language)
                  else
                    upstream_locale_file(language)
                  end
    locale_yaml = File.read(locale_file)
    YAML.load(locale_yaml)
  end

  def self.build_locale(values)
    if values.is_a?(Hash)
      OpenStruct.new(values.map { |key, value| [ key, build_locale(value) ] }.to_h)
    end
  end

  def self.update_locale(u_locale, v_locale)
    u_locale.to_h.each_pair do |key, value|
      if !v_locale.key?(key)
        if value.is_a?(Hash)
          v_locale[key] = update_locale(value, v_locale[key])
        else
          v_locale[key] = value
        end
      end
    end
  end

  def self.build_output_file_path(language, enum = false)
    current_path = File.dirname(__FILE__)
    if enum
      File.join(current_path, 'output', 'enums', "#{language}.yml")
    else
      File.join(current_path, 'output', "#{language}.yml")
    end
  end

  desc "update_locale FILE [LANGUAGE] [ENUM]", "Update a custom ArchivesSpace locale"
  def update_locale(file_path, language = 'en', enum = false)
    custom_locale = {}

    File.open(file_path, 'rb') do |locale_file|
      locale_yaml = locale_file.read
      locale_values = YAML.load(locale_yaml)

      # custom_locale = self.class.build_locale(locale_values)
      custom_locale = locale_values
      default_locale = self.class.default_locale(language: language, enum: enum)
      custom_locale = self.class.update_locale(default_locale, custom_locale)
    end

    output_file_path = self.class.build_output_file_path(language, enum)

    File.open(output_file_path, 'wb') do |output_file|
      output_file.write(YAML.dump(custom_locale))
    end
  end
end

ASpaceMigrationCLI.start(ARGV)
