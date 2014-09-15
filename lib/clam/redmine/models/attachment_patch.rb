require_dependency 'attachment'

module AttachmentPatch
  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
    base.class_eval do
      unloadable
    end
  end
  
  module ClassMethods
    # create or return a virus scanner
    def scanner
      @@scanner ||= nil
      unless @@scanner.present?
        @@scanner = ClamAV::Client.new
      end
      return @@scanner
    end
    
    # scans the given filename
    def scan(file)
      scanner.execute(ClamAV::Commands::ScanCommand.new(file))
    end
    
    # given a where query, scans and deletes all matching viruses
    def remove_viruses!(q=nil, *args)
      attachments = Attachment.where(q,*args)
      attachments.select do |a|
        a.remove_virus!
      end
    end
    
    # given a where query, returns all attachments with a matching virus
    def viruses(q=nil, *args)
      attachments = Attachment.where(q,*args)
      attachments = attachments.select do |a|
        a.virus?
      end
    end
  end
    
  module InstanceMethods
    # returns true if the attachment is a virus
    def virus?
      return nil unless File.exist?(diskfile)
      results = self.class::scan(diskfile)
      if results.select {|r| r.virus_name }.count > 0
        return results.first
      else
        return false
      end
    end
    
    # removes a virus and modifies the attachment comment
    def remove_virus!
      results = virus?
      return nil unless results.present?
      timestamp = DateTime.now.strftime('%Y-%m-%d %H:%M:%S')
      self.filename = "[DELETED:#{results.virus_name}] #{filename}"
      File.delete diskfile
      self.save!
      self.reload
      return self
    end
  end
end

Attachment.send :include, AttachmentPatch
