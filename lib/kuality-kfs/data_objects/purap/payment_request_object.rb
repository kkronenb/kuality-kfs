class PaymentRequestObject < KFSDataObject

  #DOC_INFO = { label: 'Requisition', type_code: 'REQ' }

  attr_reader :description, :item_quantitiy, :item_catalog_number, :item_description, :item_unit_cost, :item_uom, :attachment_file_name

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        attachment_file_name:       'happy_path_invoice.png'
    }

    set_options(defaults.merge(opts))
  end



end #class