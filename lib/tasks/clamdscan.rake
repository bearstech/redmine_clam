namespace :redmine do
  namespace :attachments do
    desc 'Scans attachments and removes any found viruses'
    task :clamdscan => :environment do
      viruses = Attachment.remove_viruses!
      viruses.each do |a|
        puts "#{a.id} #{a.title}"
      end
    end
  end
end
