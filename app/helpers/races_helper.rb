module RacesHelper

  #
  # Support methods for nested forms lifted from http://transfs.com/devblog/2009/06/26/nested-forms-with-rails-2-3-helpers-and-javascript-tricks/
  #
  
  def link_to_new_nested_form(name, form_builder, method, options = {})
    klass = form_builder.object.class.reflect_on_association(method).klass
    Rails.logger.warn "!!  link_to_new_nested_form: klass is #{klass.inspect}"
    options[:object] ||= klass.new
    options[:partial] ||= method.to_s.singularize
    options[:form_builder_local] ||= :f
    options[:element_id] ||= method.to_s
    options[:position] ||= :bottom
    link_to_function name do |page|
      html = generate_nested_form(form_builder,
                    method,
                    :object => options[:object],
                    :partial => options[:partial],
                    :form_builder_local => options[:form_builder_local]
                   )
      page << %{
        $('#{options[:element_id]}').insert({ #{options[:position]}: "#{ escape_javascript html }".replace(/NEW_RECORD/g, new Date().getTime()) });
      }
    end
  end

  def generate_nested_form(form_builder, method, options = {})
    options[:object] ||= form_builder.object.class.reflect_on_association(method).klass.new
    options[:partial] ||= method.to_s.singularize
    options[:form_builder_local] ||= :f
 
    form_builder.fields_for(method, options[:object], :child_index => 'NEW_RECORD') do |f|
      render(:partial => options[:partial], :locals => { options[:form_builder_local] => f })
    end
  end

  def truncate_words(text='', length=64, omission="...")
    return '' if text.blank?
    words = text.split
    omission = '' unless words.size > length
    words[0..(length-1)].join(" ") + omission
  end 

end
