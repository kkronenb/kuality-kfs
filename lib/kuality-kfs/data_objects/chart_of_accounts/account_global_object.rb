class AccountGlobalObject < KFSDataObject

  attr_accessor :fo_principal_name, :supervisor_principal_name,
                :organization_code, :sub_fund_group_code, :acct_expire_date,
                :postal_code, :city, :state, :address,
                :continuation_coa_code, :continuation_acct_number, :income_stream_financial_cost_code, :income_stream_account_number,
                :cfda_number,  :higher_ed_funct_code, :sufficient_funds_code,
                :trans_processing_sufficient_funds_code, :labor_benefit_rate_category_code,
                :new_chart_code, :new_number

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        description:                            random_alphanums(20, 'AFT'),
        new_chart_code:                         'IT - Ithaca Campus', #TODO grab this from config file
        new_number:                             '1000710', #TODO get from config
        supervisor_principal_name:              'jaraujo',
        manager_principal_name:                 'warriaga',
        organization_code:                      '0001',
        sub_fund_group_code:                    '',
        acct_expire_date:                       '',
        postal_code:                            '14853',
        city:                                   'Ithaca',
        state:                                  'NY',
        address:                                'Cornell University',
        continuation_coa_code:                  '',
        continuation_acct_number:               '',
        income_stream_financial_cost_code:      'IT - Ithaca Campus',
        income_stream_account_number:           '0142900',
        cfda_number:                            '',
        higher_ed_funct_code:                   '',
        sufficient_funds_code:                  'C - Consolidation',
        trans_processing_sufficient_funds_code: '',
        labor_benefit_rate_category_code:       '',
        press:                                  :save

    }
    set_options(defaults.merge(opts))
  end

  def build
    visit(MainPage).account_global
    on AccountGlobalPage do |page|
      page.description.focus
      page.alert.ok if page.alert.exists? # Because, y'know, sometimes it doesn't actually come up...
      fill_out page, :description, :fo_principal_name, :supervisor_principal_name,
               :organization_code, :sub_fund_group_code, :acct_expire_date,
               :postal_code, :city, :state, :address,
               :continuation_coa_code, :continuation_acct_number, :income_stream_financial_cost_code, :income_stream_account_number,
               :cfda_number,  :higher_ed_funct_code, :sufficient_funds_code,
               :trans_processing_sufficient_funds_code, :labor_benefit_rate_category_code,
               :new_chart_code, :new_number
      page.add_account_detail
    end
  end

  def add_multiple_accounting_lines
    unless @add_multiple_accounting_lines.nil?
      on(AccountGlobalPage).add_multiple_accounting_lines
      on AccountGlobalLookupPage do |page|
        page.account_number.fit @search_account_number
        page.search
        page.select_all_rows_from_this_page
        page.return_selected_results
      end
    end
  end

end