module SurveyResultsHelper
  def survey_result_read_more_link answer, read_more=nil, result_num=nil
    link_to "Read more", survey_result_read_more_path(id: answer.id, result_num: result_num),
      remote: true, class: "sort_by_link" if answer.body.to_s.size > 50 and not read_more
  end
end
