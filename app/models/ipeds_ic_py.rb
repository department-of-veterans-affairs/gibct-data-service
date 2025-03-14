# frozen_string_literal: true

class IpedsIcPy < ImportableRecord
  COLS_USED_IN_INSTITUTION = %i[tuition_in_state tuition_out_of_state books].freeze

  CSV_CONVERTER_INFO = {
    'unitid' => { column: :cross, converter: Converters::CrossConverter },
    'prgmofr' => { column: :prgmofr, converter: Converters::NumberConverter },
    'cipcode1' => { column: :cipcode1, converter: Converters::NumberConverter },
    'xciptui1' => { column: :xciptui1, converter: Converters::BaseConverter },
    'ciptuit1' => { column: :ciptuit1, converter: Converters::NumberConverter },
    'xcipsup1' => { column: :xcipsup1, converter: Converters::BaseConverter },
    'cipsupp1' => { column: :cipsupp1, converter: Converters::NumberConverter },
    'xciplgt1' => { column: :xciplgt1, converter: Converters::BaseConverter },
    'ciplgth1' => { column: :ciplgth1, converter: Converters::NumberConverter },
    'prgmsr1' => { column: :prgmsr1, converter: Converters::NumberConverter },
    'xmthcmp1' => { column: :xmthcmp1, converter: Converters::BaseConverter },
    'mthcmp1' => { column: :mthcmp1, converter: Converters::NumberConverter },
    'xwkcmp1' => { column: :xwkcmp1, converter: Converters::BaseConverter },
    'wkcmp1' => { column: :wkcmp1, converter: Converters::NumberConverter },
    'xlnayhr1' => { column: :xlnayhr1, converter: Converters::BaseConverter },
    'lnayhr1' => { column: :lnayhr1, converter: Converters::NumberConverter },
    'xlnaywk1' => { column: :xlnaywk1, converter: Converters::BaseConverter },
    'lnaywk1' => { column: :lnaywk1, converter: Converters::NumberConverter },
    'xchg1py0' => { column: :xchg1py0, converter: Converters::BaseConverter },
    'chg1py0' => { column: :chg1py0, converter: Converters::NumberConverter },
    'xchg1py1' => { column: :xchg1py1, converter: Converters::BaseConverter },
    'chg1py1' => { column: :chg1py1, converter: Converters::NumberConverter },
    'xchg1py2' => { column: :xchg1py2, converter: Converters::BaseConverter },
    'chg1py2' => { column: :chg1py2, converter: Converters::NumberConverter },
    'xchg1py3' => { column: :xchg1py3, converter: Converters::BaseConverter },
    'chg1py3' => { column: :chg1py3, converter: Converters::NumberConverter },
    'xchg4py0' => { column: :xchg4py0, converter: Converters::BaseConverter },
    'chg4py0' => { column: :chg4py0, converter: Converters::NumberConverter },
    'xchg4py1' => { column: :xchg4py1, converter: Converters::BaseConverter },
    'chg4py1' => { column: :chg4py1, converter: Converters::NumberConverter },
    'xchg4py2' => { column: :xchg4py2, converter: Converters::BaseConverter },
    'chg4py2' => { column: :chg4py2, converter: Converters::NumberConverter },
    'xchg4py3' => { column: :xchg4py3, converter: Converters::BaseConverter },
    'chg4py3' => { column: :books, converter: Converters::NumberConverter },
    'xchg5py0' => { column: :xchg5py0, converter: Converters::BaseConverter },
    'chg5py0' => { column: :chg5py0, converter: Converters::NumberConverter },
    'xchg5py1' => { column: :xchg5py1, converter: Converters::BaseConverter },
    'chg5py1' => { column: :chg5py1, converter: Converters::NumberConverter },
    'xchg5py2' => { column: :xchg5py2, converter: Converters::BaseConverter },
    'chg5py2' => { column: :chg5py2, converter: Converters::NumberConverter },
    'xchg5py3' => { column: :xchg5py3, converter: Converters::BaseConverter },
    'chg5py3' => { column: :chg5py3, converter: Converters::NumberConverter },
    'xchg6py0' => { column: :xchg6py0, converter: Converters::BaseConverter },
    'chg6py0' => { column: :chg6py0, converter: Converters::NumberConverter },
    'xchg6py1' => { column: :xchg6py1, converter: Converters::BaseConverter },
    'chg6py1' => { column: :chg6py1, converter: Converters::NumberConverter },
    'xchg6py2' => { column: :xchg6py2, converter: Converters::BaseConverter },
    'chg6py2' => { column: :chg6py2, converter: Converters::NumberConverter },
    'xchg6py3' => { column: :xchg6py3, converter: Converters::BaseConverter },
    'chg6py3' => { column: :chg6py3, converter: Converters::NumberConverter },
    'xchg7py0' => { column: :xchg7py0, converter: Converters::BaseConverter },
    'chg7py0' => { column: :chg7py0, converter: Converters::NumberConverter },
    'xchg7py1' => { column: :xchg7py1, converter: Converters::BaseConverter },
    'chg7py1' => { column: :chg7py1, converter: Converters::NumberConverter },
    'xchg7py2' => { column: :xchg7py2, converter: Converters::BaseConverter },
    'chg7py2' => { column: :chg7py2, converter: Converters::NumberConverter },
    'xchg7py3' => { column: :xchg7py3, converter: Converters::BaseConverter },
    'chg7py3' => { column: :chg7py3, converter: Converters::NumberConverter },
    'xchg8py0' => { column: :xchg8py0, converter: Converters::BaseConverter },
    'chg8py0' => { column: :chg8py0, converter: Converters::NumberConverter },
    'xchg8py1' => { column: :xchg8py1, converter: Converters::BaseConverter },
    'chg8py1' => { column: :chg8py1, converter: Converters::NumberConverter },
    'xchg8py2' => { column: :xchg8py2, converter: Converters::BaseConverter },
    'chg8py2' => { column: :chg8py2, converter: Converters::NumberConverter },
    'xchg8py3' => { column: :xchg8py3, converter: Converters::BaseConverter },
    'chg8py3' => { column: :chg8py3, converter: Converters::NumberConverter },
    'xchg9py0' => { column: :xchg9py0, converter: Converters::BaseConverter },
    'chg9py0' => { column: :chg9py0, converter: Converters::NumberConverter },
    'xchg9py1' => { column: :xchg9py1, converter: Converters::BaseConverter },
    'chg9py1' => { column: :chg9py1, converter: Converters::NumberConverter },
    'xchg9py2' => { column: :xchg9py2, converter: Converters::BaseConverter },
    'chg9py2' => { column: :chg9py2, converter: Converters::NumberConverter },
    'xchg9py3' => { column: :xchg9py3, converter: Converters::BaseConverter },
    'chg9py3' => { column: :chg9py3, converter: Converters::NumberConverter },
    'cipcode2' => { column: :cipcode2, converter: Converters::NumberConverter },
    'xciptui2' => { column: :xciptui2, converter: Converters::BaseConverter },
    'ciptuit2' => { column: :ciptuit2, converter: Converters::NumberConverter },
    'xcipsup2' => { column: :xcipsup2, converter: Converters::BaseConverter },
    'cipsupp2' => { column: :cipsupp2, converter: Converters::NumberConverter },
    'xciplgt2' => { column: :xciplgt2, converter: Converters::BaseConverter },
    'ciplgth2' => { column: :ciplgth2, converter: Converters::NumberConverter },
    'prgmsr2' => { column: :prgmsr2, converter: Converters::NumberConverter },
    'xmthcmp2' => { column: :xmthcmp2, converter: Converters::BaseConverter },
    'mthcmp2' => { column: :mthcmp2, converter: Converters::NumberConverter },
    'cipcode3' => { column: :cipcode3, converter: Converters::NumberConverter },
    'xciptui3' => { column: :xciptui3, converter: Converters::BaseConverter },
    'ciptuit3' => { column: :ciptuit3, converter: Converters::NumberConverter },
    'xcipsup3' => { column: :xcipsup3, converter: Converters::BaseConverter },
    'cipsupp3' => { column: :cipsupp3, converter: Converters::NumberConverter },
    'xciplgt3' => { column: :xciplgt3, converter: Converters::BaseConverter },
    'ciplgth3' => { column: :ciplgth3, converter: Converters::NumberConverter },
    'prgmsr3' => { column: :prgmsr3, converter: Converters::NumberConverter },
    'xmthcmp3' => { column: :xmthcmp3, converter: Converters::BaseConverter },
    'mthcmp3' => { column: :mthcmp3, converter: Converters::NumberConverter },
    'cipcode4' => { column: :cipcode4, converter: Converters::NumberConverter },
    'xciptui4' => { column: :xciptui4, converter: Converters::BaseConverter },
    'ciptuit4' => { column: :ciptuit4, converter: Converters::NumberConverter },
    'xcipsup4' => { column: :xcipsup4, converter: Converters::BaseConverter },
    'cipsupp4' => { column: :cipsupp4, converter: Converters::NumberConverter },
    'xciplgt4' => { column: :xciplgt4, converter: Converters::BaseConverter },
    'ciplgth4' => { column: :ciplgth4, converter: Converters::NumberConverter },
    'prgmsr4' => { column: :prgmsr4, converter: Converters::NumberConverter },
    'xmthcmp4' => { column: :xmthcmp4, converter: Converters::BaseConverter },
    'mthcmp4' => { column: :mthcmp4, converter: Converters::NumberConverter },
    'cipcode5' => { column: :cipcode5, converter: Converters::NumberConverter },
    'xciptui5' => { column: :xciptui5, converter: Converters::BaseConverter },
    'ciptuit5' => { column: :ciptuit5, converter: Converters::NumberConverter },
    'xcipsup5' => { column: :xcipsup5, converter: Converters::BaseConverter },
    'cipsupp5' => { column: :cipsupp5, converter: Converters::NumberConverter },
    'xciplgt5' => { column: :xciplgt5, converter: Converters::BaseConverter },
    'ciplgth5' => { column: :ciplgth5, converter: Converters::NumberConverter },
    'prgmsr5' => { column: :prgmsr5, converter: Converters::NumberConverter },
    'xmthcmp5' => { column: :xmthcmp5, converter: Converters::BaseConverter },
    'mthcmp5' => { column: :mthcmp5, converter: Converters::NumberConverter },
    'cipcode6' => { column: :cipcode6, converter: Converters::NumberConverter },
    'xciptui6' => { column: :xciptui6, converter: Converters::BaseConverter },
    'ciptuit6' => { column: :ciptuit6, converter: Converters::NumberConverter },
    'xcipsup6' => { column: :xcipsup6, converter: Converters::BaseConverter },
    'cipsupp6' => { column: :cipsupp6, converter: Converters::NumberConverter },
    'xciplgt6' => { column: :xciplgt6, converter: Converters::BaseConverter },
    'ciplgth6' => { column: :ciplgth6, converter: Converters::NumberConverter },
    'prgmsr6' => { column: :prgmsr6, converter: Converters::NumberConverter },
    'xmthcmp6' => { column: :xmthcmp6, converter: Converters::BaseConverter },
    'mthcmp6' => { column: :mthcmp6, converter: Converters::NumberConverter }
  }.freeze

  validates :cross, presence: true
  validates :chg1py3, numericality: true, allow_blank: true
  validates :books, numericality: true, allow_blank: true

  after_initialize :derive_dependent_columns

  def derive_dependent_columns
    self.tuition_in_state = chg1py3
    self.tuition_out_of_state = chg1py3
  end
end
