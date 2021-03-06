class TransferOfFundsObject < KFSDataObject

  include AccountingLinesMixin

  DOC_INFO = { label: 'Transfer Of Funds Document', type_code: 'TF' }

  attr_accessor :organization_document_number, :explanation

  def initialize(browser, opts={})
    @browser = browser

    defaults = { description: random_alphanums(40, 'AFT') }.merge!(default_accounting_lines)

    set_options(defaults.merge(opts))
  end

  def build
    visit(MainPage).transfer_of_funds
    on TransferOfFundsPage do |page|
      page.expand_all
      page.description.focus
      page.alert.ok if page.alert.exists? # Because, y'know, sometimes it doesn't actually come up...
      fill_out page, :description, :organization_document_number, :explanation
    end
  end

end