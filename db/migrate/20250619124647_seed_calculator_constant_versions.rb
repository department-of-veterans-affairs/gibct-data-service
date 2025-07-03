class SeedCalculatorConstantVersions < ActiveRecord::Migration[7.1]
  # disable_ddl_transaction! is not needed. There are only about 30 rows
  #   in calculator_constants and it's not expected to grow much.
  def up
    latest_version_id = Version.current_production.id
    return if latest_version_id.nil? # Skip if no version exists (initial buildout)

    CalculatorConstant.all.each do |calculator_constant|
      CalculatorConstantVersion.create!(
        version_id: latest_version_id,
        name: calculator_constant.name,
        float_value: calculator_constant.float_value,
        description: calculator_constant.description
      )
    end
  end

  def down
    CalculatorConstantVersion.delete_all
  end
end
