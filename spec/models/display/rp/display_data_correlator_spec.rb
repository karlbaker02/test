require 'spec_helper'
require 'display/rp/display_data_correlator'
require 'display/rp_display_repository'
require 'display/rp_display_data'
require 'display/display_data'
require 'transaction_response'
require 'display/decorated_transaction'
require 'transaction_list'
require 'config_proxy'

module Display
  module Rp
    describe DisplayDataCorrelator do
      let(:transaction_a_name) { 'Transaction A' }
      let(:transaction_2_name) { 'Transaction 2' }
      let(:transaction_3_name) { 'Transaction 3' }
      let(:transaction_4_name) { 'Transaction 4' }
      let(:transaction_b_name) { 'Private Transaction B' }
      let(:transaction_a_display_data) do
        instance_double("Display::RpDisplayData", "1", name: transaction_a_name)
      end
      let(:transaction_b_display_data) do
        instance_double("Display::RpDisplayData", "private", name: transaction_b_name)
      end
      let(:transaction_2_display_data) do
        instance_double("Display::RpDisplayData", "2", name: transaction_2_name)
      end
      let(:transaction_3_display_data) do
        instance_double("Display::RpDisplayData", "3", name: transaction_3_name)
      end
      let(:transaction_4_display_data) do
        instance_double("Display::RpDisplayData", "4", name: transaction_4_name)
      end
      let(:rp_display_repository) do
        instance_double("Display::RpDisplayRepository")
      end
      let(:homepage) { 'http://transaction-a.com' }
      let(:homepage_2) { 'http://transaction-2.com' }
      let(:homepage_3) { 'http://transaction-3.com' }
      let(:homepage_4) { 'http://transaction-4.com' }

      let(:public_simple_id) { 'test-rp' }
      let(:public_simple_id_2) { 'test-rp-2' }
      let(:public_simple_id_3) { 'test-rp-3' }
      let(:public_simple_id_4) { 'test-rp-4' }
      let(:private_simple_id) { 'some-simple-id' }

      let(:public_simple_id_loa) { ['LEVEL_1'] }
      let(:public_simple_id_2_loa) { ['LEVEL_1'] }
      let(:public_simple_id_3_loa) { %w(LEVEL_1 LEVEL_2) }
      let(:public_simple_id_4_loa) { ['LEVEL_2'] }
      let(:private_simple_id_loa) { ['LEVEL_2'] }

      let(:display_data_correlator) {
        DisplayDataCorrelator.new
      }

      let(:rps_with_homepage) { [public_simple_id] }
      let(:rps_without_homepage) { [private_simple_id] }

      let(:config_proxy) { instance_double("ConfigProxy") }

      before(:each) do
        allow(rp_display_repository).to receive(:get_translations).with(public_simple_id).and_return(transaction_a_display_data)
        allow(rp_display_repository).to receive(:get_translations).with(public_simple_id_2).and_return(transaction_2_display_data)
        allow(rp_display_repository).to receive(:get_translations).with(public_simple_id_3).and_return(transaction_3_display_data)
        allow(rp_display_repository).to receive(:get_translations).with(public_simple_id_4).and_return(transaction_4_display_data)
        allow(rp_display_repository).to receive(:get_translations).with(private_simple_id).and_return(transaction_b_display_data)
        allow(TransactionList).to receive(:rp_display_repository).and_return(rp_display_repository)
      end

      it 'returns the transactions with display name and homepage in the order listed in the relying_parties_config' do
        transaction_data = [
          instance_double("TransactionResponse", "1", 'simple_id' => public_simple_id, 'homepage' => homepage, 'loa_list' => public_simple_id_loa),
          instance_double("TransactionResponse", "2", 'simple_id' => public_simple_id_2, 'homepage' => homepage_2, 'loa_list' => public_simple_id_2_loa),
          instance_double("TransactionResponse", "3", 'simple_id' => public_simple_id_3, 'homepage' => homepage_3, 'loa_list' => public_simple_id_3_loa),
          instance_double("TransactionResponse", "4", 'simple_id' => public_simple_id_4, 'homepage' => homepage_4, 'loa_list' => public_simple_id_4_loa),
        ]
        expect(transaction_data[0]).to receive(:valid?).and_return true
        expect(transaction_data[1]).to receive(:valid?).and_return true
        expect(transaction_data[2]).to receive(:valid?).and_return true
        expect(transaction_data[3]).to receive(:valid?).and_return true
        rps_with_homepage = [public_simple_id_4, public_simple_id_2, public_simple_id, public_simple_id_3]
        expect(TransactionList).to receive(:rps_with_homepage).and_return(rps_with_homepage).exactly(3).times
        expect(TransactionList).to receive(:rps_without_homepage).and_return([]).once
        actual_result = display_data_correlator.correlate(transaction_data)
        expected_result = DisplayDataCorrelator::Transactions.new(
          [
            DecoratedTransaction.new(transaction_a_display_data, transaction_data[0]),
            DecoratedTransaction.new(transaction_2_display_data, transaction_data[1]),
            DecoratedTransaction.new(transaction_3_display_data, transaction_data[2]),
            DecoratedTransaction.new(transaction_4_display_data, transaction_data[3]),
          ],
          []
        )
        expect(actual_result).to eq expected_result
      end

      it 'translates and filters the transactions according to the relying_parties config' do
        transaction_data = [
          instance_double("TransactionResponse", 'simple_id' => public_simple_id, 'homepage' => homepage, 'loa_list' => public_simple_id_loa),
          instance_double("TransactionResponse", 'simple_id' => private_simple_id, 'loa_list' => private_simple_id_loa),
        ]
        expect(transaction_data[0]).to receive(:valid?).and_return true
        expect(transaction_data[1]).to receive(:valid?).and_return true

        expect(TransactionList).to receive(:rps_with_homepage).and_return([public_simple_id]).exactly(3).times
        expect(TransactionList).to receive(:rps_without_homepage).and_return([private_simple_id]).once
        actual_result = display_data_correlator.correlate(transaction_data)
        expected_result = DisplayDataCorrelator::Transactions.new(
          [DecoratedTransaction.new(transaction_a_display_data, transaction_data[0])],
          [DecoratedTransaction.new(transaction_b_display_data, transaction_data[1])]
        )
        expect(actual_result).to eq expected_result
      end

      it 'should return transactions with two empty lists when the transactions property is absent' do
        expect(display_data_correlator.correlate([])).to eq(DisplayDataCorrelator::Transactions.new([], []))
      end
    end
  end
end
