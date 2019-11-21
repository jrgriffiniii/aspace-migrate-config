# ArchivesSpace Locale Migration CLI
Use this to update your locale files for ArchivesSpace installations

## Usage
```bash
bundle install

# Updates the locale for English
bundle exec ruby cli.rb update_locale custom/locales/en.yml en

# Updates the enums locale for Spanish
bundle exec ruby cli.rb update_locale custom/locales/enums/es.yml es enum
```
