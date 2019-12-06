class SurveyResult < ApplicationRecord
  belongs_to :survey
  has_many :survey_answers
end
