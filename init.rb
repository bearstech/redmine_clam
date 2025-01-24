require_relative './lib/attachment_patch'

Redmine::Plugin.register :redmine_clam do
  name 'Clam plugin'
  author 'Mark David Dumlao'
  description 'Plugin that provides a clamd scanner for file attachments'
  version '0.0.1'
  url 'http://github.com/madumlao/redmine_clam'
  author_url 'http://madumlao.is-a-geek.org'
end
