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
               object: AccreditationAction.name),
      Rule.new(rule_name: CautionFlag.name,
               matcher: Rule::MATCHERS[:has],
               subject: nil,
               predicate: 'source',
               object: Hcm.name),
      Rule.new(rule_name: CautionFlag.name,
               matcher: Rule::MATCHERS[:has],
               subject: nil,
               predicate: 'source',
               object: Mou.name),
      Rule.new(rule_name: CautionFlag.name,
               matcher: Rule::MATCHERS[:has],
               subject: nil,
               predicate: 'source',
               object: Sec702.name),
      Rule.new(rule_name: CautionFlag.name,
               matcher: Rule::MATCHERS[:has],
               subject: nil,
               predicate: 'reason',
               object: 'Upcoming Campus Closure (Details Posted on Institution\'s Website)'),
      Rule.new(rule_name: CautionFlag.name,
               matcher: Rule::MATCHERS[:has],
               subject: nil,
               predicate: 'reason',
               object: 'Assigned receiver has motioned court for an emergency closure of campus. Imminent closure is a distinct possibility.'),
      Rule.new(rule_name: CautionFlag.name,
               matcher: Rule::MATCHERS[:has],
               subject: nil,
               predicate: 'reason',
               object: 'Federal Trade Commission Filed Suit for Deceptive Advertising'),
      Rule.new(rule_name: CautionFlag.name,
               matcher: Rule::MATCHERS[:has],
               subject: nil,
               predicate: 'reason',
               object: 'Denial of Recertification Application to Participate in the Federal Student Financial Assistance Program'),
      Rule.new(rule_name: CautionFlag.name,
               matcher: Rule::MATCHERS[:has],
               subject: nil,
               predicate: 'reason',
               object: 'Denial of Recertification Application to Participate in the Federal Student Financial Assistance Programs Issued by Department of Education'),
      Rule.new(rule_name: CautionFlag.name,
               matcher: Rule::MATCHERS[:has],
               subject: nil,
               predicate: 'reason',
               object: 'Loss of Title IV Participation'),
      Rule.new(rule_name: CautionFlag.name,
               matcher: Rule::MATCHERS[:has],
               subject: nil,
               predicate: 'reason',
               object: 'Post 9/11 GI Bill (CH33) not approved at this location'),
      Rule.new(rule_name: CautionFlag.name,
               matcher: Rule::MATCHERS[:has],
               subject: nil,
               predicate: 'reason',
               object: 'Accreditor has requested institution to Show Cause'),
      Rule.new(rule_name: CautionFlag.name,
               matcher: Rule::MATCHERS[:has],
               subject: nil,
               predicate: 'reason',
               object: 'Settlement reached with the Federal Trade Commission (FTC)'),
      Rule.new(rule_name: CautionFlag.name,
               matcher: Rule::MATCHERS[:has],
               subject: nil,
               predicate: 'reason',
               object: 'Settlement with U.S. Government'),
      Rule.new(rule_name: CautionFlag.name,
               matcher: Rule::MATCHERS[:has],
               subject: nil,
               predicate: 'reason',
               object: 'Settlement reached with States Attorney General'),
      Rule.new(rule_name: CautionFlag.name,
               matcher: Rule::MATCHERS[:has],
               subject: nil,
               predicate: 'reason',
               object: 'Flight Program - Suspended for 85/15 violation'),
      Rule.new(rule_name: CautionFlag.name,
               matcher: Rule::MATCHERS[:has],
               subject: nil,
               predicate: 'reason',
               object: 'Potential Suspension of VA Benefits to Five Schools for Deceptive Practices goes into effect on May 9, 2020.'),
  ]

  results = Rule.import(values, returning: [:id, :object])
  rule_results = results.results

  values = [
      # accreditation
      {rule_id: rule_id(rule_results, AccreditationAction.name),
       title: 'School has an accreditation issue',
       description: 'This school\'s accreditation has been revoked and is under appeal, or the school has been placed on probation as it didn\'t meet acceptable levels of quality.',
       link_text: 'Learn more about this school\'s accreditation',
       link_url: 'http://ope.ed.gov/accreditation/'
      },
      # hcm
      {rule_id: rule_id(rule_results, Hcm.name),
       title: 'School is on heightened cash monitoring',
       description: 'The Department of Education has placed this school on Heightened Cash Monitoring due to financial or federal compliance issues.',
       link_text: 'Learn more about Heightened Cash Monitoring',
       link_url: 'https://studentaid.ed.gov/sa/about/data-center/school/hcm'
      },
      # mou
      {rule_id: rule_id(rule_results, Mou.name),
       title: 'School is on Military Tuition Assistance probation',
       description: 'This school is on Department of Defense (DoD) Probation for Military Tuition Assistance (TA).',
       link_text: 'Learn about DoD probation',
       link_url: 'https://www.dodmou.com/Home/Faq'
      },
      # sec702
      {rule_id: rule_id(rule_results, Sec702.name),
       title: 'School isn\'t approved for Post-9/11 GI Bill or Montgomery GI Bill-Active Duty benefits',
       description: 'This school isn\'t approved for Post-9/11 GI Bill or Montgomery GI Bill-Active Duty benefits because it doesn\'t comply with Sec 702. Section 702 requires public universities to offer recent Veterans and other “covered individuals” in-state tuition, regardless of their state residency. ',
       link_text: 'Learn more about Section 702 requirements',
       link_url: 'https://www.benefits.va.gov/gibill/docs/factsheets/section_702_factsheet.pdf'
      },
      #settlement
      {rule_id: rule_id(rule_results, 'Upcoming Campus Closure (Details Posted on Institution\'s Website)'),
       title: 'Campus will be closing soon',
       description: 'This campus will be closing soon.',
       link_text: 'Visit the school\'s website to learn more',
       link_url: 'SCHOOL_URL'
      },
      #settlement
      {rule_id: rule_id(rule_results, 'Assigned receiver has motioned court for an emergency closure of campus. Imminent closure is a distinct possibility.'),
       title: 'Court-ordered emergency campus closure pending for this school',
       description: 'An assigned receiver has motioned the court for an emergency closure of this campus. It may close soon.',
       link_text: nil,
       link_url: nil,
      },
      #settlement
      {rule_id: rule_id(rule_results, 'Federal Trade Commission Filed Suit for Deceptive Advertising'),
       title: 'School is being sued for deceptive advertising',
       description: 'The Federal Trade Commission (FTC) has filed suit against this school for deceptive advertising. ',
       link_text: nil,
       link_url: nil,
      },
      #settlement
      {rule_id: rule_id(rule_results, 'Denial of Recertification Application to Participate in the Federal Student Financial Assistance Programs Issued by Department of Education'),
       title: 'School denied recertification for Federal Student Financial Assistance Programs',
       description: 'This school\'s recertification application to participate in the Federal Student Financial Assistance Programs issued by Department of Education has been denied. ',
       link_text: 'Learn more about denial of recertification',
       link_url: 'https://www.benefits.va.gov/gibill/comparison_tool/about_this_tool.asp#TitleIV',
      },
      #settlement
      {rule_id: rule_id(rule_results, 'Denial of Recertification Application to Participate in the Federal Student Financial Assistance Program'),
       title: 'School denied recertification for Federal Student Financial Assistance Programs',
       description: 'This school\'s recertification application to participate in the Federal Student Financial Assistance Programs issued by Department of Education has been denied. ',
       link_text: 'Learn more about denial of recertification',
       link_url: 'https://www.benefits.va.gov/gibill/comparison_tool/about_this_tool.asp#TitleIV',
      },
      #settlement
      {rule_id: rule_id(rule_results, 'Loss of Title IV Participation'),
       title: 'School lost approval for Title IV programs like Federal Financial Aid and Pell Grants',
       description: 'This school doesn\'t meet the criteria for Title IV participation.  Students who attend this institution will not receive financial assistance such as Federal Financial Aid and Pell Grants. ',
       link_text: 'Learn more about Title IV participation',
       link_url: 'http://www.colleges.com/content/read.taf?oid=20082&title=Federal%20Student%20AidFAFSA%20%20',
      },
      #settlement
      {rule_id: rule_id(rule_results, 'Post 9/11 GI Bill (CH33) not approved at this location'),
       title: 'School isn\'t approved for Post-9/11 GI Bill benefits',
       description: 'Post 9/11 GI Bill (CH33) benefits can\'t be used at this school as the school is not approved for them.',
       link_text: nil,
       link_url: nil,
      },
      #settlement
      {rule_id: rule_id(rule_results, 'Accreditor has requested institution to Show Cause'),
       title: 'School was asked to show cause or be dropped from the accredited list',
       description: 'The accreditor has requested this institution show cause why it should not be dropped from the accredited list. The school has a maximum of one year from the date of the order to do so.',
       link_text: nil,
       link_url: nil,
      },
      #settlement
      {rule_id: rule_id(rule_results, 'Settlement reached with the Federal Trade Commission (FTC)'),
       title: 'School has settled its case with the FTC',
       description: 'The Federal Trade Commission (FTC) has reached a settlement with this school.',
       link_text: nil,
       link_url: nil,
      },
      #settlement
      {rule_id: rule_id(rule_results, 'Settlement with U.S. Government'),
       title: 'School has settled its case with the U.S. Government',
       description: 'The U.S. Government has reached a settlement with this institution. ',
       link_text: nil,
       link_url: nil,
      },
      #settlement
      {rule_id: rule_id(rule_results, 'Flight Program - Suspended for 85/15 violation'),
       title: 'School is suspended for violating VA\'s 85/15 rule',
       description: 'This school has been suspended for violating the 85/15 rule.  The 85/15 rule requires that no more than 85% of a for-profit program\'s students receive VA funding.',
       link_text: 'Learn more about the 85/15 Rule',
       link_url: 'https://www.benefits.va.gov/gibill/comparison_tool/about_this_tool.asp#8515',
      },
      #settlement
      {rule_id: rule_id(rule_results, 'Potential Suspension of VA Benefits to Five Schools for Deceptive Practices goes into effect on May 9, 2020.'),
       title: 'Potential suspension of VA benefits for deceptive practices',
       description: 'This school is one of 5 schools facing a potential suspension of VA benefits for deceptive practices.  The suspension is effective May 9, 2020.',
       link_text: nil,
       link_url: nil,
      },
  ]

  CautionFlagRule.import(values, validate: false)
  puts "Created Caution Flag Rules"
  puts "Done ... Woo Hoo!"

end