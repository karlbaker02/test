require 'spec_helper'
require 'rails_helper'

describe SelectPhoneForm do
  it 'should be invalid when neither mobile nor smartphone answered' do
    test_form_missing_data
  end

  it 'should be valid when smartphone is answered and mobile phone is unanswered' do
    test_form_valid smart_phone: 'false'
    test_form_valid smart_phone: 'true'
  end

  it 'should be invalid when mobile is answered no and smartphone is answered yes' do
    test_form_inconsistent_data mobile_phone: 'false', smart_phone: 'true'
  end

  it 'should be invalid when mobile is answered yes and smartphone is unanswered' do
    test_form_missing_data mobile_phone: 'true'
  end

  it 'should be valid when mobile is answered yes and smartphone is answered' do
    test_form_valid mobile_phone: 'true', smart_phone: 'false'
    test_form_valid mobile_phone: 'true', smart_phone: 'true'
    test_form_valid mobile_phone: 'true', smart_phone: 'do_not_know'
  end

  describe '#selected_answers' do
    it 'should return a hash of the selected answers' do
      form = SelectPhoneForm.new(
        mobile_phone: 'true'
      )
      answers = form.selected_answers
      expect(answers).to eql(mobile_phone: true)
    end

    it 'should not return selected answers when there is no value' do
      form = SelectPhoneForm.new(
        mobile_phone: 'false',
        smart_phone: ''
      )
      answers = form.selected_answers
      expect(answers).to eql(mobile_phone: false)
    end

    it 'should not return smart_phone when the answer is do not know' do
      form = SelectPhoneForm.new(
        mobile_phone: 'true',
        smart_phone: 'do_not_know'
      )
      answers = form.selected_answers
      expect(answers).to eql(mobile_phone: true)
    end
  end

  def test_form_valid(form_fields = {})
    form = SelectPhoneForm.new(form_fields)
    expect(form.valid?).to eql true
    expect(form.errors.full_messages).to eql []
  end

  def test_form_missing_data(form_fields = {})
    form = SelectPhoneForm.new(form_fields)
    expect(form.valid?).to eql false
    expect(form.errors.full_messages).to eql ['Please answer all the questions']
  end

  def test_form_inconsistent_data(form_fields = {})
    form = SelectPhoneForm.new(form_fields)
    expect(form.valid?).to eql false
    expect(form.errors.full_messages).to eql ['Please check your selection']
  end
end
