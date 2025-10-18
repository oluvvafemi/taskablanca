module ApplicationHelper
  def nav_link_class(controller_names)
    controller_names = Array(controller_names)
    base_class = "nav-link text-white"
    controller_names.include?(controller_name) ? "#{base_class} active bg-dark" : base_class
  end
end
