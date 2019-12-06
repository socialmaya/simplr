module TemplatesHelper
  def item_with_link tag
    editable = ""

    item = TemplateItem.find_by_tag tag

    # creates new placeholder item if ones not been set
    unless item
      item = TemplateItem.new body: "This template item has not been set.", tag: tag
      item.save
    end

    editable << item.body + " "
    editable << link_to("Edit", on_point_edit_path(item.unique_token)) if current_user

    editable.html_safe
  end
end
