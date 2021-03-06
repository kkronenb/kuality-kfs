class DisbursementVoucherObject < KFSDataObject

  include PaymentInformationMixin
  include AccountingLinesMixin
  alias :add_target_line :add_source_line
  alias :import_target_lines :import_source_lines

  DOC_INFO = { label: 'Disbursement Voucher Document', type_code: 'DV' }

  attr_accessor :organization_document_number, :explanation,
                :contact_name, :phone_number, :email_address,
                :foreign_draft_in_usd, :foreign_draft_in_foreign_currency, :currency_type,
                :car_mileage, :car_mileage_reimb_amt, :per_diem_start_date

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        description:                       random_alphanums(40, 'AFT'),
        #foreign_draft_in_foreign_currency: :set,
        #currency_type:                     'Canadian $'
    }.merge!(default_accounting_lines)
     .merge!(default_payment_information_lines)

    set_options(defaults.merge(opts))
  end

  def build
    visit(MainPage).disbursement_voucher
    on DisbursementVoucherPage do |page|
      page.expand_all
      page.description.focus
      page.alert.ok if page.alert.exists? # Because, y'know, sometimes it doesn't actually come up...
      fill_out page, :description, :organization_document_number, :explanation,
                     :contact_name, :phone_number, :email_address,
                     :foreign_draft_in_usd, :foreign_draft_in_foreign_currency, :currency_type
    end
  end

end