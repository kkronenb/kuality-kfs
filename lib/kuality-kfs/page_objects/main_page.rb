class MainPage < BasePage

  page_url "#{$base_url}portal.jsp"

  #TODO abe to talk about links and button helper!

  action(:account) { |b| b.frm.link(text: 'Account').click }
  action(:account_delegate) { |b| b.frm.link(text: 'Account Delegate').click }
  action(:account_global) { |b| b.frm.link(text: 'Account Global').click }

end