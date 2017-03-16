require 'feature_helper'
require 'api_test_helper'
require 'i18n'

RSpec.describe 'When the user visits the choose a country page' do
  before(:each) do
    set_session_and_session_cookies!
  end

  it 'should have a heading' do
    given_a_session_supporting_eidas

    visit '/choose-a-country'

    expect(page).to have_current_path(choose_a_country_path)
    expect(page).to have_css 'h1.heading-xlarge', text: I18n.translate('hub.choose_country.heading')
  end

  it 'should have select when JS is disabled' do
    given_a_session_supporting_eidas

    visit '/choose-a-country'

    expect(page).to have_select 'js-disabled-country-picker'
  end

  it 'should have a typeahead when JS is enabled', js: true do
    given_a_session_supporting_eidas

    visit '/choose-a-country'

    expect(page).to have_css '.typeahead__wrapper'
  end

  def given_a_session_supporting_eidas
    page.set_rack_session transaction_supports_eidas: true
  end
end