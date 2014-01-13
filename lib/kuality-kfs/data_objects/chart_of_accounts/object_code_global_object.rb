class ObjectCodeGlobalObject < DataObject

#  include Navigation
#  include DateFactory
  include StringFactory


  attr_accessor :description,
                :object_code,
                :object_code_name,
                :object_code_short_name,
                :reports_to_object_code,
                :object_type_code,
                :level_code,
                :cg_reporting_code,

                :object_sub_type_code,
                :suny_object_code,
                :financial_object_code_description,

                :historical_financial_object_code,

                :budget_aggregation_code,
                :mandatory_transfer,
                :federal_funded_code,
                :next_year_object_code

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        description: random_alphanums(20, ' AFT'),
        object_code: random_alphanums(4), #if object code matches data user gets an error 'This document cannot be Saved or Routed because a record with the same primary key already exists.'
        object_code_name: random_alphanums(10, 'AFT'),
        object_code_short_name: random_alphanums(5, 'AFT'),
        reports_to_object_code: 'A000',
        object_type_code: 'ES',
        level_code:    'BADJ',
        cg_reporting_code:      '06SM',

        object_sub_type_code: 'BI',

        financial_object_code_description: random_alphanums(30, 'AFT'),
        budget_aggregation_code: 'L',
        mandatory_transfer: '::random::',
        federal_funded_code: '::random::'

    }
    set_options(defaults.merge(opts))
  end

  def create
    visit(MainPage).object_code
    on(ObjectCodeLookupPage).create_new
    on ObjectCodePage do |page|
      #page.description.focus
      #page.alert.ok if page.alert.exists? # Because, y'know, sometimes it doesn't actually come up...
      fill_out page, :description,
               :object_code, :object_code_name, :object_code_short_name,
               :reports_to_object_code, :object_type_code,
               :level_code, :object_sub_type_code, :financial_object_code_description,
               :cg_reporting_code, :budget_aggregation_code, :mandatory_transfer,
               :federal_funded_code, :next_year_object_code

      #Cornell
      fill_out page, :suny_object_code

      page.save
      @document_id = page.document_id
    end
  end



end #class