FactoryGirl.define do
  factory :upload do
    user

    csv_type InstitutionBuilder::TABLES.first.name
    filename 'somefile.csv'
  end
end
