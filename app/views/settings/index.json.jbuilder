json.array!(@settings) do |setting|
  json.extract! setting, :id, :user_id, :group_id, :name, :on, :state
  json.url setting_url(setting, format: :json)
end
