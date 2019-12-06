module SurveysHelper
  def snip_survey_txt txt, read_more=nil, small=nil
    unless read_more
      Survey.snip_txt txt, small
    else
      txt
    end
  end
end
