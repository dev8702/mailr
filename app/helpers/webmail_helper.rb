require 'cdfutils'
require 'mail2screen'

module WebmailHelper
  include Mail2Screen
  def link_compose_new
    link_to(t(:compose_txt), :controller=>"webmail", :action=>"compose")
  end
  
  def link_refresh
    link_to(t(:refresh), :controller=>"webmail", :action=>"refresh")
  end
  
  def link_message_list
    link_to(_('Message list'), :controller=>"webmail", :action=>"messages")
  end
  
  def link_reply_to_sender(msg_id)
    link_to(t(:reply), :controller=>"webmail", :action=>"reply", :params=>{"msg_id"=>msg_id})
  end
  
  def link_forward_message(msg_id)
    link_to(t(:forward), :controller=>"webmail", :action=>"forward", :params=>{"msg_id"=>msg_id})
  end
  
  def link_flag_for_deletion(msg_id)
    link_to(t(:delete), :controller=>"webmail", :action=>"delete", :params=>{"msg_id"=>msg_id})
  end
  
  def link_view_source(msg_id)
    link_to(t(:view_source), {:controller=>"webmail", :action=>"view_source", :params=>{"msg_id"=>msg_id}}, {'target'=>"_blank"})
  end
  
  def link_filter_add
    link_to(t(:add_filter), :controller=>'webmail', :action=>'filter_add')
  end
  
  def folder_link(folder)
    return folder.name if folder.attribs.include?(:Noselect)
    title = folder.unseen > 0 ? "#{short_fn(folder)} (#{folder.unseen})" :  "#{short_fn(folder)}"
    link = link_to title, :controller => 'webmail', :action => 'messages', :folder_name => folder.name
    link = content_tag('b', link) if folder.name == @folder_name
    link += '&nbsp;' + empty_trash_link(folder.name) if folder.trash?
    link
  end

  def message_date(datestr)
    t = Time.now
    begin
    	if datestr.kind_of?(String)
	      d = (Time.rfc2822(datestr) rescue Time.parse(value)).localtime
	    else
	    	d = datestr
	    end
      if d.day == t.day and d.month == t.month and d.year == t.year
        d.strftime("%H:%M")
      else
        d.strftime("%Y-%m-%d")
      end  
    rescue
      begin
        d = imap2time(datestr)
        if d.day == t.day and d.month == t.month and d.year == t.year
          d.strftime("%H:%M")
        else
          d.strftime("%Y-%m-%d")
        end  
      rescue
        datestr
      end
    end
  end
  
  def attachment(att, index)
    ret = "#{att.filename}"
    # todo: add link to delete attachment
    #ret << 
    ret << "<input type='hidden' name='att_files[#{index}]' value='#{att.filename}'/>"
    ret << "<input type='hidden' name='att_tfiles[#{index}]' value='#{att.temp_filename}'/>"
    ret << "<input type='hidden' name='att_ctypes[#{index}]' value='#{att.content_type}'/>"
  end
  
  def link_filter_up(filter_id)
    link_to(_('Up'), :controller=>"webmail", :action=>"filter_up", :id=>filter_id)
  end
  
  def link_filter_down(filter_id)
    link_to(_('Down'), :controller=>"webmail", :action=>"filter_down", :id=>filter_id)
  end
  
  def link_filter_edit(filter_id)
    link_to(_('Edit'), :controller=>"webmail", :action=>"filter", :id=>filter_id)
  end
  
  def link_filter_delete(filter_id)
    link_to(_('Delete'), :controller=>"webmail", :action=>"filter_delete", :id=>filter_id)
  end
  
  def page_navigation_webmail(pages)
    nav = "<p class='paginator'><small>"
    
    nav << "(#{pages.length} #{t :pages}) &nbsp; "
    
    window_pages = pages.current.window.pages
    nav << "..." unless window_pages[0].first?
    for page in window_pages
      if pages.current == page
        nav << page.number.to_s << " "
      else
        nav << link_to(page.number, :controller=>"webmail", :action=>'messages', :page=>page.number) << " "
      end
    end
    nav << "..." unless window_pages[-1].last?
    nav << " &nbsp; "
    
    nav << link_to(t(:first), :controller=>"webmail", :action=>'messages', :page=>@pages.first.number) << " | " unless @pages.current.first?
    nav << link_to(t(:prev), :controller=>"webmail", :action=>'messages', :page=>@pages.current.previous.number) << " | " if @pages.current.previous
    nav << link_to(t(:next), :controller=>"webmail", :action=>'messages', :page=>@pages.current.next.number) << " | " if @pages.current.next
    nav << link_to(t(:last), :controller=>"webmail", :action=>'messages', :page=>@pages.last.number) << " | " unless @pages.current.last?
    
    nav << "</small></p>"
    
    return nav
  end

  def parse_subject(subject)
    begin
      if mime_encoded?(subject)
        if mime_decode(subject) == '' 
          _('(No subject)')
        else
          mime_decode(subject)
        end
      else
        if from_qp(subject) == ''  
          _('(No subject)')
        else
          from_qp(subject)
        end
      end
    rescue Exception => ex
      RAILS_DEFAULT_LOGGER.debug('Exception occured - #{ex}')
      return ""
    end         
  end
  
  def message_size(size) 
  	if size / (1024*1024) > 0
  		return "#{(size / (1024*1024)).round}&nbsp;MB"
  	elsif size / 1024 > 0	
  		return "#{(size / (1024)).round}&nbsp;KB"
  	else
  		return "#{size}&nbsp;B"
  	end	
  end

  private

  def empty_trash_link(folder_name)
    link_to( "(#{t :empty})",
      { :controller => "webmail", :action => "empty", :params=>{"folder_name"=>folder_name}},
      :confirm => _('Do you really want to empty trash?')) 
  end
end
