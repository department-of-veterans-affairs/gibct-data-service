def rule_id(rule_results, object)
  rule_results.find{ |r| r[1] == object }[0]
end

if ENV['CI'].blank?

  puts 'Deleting old caution flag rules'
  CautionFlagRule.delete_all

  puts 'Deleting old rules'
  Rule.delete_all

  values = [
      Rule.new(rule_name: CautionFlag.name,
               matcher: Rule::MATCHERS[:has],
               subject: nil,
               predicate: 'source',
               object: AccreditationAction.name,
               priority: 1),
      Rule.new(rule_name: CautionFlag.name,
               matcher: Rule::MATCHERS[:has],
               subject: nil,
               predicate: 'source',
               object: Hcm.name,
               priority: 1),
      Rule.new(rule_name: CautionFlag.name,
               matcher: Rule::MATCHERS[:has],
               subject: nil,
               predicate: 'source',
               object: Mou.name,
               priority: 1),
  ]

  results = Rule.import(values, returning: [:id, :object])
  rule_results = results.results

  values = [
      # accreditation
      {rule_id: rule_id(rule_results, AccreditationAction.name),
       title: 'School has an accreditation issue',
       description: 'This school\'s accreditation has been taken away and is under appeal, or the school has been placed on probation, because it didn\'t meet acceptable levels of quality.',
       link_text: 'Learn more about this school\'s accreditation',
       link_url: 'http://ope.ed.gov/accreditation/'
      },
      # hcm
      {rule_id: rule_id(rule_results, Hcm.name),
       title: 'School placed on Heightened Cash Monitoring',
       description: 'The Department of Education has placed this school on Heightened Cash Monitoring because of financial or federal compliance issues.',
       link_text: 'Learn more about Heightened Cash Monitoring',
       link_url: 'https://studentaid.ed.gov/sa/about/data-center/school/hcm'
      },
      # mou
      {rule_id: rule_id(rule_results, Mou.name),
       title: 'School is on Military Tuition Assistance probation',
       description: 'This school is on Department of Defense (DOD) probation for Military Tuition Assistance (TA).',
       link_text: 'Learn about DOD probation',
       link_url: 'https://www.dodmou.com/Home/Faq'
      },
  ]

  CautionFlagRule.import(values, validate: false)
  puts "Created Caution Flag Rules"
  puts "Done ... Woo Hoo!"

end