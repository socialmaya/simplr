class SurveyAnswer < ApplicationRecord
  belongs_to :survey_question

  def get_body_with_other
    return body if question.grid
    case question.question_type
    when 'checkbox'
      selected = eval body
      if other and selected.last.downcase.include? "other:"
        selected[-1] = "other"
      else
        return body
      end
      return selected.to_s
    when 'radio_button'
      if other and body.downcase.include? "other:"
        return "other"
      else
        return body
      end
    else
      return body
    end
  end

  def question
    survey_question
  end

  def grid_result_txt
    txt = ""
    for row in eval(body)
      txt << "#{row.first}: "
      for col in row.second
        txt << col
        txt << ", " unless col.eql? row.second.last
      end
      txt << "; " unless row.eql? eval(body).last
    end
    txt
  end
end
