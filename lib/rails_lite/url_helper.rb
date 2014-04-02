module UrlHelper

  def build_route_helpers(controller)
    route_helpers = make_route_helpers

    [:member, :collection, :new, :edit].each do |type|
      routes = [["#{request.url}#{route_helpers[type][:path]}", "url"], ["#{route_helpers[type][:path]}", "path"] ]

      routes.each do |addr. suffix|
        define_method("#{route_helpers[type][:prefix]}_#{suffix}") do |input = nil|
          if input.nil?
            return "#{addr}"
          else
            input = (input.is_a? Object ? input.id : input)
            return "#{addr}/#{input}"
          end
        end
      end

    end

  def make_route_helpers(controller)
    resource_name = controller.to_s.downcase.gsub("scontroller", "")

    route_helpers = {
      member: {
        prefix: "#{resource_name}",
        path: "/#{resource_name}"
      }
      collection: {
        prefix: "#{resource_name}s",
        path: "/#{resource_name}s"
      }
      new: {
        prefix: "new_#{resource_name}",
        path: "/#{resource_name}s/new"
      }
      edit: {
        prefix: "edit_#{resource_name}",
        path: "/#{resource_name}s/edit"
      }
    }
  end
end