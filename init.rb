require_dependency 'clam/redmine/models/attachment_patch'

Redmine::Plugin.register :clam do
  name 'Clam plugin'
  author 'Mark David Dumlao'
  description 'Plugin that provides a clamd scanner for file attachments'
  version '0.0.1'
  url 'http://github.com/madumlao/redmine_clam'
  author_url 'http://madumlao.is-a-geek.org'
end
