require 'test_helper'

class TinyMceTest < ActionView::TestCase
  include ActiveScaffold::Helpers::ViewHelpers
  include ActiveScaffold::Bridges::TinyMce::Helpers

  # Mimic the behaviour of the tinymce-rails plugin function[1] to get
  # configuration options from tinymce.yml
  #
  # [1]: https://github.com/spohlenz/tinymce-rails/blob/master/lib/tinymce/rails/helper.rb#L37
  def tinymce_configuration(config = :default)
    case config
    when :default
      Class.new do
        def options
          {theme: 'modern'}
        end
      end.new
    when :alternate
      Class.new do
        def options
          {theme: 'alternate', toolbar: 'undo redo | format'}
        end
      end.new
    end
  end

  def test_includes
    ActiveScaffold::Bridges::TinyMce.expects(:install?).returns(true)
    with_js_framework :jquery do
      assert ActiveScaffold::Bridges.all_javascripts.include?('tinymce-jquery')
    end
  end

  def test_form_ui
    config = ActiveScaffold::Config::Core.new(:company)
    record = Company.new

    assert_dom_equal %(<textarea name=\"record[name]\" class=\"name-input mceEditor\" id=\"record_name\">\n</textarea>), active_scaffold_input_text_editor(config.columns[:name], :name => 'record[name]', :id => 'record_name', :class => 'name-input', :object => record)
  end

  def test_form_ui_alternate
    config = ActiveScaffold::Config::Core.new(:company)
    record = Company.new
    config.columns[:name].options[:tinymce_config] = :alternate

    assert_dom_equal %(<textarea name=\"record[name]\" class=\"name-input mceEditor\" id=\"record_name\">\n</textarea>), active_scaffold_input_tinymce(config.columns[:name], :name => 'record[name]', :id => 'record_name', :class => 'name-input', :object => record)
  end

  protected

  def include_tiny_mce_if_needed; end

  def tiny_mce_js; end

  def using_tiny_mce?
    true
  end
end
