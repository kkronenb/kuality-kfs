# FIXME: CashReceiptObject probably doesn't work right. We need to revise this
#        once we've identified who can create Cash Receipts.
class CashReceiptObject < KFSDataObject

  include AccountingLinesMixin

  DOC_INFO = { label: 'Cash Receipt Document', type_code: 'CR' }

  attr_accessor :organization_document_number, :explanation

  def initialize(browser, opts={})
    @browser = browser

    defaults = { description: random_alphanums(40, 'AFT') }.merge!(default_accounting_lines)

    set_options(defaults.merge(opts))
  end

  def build
    visit(MainPage).cash_receipt
    on CashReceiptPage do |page|
      page.expand_all
      page.description.focus
      page.alert.ok if page.alert.exists? # Because, y'know, sometimes it doesn't actually come up...
      fill_out page, :description, :organization_document_number, :explanation
    end
  end

  def default_accounting_lines(opts={})
    super(opts).merge(
        initial_lines: [{
                          account_number: '1258322', #TODO get from config
                          object: '4420', #TODO get from config
                          amount: '100'
                        }])
  end

end
