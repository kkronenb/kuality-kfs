class BasePage < PageFactory

  include Utilities
  include GlobalConfig

  # These constants can be used with switches to add modularity to object create methods.
  KNOWN_BUTTONS = {
    save:              'save',
    submit:            'submit',
    blanket_approve:   'blanket approve',
    close:             'close',
    cancel:            'cancel',
    reload:            'reload',
    copy:              'Copy current document',
    approve:           'approve',
    disapprove:        'disapprove',
    send_notification: 'send notification',
    recall:            'Recall current document',
    error_correction:  'error correction',
    fyi:           'fyi'
  }

  def self.available_buttons
    KNOWN_BUTTONS.values.join('|')
  end

  action(:use_new_tab) { |b| b.windows.last.use }
  action(:return_to_portal) { |b| b.portal_window.use }
  action(:close_extra_windows) { |b| b.close_children if b.windows.length > 1 }
  action(:close_children) { |b| b.windows[0].use; b.windows[1..-1].each{ |w| w.close} }
  action(:close_parents) { |b| b.windows[0..-2].each{ |w| w.close} }
  element(:logout_button) { |b| b.button(title: 'Click to logout.') }
  action(:logout) { |b| b.logout_button.click }

  element(:portal_window) { |b| b.windows(title: 'Kuali Portal Index')[0] }

  action(:form_tab) { |name, b| b.frm.h2(text: /#{name}/) }
  action(:form_status) { |name, b| b.form_tab(name).text[/(?<=\()\w+/] }

  action(:doc_search) { |b| b.img(alt: 'doc search').click }
  action(:action_list) { |b| b.img(alt: 'action list').click }
  class << self

    def glbl(*titles)
      titles.each do |title|
        action(damballa(title)) { |b| b.frm.button(class: 'globalbuttons', title: title).when_present.click }
      end
    end

    def document_header_elements
      value(:doc_title) { |b| b.frm.div(id: /^headerarea/).h1.text }
      element(:headerinfo_table) { |b| b.frm.div(id: 'headerarea').table(class: 'headerinfo') }
      value(:document_id) { |p| p.headerinfo_table[0][1].text }
      alias_method :doc_nbr, :document_id
      value(:document_status) { |p| p.headerinfo_table[0][3].text }
      value(:initiator) { |p| p.headerinfo_table[1][1].text }
      alias_method :disposition, :initiator
      value(:last_updated) {|p| p.headerinfo_table[1][3].text }
      alias_method :created, :last_updated
      value(:requisition_id) { |p| p.headerinfo_table[2][1].text }
      value(:requisition_status) { |p| p.headerinfo_table[2][3].text }
      alias_method :po_doc_status, :requisition_status
      value(:po_number) { |p| p.headerinfo_table[2][1].text }
      value(:app_doc_status) { |p| p.headerinfo_table[2][3].text }
    end

    def description_field
      element(:description) { |b| b.frm.text_field(name: 'document.documentHeader.documentDescription') }
      element(:explanation) { |b| b.frm.textarea(name: 'document.documentHeader.explanation') }
      element(:organization_document_number) { |b| b.frm.text_field(name: 'document.documentHeader.organizationDocumentNumber') }
    end

    def organization_facets
      element(:organization_name) { |b| b.frm.text_field(name: 'organizationName') }
      element(:organization_code) { |b| b.frm.text_field(name: 'organizationCode') }
      element(:organization_reference_id) { |b| b.frm.text_field(name: 'organizationReferenceId') }
    end

    def global_buttons
      glbl 'blanket approve', 'close', 'cancel', 'reload', 'copy', 'Copy current document',
           'approve', 'disapprove', 'submit', 'Send Notification', 'Recall current document','fyi', 'Calculate'
      action(:save) { |b| b.frm.button(name: 'methodToCall.save', title: 'save').click }
      action(:error_correction) { |b| b.frm.button(name: 'methodToCall.correct', title: 'Create error correction document from current document').click }
      action(:edit) { |b| b.edit_button.click }
      element(:edit_button) { |b| b.frm.button(name: 'methodToCall.editOrVersion') }
      action(:delete_selected) { |b| b.frm.button(class: 'globalbuttons', name: 'methodToCall.deletePerson').click }
      element(:send_button) { |b| b.frm.button(class: 'globalbuttons', name: 'methodToCall.sendNotification', title: 'send') }
      action(:send_fyi) { |b| b.send_button.click }
    end

    def tab_buttons
      action(:main_menu_tab) { |b| b.link(title: 'Main Menu').click }
      action(:maintenance_tab) { |b| b.link(title: 'Maintenance').click }
      action(:administration_tab) { |b| b.link(title: 'Administration').click }

      action(:expand_all) { |b| b.frm.button(name: 'methodToCall.showAllTabs').click }
    end

    def tiny_buttons
      action(:search) { |b| b.frm.button(title: 'search', value: 'search').click }
      action(:clear) { |b| b.frm.button(name: 'methodToCall.clearValues').click }
      action(:cancel_button) { |b| b.frm.link(title: 'cancel').click }
      action(:yes) { |b| b.frm.button(name: 'methodToCall.rejectYes').click }
      action(:no) {|b| b.frm.button(name: 'methodToCall.rejectNo').click }
      action(:add) { |b| b.frm.button(name: 'methodToCall.addNotificationRecipient.anchor').click }

      action(:add_multiple_accounting_lines) { |b| b.frm.button(title: 'Multiple Value Search on Account').click }
    end

    def search_results_table
      element(:header_row) { |b| b.results_table.th(class: 'sortable').parent.cells.collect { |x| snake_case(x.text.strip).to_sym } }
      action(:column_index) { |col, b| b.header_row.index(col) }
      element(:results_table) { |b| b.frm.table(id: 'row') }
      action(:open_item_via_text) { |match, text, p| p.item_row(match).link(text: text).click; p.use_new_tab; p.close_parents }
      element(:result_item) { |match, p| p.results_table.row(text: /#{match}/m) }
      action(:edit_item) { |match, p| p.results_table.row(text: /#{match}/m).link(text: 'edit').click; p.use_new_tab; p.close_parents }
      alias_method :edit_person, :edit_item

      action(:edit_first_item) { |b| b.frm.link(text: 'edit').click; b.use_new_tab; b.close_parents }

      action(:item_row) { |match, b| b.results_table.row(text: /#{match}/m) }
      alias_method :result_item, :item_row
      # Note: Use this when you need to click the "open" link on the target row
      action(:open) { |match, p| p.results_table.row(text: /#{match}/m).link(text: 'open').click; p.use_new_tab; p.close_parents }
      # Note: Use this when the link itself is the text you want to match
      action(:open_item) { |match, b| b.item_row(match).link(text: /#{match}/).click; b.use_new_tab; b.close_parents }
      action(:delete_item) { |match, p| p.item_row(match).link(text: 'delete').click; p.use_new_tab; p.close_parents }

      action(:return_value) { |match, p| p.item_row(match).link(text: 'return value').click }
      action(:select_item) { |match, p| p.item_row(match).link(text: 'select').click }
      action(:return_random) { |b| b.return_value_links[rand(b.return_value_links.length)].click; b.use_new_tab; b.close_parents }
      action(:return_random_row) { |b| b.results_table[rand(b.results_table.to_a.length - 1) + 1] }
      element(:return_value_links) { |b| b.results_table.links(text: 'return value') }

      action(:select_all_rows_from_this_page) { |b| b.frm.img(title: 'Select all rows from this page').click }
      action(:return_selected_results) { |b| b.frm.button(title: 'Return selected results').click }

      p_value(:docs_with_status) { |status, b| array = []; (b.results_table.rows.find_all{|row| row[1].text==status}).each { |row| array << row[0].text }; array }

      action(:select_monthly_item){ |obj_code, monthly_number, p| p.frm.link(href: /financialObjectCode=#{obj_code}(.*?)universityFiscalPeriodCode=#{monthly_number}/).click; p.use_new_tab; p.close_parents }
      action(:single_entry_monthly_item){ |monthly_number, p| p.frm.link(href: /universityFiscalPeriodCode=#{monthly_number}/).click; p.use_new_tab; p.close_parents }

      action(:select_this_link_without_frm) { |match, b| b.table(id: 'row').link(text: match).when_present.click }

      action(:sort_results_by) { |title_text, b| b.results_table.link(text: title_text).click }

      value(:no_result_table_returned) { |b| b.frm.divs(id: 'lookup')[0].parent.text.match /No values match this search/m }
      alias_method :no_result_table_returned?, :no_result_table_returned

      #action(:find_header_index) { |text_match, b| b.frm.results_table.ths.each { |t| puts t.text.to_s + 'la la la la la' + i.to_s; i += 1  }
      value(:get_cell_value_by_index) { |index_number, b| b.results_table.td(index: index_number).text }
    end

    def general_ledger_pending_entries
      element(:glpe_results_table) { |b| b.frm.div(id:'tab-GeneralLedgerPendingEntries-div').table }
      action(:show_glpe) { |b| b.frm.button(title: 'open General Ledger Pending Entries').when_present.click }
    end

    def notes_and_attachments
      element(:note_text) { |b| b.frm.textarea(name: 'newNote.noteText') }
      action(:add_note) { |b| b.frm.button(title: 'Add a Note').click }
      action(:delete_note) { |l=0,b| b.frm.button(name: "methodToCall.deleteBONote.line#{l}").click }
      action(:send_note_fyi) { |l=0,b| b.frm.button(name: "methodToCall.sendNoteWorkflowNotification.line#{l}").click }
      action(:notification_recipient) { |l=0,b| b.frm.text_field(id: "document.note[#{l}].adHocRouteRecipient.id") }
      element(:notes_tab) { |b| b.div(id: 'tab-NotesandAttachments-div') }
      element(:attachment_type) { |b| b.frm.select(name: 'newNote.attachment.attachmentTypeCode') }

      element(:attach_notes_file) { |b| b.frm.file_field(name: 'attachmentFile') }
      element(:notes_table) { |b| b.frm.table(summary: 'view/add notes') }

      #viewing document where changes have been made
      element(:account_line_changed_text) { |b| b.td(class: 'datacell center', text: /^Accounting Line changed from:/) }
      element(:send_to_vendor) { |b| b.frm.select(name: 'newNote.noteTopicText') }
      element(:attach_notes_file_1) { |b| b.frm.button(name: 'methodToCall.downloadBOAttachment.attachment[0]') }
      action(:download_file_button) { |l=0, b| b.frm.button(name: "methodToCall.downloadBOAttachment.attachment[#{l}]") }
      action(:download_file) { |l=0, b| b.download_file(l).click }

    end

    def route_log
      element(:route_log_iframe) { |b| b.frm.iframe(name: 'routeLogIFrame') }
      element(:actions_taken_table) { |b| b.route_log_iframe.div(id: 'tab-ActionsTaken-div').table }
      value(:actions_taken) { |b| (b.actions_taken_table.rows.collect{ |row| row[1].text }.compact.uniq).reject{ |action| action==''} }
      element(:pnd_act_req_table) { |b| b.route_log_iframe.div(id: 'tab-PendingActionRequests-div').table }
      value(:action_requests) { |b| (b.pnd_act_req_table.rows.collect{ |row| row[1].text}).reject{ |action| action==''} }
      action(:show_future_action_requests) { |b| b.route_log_iframe.h2(text: 'Future Action Requests').parent.parent.image(title: 'show').click }
      element(:future_actions_table) { |b| b.route_log_iframe.div(id: 'tab-FutureActionRequests-div').table }
      action(:requested_action_for) { |name, b| b.future_actions_table.tr(text: /#{name}/).td(index: 2).text }

      action(:pending_action_annotation) { |i=0, b| b.iframe(id: 'routeLogIFrame').div(id: 'tab-PendingActionRequests-div').table[(1+(i*2))][4].text }
      value(:pending_action_annotation_1) { |b| b.iframe(id: 'routeLogIFrame').div(id: 'tab-PendingActionRequests-div').table[1][4].text }
      value(:pending_action_annotation_2) { |b| b.iframe(id: 'routeLogIFrame').div(id: 'tab-PendingActionRequests-div').table[3][4].text }
    end

    # Gathers all errors on the page and puts them in an array called "errors"
    def error_messages
      value(:errors) do |b|
        errs = []
        b.left_errmsg_tabs.each do |div|
          if div.div.div.exist?
            errs << div.div.divs.collect{ |div| div.text }
          elsif div.div.exist?
            errs << div.divs.collect{ |div| div.text unless div.text == '' }.compact
          elsif div.li.exist?
            errs << div.lis.collect{ |li| li.text }
          end
        end
        b.left_errmsg.each do |div|
          if div.div.div.exist?
            errs << div.div.divs.collect{ |div| div.text }
          elsif div.li.exist?
            errs << div.lis.collect{ |li| li.text }
          end
        end
        errs.flatten
      end
      element(:left_errmsg_tabs) { |b| b.frm.divs(class: 'left-errmsg-tab') }
      element(:left_errmsg) { |b| b.frm.divs(class: 'left-errmsg') }
      value(:left_errmsg_text) { |b| b.left_errmsg.collect {|m| m.text.split("\n")}.flatten }
      element(:error_messages_div) { |b| b.frm.div(class: 'error') }
      element(:error_message_of) { |error_message, b| b.frm.div(text: 'Errors found in this Section:').div(text: error_message) }
    end

    def validation_elements
      element(:validation_button) { |b| b.frm.button(name: 'methodToCall.activate') }
      action(:show_data_validation) { |b| b.frm.button(id: 'tab-DataValidation-imageToggle').click; b.validation_button.wait_until_present }
      action(:turn_on_validation) { |b| b.validation_button.click; b.special_review_button.wait_until_present }
      element(:validation_errors_and_warnings) { |b| errs = []; b.validation_err_war_fields.each { |field| errs << field.html[/(?<=>).*(?=<)/] }; errs }
      element(:validation_err_war_fields) { |b| b.frm.tds(width: '94%') }
    end

    # ========
    private
    # ========

    def links(*links_text)
      links_text.each { |link| elementate(:link, link) }
    end

    def buttons(*buttons_text)
      buttons_text.each { |button| elementate(:button, button) }
    end

    # Use this to define methods to click on the green
    # buttons on the page, all of which can be identified
    # by the title tag. The method takes a hash, where the key
    # will become the method name, and the value is the string
    # that matches the green button's link title tag.
    def green_buttons(links={})
      links.each_pair do |name, title|
        action(name) { |b| b.frm.link(title: title).click }
      end
    end

    # A helper method that converts the passed string into snake case. See the StringFactory
    # module for more info.
    #
    def damballa(text)
      StringFactory::damballa(text)
    end

    def elementate(type, text)
      identifiers={:link=>:text, :button=>:value}
      el_name=damballa("#{text}_#{type}")
      act_name=damballa(text)
      element(el_name) { |b| b.frm.send(type, identifiers[type]=>text) }
      action(act_name) { |b| b.frm.send(type, identifiers[type]=>text).click }
    end

    # Used for getting rid of the space in the full name
    def nsp(string)
      string.gsub(' ', '')
    end

    # Used to add an extra space in the full name (because some
    # elements have that, annoyingly!)
    def twospace(string)
      string.gsub(' ', '  ')
    end

  end # self

end # BasePage