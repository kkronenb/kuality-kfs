class OrganizationObject < KFSDataObject

  attr_accessor :chart_code, :organization_code, :name, :manager_principal_name, :resp_center_code,
                :physcal_campus_code, :type_code, :default_account_number,
                :address_line_1, :address_line_2, :postal_code, :country_code,
                :begin_date, :end_date, :reports_to_chart_code, :reports_to_org_code, :active,
                :plant_chart, :plant_account_number, :campus_plant_chart_code, :campus_plant_account_number

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        description:            random_alphanums(40, 'AFT'),
        chart_code:             get_aft_parameter_value(ParameterConstants::DEFAULT_CHART_CODE),
        organization_code:      random_alphanums(4),
        name:                   random_alphanums(10, 'AFT'),
        manager_principal_name: 'ccs1', #TODO grab this from config file
        resp_center_code:       'NA',
        physcal_campus_code:    get_aft_parameter_value(ParameterConstants::DEFAULT_CHART_CODE),
        type_code:              'D - Department', #TODO grab this from config file
        address_line_1:         '120 Maple Ave', #TODO grab this from config file
        address_line_2:         'Cornell University', #TODO grab this from config file
        postal_code:            '14850', #TODO grab this from config file
        country_code:           'United States',
        begin_date:             '01/01/2010',
        reports_to_chart_code:  get_aft_parameter_value(ParameterConstants::DEFAULT_CHART_CODE),
        reports_to_org_code:    '01Y9', #TODO grab this from config file
        plant_chart:            get_aft_parameter_value(ParameterConstants::DEFAULT_CHART_CODE),
        plant_account_number:   '1000710', #TODO grab this from config file
        campus_plant_chart_code: get_aft_parameter_value(ParameterConstants::DEFAULT_CHART_CODE),
        campus_plant_account_number: '1000710'#, #TODO grab this from config file
        #press:                       :save
    }
    set_options(defaults.merge(opts))
  end

  def build
    visit(MainPage).organization
    on(OrganizationLookupPage).create
    on OrganizationPage do |page|
      page.expand_all
      page.description.focus
      page.alert.ok if page.alert.exists? # Because, y'know, sometimes it doesn't actually come up...
      fill_out page, :description, :chart_code, :organization_code, :name, :manager_principal_name, :resp_center_code,
                     :physcal_campus_code, :type_code,
                     :address_line_1, :address_line_2, :postal_code, :country_code,
                     :begin_date, :end_date, :reports_to_chart_code, :reports_to_org_code
    end
  end

end