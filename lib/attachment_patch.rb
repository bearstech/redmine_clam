require_dependency 'attachment'

module AttachmentPatch
  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
    base.class_eval do
      unloadable
      
      after_save :remove_virus!
    end
  end
  
  module ClassMethods
    # create or return a virus scanner
    def scanner
      @@scanner ||= nil
      unless @@scanner.present?
        @@scanner = ClamAV::Client.new
      end
      
      # new connection if connection dies
      begin
        @@scanner.execute(ClamAV::Commands::PingCommand.new)
      rescue
        @@scanner = ClamAV::Client.new
      end
      
      return @@scanner
    end
    
    # scans the given filename
    def scan(file)
      File.open(file, 'r') do |fh|
        scanner.execute(ClamAV::Commands::InstreamCommand.new(fh))
      end
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
      return false unless File.exist?(diskfile)

      logger.info("  redmine_clam: scanning #{diskfile}")
      results = self.class::scan(diskfile)
      logger.info("  redmine_clam: scan results: " + results.inspect)
      results.is_a?(ClamAV::VirusResponse)
    end
    
    # removes a virus and modifies the attachment comment
    def remove_virus!
      return nil unless virus?

      logger.info("  redmine_clam: removing infected file")
      File.delete(diskfile)
      update_column(:filename, "VIRUS_FOUND_" + filename)  # SAYS OK BUT DOES NOT WORK I DUNNO WHY

      # This does not propagate correctly up to the upload form in the UI
      # (which is supposed to print somewhere the HTTP Status line, which is not HTTP/2 compatible...)
      #errors.add(:base, "Virus detected")
    end
  end
end

Attachment.send :include, AttachmentPatch
