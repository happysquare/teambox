module EmailSpec
  class EmailViewer
    extend Deliveries
    
    def self.save_and_open_all_raw_emails
      filename = "#{RAILS_ROOT}/tmp/email-#{Time.now.to_i}.txt"

      File.open(filename, "w") do |f|
        all_emails.each do |m|
          f.write m.to_s
          f.write "\n" + '='*80 + "\n"
        end
      end

      open_in_text_editor(filename)
    end

    def self.save_and_open_all_html_emails
      all_emails.each_with_index do |m, index|
        parts = m.multipart?? m.parts : Array.wrap(m)
        if html_part = parts.detect{ |p| p.content_type == 'text/html' }
          filename = tmp_email_filename("-#{index}.html")
          File.open(filename, "w") do |f|
            f.write html_part.body
          end
          open_in_browser(filename)
        end
      end
    end

    def self.save_and_open_all_text_emails
      filename = tmp_email_filename

      File.open(filename, "w") do |f|
        all_emails.each do |m|
          if m.multipart? && text_part = m.parts.detect{ |p| p.content_type == 'text/plain' }
            m.ordered_each{|k,v| f.write "#{k}: #{v}\n" }
            f.write text_part.body
          else
            f.write m.to_s
          end
          f.write "\n" + '='*80 + "\n"
        end
      end

      open_in_text_editor(filename)
    end
  
    def self.save_and_open_email(mail)
      filename = "#{RAILS_ROOT}/tmp/email-#{Time.now.to_i}.txt"

      File.open(filename, "w") do |f|
        f.write mail.to_s
      end

      open_in_text_editor(filename)
    end
    
    def self.open_in_text_editor(filename)
      `mate #{filename}`
    end
    
    def self.open_in_browser(filename)
      `open #{filename}`
    end
    
    def self.tmp_email_filename(extension = '.txt')
      "#{RAILS_ROOT}/tmp/email-#{Time.now.to_i}#{extension}"
    end
  end
end