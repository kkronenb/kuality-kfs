class OrganizationReviewRoleObject < KFSDataObject

  attr_accessor :chart_code, :org_code, :doc_type, :review_types,
                :from_amount, :to_amount, :accounting_line_override_code, :principal_name,
                :namespace, :role_name, :group_namespace, :group_name, :action_type_code,
                :priority_number, :action_policy_code, :force_action, :action_from_date, :action_to_date

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        description:            random_alphanums(40, 'AFT'),
        chart_code:             'IT - Ithaca Campus', #TODO grab this from config file
        org_code:               '017D', #TODO grab this from config file
        doc_type:               'KFST',
        review_types:           'B',
        action_type_code:       'FYI',
        action_policy_code:     'FIRST'
    }
    set_options(defaults.merge(opts))
  end

  def build
    visit(MainPage).organization_review
    on(OrganizationReviewLookupPage).create
    on OrganizationReviewRolePage do |page|
      page.expand_all
      page.description.focus
      page.alert.ok if page.alert.exists? # Because, y'know, sometimes it doesn't actually come up...
      fill_out page, :description, :chart_code, :org_code, :review_types, :action_type_code, :action_policy_code

      page.principal_search
      on PersonLookup do |search|
        search.principal_name.set random_letters(1) + '*'
        search.search
        search.return_random
      end

      page.document_type_search
      on DocumentTypeLookupPage do |search|
        search.name.set 'KFST'
        search.search
        search.return_random
      end
    end
  end

end