# wrap the action rendering for ActiveScaffold controllers
module ActiveScaffold
  module ActionController #:nodoc:

    def self.prepended(base)
      # Protect from trying to augment modules that appear
      # as the result of adding other gems.
      return if base != ::ActionController::Base

      base.class_eval do
        alias_method :render_without_active_scaffold, :render

        def render(*args, &block)
          render_with_active_scaffold(*args, &block)
        end
      end
    end

    def render_with_active_scaffold(*args, &block)
      if self.class.uses_active_scaffold? && params[:adapter] && @rendering_adapter.nil? && request.xhr?
        @rendering_adapter = true # recursion control
        # if we need an adapter, then we render the actual stuff to a string and insert it into the adapter template
        opts = args.blank? ? {} : args.first
        render_without_active_scaffold  :partial => params[:adapter][1..-1],
               :locals => {:payload => render_to_string(opts.merge(:layout => false), &block).html_safe},
               :use_full_path => true, :layout => false, :content_type => :html
        @rendering_adapter = nil # recursion control
      else
        render_without_active_scaffold(*args, &block)
      end
    end
  end
end

module ActionController
  class Base
    prepend ActiveScaffold::ActionController
  end
end
