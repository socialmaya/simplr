module SurveyQuestionsHelper
  def survey_question_read_more_link question, read_more=nil
    link_to "Read more", survey_question_read_more_path(question.id), remote: true, class: "survey_interactive_link" \
      if question.body.to_s.size > 50 and not read_more
  end

  def show_ten_or_all_questions survey
    if @surveys
      survey.questions.first 10
    else
      survey.questions
    end
  end

  def active_question_type_link this_links_type
    case @type
    when 'checkbox'
      if this_links_type.eql? :checkbox
        ' '
      else
        'surveys_link '
      end
    when 'radio_button'
      if this_links_type.eql? :radio_button
        ' '
      else
        'surveys_link '
      end
    when 'open_ended_paragraph'
      if this_links_type.eql? :open_ended_paragraph
        ' '
      else
        'surveys_link '
      end
    else
      if this_links_type.eql? :open_ended
        ' '
      else
        'surveys_link '
      end
    end
  end
end
