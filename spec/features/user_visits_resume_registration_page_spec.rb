require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the resume registration page and' do
  before(:each) do
    set_session_and_session_cookies!
    stub_api_idp_list_for_sign_in
    set_selected_idp_in_session(entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one')
    stub_translations
  end

  context 'and has a cookie containing a PENDING state and valid IDP identifiers' do
    it 'displays correct text and button' do
      set_journey_hint_cookie('http://idcorp.com', 'PENDING', 'en')

      visit '/resume-registration'

      expect(page).to have_content t('hub.paused_registration.resume.intro', rp_name: 'Test RP', display_name: 'IDCorp')
      expect(page).to have_content t('hub.paused_registration.resume.heading', rp_name: 'Test RP', display_name: 'IDCorp')
      expect(page).to have_button t('hub.paused_registration.resume.continue', display_name: 'IDCorp')
      expect(page).to have_content t('hub.paused_registration.resume.alternative_other_ways', rp_name: 'Test RP')
    end
  end
end
