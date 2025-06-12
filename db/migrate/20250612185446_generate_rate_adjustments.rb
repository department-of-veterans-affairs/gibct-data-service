class GenerateRateAdjustments < ActiveRecord::Migration[7.1]
  def up
    path = File.join(Rails.root, 'db', 'seeds', 'models', 'rate_adjustments.yml')
    seeds = YAML.load_file(path)
    seeds.each do |attributes|
      RateAdjustment.create(attributes)
    end

    # Associate existing calculator constants with rate adjustment
    CalculatorConstant.all.each { |constant| constant.set_rate_adjustment_if_exists }
  end

  def down
    RateAdjustment.destroy_all
  end
end
