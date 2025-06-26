# frozen_string_literal: true

RSpec.shared_examples 'a collection updatable' do |column|
  let(:controller_name) { described_class.controller_name }
  let(:factory_name) { controller_name.singularize.to_sym }
  let(:records) { create_list(factory_name, 2) }
  let(:other_records) { create_list(factory_name, 2) }
  let(:nested_params) do
    records.each_with_object({}) do |record, hash|
      hash[record.id.to_s] = { column => record.send(column) + 1.0 }
    end
  end
  let(:params) {{ controller_name => nested_params }}

  it "updates #{described_class.controller_name.tr('_', ' ')}" do
    expected_values = records.map { |record| record.send(column) + 1.0 }
    post(:update, params: params)
    updated_values = records.map { |record| record.reload.send(column) }
    expect(updated_values).to eq(expected_values)
  end

  it "skips update if #{described_class.controller_name.singularize.tr('_', ' ')} unchanged" do
    initial_values = other_records.pluck(column)
    post(:update, params: params)
    updated_values = other_records.map { |record| record.reload.send(column) }
    expect(updated_values).to eq(initial_values)
  end
end