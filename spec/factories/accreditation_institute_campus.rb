# frozen_string_literal: true

FactoryBot.define do
  factory :accreditation_institute_campus do
    dapip_id 131_584
    ope '00279100'
    ope6 '02791'
    location_name 'Greendale Community College'
    parent_name '-'
    parent_dapip_id 0
    location_type 'Institution'
    address '123 Main St, Greendale, CA 90234'
    general_phone '5554443333'
    admin_name 'Craig Pelton'
    admin_phone '5556667777'
    admin_email 'craig@example.com'
  end

  factory :accreditation_campus, class: 'AccreditationInstituteCampus' do
    dapip_id 131_584_002
    ope '00279102'
    ope6 '02791'
    location_name 'Greendale Law School'
    parent_name 'Greendale Community College'
    parent_dapip_id 1_315_840
    location_type 'Additional Location'
    address '456 College St, Greendale, CA 90234'
  end
end
