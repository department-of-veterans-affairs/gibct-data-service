def settlement_rule(rule_results, object)
  rule_results.find{ |r| r[1] == Settlement.name && r[2] == object }[0]
end

if ENV['CI'].blank?

  puts 'Deleting old caution flag rules'
  CautionFlagRule.delete_all

  puts 'Deleting old rules'
  Rule.delete_all

  values = [
      Rule.new(rule_name: CautionFlag.name,
               matcher: Rule::MATCHERS[:has],
               action: Rule::ACTIONS[:update],
               subject: AccreditationAction.name,
               predicate: nil,
               object: nil),
      Rule.new(rule_name: CautionFlag.name,
               matcher: Rule::MATCHERS[:has],
               action: Rule::ACTIONS[:update],
               subject: Hcm.name,
               predicate: nil,
               object: nil),
      Rule.new(rule_name: CautionFlag.name,
               matcher: Rule::MATCHERS[:has],
               action: Rule::ACTIONS[:update],
               subject: Mou.name,
               predicate: nil,
               object: nil),
      Rule.new(rule_name: CautionFlag.name,
               matcher: Rule::MATCHERS[:has],
               action: Rule::ACTIONS[:update],
               subject: Sec702.name,
               predicate: nil,
               object: nil),
      Rule.new(rule_name: CautionFlag.name,
               matcher: Rule::MATCHERS[:has],
               action: Rule::ACTIONS[:update],
               subject: Settlement.name,
               predicate: 'Upcoming Campus Closure (Details Posted on Institution\'s Website)',
               object: nil),
  ]

  results = Rule.import(values, returning: [:id, :subject, :predicate])
  rule_results = results.results

  values = [
      # accreditation
      {rule_id: rule_results.find{|r| r[1] == AccreditationAction.name}[0],
       title: 'School has an accreditation issue',
       description: 'This school\'s accreditation has been revoked and is under appeal, or the school has been placed on probation as it didn\'t meet acceptable levels of quality.',
       link_text: 'Learn more about this school\'s accreditation',
       link_url: 'http://ope.ed.gov/accreditation/'
      },
      # hcm
      {rule_id: rule_results.find{|r| r[1] == Hcm.name}[0],
       title: 'School is on heightened cash monitoring',
       description: 'The Department of Education has placed this school on Heightened Cash Monitoring due to financial or federal compliance issues.',
       link_text: 'Learn more about Heightened Cash Monitoring',
       link_url: 'https://studentaid.ed.gov/sa/about/data-center/school/hcm'
      },
      # mou
      {rule_id: rule_results.find{|r| r[1] == Mou.name}[0],
       title: 'School is on Military Tuition Assistance probation',
       description: 'This school is on Department of Defense (DoD) Probation for Military Tuition Assistance (TA).',
       link_text: 'Learn about DoD probation',
       link_url: 'https://www.dodmou.com/Home/Faq'
      },
      # sec702
      {rule_id: rule_results.find{|r| r[1] == Sec702.name}[0],
       title: 'School isn\'t approved for Post-9/11 GI Bill or Montgomery GI Bill-Active Duty benefits',
       description: 'This school isn\'t approved for Post-9/11 GI Bill or Montgomery GI Bill-Active Duty benefits because it doesn\'t comply with Sec 702. Section 702 requires public universities to offer recent Veterans and other “covered individuals” in-state tuition, regardless of their state residency. ',
       link_text: 'Learn more about Section 702 requirements',
       link_url: 'https://www.benefits.va.gov/gibill/docs/factsheets/section_702_factsheet.pdf'
      },
      #settlement
      {rule_id: settlement_rule(rule_results, 'Upcoming Campus Closure (Details Posted on Institution\'s Website)'),
       title: '"Campus will be closing soon',
       description: 'This campus will be closing soon.',
       link_text: 'Visit the school\'s website to learn more',
       link_url: 'SCHOOL_URL'
      },
      # #settlement
      # {rule: CautionFlagRule::RULES[:like_reason],
      #  title: '',
      #  description: '',
      #  link_text: '',
      #  link_url: ''
      # },
      # #settlement
      # {rule: CautionFlagRule::RULES[:like_reason],
      #  title: '',
      #  description: '',
      #  link_text: '',
      #  link_url: ''
      # },
      # #settlement
      # {rule: CautionFlagRule::RULES[:like_reason],
      #  title: '',
      #  description: '',
      #  link_text: '',
      #  link_url: ''
      # },
      # #settlement
      # {rule: CautionFlagRule::RULES[:like_reason],
      #  title: '',
      #  description: '',
      #  link_text: '',
      #  link_url: ''
      # },
      # #settlement
      # {rule: CautionFlagRule::RULES[:like_reason],
      #  title: '',
      #  description: '',
      #  link_text: '',
      #  link_url: ''
      # },
      # #settlement
      # {rule: CautionFlagRule::RULES[:like_reason],
      #  title: '',
      #  description: '',
      #  link_text: '',
      #  link_url: ''
      # },
      # #settlement
      # {rule: CautionFlagRule::RULES[:like_reason],
      #  title: '',
      #  description: '',
      #  link_text: '',
      #  link_url: ''
      # },
      # #settlement
      # {rule: CautionFlagRule::RULES[:like_reason],
      #  title: '',
      #  description: '',
      #  link_text: '',
      #  link_url: ''
      # },
      # #settlement
      # {rule: CautionFlagRule::RULES[:like_reason],
      #  title: '',
      #  description: '',
      #  link_text: '',
      #  link_url: ''
      # },
      # #settlement
      # {rule: CautionFlagRule::RULES[:like_reason],
      #  title: '',
      #  description: '',
      #  link_text: '',
      #  link_url: ''
      # },
  ]

  CautionFlagRule.import(values, validate: false)
  puts "Created Caution Flag Rules"
  puts "Done ... Woo Hoo!"

end