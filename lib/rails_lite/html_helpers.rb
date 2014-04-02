module HtmlHelpers
  def link_to(body, destination)
    "<a href='#{destination.html_escape}'>#{body.html_escape}</a>".html_safe
  end

  def button_to(body, destination, method)
    <<-html
      <form action='#{destination.html_escape}' class='button_to' method='post>
        <input type='hidden' name='_method' value='#{method.html_escape}' />

        <input type='hidden' name='authenticity_token' value='#{form_authenticity_token}' />
        <input type='submit' value='#{body.html_escape}' />
      </form>
    html
  end
end