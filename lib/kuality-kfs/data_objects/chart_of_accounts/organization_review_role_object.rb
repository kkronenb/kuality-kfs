class OrganizationReviewRoleObject < KFSDataObject

  attr_accessor :chart_code, :organization_code, :doc_type, :review_types,
                :from_amount, :to_amount, :accounting_line_override_code, :principal_name,
                :namespace, :role_name, :group_namespace, :group_name, :action_type_code,
                :priority_number, :action_policy_code, :force_action, :action_from_date, :action_to_date

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        description:            random_alphanums(40, 'AFT'),
        chart_code:             'IT - Ithaca Campus', #TODO grab this from config file
        organization_code:               '017D', #TODO grab this from config file
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
      fill_out page, :description, :chart_code, :organization_code, :review_types, :action_type_code, :action_policy_code

      page.principal_search
    end
    on PersonLookup do |search|
      search.principal_name.fit random_letters(1) + '*'
      search.search
      search.return_random
    end
    on(OrganizationReviewRolePage).document_type_search
    on DocumentTypeLookupPage do |search|
      search.name.fit 'KFST'
      search.search
      search.return_random
    end
    @document_id = on(OrganizationReviewRolePage).document_id
    # We need to do this last step to let @browser know that we're back on the OrganizationReviewRolePage. This object is weird.
  end

end